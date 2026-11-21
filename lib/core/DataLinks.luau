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
            SetExpanded = true, SetLayoutMode = true, Update = true, Append = true }
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
            Action = action, Connected = true, Busy = false }
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
                    assert(type(mapped) == "table" and mapped.Id ~= nil,
                        "Update link requires { Id, Changes }")
                    target:Update(mapped.Id, mapped.Changes or mapped)
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
            if not self.Connected then return end
            self.Connected = false
            if subscription then subscription:Disconnect(); subscription = nil end
            links[self] = nil
        end
        links[link] = true
        if options.Immediate == true and type(source.GetSelection) == "function" then
            relay(source:GetSelection())
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
