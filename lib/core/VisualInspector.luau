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
    -- R3: explicit snapshots, never a background per-frame inspector.
    local function copySnapshot(value)
        if type(value) ~= "table" then return value end
        local result = {}
        for key, child in value do result[key] = copySnapshot(child) end
        return result
    end

    local function rectFor(node)
        local position, size = node.AbsolutePosition, node.AbsoluteSize
        return {
            X = math.floor(position.X + .5), Y = math.floor(position.Y + .5),
            Width = math.max(0, math.floor(size.X + .5)),
            Height = math.max(0, math.floor(size.Y + .5)),
        }
    end

    local function clipRect(a, b)
        local left = math.max(a.X, b.X)
        local top = math.max(a.Y, b.Y)
        local right = math.min(a.X + a.Width, b.X + b.Width)
        local bottom = math.min(a.Y + a.Height, b.Y + b.Height)
        return {
            X = left, Y = top,
            Width = math.max(0, right - left),
            Height = math.max(0, bottom - top),
        }
    end

    local function inspectNode(hub, node)
        if not node or not node.Parent or not node:IsA("GuiObject")
            or not node:IsDescendantOf(hub.Gui) then return nil end
        local position = rectFor(node)
        local hitbox = copySnapshot(position)
        local clippedBy = {}
        local effectivelyVisible = node.Visible
        local cursor = node.Parent
        while cursor and cursor ~= hub.Gui do
            if cursor:IsA("GuiObject") then
                effectivelyVisible = effectivelyVisible and cursor.Visible
                if cursor.ClipsDescendants then
                    position = clipRect(position, rectFor(cursor))
                    table.insert(clippedBy, cursor.Name)
                end
            end
            cursor = cursor.Parent
        end
        if hub.Gui:IsA("ScreenGui") then
            effectivelyVisible = effectivelyVisible and hub.Gui.Enabled
        end
        local tokens = {}
        for _, entry in hub._tokenBindings and hub._tokenBindings[node] or {} do
            tokens[#tokens + 1] = {
                Property = entry.Property, Path = entry.Path,
                Overridden = hub:HasTokenOverride(entry.Path),
            }
        end
        table.sort(tokens, function(a, b)
            return a.Property < b.Property
        end)
        local state = hub._tokenStateBindings and hub._tokenStateBindings[node]
        return {
            Name = node.Name, Class = node.ClassName,
            Path = describe(node).Path,
            Parent = node.Parent and node.Parent.Name or "",
            ZIndex = node.ZIndex, Visible = node.Visible,
            EffectiveVisible = effectivelyVisible,
            Hitbox = hitbox, EffectiveHitbox = position,
            FullyClipped = effectivelyVisible and (position.Width == 0 or position.Height == 0),
            ClippedBy = clippedBy, TokenBindings = tokens,
            TokenState = state and state.Connected and state.State or nil,
        }
    end

    -- Visit descendants in Roblox's child order without eagerly flattening
    -- the whole GUI tree. The visitor can stop as soon as a limit is reached;
    -- excluded Inspector subtrees are never allocated or traversed.
    local function visitDescendants(root, visitor, skip)
        local stack = { { Children = root:GetChildren(), Index = 0 } }
        while #stack > 0 do
            local frame = stack[#stack]
            frame.Index += 1
            local node = frame.Children[frame.Index]
            if not node then
                stack[#stack] = nil
            elseif not skip or not skip(node) then
                if visitor(node) then return true end
                local children = node:GetChildren()
                if #children > 0 then
                    stack[#stack + 1] = { Children = children, Index = 0 }
                end
            end
        end
        return false
    end

    local function skipInspectorBranch(hub, node)
        local active = hub._visualInspector
        if not active or active.Destroyed then return false end
        return node == active.Highlight
            or (active.Window and node == active.Window.Layer)
    end

    -- Report contains only primitive values and detached Lua tables. No Instance
    -- or handler references escape; callers may JSON-encode or edit the result.
    function Hub:GetVisualTreeSnapshot(options)
        if self._destroyed or not self.Gui then return nil, "hub destroyed" end
        options = type(options) == "table" and options or {}
        local limit = tonumber(options.MaxNodes) or 250
        if limit ~= limit then limit = 250 end
        limit = math.clamp(math.floor(limit), 1, 1000)
        local filter = string.lower(tostring(options.Filter or ""))
        local includeHidden = options.IncludeHidden == true
        local nodes, truncated, matched = {}, false, 0
        visitDescendants(self.Gui, function(node)
            if node:IsA("GuiObject")
                and (filter == "" or string.find(
                    string.lower(node.Name), filter, 1, true))
                and (includeHidden or node.Visible) then
                matched += 1
                if #nodes >= limit then
                    truncated = true
                    return true -- the (limit + 1)th match confirms truncation
                end
                local record = inspectNode(self, node)
                if record then nodes[#nodes + 1] = record end
            end
            return false
        end, function(node)
            return skipInspectorBranch(self, node)
        end)
        return {
            Version = 1, MaxNodes = limit, Truncated = truncated,
            MatchedAtLeast = matched, Nodes = nodes,
        }
    end

    function Hub:CaptureDeveloperReport(options)
        if self._destroyed then return nil, "hub destroyed" end
        local tree, reason = self:GetVisualTreeSnapshot(options)
        if not tree then return nil, reason end
        return {
            Version = 1, Time = os.clock(),
            Tree = tree,
            Stats = self:GetDeveloperStats(),
            Resources = self:GetDeveloperResourceSnapshot(),
            Diagnostics = self:GetDeveloperDiagnostics(),
            Extensions = self:ListExtensions(),
            Components = self:ListComponents(),
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
            Description = "只读结构 · 命中区域 · 裁剪 · Token",
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
        local infoRow = right:_row(290, "InspectorPropertyPanel")
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
            local spatial = inspectNode(hub, node)
            if not spatial then return end
            data.Hitbox = copySnapshot(spatial.Hitbox)
            data.EffectiveHitbox = copySnapshot(spatial.EffectiveHitbox)
            data.FullyClipped = spatial.FullyClipped
            data.EffectiveVisible = spatial.EffectiveVisible
            data.ClippedBy = copySnapshot(spatial.ClippedBy)
            data.TokenBindings = copySnapshot(spatial.TokenBindings)
            data.TokenState = spatial.TokenState
            inspector.Snapshot = data
            info.Text = string.format(
                "%s [%s]\n%s\n\n位置: %s\n尺寸: %s\nZIndex: %d\n可见: %s\n背景: %s\n透明度: %.2f",
                data.Name, data.Class, data.Path,
                data.Position, data.Size, data.ZIndex, tostring(data.Visible),
                data.Background, data.BackgroundTransparency)
            local tokenDetails = {}
            for index, binding in spatial.TokenBindings do
                if index > 4 then break end
                tokenDetails[#tokenDetails + 1] = binding.Property .. " ← " .. binding.Path
                    .. (binding.Overridden and " (override)" or "")
            end
            info.Text ..= "\n触控框: " .. spatial.Hitbox.Width .. " × " .. spatial.Hitbox.Height
                .. "\n裁剪后: " .. spatial.EffectiveHitbox.Width .. " × "
                .. spatial.EffectiveHitbox.Height
                .. "\n裁剪父级: " .. (#spatial.ClippedBy > 0 and table.concat(spatial.ClippedBy, ", ") or "无")
                .. "\nToken: " .. (#tokenDetails > 0 and table.concat(tokenDetails, "; ") or "无直接绑定")
                .. "\n诊断数: " .. #hub:GetDeveloperDiagnostics()
            local origin = hub.Gui.AbsolutePosition
            local scale = math.max(hub._scale or 1, .01)
            local bounds = spatial.EffectiveHitbox
            highlight.Position = UDim2.fromOffset(
                (bounds.X - origin.X) / scale, (bounds.Y - origin.Y) / scale)
            highlight.Size = UDim2.fromOffset(
                bounds.Width / scale, bounds.Height / scale)
            highlight.Visible = spatial.EffectiveVisible and bounds.Width > 0
                and bounds.Height > 0 and win.IsOpen
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
            -- Parent clipping and visibility can change without the selected
            -- node moving. Subscribe only while an Inspector target is selected.
            local ancestor = node.Parent
            while ancestor and ancestor ~= hub.Gui do
                if ancestor:IsA("GuiObject") then
                    for _, property in { "AbsolutePosition", "AbsoluteSize",
                        "Visible", "ClipsDescendants" } do
                        targetConnections[#targetConnections + 1] =
                            ancestor:GetPropertyChangedSignal(property):Connect(update)
                    end
                end
                ancestor = ancestor.Parent
            end
            update()
            return true
        end
        function inspector:GetSnapshot()
            if self.Destroyed or not self.Snapshot then return nil end
            return copySnapshot(self.Snapshot)
        end
        function inspector:ExportTree(snapshotOptions)
            if self.Destroyed then return nil, "inspector destroyed" end
            return hub:GetVisualTreeSnapshot(snapshotOptions)
        end
        function inspector:ExportReport(snapshotOptions)
            if self.Destroyed then return nil, "inspector destroyed" end
            return hub:CaptureDeveloperReport(snapshotOptions)
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
            visitDescendants(hub.Gui, function(node)
                if node:IsA("GuiObject") and node.Visible
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
                    if index >= math.clamp(tonumber(options.Limit) or 80, 8, 150) then
                        return true
                    end
                end
                return false
            end, function(node)
                return node == win.Layer or node == highlight
            end)
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
