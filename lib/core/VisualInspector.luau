-- SPDX-License-Identifier: MPL-2.0
-- Read-only visual hierarchy inspector, built on the existing Window overlay.
do
    local function describe(node)
        if not node or not node.Parent then return nil end
        local path = {}
        local cursor = node
        while cursor and #path < 7 do
            table.insert(path, 1, cursor.Name)
            cursor = cursor.Parent
        end
        local pos, size = node.AbsolutePosition, node.AbsoluteSize
        local color = node.BackgroundColor3
        return {
            Name = node.Name, Class = node.ClassName,
            Path = table.concat(path, "/"),
            Position = string.format("%.0f, %.0f", pos.X, pos.Y),
            Size = string.format("%.0f × %.0f", size.X, size.Y),
            ZIndex = node.ZIndex, Visible = node.Visible,
            BackgroundTransparency = node.BackgroundTransparency,
            Background = string.format("#%02X%02X%02X",
                math.floor(color.R * 255 + .5),
                math.floor(color.G * 255 + .5),
                math.floor(color.B * 255 + .5)),
        }
    end
    function Hub:OpenVisualInspector(options)
        if self._destroyed then return nil end
        options = type(options) == "table" and options or {}
        local existing = self._visualInspector
        if existing and not existing.Destroyed then
            existing:Refresh()
            existing.Window:Open()
            return existing
        end
        local hub = self
        local win = self:Window({
            Title = options.Title or "Visual Inspector",
            Description = "只读结构 · 位置 · 尺寸 · 颜色",
            Width = math.clamp(tonumber(options.Width) or 560, 360, 720),
            Height = math.clamp(tonumber(options.Height) or 430, 300, 620),
            Icon = "scan-eye", _internal = true,
        })
        local tab = win:Tab({ Name = "Inspect", Icon = "layers" })
        local left = tab:Section({ Name = "元素", Side = "Left",
            Pinnable = false, Collapsible = false })
        local right = tab:Section({ Name = "实时属性", Side = "Right",
            Pinnable = false, Collapsible = false })
        local listRow = left:_row(230, "InspectorList")
        local listFrame = create("ScrollingFrame", { Name = "InspectorTargets",
            Parent = listRow, Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
            BackgroundTransparency = 1, ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new() })
        list(Enum.FillDirection.Vertical, 4).Parent = listFrame
        local infoRow = right:_row(215, "InspectorPropertyPanel")
        local info = text({ Name = "InspectorProperties", Parent = infoRow,
            Text = "选择左侧元素查看实时布局属性", TextSize = 11,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
            TextColor3 = self:GetToken("Color.TextSecondary"),
            Size = UDim2.fromScale(1, 1) })
        self:BindToken(info, "TextColor3", "Color.TextSecondary")
        local highlight = create("Frame", { Name = "InspectorHighlight",
            Parent = self.Gui, BackgroundTransparency = 1, BorderSizePixel = 0,
            Visible = false, Active = false, ZIndex = 102,
            Size = UDim2.fromOffset(0, 0) })
        local edge = stroke(self:GetToken("Color.Accent"), 2, 0)
        edge.Parent = highlight
        self:BindToken(edge, "Color", "Color.Accent")
        local inspector = { Window = win, Selected = nil, Destroyed = false,
            Targets = {}, Highlight = highlight, Snapshot = nil }
        local listConnections, targetConnections = {}, {}
        local function disconnect(items)
            for _, connection in items do connection:Disconnect() end
            table.clear(items)
        end
        local function update()
            if inspector.Destroyed then return end
            local node = inspector.Selected
            if not node or not node.Parent or not node:IsDescendantOf(hub.Gui)
                or node:IsDescendantOf(win.Layer) then
                inspector.Selected = nil
                inspector.Snapshot = nil
                highlight.Visible = false
                info.Text = "选择左侧元素查看实时布局属性"
                return
            end
            local data = describe(node)
            inspector.Snapshot = data
            info.Text = string.format(
                "%s [%s]\n%s\n\n位置: %s\n尺寸: %s\nZIndex: %d\n可见: %s\n背景: %s\n透明度: %.2f",
                data.Name, data.Class, data.Path,
                data.Position, data.Size, data.ZIndex, tostring(data.Visible),
                data.Background, data.BackgroundTransparency)
            local origin = hub.Gui.AbsolutePosition
            local scale = math.max(hub._scale or 1, .01)
            local pos = node.AbsolutePosition
            highlight.Position = UDim2.fromOffset(
                (pos.X - origin.X) / scale, (pos.Y - origin.Y) / scale)
            highlight.Size = UDim2.fromOffset(
                node.AbsoluteSize.X / scale, node.AbsoluteSize.Y / scale)
            highlight.Visible = node.Visible and node.AbsoluteSize.X > 0
                and node.AbsoluteSize.Y > 0 and win.IsOpen
        end
        function inspector:SelectTarget(node)
            if self.Destroyed or not node or not node:IsA("GuiObject")
                or not node:IsDescendantOf(hub.Gui)
                or node:IsDescendantOf(win.Layer)
                or node == highlight then return false end
            disconnect(targetConnections)
            self.Selected = node
            for _, property in { "AbsolutePosition", "AbsoluteSize",
                "Visible", "ZIndex", "BackgroundColor3", "BackgroundTransparency" } do
                targetConnections[#targetConnections + 1] =
                    node:GetPropertyChangedSignal(property):Connect(update)
            end
            targetConnections[#targetConnections + 1] = node.Destroying:Connect(update)
            update()
            return true
        end
        function inspector:GetSnapshot()
            if self.Destroyed or not self.Snapshot then return nil end
            return table.clone(self.Snapshot)
        end
        function inspector:Refresh()
            if self.Destroyed then return false end
            disconnect(listConnections)
            for _, child in listFrame:GetChildren() do
                if child:IsA("GuiObject") then child:Destroy() end
            end
            table.clear(self.Targets)
            local index = 0
            local filter = string.lower(tostring(options.Filter or ""))
            for _, node in hub.Gui:GetDescendants() do
                if node:IsA("GuiObject") and not node:IsDescendantOf(win.Layer)
                    and node ~= highlight and node.Visible
                    and (filter == "" or string.find(string.lower(node.Name), filter, 1, true)) then
                    index += 1
                    self.Targets[index] = node
                    local button = create("TextButton", {
                        Name = "Inspect_" .. index, Parent = listFrame,
                        Text = string.format("%s · %s", node.ClassName, node.Name),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextSize = 11, FontFace = inter(),
                        TextColor3 = hub:GetToken("Color.TextPrimary"),
                        BackgroundColor3 = hub:GetToken("Color.Surface2"),
                        AutoButtonColor = false, LayoutOrder = index,
                        Size = UDim2.new(1, -5, 0, 36),
                    }, { corner(6), padding(0, 8) })
                    hub:BindToken(button, "TextColor3", "Color.TextPrimary")
                    hub:BindToken(button, "BackgroundColor3", "Color.Surface2")
                    listConnections[#listConnections + 1] =
                        button.MouseButton1Click:Connect(function()
                            inspector:SelectTarget(node)
                        end)
                    if index >= math.clamp(tonumber(options.Limit) or 80, 8, 150) then break end
                end
            end
            listFrame.CanvasSize = UDim2.fromOffset(0, index * 40)
            update()
            return true
        end
        function inspector:Close()
            if self.Destroyed then return end
            win:Close()
            highlight.Visible = false
        end
        function inspector:Destroy()
            if self.Destroyed then return end
            self.Destroyed = true
            disconnect(listConnections)
            disconnect(targetConnections)
            highlight:Destroy()
            win:Destroy()
            if hub._visualInspector == self then hub._visualInspector = nil end
        end
        win.Layer.Destroying:Connect(function()
            inspector.Destroyed = true
            disconnect(listConnections)
            disconnect(targetConnections)
            if highlight.Parent then highlight:Destroy() end
            if hub._visualInspector == inspector then hub._visualInspector = nil end
        end)
        self._visualInspector = inspector
        inspector:Refresh()
        win:Open()
        return inspector
    end
    function Hub:CloseVisualInspector()
        local inspector = self._visualInspector
        if not inspector then return false end
        inspector:Close()
        return true
    end
end
