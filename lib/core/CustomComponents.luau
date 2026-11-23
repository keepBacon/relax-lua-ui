-- SPDX-License-Identifier: MPL-2.0
-- Hub-scoped, lifecycle-safe third-party Section controls.
-- Uses _control, Design Tokens, DeveloperScope and the existing config pipeline.
do
    local function copyValue(value)
        if type(value) == "table" then return table.clone(value) end
        return value
    end
    local function validName(value)
        return type(value) == "string" and #value > 0 and #value <= 72
            and value:match("^[%w_.%-]+$") ~= nil
            and Section[value] == nil and value ~= "Component"
    end
    local function registry(hub)
        if not hub._customComponents then
            hub._customComponents = { Definitions = {}, Order = {}, Instances = {} }
        end
        return hub._customComponents
    end
    local function removeFrom(list, target)
        if type(list) ~= "table" then return end
        local index = table.find(list, target)
        if index then table.remove(list, index) end
    end

    function Hub:RegisterComponent(name, descriptor, ownerScope)
        if self._destroyed then return false, "hub destroyed" end
        if not validName(name) then
            return false, "invalid component name or reserved Section method"
        end
        if type(descriptor) ~= "table" or type(descriptor.Render) ~= "function"
            or (descriptor.Validate ~= nil and type(descriptor.Validate) ~= "function") then
            return false, "component requires Render(context, options) and optional Validate"
        end
        if ownerScope and (type(ownerScope.Defer) ~= "function" or ownerScope.Closed) then
            return false, "owner scope must be open"
        end
        local state = registry(self)
        if state.Definitions[name] then return false, "component already registered" end
        local entry = {
            Name = name, Descriptor = descriptor, OwnerScope = ownerScope,
            Version = tostring(descriptor.Version or "0.0.0"),
        }
        state.Definitions[name] = entry
        state.Instances[name] = {}
        table.insert(state.Order, name)
        if ownerScope then
            local hub = self
            ownerScope:Defer(function()
                if not hub._destroyed then hub:UnregisterComponent(name) end
            end)
        end
        return true, { Name = name, Version = entry.Version }
    end

    function Hub:GetComponent(name)
        local state = self._customComponents
        local entry = state and state.Definitions[name]
        if not entry then return nil end
        local count = 0
        for _ in state.Instances[name] or {} do count += 1 end
        return { Name = entry.Name, Version = entry.Version, Instances = count }
    end

    function Hub:ListComponents()
        local names = {}
        local state = self._customComponents
        for _, name in state and state.Order or {} do
            if state.Definitions[name] then names[#names + 1] = name end
        end
        return names
    end

    function Hub:UnregisterComponent(name)
        local state = self._customComponents
        local entry = state and state.Definitions[name]
        if not entry then return false, "component not registered" end
        state.Definitions[name] = nil
        removeFrom(state.Order, name)
        local instances = state.Instances[name] or {}
        local snapshot = {}
        for instance in instances do snapshot[#snapshot + 1] = instance end
        for _, instance in snapshot do instance:Destroy() end
        state.Instances[name] = nil
        return true
    end

    function Hub:_componentReinitializeDescriptors()
        local result = {}
        local state = self._customComponents
        if state then
            for _, name in state.Order do
                local entry = state.Definitions[name]
                if entry and not entry.OwnerScope then
                    result[#result + 1] = {
                        Name = name, Descriptor = entry.Descriptor,
                    }
                end
            end
        end
        return result
    end

    function Hub:_disposeComponents()
        local state = self._customComponents
        if not state then return end
        for i = #state.Order, 1, -1 do
            self:UnregisterComponent(state.Order[i])
        end
        self._customComponents = nil
    end

    function Section:Component(nameOrSpec, providedOptions)
        local name, options
        if type(nameOrSpec) == "table" then
            name = nameOrSpec.Name
            options = nameOrSpec.Options or {}
        else
            name = nameOrSpec
            options = providedOptions or {}
        end
        if type(options) ~= "table" then return nil, "component options must be a table" end
        local hub = self.Hub
        if hub._destroyed then return nil, "hub destroyed" end
        local state = hub._customComponents
        local entry = state and state.Definitions[name]
        if not entry then return nil, "unregistered component: " .. tostring(name) end
        local spec = entry.Descriptor
        local height = tonumber(options.Height or spec.Height or 44) or 44
        if height ~= height then height = 44 end
        height = math.clamp(math.floor(height), 28, 320)
        local authored = table.clone(options)
        if authored.Name == nil then authored.Name = name end
        local scope, reason = hub:CreateDeveloperScope("component:" .. name)
        if not scope then return nil, reason end
        local row = self:_row(height, "Component_" .. name)
        if options.AutoHeight == true then
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.Size = UDim2.new(1, 0, 0, 0)
        end
        -- _control owns flags, availability, ModuleCard children, search and
        -- callback dispatch; its recipe is deferred until Render succeeds.
        local control = self:_control("Component", authored, row)
        control.ComponentName = name
        control.Persist = options.Persist ~= false and spec.Persist ~= false
        control.Value = copyValue(options.Default ~= nil and options.Default or spec.Default)
        control._componentScope = scope
        state.Instances[name][control] = true
        local view, disposed = nil, false
        function control:Get()
            return copyValue(self.Value)
        end
        function control:Set(value, silent)
            if self._disposed then return false, "component destroyed" end
            if spec.Validate then
                local accepted, result, message = pcall(spec.Validate, value, authored, self)
                if not accepted then
                    hub:ReportDeveloperDiagnostic("Error", "component.validate",
                        tostring(result), name)
                    return false, tostring(result)
                end
                if result == false then return false, message or "value rejected" end
            end
            if view and type(view.Set) == "function" then
                local accepted, result, message = pcall(view.Set, view, value, silent)
                if not accepted then
                    hub:ReportDeveloperDiagnostic("Error", "component.set",
                        tostring(result), name)
                    return false, tostring(result)
                end
                if result == false then return false, message or "render update rejected" end
            end
            self.Value = copyValue(value)
            self:_dataEvent("Value", self:Get())
            if not silent then self:_emit(self:Get()) end
            return true
        end
        function control:Destroy()
            if disposed then return end
            disposed = true
            if view and type(view.Destroy) == "function" then
                local ok, err = pcall(view.Destroy, view)
                if not ok then
                    hub:ReportDeveloperDiagnostic("Error", "component.destroy",
                        tostring(err), name)
                end
            end
            scope:Close()
            local current = hub._customComponents
            if current and current.Instances[name] then
                current.Instances[name][self] = nil
            end
            hub:_dataDetachControl(self)
            removeFrom(hub._requiredControls, self)
            removeFrom(self.Section.Controls, self)
            if self._moduleCard then
                removeFrom(self._moduleCard._moduleControls, self)
            end
            for i = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[i].Result == self then table.remove(hub._recipe, i) end
            end
            if self.Flag and RiftUI.Flags[self.Flag] == self then
                RiftUI.Flags[self.Flag] = nil
            end
            row:Destroy()
        end
        local context = {
            Hub = hub, Section = self, Control = control,
            Frame = row, Scope = scope,
        }
        function context:BindToken(instance, property, path, transform)
            local binding, err = hub:BindToken(instance, property, path, transform)
            if binding then scope:Own(binding) end
            return binding, err
        end
        function context:Connect(signal, callback)
            return scope:Connect(signal, callback)
        end
        function context:OnDestroy(callback)
            return scope:Defer(callback)
        end
        function context:Emit(value, silent)
            return control:Set(value, silent)
        end
        local ok, result = xpcall(spec.Render, debug.traceback, context, authored)
        if not ok or (result ~= nil and type(result) ~= "table") then
            local failure = ok and "Render must return table or nil" or tostring(result)
            hub:ReportDeveloperDiagnostic("Error", "component.render", failure, name)
            control:Destroy()
            return nil, failure
        end
        view = result
        if control.Value ~= nil then
            local setOK, setErr = control:Set(control.Value, true)
            if not setOK then
                control:Destroy()
                return nil, setErr
            end
        elseif view and type(view.Get) == "function" then
            local got, value = pcall(view.Get, view)
            if got then control.Value = copyValue(value) end
        end
        -- Destruction by a parent Group/ModuleCard must be equivalent to the
        -- explicit public Destroy method, including data link subscriptions.
        scope:Connect(row.Destroying, function() control:Destroy() end)
        hub:_record(self, "Component", {
            Name = name, Options = authored,
        }, control)
        return hub:_finishRequiredControl(control)
    end
end