-- SPDX-License-Identifier: MPL-2.0
-- Per-Hub developer SDK: extension lifecycle, scoped ownership and diagnostics.
-- No global polling, network calls or second control/event runtime.
do
    local MAX_DIAGNOSTICS = 80
    local VALID_SEVERITIES = { Info = true, Warning = true, Error = true }

    function Hub:_developerKitState()
        if not self._developerKit then
            self._developerKit = {
                Extensions = {}, Order = {}, Scopes = {}, Listeners = {},
                Diagnostics = {}, EventCount = 0, FaultCount = 0,
                Sequence = 0, Disposing = false,
            }
        end
        return self._developerKit
    end

    function Hub:ReportDeveloperDiagnostic(severity, code, message, context)
        if not VALID_SEVERITIES[severity] then
            return nil, "severity must be Info, Warning or Error"
        end
        local state = self:_developerKitState()
        state.Sequence += 1
        local item = {
            Id = state.Sequence, Time = os.clock(), Severity = severity,
            Code = tostring(code or "unknown"):sub(1, 96),
            Message = tostring(message or ""):sub(1, 900),
            Context = context == nil and nil or tostring(context):sub(1, 240),
        }
        table.insert(state.Diagnostics, item)
        if #state.Diagnostics > MAX_DIAGNOSTICS then table.remove(state.Diagnostics, 1) end
        if severity == "Error" then state.FaultCount += 1 end
        return table.clone(item)
    end

    function Hub:GetDeveloperDiagnostics(severity)
        if severity ~= nil and not VALID_SEVERITIES[severity] then return {} end
        local state = self._developerKit
        local result = {}
        for _, item in state and state.Diagnostics or {} do
            if severity == nil or item.Severity == severity then
                result[#result + 1] = table.clone(item)
            end
        end
        return result
    end

    function Hub:ClearDeveloperDiagnostics()
        if self._developerKit then table.clear(self._developerKit.Diagnostics) end
    end

    function Hub:CreateDeveloperScope(name)
        if self._destroyed then return nil, "hub destroyed" end
        local hub, state = self, self:_developerKitState()
        if state.Disposing then return nil, "hub shutting down" end
        local scope = { Name = tostring(name or "scope"), Closed = false, _resources = {} }
        function scope:Own(resource)
            if resource == nil then return nil end
            if self.Closed then
                pcall(hub._disposeResource, hub, resource)
            else
                table.insert(self._resources, resource)
            end
            return resource
        end
        function scope:Defer(callback)
            assert(type(callback) == "function", "scope:Defer expects a function")
            return self:Own(callback)
        end
        function scope:Connect(signal, callback)
            assert(type(callback) == "function", "scope:Connect expects a callback")
            if self.Closed then return nil, "scope closed" end
            local ok, connection = pcall(function() return signal:Connect(callback) end)
            if not ok then return nil, tostring(connection) end
            return self:Own(connection)
        end
        function scope:Close()
            if self.Closed then return false end
            self.Closed = true
            state.Scopes[self] = nil
            for i = #self._resources, 1, -1 do
                local resource = self._resources[i]
                self._resources[i] = nil
                local ok, err = pcall(hub._disposeResource, hub, resource)
                if not ok then
                    hub:ReportDeveloperDiagnostic("Error", "scope.cleanup",
                        tostring(err), self.Name)
                end
            end
            return true
        end
        state.Scopes[scope] = true
        return scope
    end

    function Hub:OnDeveloperEvent(event, callback, scope)
        if type(event) ~= "string" or event == "" or type(callback) ~= "function" then
            return nil, "event name and callback required"
        end
        if self._destroyed then return nil, "hub destroyed" end
        local state = self:_developerKitState()
        if state.Disposing then return nil, "hub shutting down" end
        local listeners = state.Listeners[event] or {}
        state.Listeners[event] = listeners
        local subscription = { Connected = true }
        function subscription:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            local index = table.find(listeners, self)
            if index then table.remove(listeners, index) end
            if #listeners == 0 and state.Listeners[event] == listeners then
                state.Listeners[event] = nil
            end
        end
        subscription.Callback = callback
        table.insert(listeners, subscription)
        if scope then
            if scope.Closed or type(scope.Own) ~= "function" then
                subscription:Disconnect()
                return nil, "invalid or closed scope"
            end
            scope:Own(subscription)
        end
        return subscription
    end

    function Hub:EmitDeveloperEvent(event, payload)
        if self._destroyed then return false, "hub destroyed" end
        if type(event) ~= "string" or event == "" then
            return false, "event name required"
        end
        local state = self:_developerKitState()
        if state.Disposing then return false, "hub shutting down" end
        state.EventCount += 1
        local listeners = state.Listeners[event] or {}
        local snapshot = table.clone(listeners)
        local delivered = 0
        for _, listener in snapshot do
            if listener.Connected then
                local ok, err = xpcall(listener.Callback, debug.traceback, payload, event, self)
                if ok then
                    delivered += 1
                else
                    self:ReportDeveloperDiagnostic("Error", "event.callback",
                        tostring(err), event)
                end
            end
        end
        return true, delivered
    end

    function Hub:GetExtension(name)
        local state = self._developerKit
        local item = state and state.Extensions[name]
        if not item then return nil end
        return {
            Name = item.Name, Version = item.Version,
            State = item.Active and "Active" or "Starting",
        }
    end

    function Hub:ListExtensions()
        local state = self._developerKit
        local names = {}
        for _, name in state and state.Order or {} do
            if state.Extensions[name] then names[#names + 1] = name end
        end
        return names
    end

    function Hub:RegisterExtension(name, descriptor)
        if self._destroyed then return false, "hub destroyed" end
        if type(name) ~= "string" or #name < 1 or #name > 72
            or not name:match("^[%w_.%-]+$") then
            return false, "extension name must use letters, digits, _, - or ."
        end
        if type(descriptor) ~= "table" or type(descriptor.Start) ~= "function"
            or (descriptor.Stop ~= nil and type(descriptor.Stop) ~= "function") then
            return false, "extension requires Start(hub, scope) and optional Stop"
        end
        local state = self:_developerKitState()
        if state.Disposing then return false, "hub shutting down" end
        if state.Extensions[name] then return false, "extension already registered" end
        local scope, reason = self:CreateDeveloperScope("extension:" .. name)
        if not scope then return false, reason end
        local entry = {
            Name = name, Version = tostring(descriptor.Version or "0.0.0"),
            Descriptor = descriptor, Scope = scope, Active = false,
        }
        state.Extensions[name] = entry
        -- Extension-owned controls are rebuilt by Start on Reinitialize;
        -- do not duplicate them in the normal control replay recipe.
        local wasReplaying = self._replaying
        self._replaying = true
        local ok, result = xpcall(descriptor.Start, debug.traceback, self, scope)
        self._replaying = wasReplaying
        if not ok then
            state.Extensions[name] = nil
            scope:Close()
            self:ReportDeveloperDiagnostic("Error", "extension.start",
                tostring(result), name)
            return false, tostring(result)
        end
        if result ~= nil then scope:Own(result) end
        entry.Active = true
        table.insert(state.Order, name)
        self:EmitDeveloperEvent("extension.registered", { Name = name })
        return true, self:GetExtension(name)
    end

    function Hub:UnregisterExtension(name)
        local state = self._developerKit
        local entry = state and state.Extensions[name]
        if not entry then return false, "extension not registered" end
        state.Extensions[name] = nil
        local index = table.find(state.Order, name)
        if index then table.remove(state.Order, index) end
        entry.Active = false
        local stop = entry.Descriptor.Stop
        if stop then
            local ok, err = xpcall(stop, debug.traceback, self, entry.Scope)
            if not ok then
                self:ReportDeveloperDiagnostic("Error", "extension.stop", tostring(err), name)
            end
        end
        entry.Scope:Close()
        if not state.Disposing and not self._destroyed then
            self:EmitDeveloperEvent("extension.unregistered", { Name = name })
        end
        return true
    end

    function Hub:GetDeveloperStats()
        local state = self._developerKit
        local active, scopes, listeners = 0, 0, 0
        if state then
            for _ in state.Extensions do active += 1 end
            for _ in state.Scopes do scopes += 1 end
            for _, bucket in state.Listeners do listeners += #bucket end
        end
        return {
            Extensions = active, Scopes = scopes, Listeners = listeners,
            Diagnostics = state and #state.Diagnostics or 0,
            Events = state and state.EventCount or 0,
            Faults = state and state.FaultCount or 0,
        }
    end

    function Hub:_developerReinitializeDescriptors()
        local state = self._developerKit
        local specs = {}
        if state then
            for _, name in state.Order do
                local entry = state.Extensions[name]
                if entry and entry.Active then
                    specs[#specs + 1] = { Name = name, Descriptor = entry.Descriptor }
                end
            end
        end
        return specs
    end

    function Hub:_disposeDeveloperKit()
        local state = self._developerKit
        if not state or state.Disposing then return end
        state.Disposing = true
        for i = #state.Order, 1, -1 do
            self:UnregisterExtension(state.Order[i])
        end
        local remaining = {}
        for scope in state.Scopes do remaining[#remaining + 1] = scope end
        for _, scope in remaining do scope:Close() end
        for _, bucket in state.Listeners do
            for _, subscription in bucket do subscription.Connected = false end
        end
        table.clear(state.Listeners)
        self._developerKit = nil
    end
end