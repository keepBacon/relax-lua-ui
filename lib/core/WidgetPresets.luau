-- SPDX-License-Identifier: MPL-2.0
-- Reusable, live composite widget recipes; uses existing Section controls.
do
    local ALLOWED = {
        Button = true, Toggle = true, Slider = true, Dropdown = true,
        Input = true, Segmented = true, InfoGrid = true, StatusList = true,
        MiniChart = true, InlineAction = true, EmptyState = true,
        Skeleton = true, Accordion = true, Form = true,
    }
    local function cloneValue(value)
        if type(value) ~= "table" then return value end
        local out = {}
        for k, v in value do out[k] = cloneValue(v) end
        return out
    end
    local BUILTINS = {
        Performance = {
            Title = "性能监控", Widgets = {
                { Id = "history", Type = "MiniChart", Options = {
                    Name = "FPS 趋势", Type = "Sparkline", Min = 0, Max = 144,
                    Suffix = " FPS", Data = { 62, 66, 70, 68, 75, 72, 80 } } },
                { Id = "target", Type = "Slider", Options = {
                    Name = "目标 FPS", Min = 30, Max = 144, Default = 60 } },
            },
        },
        Network = {
            Title = "网络状态", Widgets = {
                { Id = "latency", Type = "MiniChart", Options = {
                    Name = "延迟历史", Type = "Bars", Min = 0, Max = 250,
                    Suffix = " ms", Data = { 34, 28, 41, 29, 37 } } },
                { Id = "status", Type = "StatusList", Options = {
                    Name = "连接状态", Items = { { Id = "server",
                        Name = "服务器", Status = "Connected" } } } },
            },
        },
        QuickSettings = {
            Title = "快速设置", Widgets = {
                { Id = "enabled", Type = "Toggle", Options = {
                    Name = "启用功能", Default = true } },
                { Id = "strength", Type = "Slider", Options = {
                    Name = "强度", Min = 0, Max = 100, Default = 50 } },
                { Id = "mode", Type = "Dropdown", Options = {
                    Name = "模式", Options = { "平衡", "性能", "质量" }, Default = "平衡" } },
            },
        },
    }
    function Hub:_ensureWidgetPresets()
        if not self._widgetPresets then
            self._widgetPresets = cloneValue(BUILTINS)
        end
        return self._widgetPresets
    end
    function Hub:RegisterWidgetPreset(name, definition, replace)
        assert(type(name) == "string" and name ~= "", "WidgetPreset name required")
        assert(type(definition) == "table" and type(definition.Widgets) == "table",
            "WidgetPreset.Widgets must be an array")
        local seen = {}
        assert(#definition.Widgets > 0 and #definition.Widgets <= 20,
            "WidgetPreset supports 1–20 widgets")
        for index, item in definition.Widgets do
            assert(type(item) == "table" and ALLOWED[item.Type],
                "unsupported preset widget type at index " .. tostring(index))
            local id = tostring(item.Id or index)
            assert(not seen[id], "duplicate preset widget Id: " .. id)
            seen[id] = true
        end
        local presets = self:_ensureWidgetPresets()
        if presets[name] and not replace then return false, "preset already exists" end
        presets[name] = cloneValue(definition)
        return true
    end
    function Hub:ListWidgetPresets()
        local result = {}
        for name in self:_ensureWidgetPresets() do result[#result + 1] = name end
        table.sort(result)
        return result
    end
    function Hub:GetWidgetPreset(name)
        local data = self:_ensureWidgetPresets()[name]
        return data and cloneValue(data) or nil
    end
    function Hub:UnregisterWidgetPreset(name)
        if BUILTINS[name] then return false, "built-in preset cannot be unregistered" end
        local presets = self:_ensureWidgetPresets()
        if not presets[name] then return false end
        presets[name] = nil
        return true
    end

    function Section:UseWidgetPreset(name, options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local definition = hub:GetWidgetPreset(name)
        if not definition then return nil, "unknown widget preset: " .. tostring(name) end
        local created, map = {}, {}
        local namespace = tostring(options.FlagPrefix or name)
        local overrides = type(options.Overrides) == "table" and options.Overrides or {}
        local function dispose(control)
            if not control or control._disposed then return end
            if type(control.Destroy) == "function" then
                control:Destroy()
                return
            end
            control._disposed = true
            if control.Flag and RiftUI.Flags[control.Flag] == control then
                RiftUI.Flags[control.Flag] = nil
            end
            local index = table.find(control.Section.Controls, control)
            if index then table.remove(control.Section.Controls, index) end
            for i = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[i].Result == control then
                    table.remove(hub._recipe, i)
                end
            end
            for sub in control._dataSubscriptions or {} do sub:Disconnect() end
            if control.Frame then control.Frame:Destroy() end
        end
        for index, spec in definition.Widgets do
            local id = tostring(spec.Id or index)
            local args = cloneValue(spec.Options or {})
            for key, value in type(overrides[id]) == "table" and overrides[id] or {} do
                args[key] = cloneValue(value)
            end
            if options.FlagPrefix and not args.Flag
                and spec.Type ~= "Button" and spec.Type ~= "MiniChart"
                and spec.Type ~= "StatusList" and spec.Type ~= "InfoGrid" then
                args.Flag = namespace .. "/" .. id
            end
            local creator = self[spec.Type]
            if type(creator) ~= "function" then
                for i = #created, 1, -1 do dispose(created[i]) end
                return nil, "preset control unavailable: " .. spec.Type
            end
            local ok, control = pcall(creator, self, args)
            if not ok or type(control) ~= "table" then
                for i = #created, 1, -1 do dispose(created[i]) end
                return nil, "preset build failed (" .. id .. "): " .. tostring(control)
            end
            map[id] = control
            created[#created + 1] = control
        end
        local preset = { Name = name, Widgets = map, Destroyed = false }
        function preset:GetWidget(id)
            return not self.Destroyed and map[tostring(id)] or nil
        end
        function preset:Get()
            local data = {}
            if self.Destroyed then return data end
            for id, control in map do
                if type(control.Get) == "function" then
                    data[id] = cloneValue(control:Get())
                end
            end
            return data
        end
        function preset:SetWidget(id, value, silent)
            if self.Destroyed then return false end
            local control = map[tostring(id)]
            if not control or type(control.Set) ~= "function" then return false end
            local ok, result = pcall(control.Set, control, value, silent)
            return ok and result ~= false
        end
        function preset:SetValues(values, silent)
            if self.Destroyed or type(values) ~= "table" then return false end
            local success = true
            for id, value in values do
                if not self:SetWidget(id, value, silent) then success = false end
            end
            return success
        end
        function preset:Refresh()
            if self.Destroyed or type(definition.Provider) ~= "function" then return false end
            local ok, data = pcall(definition.Provider, self)
            if not ok or type(data) ~= "table" then return false end
            return self:SetValues(data, true)
        end
        function preset:Destroy()
            if self.Destroyed then return end
            self.Destroyed = true
            for i = #created, 1, -1 do dispose(created[i]) end
            table.clear(map)
            table.clear(created)
        end
        return preset
    end
end
