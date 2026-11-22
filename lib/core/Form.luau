-- SPDX-License-Identifier: MPL-2.0
-- Validated mobile-first settings forms using the existing Section control model.
do
    local function formFields(raw)
        assert(type(raw) == "table", "Form.Fields must be an array")
        local seen, fields = {}, {}
        for index, value in raw do
            assert(type(value) == "table", "Form field must be a table")
            local item = table.clone(value)
            item.Id = tostring(item.Id or item.Key or index)
            assert(not seen[item.Id], "Form duplicate field Id: " .. item.Id)
            seen[item.Id] = true
            item.Name = tostring(item.Name or item.Label or item.Id)
            item.Type = item.Type or "Input"
            assert(item.Type == "Input" or item.Type == "Number" or
                item.Type == "Toggle" or item.Type == "Select",
                "Form field Type must be Input, Number, Toggle or Select")
            if item.Type == "Select" then
                item.Options = type(item.Options) == "table" and table.clone(item.Options) or {}
            end
            fields[#fields + 1] = item
        end
        return fields
    end
    local function formSnapshot(values)
        return table.clone(values)
    end
    local function formEquals(a, b, fields)
        for _, field in fields do
            if a[field.Id] ~= b[field.Id] then return false end
        end
        return true
    end
    function Section:Form(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local fields = formFields(options.Fields or {})
        local row = self:_row(0, "Form_" .. tostring(options.Name or ""))
        row.AutomaticSize = Enum.AutomaticSize.Y
        local c = self:_control("Form", options, row)
        local defaults, values, errors, widgets = {}, {}, {}, {}
        local busy, dirty, alive, serial = false, false, true, 0
        for _, field in fields do
            local default = field.Default
            if field.Type == "Toggle" then default = default == true
            elseif field.Type == "Number" then
                default = default == nil and "" or tostring(default)
            else default = default == nil and "" or tostring(default) end
            defaults[field.Id] = default
            values[field.Id] = default
        end
        c.Value = formSnapshot(values)
        local shell = create("Frame", {
            Name = "FormShell", Parent = row,
            BackgroundColor3 = hub:GetToken("Color.Surface1"),
            BackgroundTransparency = .44,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        }, { corner(hub:GetToken("Radius.S")),
            stroke(hub:GetToken("Color.BorderSubtle"), 1, .55),
            padding(10, 10, 10, 10),
            list(Enum.FillDirection.Vertical, 7) })
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        hub:BindToken(shell:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
        local fieldHost = create("Frame", {
            Name = "FormFields", Parent = shell,
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
        }, { list(Enum.FillDirection.Vertical, 9) })
        local footer = create("Frame", {
            Name = "FormFooter", Parent = shell, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 2,
        })
        local submit = create("TextButton", {
            Name = "FormSubmit", Parent = footer,
            Text = tostring(options.SubmitText or "提交"),
            FontFace = inter(Enum.FontWeight.Medium), TextSize = 13,
            TextColor3 = hub:GetToken("Color.AccentText"),
            BackgroundColor3 = hub:GetToken("Color.Accent"),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(92, 38),
            AutoButtonColor = false,
        }, { corner(8) })
        hub:BindToken(submit, "BackgroundColor3", "Color.Accent")
        hub:BindToken(submit, "TextColor3", "Color.AccentText")
        local errorSummary = text({
            Name = "FormSummary", Parent = footer, Text = "",
            TextWrapped = true, Visible = false, TextSize = 11,
            TextColor3 = hub:GetToken("Color.Danger"),
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -105, 1, 0),
        })
        hub:BindToken(errorSummary, "TextColor3", "Color.Danger")
        local connections = {}
        local function connect(signal, fn)
            local conn = signal:Connect(fn)
            connections[#connections + 1] = conn
            return conn
        end
        local function reflect()
            dirty = not formEquals(values, defaults, fields)
            c.Value = formSnapshot(values)
            for _, field in fields do
                local widget = widgets[field.Id]
                if widget then
                    if widget.Input and widget.Input.Text ~= tostring(values[field.Id] or "") then
                        widget.Input.Text = tostring(values[field.Id] or "")
                    end
                    if widget.Toggle then
                        widget.Toggle.Text = values[field.Id] and "✓ 已启用" or "○ 已关闭"
                    end
                    if widget.Select then
                        local value = values[field.Id]
                        widget.Select.Text = tostring(value ~= "" and value or "请选择") .. "  ▾"
                    end
                    if widget.Error then
                        widget.Error.Text = errors[field.Id] or ""
                        widget.Error.Visible = errors[field.Id] ~= nil
                    end
                end
            end
        end
        local function valueError(field, value)
            if field.Required and (value == nil or value == "" or (field.Type == "Toggle" and value ~= true)) then
                return "此项为必填"
            end
            if field.Type == "Number" and value ~= "" then
                local n = tonumber(value)
                if not n then return "请输入数字" end
                if field.Min ~= nil and n < field.Min then return "不能小于 " .. tostring(field.Min) end
                if field.Max ~= nil and n > field.Max then return "不能大于 " .. tostring(field.Max) end
            elseif field.Type == "Input" then
                local length = utf8.len(tostring(value)) or #tostring(value)
                if field.MinLength and length < field.MinLength then
                    return "至少输入 " .. tostring(field.MinLength) .. " 个字符"
                end
                if field.MaxLength and length > field.MaxLength then
                    return "最多输入 " .. tostring(field.MaxLength) .. " 个字符"
                end
                if field.Pattern and value ~= "" then
                    local ok, found = pcall(string.match, value, field.Pattern)
                    if not ok or not found then return field.PatternMessage or "格式不正确" end
                end
            elseif field.Type == "Select" and value ~= "" then
                local found = false
                for _, item in field.Options do
                    if (type(item) == "table" and (item.Value or item.Label) or item) == value then
                        found = true; break
                    end
                end
                if not found then return "选项无效" end
            end
            if type(field.Validate) == "function" then
                local ok, accepted, reason = pcall(field.Validate, value, formSnapshot(values))
                if not ok then return "校验失败: " .. tostring(accepted) end
                if accepted == false then return tostring(reason or "值无效") end
                if type(accepted) == "string" then return accepted end
            end
            return nil
        end
        function c:Get() return formSnapshot(values) end
        function c:GetValues() return self:Get() end
        function c:IsDirty() return dirty end
        function c:IsSubmitting() return busy end
        function c:GetErrors() return formSnapshot(errors) end
        function c:Validate()
            table.clear(errors)
            local first
            for _, field in fields do
                local err = valueError(field, values[field.Id])
                if err then
                    errors[field.Id] = err
                    if not first then first = field.Id end
                end
            end
            errorSummary.Text = first and ("请检查：" .. tostring(first)) or ""
            errorSummary.Visible = first ~= nil
            reflect()
            return first == nil, formSnapshot(errors), first
        end
        function c:Set(data, silent)
            if not alive or busy then return false, "form busy or destroyed" end
            if type(data) ~= "table" then return false, "Form:Set requires a table" end
            for _, field in fields do
                if data[field.Id] ~= nil then
                    if field.Type == "Toggle" then
                        values[field.Id] = data[field.Id] == true
                    else
                        values[field.Id] = tostring(data[field.Id])
                    end
                    errors[field.Id] = nil
                end
            end
            reflect()
            if not silent then self:_emit(self:Get()) end
            return true
        end
        function c:Reset(silent)
            if not alive or busy then return false end
            values = formSnapshot(defaults)
            table.clear(errors)
            errorSummary.Text = ""
            errorSummary.Visible = false
            reflect()
            if not silent then self:_emit(self:Get()) end
            return true
        end
        function c:Focus(id)
            local node = widgets[tostring(id)]
            if not node then return false end
            local target = node.Input or node.Select or node.Toggle
            if target then
                if target:IsA("TextBox") then target:CaptureFocus() end
                local ancestor = row.Parent
                while ancestor do
                    if ancestor:IsA("ScrollingFrame") then
                        local y = target.AbsolutePosition.Y - ancestor.AbsolutePosition.Y
                        ancestor.CanvasPosition = Vector2.new(ancestor.CanvasPosition.X,
                            math.max(0, ancestor.CanvasPosition.Y + y - 10))
                        break
                    end
                    ancestor = ancestor.Parent
                end
            end
            return true
        end
        function c:FinishSubmit(success, message)
            if not alive then return false end
            busy = false
            submit.Text = tostring(options.SubmitText or "提交")
            submit.Active = true
            if success then
                defaults = formSnapshot(values)
                dirty = false
            end
            if message then
                errorSummary.Text = tostring(message)
                errorSummary.Visible = true
            end
            return true
        end
        function c:Submit()
            if not alive or busy then return false, "form busy or destroyed" end
            if not self:IsAvailable() then return false, "form unavailable" end
            local valid, validationErrors, first = self:Validate()
            if not valid then self:Focus(first); return false, validationErrors end
            busy = true
            submit.Text = tostring(options.LoadingText or "提交中…")
            submit.Active = false
            local fn = options.OnSubmit or options.Submit
            local ok, result, message = true, true, nil
            if type(fn) == "function" then
                ok, result, message = pcall(fn, self:Get(), self)
            end
            if not ok then
                self:FinishSubmit(false, tostring(result))
                return false, tostring(result)
            end
            if options.Async and result == "pending" then return true, "pending" end
            local success = result ~= false
            self:FinishSubmit(success, success and nil or tostring(message or "提交失败"))
            return success, message
        end
        local function makeField(field, index)
            local holder = create("Frame", {
                Name = "Field_" .. field.Id, Parent = fieldHost,
                BackgroundTransparency = 1, LayoutOrder = index,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, { list(Enum.FillDirection.Vertical, 4) })
            text({
                Name = "FieldLabel", Parent = holder,
                Text = field.Name .. (field.Required and " *" or ""),
                TextColor3 = hub:GetToken("Color.TextPrimary"), TextSize = 12,
                Size = UDim2.new(1, 0, 0, 18),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local widget = {}
            local inputHeight = 38
            if field.Type == "Input" or field.Type == "Number" then
                widget.Input = create("TextBox", {
                    Name = "FieldInput", Parent = holder, ClearTextOnFocus = false,
                    BackgroundColor3 = hub:GetToken("Color.InputSurface"),
                    TextColor3 = hub:GetToken("Color.TextPrimary"),
                    PlaceholderColor3 = hub:GetToken("Color.TextMuted"),
                    Text = tostring(values[field.Id] or ""),
                    PlaceholderText = tostring(field.Placeholder or ""),
                    FontFace = inter(), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, inputHeight),
                }, { corner(7), padding(0, 9) })
                hub:BindToken(widget.Input, "BackgroundColor3", "Color.InputSurface")
                hub:BindToken(widget.Input, "TextColor3", "Color.TextPrimary")
                connect(widget.Input.FocusLost, function()
                    if alive and not busy then
                        values[field.Id] = widget.Input.Text
                        errors[field.Id] = nil
                        reflect()
                        c:_emit(c:Get())
                    end
                end)
            else
                local button = create("TextButton", {
                    Name = "FieldChoice", Parent = holder,
                    Text = "", AutoButtonColor = false,
                    FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                    TextColor3 = hub:GetToken("Color.TextPrimary"),
                    BackgroundColor3 = hub:GetToken("Color.InputSurface"),
                    Size = UDim2.new(1, 0, 0, inputHeight),
                }, { corner(7) })
                hub:BindToken(button, "BackgroundColor3", "Color.InputSurface")
                hub:BindToken(button, "TextColor3", "Color.TextPrimary")
                if field.Type == "Toggle" then
                    widget.Toggle = button
                    connect(button.MouseButton1Click, function()
                        if busy or not c:IsAvailable() then return end
                        values[field.Id] = not values[field.Id]
                        errors[field.Id] = nil
                        reflect()
                        c:_emit(c:Get())
                    end)
                else
                    widget.Select = button
                    connect(button.MouseButton1Click, function()
                        if busy or not c:IsAvailable() then return end
                        local entries = {}
                        for i, candidate in field.Options do
                            local value = type(candidate) == "table" and
                                (candidate.Value or candidate.Label) or candidate
                            local label = type(candidate) == "table" and
                                (candidate.Label or candidate.Value) or candidate
                            entries[i] = { Id = tostring(i), Text = tostring(label),
                                Disabled = type(candidate) == "table" and candidate.Disabled == true }
                        end
                        hub:OpenContextMenu(button, entries, {
                            Callback = function(id)
                                local item = field.Options[tonumber(id)]
                                if not item then return end
                                values[field.Id] = tostring(type(item) == "table" and
                                    (item.Value or item.Label) or item)
                                errors[field.Id] = nil
                                reflect()
                                c:_emit(c:Get())
                            end,
                        })
                    end)
                end
            end
            widget.Error = text({
                Name = "FieldError", Parent = holder, Text = "", Visible = false,
                TextWrapped = true, TextColor3 = hub:GetToken("Color.Danger"),
                TextSize = 11, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            hub:BindToken(widget.Error, "TextColor3", "Color.Danger")
            widgets[field.Id] = widget
        end
        for i, field in fields do makeField(field, i) end
        connect(submit.MouseButton1Click, function() c:Submit() end)
        function c:Destroy()
            if not alive then return end
            alive, serial = false, serial + 1
            self._disposed = true
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            if self.Flag and RiftUI.Flags[self.Flag] == self then RiftUI.Flags[self.Flag] = nil end
            local index = table.find(self.Section.Controls, self)
            if index then table.remove(self.Section.Controls, index) end
            local parent = self._moduleCard
            if parent and parent._moduleControls then
                local i = table.find(parent._moduleControls, self)
                if i then table.remove(parent._moduleControls, i) end
            end
            for i = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[i].Result == self then table.remove(hub._recipe, i) end
            end
            for subscription in self._dataSubscriptions or {} do subscription:Disconnect() end
            row:Destroy()
        end
        connect(row.Destroying, function()
            alive = false
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
        end)
        reflect()
        return hub:_finishRequiredControl(c)
    end
end
