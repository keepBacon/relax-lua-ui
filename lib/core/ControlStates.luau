-- SPDX-License-Identifier: MPL-2.0
-- Unified two-state control availability and native, theme-aware action dialogs.
-- MacUI-inspired modal ownership + OasisUI-inspired safe, configurable actions.
-- No CanvasGroup: content and labels render without texture downsampling.
do
    local function actionText(value, fallback)
        return type(value) == "string" and value ~= "" and value or fallback
    end

    function Hub:OpenActionDialog(options)
        if self._destroyed then return nil end
        options = type(options) == "table" and options or {}
        local theme = self.Theme
        local width = math.clamp(tonumber(options.Width) or 382, 260, 460)
        local layer = create("TextButton", {
            Name = "ActionDialog", BackgroundColor3 = themeColor(theme, "Scrim"),
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
            Active = true, Size = UDim2.fromScale(1, 1), ZIndex = 110, Parent = self.Gui,
        })
        local holder = create("Frame", {
            Name = "Holder", BackgroundTransparency = 1, Active = true,
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(.5, 0, .5, 8),
            Size = UDim2.new(1, -32, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 111, Parent = layer,
        })
        create("UISizeConstraint", { MaxSize = Vector2.new(width, 600), Parent = holder })
        shadow(holder, 24, 111, 8)
        local card = create("Frame", {
            Name = "DialogCard", BackgroundColor3 = themeColor(theme, "Panel"),
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 112, Parent = holder,
        }, { corner(16), stroke(themeColor(theme, "PanelStroke")),
            padding(16, 18, 16, 18), list(Enum.FillDirection.Vertical, 10) })
        local heading = create("Frame", {
            Name = "Heading", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1,
            ZIndex = 113, Parent = card,
        })
        local iconPlate = create("Frame", {
            Name = "IconPlate", BackgroundColor3 = themeColor(theme, "Field"),
            Size = UDim2.fromOffset(32, 32), ZIndex = 114, Parent = heading,
        }, { corner(10) })
        iconLabel(options.Icon or "lock", 18, theme.Text, {
            Parent = iconPlate, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 115,
        })
        text({
            Name = "DialogTitle", Parent = heading,
            Text = actionText(options.Title, "功能暂不可用"),
            FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 15,
            TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.fromOffset(42, 2),
            Size = UDim2.new(1, -80, 0, 28),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 114,
        })
        local closeButton = create("TextButton", {
            Name = "Close", BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, 0, .5, 0),
            Size = UDim2.fromOffset(36, 36), ZIndex = 114, Parent = heading,
        })
        iconLabel("x", 17, theme.SubText, {
            Parent = closeButton, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 115,
        })
        local body = create("ScrollingFrame", {
            Name = "Explanation", BackgroundColor3 = themeColor(theme, "Field"),
            BackgroundTransparency = .35, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(), Size = UDim2.new(1, 0, 0, 64),
            LayoutOrder = 2, ZIndex = 113, Parent = card,
        }, { corner(10), padding(10, 12, 10, 12) })
        local summary = text({
            Name = "Reason", Parent = body,
            Text = actionText(options.Content or options.Reason, "此控件当前已锁定。"),
            TextSize = 12, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
            TextColor3 = themeColor(theme, "SubText"),
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 114,
        })
        local details = options.Details
        local description
        if type(details) == "string" and details ~= "" then
            description = text({
                Name = "Details", Parent = body,
                Text = details, TextSize = 11, TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = themeColor(theme, "Muted"),
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 114,
            })
        end
        local function fitBody()
            if not body.Parent then return end
            local scale = math.max(self._scale or 1, .01)
            local first = math.max(18, math.ceil(summary.TextBounds.Y / scale),
                math.ceil(summary.AbsoluteSize.Y / scale))
            local second = 0
            if description then
                second = math.max(18, math.ceil(description.TextBounds.Y / scale),
                    math.ceil(description.AbsoluteSize.Y / scale))
                description.Position = UDim2.fromOffset(0, first + 10)
            end
            local required = first + (description and (second + 10) or 0) + 22
            body.Size = UDim2.new(1, 0, 0, math.clamp(required, 56, 170))
            body.CanvasSize = UDim2.fromOffset(0, required)
        end
        -- Choose stacked full-width buttons or a right-aligned horizontal row.
        local actions = options.Buttons or { { Text = "知道了", Primary = true } }
        local layout = options.ButtonLayout or options.ActionsLayout or options.Layout
        local horizontal = layout == "HorizontalRight" or layout == "Horizontal"
        local available = math.min(width, math.max(220, viewport().X / (self._scale or 1) - 32)) - 36
        -- On narrow screens or with too many actions, do not clip buttons.
        if horizontal and (#actions > 3 or available < #actions * 88 + math.max(0, #actions - 1) * 7) then
            horizontal = false
        end
        local buttonWidth = horizontal and math.floor(math.min(148,
            (available - (#actions - 1) * 7) / math.max(#actions, 1))) or 0
        local actionRow = create("Frame", {
            Name = "Actions", BackgroundTransparency = 1,
            Size = horizontal and UDim2.new(1, 0, 0, 36) or UDim2.new(1, 0, 0, 0),
            AutomaticSize = horizontal and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
            LayoutOrder = 4, ZIndex = 113, Parent = card,
        }, { list(horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            7, horizontal and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left,
            Enum.VerticalAlignment.Center) })
        local errorLabel = text({
            Name = "Error", Parent = card, Text = "",
            TextSize = 11, TextColor3 = themeColor(theme, "Danger"),
            TextWrapped = true, Visible = false,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 3, ZIndex = 113,
        })
        local handle = { Layer = layer, Card = card, Body = body, Closed = false }
        local connections = {}
        local function bind(signal, fn)
            local conn = signal:Connect(fn)
            table.insert(connections, conn)
            return conn
        end
        function handle:SetError(message)
            errorLabel.Text = tostring(message or "")
            errorLabel.Visible = errorLabel.Text ~= ""
        end
        function handle:SetContent(message)
            summary.Text = tostring(message or "")
            fitBody()
        end
        function handle:Close()
            if self.Closed then return end
            self.Closed = true
            local hub = self.Hub
            hub:_overlayUnregister("Prompt", self)
            Motion.play(hub, "action-dialog-exit:" .. tostring(layer), layer,
                { BackgroundTransparency = 1 }, Motion.Presets.Dismiss)
            Motion.play(hub, "action-dialog-holder:" .. tostring(layer), holder,
                { Position = UDim2.new(.5, 0, .5, 8) }, Motion.Presets.Dismiss,
                function() if layer.Parent then layer:Destroy() end end)
            if type(options.OnClose) == "function" then
                local ok, err = pcall(options.OnClose, self)
                if not ok then warn("[RelaxUI Dialog] OnClose: " .. tostring(err)) end
            end
        end
        handle.Hub = self
        -- A modal shade consumes native clicks even when global routing is bypassed.
        bind(layer.MouseButton1Click, function()
            if options.CloseOnOutside == true then handle:Close() end
        end)
        bind(closeButton.MouseButton1Click, function() handle:Close() end)
        bind(summary:GetPropertyChangedSignal("TextBounds"), fitBody)
        if description then bind(description:GetPropertyChangedSignal("TextBounds"), fitBody) end
        bind(layer.Destroying, function()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            handle.Closed = true
            self:_overlayUnregister("Prompt", handle)
        end)
        for index, option in actions do
            if type(option) == "table" then
                local primary = option.Primary == true or option.Style == "Primary"
                local danger = option.Danger == true or option.Style == "Danger"
                local btn = create("TextButton", {
                    Name = "Action_" .. index, Text = actionText(option.Text or option.Title, "确定"),
                    BackgroundColor3 = themeColor(theme, primary and "Accent" or "Tile"),
                    TextColor3 = themeColor(theme, primary and "AccentText" or
                        (danger and "Danger" or "Text")),
                    FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                    AutoButtonColor = false, Size = horizontal and UDim2.fromOffset(buttonWidth, 36)
                        or UDim2.new(1, 0, 0, 36),
                    LayoutOrder = index, ZIndex = 114, Parent = actionRow,
                }, { corner(9) })
                if not primary then stroke(themeColor(theme, "FieldStroke")).Parent = btn end
                bind(btn.MouseButton1Click, function()
                    if handle.Closed then return end
                    local keep = option.KeepOpen == true
                    if type(option.Callback) == "function" then
                        local ok, result = pcall(option.Callback, handle)
                        if not ok then handle:SetError(tostring(result)); return end
                        if result == false then keep = true end
                    end
                    if not keep then handle:Close() end
                end)
            end
        end
        self:_overlayRegister("Prompt", handle, {
            Content = holder, Modal = true, Outside = false, Escape = options.Escape ~= false,
            Close = function() handle:Close() end,
        })
        fitBody()
        Motion.play(self, "action-dialog-enter:" .. tostring(layer), layer,
            { BackgroundTransparency = .46 }, Motion.Presets.Control)
        Motion.play(self, "action-dialog-holder:" .. tostring(layer), holder,
            { Position = UDim2.fromScale(.5, .5) }, Motion.Presets.Panel)
        return handle
    end

    function Hub:_ensureLockOverlay(control)
        local row = control.Frame
        if control._lockOverlay and control._lockOverlay.Parent then return control._lockOverlay end
        local overlay = create("TextButton", {
            Name = "ControlLockShade", Parent = row, Text = "",
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = .40,
            Active = true, AutoButtonColor = false, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 45,
        }, { corner(8) })
        -- A fully transparent shake target: only the lock glyph is visible.
        local iconPlate = create("Frame", {
            Name = "LockPlate", Parent = overlay, BackgroundTransparency = 1,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromOffset(36, 36), ZIndex = 46,
        })
        local glyph = iconLabel("lock", 19, self.Theme.Text, {
            Parent = iconPlate, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 47,
        })
        if not glyph then
            -- Draw a simple padlock fallback instead of relying on missing emoji glyphs.
            create("Frame", {
                Name = "Shackle", Parent = iconPlate, BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 7), Size = UDim2.fromOffset(12, 13),
                ZIndex = 47,
            }, { corner(7), stroke(themeColor(self.Theme, "Text"), 2) })
            create("Frame", {
                Name = "LockBody", Parent = iconPlate,
                BackgroundColor3 = themeColor(self.Theme, "Text"),
                Position = UDim2.fromOffset(9, 17), Size = UDim2.fromOffset(18, 12),
                ZIndex = 48,
            }, { corner(3) })
        end
        control._lockOverlay, control._lockIcon = overlay, iconPlate
        control._lockShakeId = 0
        local hub = self
        overlay.MouseButton1Click:Connect(function()
            if hub._destroyed or control._disposed then return end
            local available = control:IsAvailable()
            if available then return end
            hub:_shakeControlLock(control)
            hub:_openLockedReason(control)
        end)
        return overlay
    end

    function Hub:_shakeControlLock(control)
        local plate = control._lockIcon
        if not plate or not plate.Parent then return end
        control._lockShakeId = (control._lockShakeId or 0) + 1
        local id = control._lockShakeId
        task.spawn(function()
            for _, dx in { -5, 5, -4, 4, -2, 0 } do
                if self._destroyed or control._disposed or not plate.Parent
                    or control._lockShakeId ~= id then return end
                local move = tween(plate, TweenInfo.new(.045, Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out), { Position = UDim2.new(.5, dx, .5, 0) })
                move.Completed:Wait()
            end
        end)
    end

    function Hub:_openLockedReason(control)
        if self._destroyed then return end
        if self._activeLockDialog and not self._activeLockDialog.Closed then
            self._activeLockDialog:Close()
        end
        local _, reason = control:IsAvailable()
        reason = actionText(reason, "此控件当前已锁定。")
        local custom = control._lockOptions or {}
        local actions = custom.Actions
        if type(actions) ~= "table" or #actions == 0 then
            actions = {
                { Text = "复制原因", Callback = function(handle)
                    if typeof(setclipboard) == "function" then
                        local ok = pcall(setclipboard, reason)
                        if ok then handle:SetError("已复制锁定原因"); return false end
                    end
                    handle:SetError("当前环境无法复制文本")
                    return false
                end, KeepOpen = true },
                { Text = "知道了", Primary = true },
            }
        else
            local adapted = {}
            for _, spec in actions do
                if type(spec) == "table" then
                    local original = spec.Callback
                    local action = table.clone(spec)
                    if type(original) == "function" then
                        action.Callback = function(handle)
                            return original(control, handle)
                        end
                    end
                    table.insert(adapted, action)
                end
            end
            actions = #adapted > 0 and adapted or { { Text = "知道了", Primary = true } }
        end
        local dialog = self:OpenActionDialog({
            Title = actionText(custom.Title, control.Name .. " · 已锁定"),
            Content = reason, Details = custom.Details,
            Icon = custom.Icon or "lock", Width = custom.Width,
            Buttons = actions,
            ButtonLayout = custom.ButtonLayout or custom.ActionsLayout or custom.Layout,
            CloseOnOutside = custom.CloseOnOutside == true,
            OnClose = function(handle)
                if self._activeLockDialog == handle then self._activeLockDialog = nil end
                if type(custom.OnClose) == "function" then pcall(custom.OnClose, control, handle) end
            end,
        })
        self._activeLockDialog = dialog
        return dialog
    end

    function Hub:_syncLockOverlay(control)
        if not control or not control.Frame or not control.Frame.Parent or self._destroyed then return end
        local available = control:IsAvailable()
        if available then
            if control._lockOverlay then control._lockOverlay.Visible = false end
        else
            self:_ensureLockOverlay(control).Visible = true
        end
    end
end
