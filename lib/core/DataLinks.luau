-- SPDX-License-Identifier: MPL-2.0
-- Owner-scoped explicit data links. No global listeners or hidden polling.
do
    -- Per-hub bounded synchronous cascades avoid cyclic/branching runaway.
    local MAX_CASCADE_HOPS, MAX_CASCADE_DEPTH = 64, 24
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
        assert(options.Filter == nil or type(options.Filter) == "function", "Filter must be a function")
        if not options.Apply then
            assert(type(target[action]) == "function", "target does not support " .. action)
        end
        local links = self._dataLinks
        if not links then links = {}; self._dataLinks = links end
        local link = { Source = source, Target = target, Event = event,
            Action = action, Options = table.clone(options),
            Connected = true, Busy = false, Paused = options.Paused == true,
            Delivered = 0, Skipped = 0, Errors = 0, LastError = nil,
            Cycles = 0, Overflow = 0 }
        local subscription
        local function relay(payload)
            if not link.Connected or self._destroyed or source._disposed or target._disposed then
                return false, "link disconnected"
            end
            if link.Paused or link.Busy then
                link.Skipped += 1
                if link.Busy then link.Cycles += 1 end
                return false, link.Paused and "link paused" or "reentrant event"
            end
            local cascade = self._dataLinkCascade
            local root = cascade == nil
            if root then
                cascade = { Seen = {}, Hops = 0, Depth = 0 }
                self._dataLinkCascade = cascade
            end
            if cascade.Seen[link] then
                link.Skipped += 1
                link.Cycles += 1
                if root then self._dataLinkCascade = nil end
                return false, "cascade already visited link"
            end
            if cascade.Hops >= MAX_CASCADE_HOPS or cascade.Depth >= MAX_CASCADE_DEPTH then
                link.Skipped += 1
                link.Overflow += 1
                if root then self._dataLinkCascade = nil end
                return false, "cascade propagation limit reached"
            end
            cascade.Seen[link] = true
            cascade.Hops += 1
            cascade.Depth += 1
            link.Busy = true
            local applied, skipped = false, false
            local ok, err = xpcall(function()
                if options.Filter and not options.Filter(payload, source, target) then
                    skipped = true
                    return
                end
                local mapped = payload
                if options.Map then mapped = options.Map(payload, source, target) end
                if mapped == nil then skipped = true; return end
                local result, reason
                if options.Apply then
                    result, reason = options.Apply(target, mapped, source)
                elseif action == "Select" then
                    result, reason = target:Select(type(mapped) == "table" and mapped.Id or mapped, true)
                elseif action == "SetExpanded" then
                    assert(type(mapped) == "table" and mapped.Id ~= nil,
                        "SetExpanded link requires { Id, Expanded }")
                    result, reason = target:SetExpanded(mapped.Id, mapped.Expanded)
                elseif action == "Update" then
                    assert(type(mapped) == "table" and (mapped.Id ~= nil or mapped.Key ~= nil),
                        "Update link requires { Id/Key, Value/Changes }")
                    local key = mapped.Id or mapped.Key
                    if target.Type == "InfoGrid" or target.Type == "InfoList" then
                        local value = mapped.Value
                        if value == nil then value = mapped.Changes end
                        result, reason = target:Update(key, value, mapped.Tone, options.Silent == true)
                    else
                        result, reason = target:Update(key, mapped.Changes or mapped, options.Silent == true)
                    end
                elseif action == "UpdateMany" then
                    result, reason = target:UpdateMany(mapped, options.Strict == true)
                elseif action == "SetStatus" then
                    if type(mapped) == "table" then
                        local value = mapped.Status
                        if value == nil then value = mapped.Value end
                        result, reason = target:SetStatus(value, mapped.Tone)
                    else result, reason = target:SetStatus(mapped) end
                elseif action == "SetLocked" then
                    if type(mapped) == "table" then
                        result, reason = target:SetLocked(mapped.Locked == true, mapped.Reason)
                    else result, reason = target:SetLocked(mapped == true) end
                else
                    result, reason = target[action](target, mapped)
                end
                -- Void setters signal successful application through their lack
                -- of an explicit false result; false-returning setters are failures.
                if result == false then error(tostring(reason or "target rejected linked value")) end
                applied = true
            end, debug.traceback)
            link.Busy = false
            cascade.Depth -= 1
            if root then self._dataLinkCascade = nil end
            if not ok then
                link.Errors += 1
                link.LastError = tostring(err)
                warn("[RiftUI] data link: " .. tostring(err))
                return false, link.LastError
            end
            if skipped then
                link.Skipped += 1
                return false, "event filtered"
            end
            if applied then
                link.Delivered += 1
                link.LastError = nil
            end
            return applied
        end
        local getters = {
            Selection = "GetSelection", Value = "Get", Status = "GetStatus",
            Summary = "GetSummary", Favorite = "IsFavorite",
            Expanded = "GetExpandedPreference", Locked = "IsLocked", Data = "Get",
        }
        local function currentPayload()
            local getter = getters[event]
            if not getter or type(source[getter]) ~= "function" then
                return false, "event has no snapshot getter: " .. event
            end
            local ok, payload = pcall(source[getter], source)
            if not ok then return false, tostring(payload) end
            return true, payload
        end
        function link:Pause()
            if not self.Connected then return false, "link disconnected" end
            self.Paused = true
            self.Options.Paused = true
            return true
        end
        function link:Resume(sync)
            if not self.Connected then return false, "link disconnected" end
            self.Paused = false
            self.Options.Paused = false
            if sync == true then return self:Refresh() end
            return true
        end
        function link:Refresh()
            if not self.Connected then return false, "link disconnected" end
            local ok, payload = currentPayload()
            if not ok then return false, payload end
            -- nil is a valid selection clearing value; other events with nil
            -- payload are intentionally skipped by the mapping contract.
            if payload == nil and event ~= "Selection" then
                return false, "snapshot unavailable"
            end
            return relay(payload)
        end
        function link:GetStats()
            return { Connected = self.Connected, Paused = self.Paused,
                Delivered = self.Delivered, Skipped = self.Skipped,
                Errors = self.Errors, LastError = self.LastError,
                Cycles = self.Cycles, Overflow = self.Overflow,
                Event = self.Event, Action = self.Action }
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
        if options.Immediate == true and not link.Paused then
            link:Refresh()
        end
        return link
    end

    function Hub:_dataDetachControl(control)
        for link in self._dataLinks or {} do
            if link.Source == control or link.Target == control then link:Disconnect() end
        end
        control._disposed = true
        if control._dataSubscriptions then
            for handle in table.clone(control._dataSubscriptions) do handle:Disconnect() end
            table.clear(control._dataSubscriptions)
        end
        if control._dataObservers then table.clear(control._dataObservers) end
    end

    function Hub:_clearDataLinks()
        for link in self._dataLinks or {} do link:Disconnect() end
        self._dataLinks = nil
        for handle in self._directDataSubscriptions or {} do handle:Disconnect() end
        self._directDataSubscriptions = nil
        self._dataLinkCascade = nil
    end
end
