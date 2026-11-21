-- SPDX-License-Identifier: MPL-2.0
-- Owner-scoped explicit data links. No global listeners or hidden polling.
do
    function Hub:LinkData(source, target, options)
        options = type(options) == "table" and options or {}
        assert(type(source) == "table" and type(source.OnDataEvent) == "function",
            "LinkData requires a source control with OnDataEvent")
        assert(type(target) == "table", "LinkData requires a target control")
        assert(source.Section and source.Section.Hub == self
            and target.Section and target.Section.Hub == self,
            "LinkData controls must belong to the same hub")
        assert(not source._disposed and not target._disposed, "cannot link destroyed controls")
        local event = options.Event or "Selection"
        local action = options.Action or "Select"
        local supported = { Select = true, SetQuery = true, SetFilter = true,
            SetExpanded = true, SetLayoutMode = true, Update = true, UpdateMany = true,
            Append = true, Set = true, SetStatus = true, SetSummary = true,
            SetFavorite = true, SetLocked = true, SetOrder = true }
        assert(supported[action] or type(options.Apply) == "function",
            "unsupported data link action")
        assert(type(event) == "string" and event ~= "", "LinkData event must be a string")
        assert(options.Map == nil or type(options.Map) == "function", "Map must be a function")
        if not options.Apply then
            assert(type(target[action]) == "function", "target does not support " .. action)
        end
        local links = self._dataLinks
        if not links then links = {}; self._dataLinks = links end
        local link = { Source = source, Target = target, Event = event,
            Action = action, Options = table.clone(options),
            Connected = true, Busy = false }
        local subscription
        local function relay(payload)
            if not link.Connected or link.Busy or self._destroyed
                or source._disposed or target._disposed then return end
            link.Busy = true
            local ok, err = xpcall(function()
                local mapped = payload
                if options.Map then mapped = options.Map(payload, source, target) end
                if mapped == nil then return end
                if options.Apply then
                    options.Apply(target, mapped, source)
                elseif action == "Select" then
                    target:Select(type(mapped) == "table" and mapped.Id or mapped, true)
                elseif action == "SetExpanded" then
                    assert(type(mapped) == "table" and mapped.Id ~= nil,
                        "SetExpanded link requires { Id, Expanded }")
                    target:SetExpanded(mapped.Id, mapped.Expanded)
                elseif action == "Update" then
                    assert(type(mapped) == "table" and (mapped.Id ~= nil or mapped.Key ~= nil),
                        "Update link requires { Id/Key, Value/Changes }")
                    local key = mapped.Id or mapped.Key
                    if target.Type == "InfoGrid" or target.Type == "InfoList" then
                        local value = mapped.Value
                        if value == nil then value = mapped.Changes end
                        target:Update(key, value, mapped.Tone)
                    else
                        target:Update(key, mapped.Changes or mapped)
                    end
                elseif action == "SetStatus" then
                    if type(mapped) == "table" then
                        target:SetStatus(mapped.Status or mapped.Value, mapped.Tone)
                    else target:SetStatus(mapped) end
                elseif action == "SetLocked" then
                    if type(mapped) == "table" then
                        target:SetLocked(mapped.Locked == true, mapped.Reason)
                    else target:SetLocked(mapped == true) end
                else
                    target[action](target, mapped)
                end
            end, debug.traceback)
            link.Busy = false
            if not ok then
                warn("[RiftUI] data link: " .. tostring(err))
            end
        end
        subscription = source:OnDataEvent(event, relay)
        function link:Disconnect()
            -- Close over the live subscription, not the caller. An old link
            -- reference forwarded after Reinitialize must still disconnect it.
            if not link.Connected then return end
            link.Connected = false
            if subscription then subscription:Disconnect(); subscription = nil end
            links[link] = nil
        end
        links[link] = true
        if options.Immediate == true then
            local getters = {
                Selection = "GetSelection", Value = "Get", Status = "GetStatus",
                Summary = "GetSummary", Favorite = "IsFavorite",
                Expanded = "GetExpandedPreference", Locked = "IsLocked", Data = "Get",
            }
            local getter = getters[event]
            if getter and type(source[getter]) == "function" then relay(source[getter](source)) end
        end
        return link
    end

    function Hub:_dataDetachControl(control)
        for link in self._dataLinks or {} do
            if link.Source == control or link.Target == control then link:Disconnect() end
        end
        control._disposed = true
        if control._dataObservers then table.clear(control._dataObservers) end
    end

    function Hub:_clearDataLinks()
        for link in self._dataLinks or {} do link:Disconnect() end
        self._dataLinks = nil
    end
end
