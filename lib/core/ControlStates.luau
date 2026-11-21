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
        local dialogTokens = self.Tokens.Components.Dialog
        local typeTokens = self.Tokens.Typography
        local colors = self.Tokens.Color
        local width = math.clamp(tonumber(options.Width) or dialogTokens.Width,
            dialogTokens.MinWidth, dialogTokens.MaxWidth)
        local availableHeight = math.max(210, viewport().Y / math.max(self._scale or 1, .01)
            - topInset() / math.max(self._scale or 1, .01) - 28)
        local maxDialogHeight = math.min(dialogTokens.MaxHeight, availableHeight)
        local layer = create("TextButton", {
            Name = "ActionDialog", BackgroundColor3 = colors.DialogScrim,
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
            Active = true, Size = UDim2.fromScale(1, 1), ZIndex = 110, Parent = self.Gui,
        })
        local holder = create("Frame", {
            Name = "Holder", BackgroundTransparency = 1, Active = true,
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(.5, 0, .5, 8),
            Size = UDim2.new(1, -dialogTokens.EdgeInset * 2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 111, Parent = layer,
        })
        local sizeLimit = create("UISizeConstraint", {
            MaxSize = Vector2.new(width, maxDialogHeight), Parent = holder,
        })
        shadow(holder, 24, 111, 8)
        local card = create("Frame", {
            Name = "DialogCard", BackgroundColor3 = colors.DialogSurface,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 112, Parent = holder,
        }, { corner(dialogTokens.Radius), stroke(colors.DialogBorder),
            padding(dialogTokens.PaddingY, dialogTokens.PaddingX,
                dialogTokens.PaddingY, dialogTokens.PaddingX),
            list(Enum.FillDirection.Vertical, dialogTokens.Gap) })
        local heading = create("Frame", {
            Name = "Heading", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, dialogTokens.HeadingHeight), LayoutOrder = 1,
            ZIndex = 113, Parent = card,
        })
        local iconPlate = create("Frame", {
            Name = "IconPlate", BackgroundColor3 = colors.DialogIconSurface,
            Size = UDim2.fromOffset(dialogTokens.IconPlateSize, dialogTokens.IconPlateSize),
            ZIndex = 114, Parent = heading,
        }, { corner(dialogTokens.IconPlateRadius) })
        local headingIcon = iconLabel(options.Icon or "lock", dialogTokens.IconSize, colors.DialogIcon, {
            Parent = iconPlate, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 115,
        })
        if not headingIcon then
            text({
                Name = "DialogIconFallback", Parent = iconPlate, Text = "!",
                TextColor3 = colors.DialogIcon, TextSize = dialogTokens.IconSize,
                FontFace = inter(Enum.FontWeight.SemiBold),
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1), ZIndex = 115,
            })
        end
        local titleLabel = text({
            Name = "DialogTitle", Parent = heading,
            Text = actionText(options.Title, "功能暂不可用"),
            FontFace = inter(Enum.FontWeight[typeTokens.DialogTitle.Weight]),
            TextSize = typeTokens.DialogTitle.Size, LineHeight = typeTokens.DialogTitle.LineHeight,
            TextColor3 = colors.DialogTitle,
            Position = UDim2.fromOffset(dialogTokens.IconPlateSize + dialogTokens.TitleGap, dialogTokens.TitleTop),
            Size = UDim2.new(1, -(dialogTokens.IconPlateSize + dialogTokens.TitleGap + dialogTokens.CloseSize + 2), 0,
                dialogTokens.HeadingHeight - dialogTokens.TitleTop),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 114,
        })
        local closeButton = create("TextButton", {
            Name = "Close", BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, 0, .5, 0),
            Size = UDim2.fromOffset(dialogTokens.CloseSize, dialogTokens.CloseSize), ZIndex = 114, Parent = heading,
        })
        local closeGlyph = iconLabel("x", dialogTokens.CloseIconSize, colors.DialogCloseIcon, {
            Parent = closeButton, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 115,
        })
        if not closeGlyph then
            text({
                Name = "DialogCloseFallback", Parent = closeButton, Text = "×",
                TextColor3 = colors.DialogCloseIcon, TextSize = dialogTokens.CloseIconSize + 2,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1), ZIndex = 115,
            })
        end
        local body = create("ScrollingFrame", {
            Name = "Explanation", BackgroundColor3 = colors.DialogBodySurface,
            BackgroundTransparency = dialogTokens.BodyTransparency, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(), Size = UDim2.new(1, 0, 0, 64),
            LayoutOrder = 2, ZIndex = 113, Parent = card,
        }, { corner(dialogTokens.BodyRadius), padding(dialogTokens.BodyPaddingY,
            dialogTokens.BodyPaddingX, dialogTokens.BodyPaddingY, dialogTokens.BodyPaddingX) })
        local summary = text({
            Name = "Reason", Parent = body,
            Text = actionText(options.Content or options.Reason, "此控件当前已锁定。"),
            TextSize = typeTokens.DialogBody.Size,
            FontFace = inter(Enum.FontWeight[typeTokens.DialogBody.Weight]),
            LineHeight = typeTokens.DialogBody.LineHeight,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
            TextColor3 = colors.DialogBodyText,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 114,
        })
        local details = options.Details
        local description
        if type(details) == "string" and details ~= "" then
            description = text({
                Name = "Details", Parent = body,
                Text = details, TextSize = typeTokens.DialogDetail.Size,
                FontFace = inter(Enum.FontWeight[typeTokens.DialogDetail.Weight]),
                LineHeight = typeTokens.DialogDetail.LineHeight,
                TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = colors.DialogDetailText,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 114,
            })
        end
        local actions = type(options.Buttons) == "table" and options.Buttons
            or { { Text = "知道了", Primary = true } }
        local horizontal = false
        local actionButtons = {}
        local function fitBody()
            if not body.Parent then return end
            local scale = math.max(self._scale or 1, .01)
            local first = math.max(18, math.ceil(summary.TextBounds.Y / scale),
                math.ceil(summary.AbsoluteSize.Y / scale))
            local second = 0
            if description then
                second = math.max(18, math.ceil(description.TextBounds.Y / scale),
                    math.ceil(description.AbsoluteSize.Y / scale))
                description.Position = UDim2.fromOffset(0, first + dialogTokens.BodyGap)
            end
            local required = first + (description and (second + dialogTokens.BodyGap) or 0)
                + dialogTokens.BodyPaddingY * 2 + 2
            -- Make room for action buttons on short Android viewports.
            local buttonHeight = (horizontal and 1 or #actions) * dialogTokens.ButtonHeight
                + (horizontal and 0 or math.max(0, #actions - 1) * dialogTokens.ButtonGap)
            local bodyMax = math.max(dialogTokens.BodyMinHeight, math.min(dialogTokens.BodyMaxHeight,
                maxDialogHeight - (dialogTokens.HeadingHeight + buttonHeight
                    + dialogTokens.PaddingY * 2 + dialogTokens.Gap * 3 + 16)))
            body.Size = UDim2.new(1, 0, 0,
                math.clamp(required, math.min(dialogTokens.BodyMinHeight, bodyMax), bodyMax))
            body.CanvasSize = UDim2.fromOffset(0, required)
        end
        -- Choose stacked full-width buttons or a right-aligned horizontal row.
        local layout = options.ButtonLayout or options.ActionsLayout or options.Layout
        horizontal = layout == "HorizontalRight" or layout == "Horizontal"
        local available = math.min(width, math.max(220,
            viewport().X / (self._scale or 1) - dialogTokens.EdgeInset * 2))
            - dialogTokens.PaddingX * 2
        -- On narrow screens or with too many actions, do not clip buttons.
        if horizontal and (#actions > dialogTokens.MaxHorizontalButtons
            or available < #actions * dialogTokens.ButtonMinWidth
                + math.max(0, #actions - 1) * dialogTokens.ButtonGap) then
            horizontal = false
        end
        local buttonWidth = horizontal and math.floor(math.min(dialogTokens.ButtonMaxWidth,
            (available - (#actions - 1) * dialogTokens.ButtonGap) / math.max(#actions, 1))) or 0
        local actionRow = create("Frame", {
            Name = "Actions", BackgroundTransparency = 1,
            Size = horizontal and UDim2.new(1, 0, 0, dialogTokens.ButtonHeight)
                or UDim2.new(1, 0, 0, 0),
            AutomaticSize = horizontal and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
            LayoutOrder = 4, ZIndex = 113, Parent = card,
        }, { list(horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            dialogTokens.ButtonGap,
            horizontal and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left,
            Enum.VerticalAlignment.Center) })
        local errorLabel = text({
            Name = "Error", Parent = card, Text = "",
            TextSize = typeTokens.DialogError.Size,
            FontFace = inter(Enum.FontWeight[typeTokens.DialogError.Weight]),
            TextColor3 = colors.DialogErrorText,
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
            if self.Closed then return end
            errorLabel.Text = tostring(message or "")
            errorLabel.Visible = errorLabel.Text ~= ""
        end
        function handle:SetContent(message)
            if self.Closed then return end
            summary.Text = tostring(message or "")
            fitBody()
        end
        function handle:Close()
            if self.Closed then return end
            self.Closed = true
            local hub = self.Hub
            layer.Active = false
            hub:_overlayUnregister("Prompt", self)
            -- When a hub is being torn down, avoid retaining any animation callbacks.
            if hub._destroyed then
                if layer.Parent then layer:Destroy() end
                return
            end
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
        bind(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
            if handle.Closed then return end
            availableHeight = math.max(210, viewport().Y / math.max(self._scale or 1, .01)
                - topInset() / math.max(self._scale or 1, .01) - 28)
            maxDialogHeight = math.min(600, availableHeight)
            sizeLimit.MaxSize = Vector2.new(width, maxDialogHeight)
            fitBody()
        end)
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
                    BackgroundColor3 = colors[primary and "DialogPrimarySurface" or "DialogButtonSurface"],
                    TextColor3 = colors[primary and "DialogPrimaryText" or
                        (danger and "DialogDangerText" or "DialogButtonText")],
                    FontFace = inter(Enum.FontWeight[typeTokens.DialogButton.Weight]),
                    TextSize = typeTokens.DialogButton.Size,
                    LineHeight = typeTokens.DialogButton.LineHeight,
                    AutoButtonColor = false,
                    Size = horizontal and UDim2.fromOffset(buttonWidth, dialogTokens.ButtonHeight)
                        or UDim2.new(1, 0, 0, dialogTokens.ButtonHeight),
                    LayoutOrder = index, ZIndex = 114, Parent = actionRow,
                }, { corner(dialogTokens.ButtonRadius) })
                local outline
                if not primary then
                    outline = stroke(colors.DialogButtonBorder)
                    outline.Parent = btn
                end
                table.insert(actionButtons, { Button = btn, Primary = primary,
                    Danger = danger, Border = outline })
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
        -- Live semantic bindings own color/typography/radius. Geometry that
        -- depends on multiple tokens is refreshed together by one observer.
        local function bindStyle(inst, property, path)
            if inst then self:BindToken(inst, property, path) end
        end
        for _, spec in {
            { layer, "BackgroundColor3", "Color.DialogScrim" },
            { card, "BackgroundColor3", "Color.DialogSurface" },
            { body, "BackgroundColor3", "Color.DialogBodySurface" },
            { body, "BackgroundTransparency", "Components.Dialog.BodyTransparency" },
            { iconPlate, "BackgroundColor3", "Color.DialogIconSurface" },
            { titleLabel, "TextSize", "Typography.DialogTitle.Size" },
            { titleLabel, "LineHeight", "Typography.DialogTitle.LineHeight" },
            { titleLabel, "TextColor3", "Color.DialogTitle" },
            { summary, "TextSize", "Typography.DialogBody.Size" },
            { summary, "LineHeight", "Typography.DialogBody.LineHeight" },
            { summary, "TextColor3", "Color.DialogBodyText" },
            { errorLabel, "TextSize", "Typography.DialogError.Size" },
            { errorLabel, "TextColor3", "Color.DialogErrorText" },
            { iconPlate:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Dialog.IconPlateRadius" },
            { card:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Dialog.Radius" },
            { body:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Dialog.BodyRadius" },
            { card:FindFirstChildOfClass("UIStroke"), "Color", "Color.DialogBorder" },
        } do bindStyle(spec[1], spec[2], spec[3]) end
        if description then
            bindStyle(description, "TextSize", "Typography.DialogDetail.Size")
            bindStyle(description, "LineHeight", "Typography.DialogDetail.LineHeight")
            bindStyle(description, "TextColor3", "Color.DialogDetailText")
        end
        local iconNode = headingIcon or iconPlate:FindFirstChild("DialogIconFallback")
        local closeNode = closeGlyph or closeButton:FindFirstChild("DialogCloseFallback")
        if iconNode then
            bindStyle(iconNode, headingIcon and "ImageColor3" or "TextColor3", "Color.DialogIcon")
        end
        if closeNode then
            bindStyle(closeNode, closeGlyph and "ImageColor3" or "TextColor3", "Color.DialogCloseIcon")
        end
        for _, spec in actionButtons do
            bindStyle(spec.Button, "TextSize", "Typography.DialogButton.Size")
            bindStyle(spec.Button, "LineHeight", "Typography.DialogButton.LineHeight")
            bindStyle(spec.Button, "BackgroundColor3",
                spec.Primary and "Color.DialogPrimarySurface" or "Color.DialogButtonSurface")
            bindStyle(spec.Button, "TextColor3", spec.Primary and "Color.DialogPrimaryText"
                or (spec.Danger and "Color.DialogDangerText" or "Color.DialogButtonText"))
            bindStyle(spec.Button:FindFirstChildOfClass("UICorner"), "CornerRadius",
                "Components.Dialog.ButtonRadius")
            if spec.Border then bindStyle(spec.Border, "Color", "Color.DialogButtonBorder") end
        end
        local geometryReady = false
        local function syncGeometry()
            if handle.Closed or not card.Parent then return end
            if geometryReady then
                layer.BackgroundTransparency = self.Tokens.Components.Dialog.ScrimTransparency
            end
            dialogTokens = self.Tokens.Components.Dialog
            typeTokens = self.Tokens.Typography
            width = math.clamp(tonumber(options.Width) or dialogTokens.Width,
                dialogTokens.MinWidth, dialogTokens.MaxWidth)
            availableHeight = math.max(dialogTokens.MinViewportHeight,
                viewport().Y / math.max(self._scale or 1, .01)
                    - topInset() / math.max(self._scale or 1, .01)
                    - dialogTokens.EdgeInset * 2)
            maxDialogHeight = math.min(dialogTokens.MaxHeight, availableHeight)
            sizeLimit.MaxSize = Vector2.new(width, maxDialogHeight)
            holder.Size = UDim2.new(1, -dialogTokens.EdgeInset * 2, 0, 0)
            local cardPadding = card:FindFirstChildOfClass("UIPadding")
            if cardPadding then
                cardPadding.PaddingTop = UDim.new(0, dialogTokens.PaddingY)
                cardPadding.PaddingBottom = UDim.new(0, dialogTokens.PaddingY)
                cardPadding.PaddingLeft = UDim.new(0, dialogTokens.PaddingX)
                cardPadding.PaddingRight = UDim.new(0, dialogTokens.PaddingX)
            end
            local cardList = card:FindFirstChildOfClass("UIListLayout")
            if cardList then cardList.Padding = UDim.new(0, dialogTokens.Gap) end
            local bodyPadding = body:FindFirstChildOfClass("UIPadding")
            if bodyPadding then
                bodyPadding.PaddingTop = UDim.new(0, dialogTokens.BodyPaddingY)
                bodyPadding.PaddingBottom = UDim.new(0, dialogTokens.BodyPaddingY)
                bodyPadding.PaddingLeft = UDim.new(0, dialogTokens.BodyPaddingX)
                bodyPadding.PaddingRight = UDim.new(0, dialogTokens.BodyPaddingX)
            end
            heading.Size = UDim2.new(1, 0, 0, dialogTokens.HeadingHeight)
            iconPlate.Size = UDim2.fromOffset(dialogTokens.IconPlateSize,
                dialogTokens.IconPlateSize)
            if headingIcon then
                headingIcon.Size = UDim2.fromOffset(dialogTokens.IconSize, dialogTokens.IconSize)
            elseif iconNode then iconNode.TextSize = dialogTokens.IconSize end
            titleLabel.Position = UDim2.fromOffset(dialogTokens.IconPlateSize
                + dialogTokens.TitleGap, dialogTokens.TitleTop)
            titleLabel.Size = UDim2.new(1,
                -(dialogTokens.IconPlateSize + dialogTokens.TitleGap
                    + dialogTokens.CloseSize + 2),
                0, dialogTokens.HeadingHeight - dialogTokens.TitleTop)
            closeButton.Size = UDim2.fromOffset(dialogTokens.CloseSize, dialogTokens.CloseSize)
            if closeGlyph then
                closeGlyph.Size = UDim2.fromOffset(dialogTokens.CloseIconSize,
                    dialogTokens.CloseIconSize)
            elseif closeNode then closeNode.TextSize = dialogTokens.CloseIconSize + 2 end
            titleLabel.FontFace = inter(Enum.FontWeight[typeTokens.DialogTitle.Weight])
            summary.FontFace = inter(Enum.FontWeight[typeTokens.DialogBody.Weight])
            errorLabel.FontFace = inter(Enum.FontWeight[typeTokens.DialogError.Weight])
            if description then
                description.FontFace = inter(Enum.FontWeight[typeTokens.DialogDetail.Weight])
            end
            available = math.min(width, math.max(220,
                viewport().X / math.max(self._scale or 1, .01)
                    - dialogTokens.EdgeInset * 2)) - dialogTokens.PaddingX * 2
            horizontal = (layout == "HorizontalRight" or layout == "Horizontal")
                and #actions <= dialogTokens.MaxHorizontalButtons
                and available >= #actions * dialogTokens.ButtonMinWidth
                    + math.max(0, #actions - 1) * dialogTokens.ButtonGap
            local rowLayout = actionRow:FindFirstChildOfClass("UIListLayout")
            if rowLayout then
                rowLayout.FillDirection = horizontal and Enum.FillDirection.Horizontal
                    or Enum.FillDirection.Vertical
                rowLayout.HorizontalAlignment = horizontal and Enum.HorizontalAlignment.Right
                    or Enum.HorizontalAlignment.Left
                rowLayout.Padding = UDim.new(0, dialogTokens.ButtonGap)
            end
            actionRow.AutomaticSize = horizontal and Enum.AutomaticSize.None
                or Enum.AutomaticSize.Y
            actionRow.Size = UDim2.new(1, 0, 0, horizontal and dialogTokens.ButtonHeight or 0)
            buttonWidth = horizontal and math.floor(math.min(dialogTokens.ButtonMaxWidth,
                (available - math.max(0, #actions - 1) * dialogTokens.ButtonGap)
                    / math.max(#actions, 1))) or 0
            for _, action in actionButtons do
                action.Button.Size = horizontal and UDim2.fromOffset(buttonWidth, dialogTokens.ButtonHeight)
                    or UDim2.new(1, 0, 0, dialogTokens.ButtonHeight)
                action.Button.FontFace = inter(Enum.FontWeight[typeTokens.DialogButton.Weight])
            end
            fitBody()
            geometryReady = true
        end
        local listener = self:WatchDesignTokens(syncGeometry)
        bind(layer.Destroying, function()
            if listener then listener:Disconnect() end
        end)
        self:_overlayRegister("Prompt", handle, {
            Content = holder, Modal = true, Outside = false, Escape = options.Escape ~= false,
            Close = function() handle:Close() end,
        })
        syncGeometry()
        Motion.play(self, "action-dialog-enter:" .. tostring(layer), layer,
            { BackgroundTransparency = dialogTokens.ScrimTransparency }, Motion.Presets.Control)
        Motion.play(self, "action-dialog-holder:" .. tostring(layer), holder,
            { Position = UDim2.fromScale(.5, .5) }, Motion.Presets.Panel)
        return handle
    end

    function Hub:_ensureLockOverlay(control)
        local row = control.Frame
        if control._lockOverlay and control._lockOverlay.Parent then return control._lockOverlay end
        local overlay = create("TextButton", {
            Name = "ControlLockShade", Parent = row, Text = "",
            BackgroundColor3 = self.Tokens.Color.LockShade,
            BackgroundTransparency = self:GetToken("Components.Dialog.LockTransparency"),
            Active = true, AutoButtonColor = false, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 45,
        }, { corner(self:GetToken("Components.Dialog.LockRadius")) })
        -- A fully transparent shake target: only the lock glyph is visible.
        local iconPlate = create("Frame", {
            Name = "LockPlate", Parent = overlay, BackgroundTransparency = 1,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromOffset(self:GetToken("Components.Dialog.LockPlateSize"),
                self:GetToken("Components.Dialog.LockPlateSize")), ZIndex = 46,
        })
        local glyph = iconLabel("lock", self:GetToken("Components.Dialog.LockIconSize"),
            self.Tokens.Color.LockIcon, {
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
        self:BindToken(overlay, "BackgroundColor3", "Color.LockShade")
        self:BindToken(overlay, "BackgroundTransparency", "Components.Dialog.LockTransparency")
        self:BindToken(overlay:FindFirstChildOfClass("UICorner"), "CornerRadius",
            "Components.Dialog.LockRadius")
        if glyph then self:BindToken(glyph, "ImageColor3", "Color.LockIcon") end
        control._lockOverlay, control._lockIcon = overlay, iconPlate
        control._lockShakeId = 0
        local hub = self
        hub:_connect(row.Destroying, function()
            control._lockShakeId += 1
            if control._lockIcon then cancelMotion(control._lockIcon) end
            control._lockOverlay = nil
            control._lockIcon = nil
        end)
        hub:_connect(overlay.MouseButton1Click, function()
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
        cancelMotion(plate)
        plate.Position = UDim2.fromScale(.5, .5)
        task.spawn(function()
            for _, dx in { -5, 5, -4, 4, -2, 0 } do
                if self._destroyed or control._disposed or not plate.Parent
                    or control._lockShakeId ~= id then return end
                local move = tween(plate, TweenInfo.new(.045, Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out), { Position = UDim2.new(.5, dx, .5, 0) })
                move.Completed:Wait()
            end
            if not self._destroyed and plate.Parent and control._lockShakeId == id then
                plate.Position = UDim2.fromScale(.5, .5)
            end
        end)
    end

    function Hub:_openLockedReason(control)
        if self._destroyed then return end
        local allowed, reason = control:IsAvailable()
        if allowed then return nil end
        reason = actionText(reason, "此控件当前已锁定。")
        local previous = self._activeLockDialog
        if previous and not previous.Closed then
            if self._activeLockControl == control then
                previous:SetContent(reason)
                return previous
            end
            previous:Close()
            -- Repeated touches on different controls must not accumulate
            -- animation-out layers behind the newly opened modal.
            if previous.Layer and previous.Layer.Parent then previous.Layer:Destroy() end
        end
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
                if self._activeLockDialog == handle then
                    self._activeLockDialog = nil
                    self._activeLockControl = nil
                end
                if type(custom.OnClose) == "function" then pcall(custom.OnClose, control, handle) end
            end,
        })
        self._activeLockDialog = dialog
        self._activeLockControl = control
        return dialog
    end

    function Hub:_syncLockOverlay(control)
        if not control or not control.Frame or not control.Frame.Parent or self._destroyed then return end
        local available = control:IsAvailable()
        if available then
            if control._lockOverlay then
                control._lockOverlay.Visible = false
                control._lockShakeId = (control._lockShakeId or 0) + 1
                if control._lockIcon then
                    cancelMotion(control._lockIcon)
                    control._lockIcon.Position = UDim2.fromScale(.5, .5)
                end
            end
            if self._activeLockControl == control and self._activeLockDialog then
                self._activeLockDialog:Close()
            end
        else
            self:_ensureLockOverlay(control).Visible = true
            if self._activeLockControl == control and self._activeLockDialog
                and not self._activeLockDialog.Closed then
                local _, reason = control:IsAvailable()
                self._activeLockDialog:SetContent(actionText(reason, "此控件当前已锁定。"))
            end
        end
    end
end
