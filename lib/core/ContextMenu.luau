-- SPDX-License-Identifier: MPL-2.0
-- ContextMenu: compact contextual actions, anchored to existing OverlayStack popup.
-- Supports right-click, touch long press, nested items and explicit API opens.
do
    local function validateMenu(items, depth)
        assert(type(items) == "table", "ContextMenu.Items must be an array")
        assert(depth <= 4, "ContextMenu nested depth exceeds 4")
        assert(#items <= 100, "ContextMenu supports up to 100 entries per level")
        local copy = {}
        for i, raw in items do
            assert(type(raw) == "table", "ContextMenu entry must be a table")
            local item = table.clone(raw)
            item.Id = tostring(item.Id or item.Key or i)
            item.Text = tostring(item.Text or item.Title or item.Name or item.Id)
            if item.Children ~= nil then item.Children = validateMenu(item.Children, depth + 1) end
            copy[i] = item
        end
        return copy
    end

    function Hub:OpenContextMenu(anchor, items, options)
        if self._destroyed then return nil, "hub destroyed" end
        if not anchor or not anchor:IsDescendantOf(self.Gui) then
            return nil, "ContextMenu anchor must be inside hub GUI"
        end
        options = type(options) == "table" and options or {}
        local entries = validateMenu(items or options.Items or {}, 1)
        local menu = { Closed = false, Items = entries, Anchor = anchor }
        local theme = self.Theme
        local menuWidth = math.clamp(tonumber(options.Width) or 228, 170, 340)
        local lineHeight = 37
        local frame = create("Frame", {
            Name = "ContextMenu", Parent = nil,
            BackgroundColor3 = self:GetToken("Color.PopupSurface"),
            Size = UDim2.fromOffset(menuWidth, 48),
            ZIndex = 41,
        }, { corner(self:GetToken("Components.Popup.Radius")),
            stroke(self:GetToken("Color.PopupBorder"), 1, .30) })
        local scroll = create("ScrollingFrame", {
            Name = "ContextRows", Parent = frame,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Size = UDim2.fromScale(1, 1), ZIndex = 42,
        })
        local page = entries
        local history = {}
        local rows = {}
        local connections = {}
        local function connect(signal, callback)
            local c = signal:Connect(callback)
            table.insert(connections, c)
            return c
        end
        local function clearRows()
            for _, connection in connections do connection:Disconnect() end
            table.clear(connections)
            for _, node in rows do node:Destroy() end
            table.clear(rows)
        end
        local function render()
            if menu.Closed then return end
            clearRows()
            local y = 5
            if #history > 0 then
                local back = create("TextButton", {
                    Name = "Back", Parent = scroll, Text = "‹   返回",
                    BackgroundTransparency = 1, AutoButtonColor = false,
                    TextColor3 = self:GetToken("Color.TextSecondary"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                    Position = UDim2.fromOffset(9, y),
                    Size = UDim2.new(1, -18, 0, 32), ZIndex = 43,
                })
                table.insert(rows, back)
                connect(back.MouseButton1Click, function()
                    page = table.remove(history)
                    render()
                end)
                y += 34
            end
            for index, item in page do
                if item.Separator or item.Divider then
                    local divider = create("Frame", {
                        Name = "Separator", Parent = scroll,
                        BackgroundColor3 = self:GetToken("Color.BorderSubtle"),
                        BackgroundTransparency = .38, BorderSizePixel = 0,
                        Position = UDim2.fromOffset(12, y + 5),
                        Size = UDim2.new(1, -24, 0, 1), ZIndex = 43,
                    })
                    table.insert(rows, divider)
                    y += 12
                else
                    local disabled = item.Disabled == true
                    local hit = create("TextButton", {
                        Name = "Action_" .. item.Id, Parent = scroll,
                        BackgroundColor3 = self:GetToken("Color.PopupItemSelected"),
                        BackgroundTransparency = 1, AutoButtonColor = false,
                        Active = not disabled, Text = "",
                        Position = UDim2.fromOffset(5, y),
                        Size = UDim2.new(1, -10, 0, lineHeight), ZIndex = 43,
                    }, { corner(7) })
                    table.insert(rows, hit)
                    local left = 11
                    if type(item.Icon) == "string" then
                        local icon = iconLabel(item.Icon, 15,
                            self:GetToken("Color.TextSecondary"), {
                            Parent = hit, Position = UDim2.fromOffset(11, 11), ZIndex = 44,
                        })
                        if icon then left = 34 end
                    end
                    text({ Parent = hit, Name = "Label", Text = item.Text,
                        FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                        TextColor3 = disabled and self:GetToken("Color.TextMuted")
                            or self:GetToken(item.Danger and "Color.Danger" or "Color.PopupItemText"),
                        Position = UDim2.fromOffset(left, 0),
                        Size = UDim2.new(1, -left - 36, 1, 0),
                        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 44 })
                    text({ Parent = hit, Name = "Shortcut",
                        Text = item.Children and "›" or tostring(item.Shortcut or ""),
                        TextSize = 11, TextColor3 = self:GetToken("Color.TextMuted"),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Position = UDim2.new(1, -48, 0, 0),
                        Size = UDim2.fromOffset(37, lineHeight), ZIndex = 44 })
                    connect(hit.MouseEnter, function()
                        if not disabled then Motion.play(self, "context-hover:" .. tostring(hit),
                            hit, { BackgroundTransparency = .76 }, Motion.Presets.Micro) end
                    end)
                    connect(hit.MouseLeave, function()
                        Motion.play(self, "context-hover:" .. tostring(hit),
                            hit, { BackgroundTransparency = 1 }, Motion.Presets.Micro)
                    end)
                    connect(hit.MouseButton1Click, function()
                        if menu.Closed or disabled or self:_overlayTop() == nil
                            or self:_overlayTop().Kind ~= "Popup" then return end
                        if item.Children then
                            table.insert(history, page)
                            page = item.Children
                            render()
                        else
                            menu:Close()
                            local callback = item.Callback or options.Callback
                            if type(callback) == "function" then
                                local ok, err = pcall(callback, item.Id, item, index)
                                if not ok then warn("[RelaxUI ContextMenu] " .. tostring(err)) end
                            end
                        end
                    end)
                    y += lineHeight + 1
                end
            end
            if #page == 0 then
                local empty = text({ Parent = scroll, Name = "Empty", Text = options.EmptyText or "无可用操作",
                    TextSize = 12, TextColor3 = self:GetToken("Color.TextMuted"),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 36) })
                table.insert(rows, empty)
                y += 36
            end
            frame.Size = UDim2.fromOffset(menuWidth, math.min(y + 6,
                (tonumber(options.MaxHeight) or 296)))
            scroll.CanvasSize = UDim2.fromOffset(0, y + 6)
            scroll.CanvasPosition = Vector2.zero
        end
        function menu:IsOpen() return not self.Closed end
        function menu:SetItems(nextItems)
            if self.Closed then return false end
            self.Items = validateMenu(nextItems, 1)
            page = self.Items
            table.clear(history)
            render()
            return true
        end
        function menu:Close()
            if self.Closed then return end
            self.Closed = true
            if self.Hub._popup and self.Hub._popup.Frame == frame then self.Hub:_closePopup() end
        end
        menu.Hub = self
        self:_openPopup(anchor, frame, function()
            menu.Closed = true
            clearRows()
            for _, c in connections do c:Disconnect() end
            table.clear(connections)
        end)
        if not self._popup or self._popup.Frame ~= frame then return nil, "popup unavailable" end
        self:BindToken(frame, "BackgroundColor3", "Color.PopupSurface")
        self:BindToken(frame:FindFirstChildOfClass("UIStroke"), "Color", "Color.PopupBorder")
        render()
        return menu
    end

    function Hub:BindContextMenu(anchor, entries, options)
        if not anchor or not anchor:IsDescendantOf(self.Gui) then
            return nil, "invalid context menu target"
        end
        options = type(options) == "table" and options or {}
        local hub = self
        local handle = { Connected = true, Menu = nil }
        local held, serial, origin = nil, 0, nil
        local conns = {}
        local function connect(signal, callback)
            table.insert(conns, signal:Connect(callback))
        end
        function handle:Open()
            if not self.Connected then return nil end
            local menu = hub:OpenContextMenu(anchor, entries, options)
            self.Menu = menu
            return menu
        end
        function handle:SetItems(items)
            entries = validateMenu(items, 1)
            if self.Menu and self.Menu:IsOpen() then self.Menu:SetItems(entries) end
        end
        function handle:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            serial += 1
            held = nil
            if self.Menu and self.Menu:IsOpen() then self.Menu:Close() end
            for _, conn in conns do conn:Disconnect() end
            table.clear(conns)
        end
        connect(anchor.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                handle:Open()
                return
            end
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            held, origin = input, input.Position
            serial += 1
            local ticket = serial
            task.delay(math.clamp(tonumber(options.LongPressTime) or .55, .45, .65), function()
                if handle.Connected and serial == ticket and held == input then
                    held = nil
                    handle:Open()
                end
            end)
        end)
        connect(anchor.InputChanged, function(input)
            if held and input == held and origin
                and (input.Position - origin).Magnitude > 12 then
                held = nil
                serial += 1
            end
        end)
        connect(anchor.InputEnded, function(input)
            if held == input then held = nil; serial += 1 end
        end)
        connect(anchor.Destroying, function() handle:Disconnect() end)
        return handle
    end

    function Section:ContextMenu(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(44, "ContextMenu_" .. (options.Name or "Actions"))
        local c = self:_control("ContextMenu", options, row)
        local trigger = create("TextButton", {
            Name = "ContextTrigger", Parent = row,
            Text = tostring(options.Name or "更多操作"),
            FontFace = inter(Enum.FontWeight.Medium),
            TextSize = hub:GetToken("Typography.ControlLabel.Size"),
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            BackgroundColor3 = hub:GetToken("Color.Surface2"),
            Size = UDim2.new(1, 0, 0, 40),
            AutoButtonColor = false,
        }, { corner(hub:GetToken("Radius.S")),
            stroke(hub:GetToken("Color.BorderSubtle"), 1, .4) })
        hub:BindToken(trigger, "BackgroundColor3", "Color.Surface2")
        hub:BindToken(trigger, "TextColor3", "Color.TextPrimary")
        local binding = hub:BindContextMenu(trigger, options.Items or {}, {
            Callback = function(id, item)
                c.Value = id
                c:_emit(id, item)
            end,
            LongPressTime = options.LongPressTime,
            Width = options.Width,
        })
        c.Trigger = trigger
        function c:Get() return self.Value end
        function c:SetItems(items) binding:SetItems(items) end
        function c:Open()
            if not c:IsAvailable() then return nil end
            return binding:Open()
        end
        function c:Close()
            if binding.Menu and binding.Menu:IsOpen() then binding.Menu:Close() end
        end
        hub:_connect(trigger.MouseButton1Click, function()
            if c:IsAvailable() and not hub._popupJustClosed then c:Open() end
        end)
        hub:_connect(row.Destroying, function() binding:Disconnect(); c._disposed = true end)
        return hub:_finishRequiredControl(c)
    end
end
