-- RelaxUI first-run navigation tour. Separate from the configuration/compatibility wizard.
-- Opt-in with CreateHub({ NavigationGuide = true }); never blocks ordinary third-party hubs.
function Hub:_showNavigationGuideOnce()
    if self._destroyed or self._guideOpen or self._setupOpen
        or self.Options.NavigationGuide ~= true or self._replaying then return false end
    if self._guideSeen or (self.SetupData and self.SetupData.NavigationGuideSeen) then return false end
    local top = self:_overlayTop()
    if top and top.Modal then return false end
    return self:OpenNavigationGuide()
end

function Hub:OpenNavigationGuide()
    if self._destroyed or self._guideOpen or self._setupOpen or self._loading then return false end
    local existing = self:_overlayTop()
    if existing and existing.Modal then return false end
    self:CloseCommandPalette(true)
    self:_closePopup()
    self:_closeSubTabs()

    local firstTab, subTabParent
    for _, tab in self.Tabs do
        if not tab._internal then
            firstTab = firstTab or tab
            if not subTabParent and #(tab.SubTabs or {}) > 0 then subTabParent = tab end
        end
    end
    local steps = {
        { Name = "底部导航", Text = "底部 Dock 用来切换功能页面。点击图标即可进入对应分页。", Target = self.Dock },
    }
    if firstTab and firstTab.Tile then
        table.insert(steps, { Name = "一级分页", Text = "点击功能图标打开对应面板，再次点击可关闭或切换。", Target = firstTab.Tile })
    end
    if subTabParent then
        table.insert(steps, { Name = "二级分页", Text = "再次点击带有子页面的一级图标，可以展开二级分页；选择子项进入具体内容。", Target = subTabParent.Tile })
    end
    if self.CommandButton then
        table.insert(steps, { Name = "搜索与命令", Text = "使用放大镜快速查找控件、页面和命令，无需逐页翻找。", Target = self.CommandButton })
    end
    if self.SettingsTab and self.SettingsTab.Tile then
        table.insert(steps, { Name = "设置", Text = "这里可以修改主题、动画、语言和配置，并重新打开导航引导。", Target = self.SettingsTab.Tile })
    end
    if self.Restore and UserInputService.TouchEnabled then
        table.insert(steps, { Name = "悬浮入口", Text = "点击 Graphite 悬浮按钮隐藏或恢复工具栏；长按 1 秒可拖动，位置会保存。", Target = self.Restore })
    end
    if #steps == 0 then return false end

    local theme = self.Theme
    local layer = create("Frame", {
        Name = "NavigationGuide", BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = .55, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ZIndex = 102, Active = true,
        Parent = self.Gui,
    })
    local outline = create("Frame", {
        Name = "NavigationTarget", BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 103, Parent = layer,
    }, { corner(10), stroke(themeColor(theme, "Accent"), 1.8, .05) })
    local card = create("Frame", {
        Name = "NavigationCard", BackgroundColor3 = themeColor(theme, "Panel"),
        BorderSizePixel = 0, Size = UDim2.fromOffset(290, 174),
        ZIndex = 104, Parent = layer,
    }, { corner(12), stroke(themeColor(theme, "PanelStroke"), 1, .08) })
    local progress = create("TextLabel", {
        Name = "Progress", BackgroundTransparency = 1, Text = "",
        FontFace = inter(Enum.FontWeight.Medium), TextSize = 11,
        TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 16),
        ZIndex = 105, Parent = card,
    })
    local heading = create("TextLabel", {
        Name = "Heading", BackgroundTransparency = 1, Text = "",
        FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 17,
        TextColor3 = themeColor(theme, "Text"), TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(16, 33), Size = UDim2.new(1, -32, 0, 26),
        ZIndex = 105, Parent = card,
    })
    local description = create("TextLabel", {
        Name = "Description", BackgroundTransparency = 1, Text = "",
        FontFace = inter(), TextSize = 12, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = themeColor(theme, "SubText"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(16, 66), Size = UDim2.new(1, -32, 0, 53),
        ZIndex = 105, Parent = card,
    })
    local function action(name, label, width, right, primary)
        return create("TextButton", {
            Name = name, Text = label, AutoButtonColor = false, BorderSizePixel = 0,
            BackgroundColor3 = primary and themeColor(theme, "Accent") or themeColor(theme, "Tile"),
            BackgroundTransparency = primary and 0 or .08,
            TextColor3 = primary and themeColor(theme, "AccentText") or themeColor(theme, "SubText"),
            FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -right, 1, -14),
            Size = UDim2.fromOffset(width, 32), ZIndex = 105, Parent = card,
        }, { corner(8) })
    end
    local skip = action("Skip", "跳过", 52, 234, false)
    local back = action("Back", "上一步", 74, 94, false)
    local advance = action("Next", "下一步", 80, 14, true)
    local connections, stepIndex, closed = {}, 1, false
    local targetConnections = {}
    local function connect(signal, fn, list)
        table.insert(list or connections, signal:Connect(fn))
    end
    local function disconnect(list)
        for _, conn in list do conn:Disconnect() end
        table.clear(list)
    end
    self._guideOpen = true
    self._navigationGuide = layer
    self:_overlayRegister("NavigationGuide", layer, {
        Content = card, Modal = true, Escape = false, Outside = false,
    })

    local function close(remember)
        if closed then return end
        closed = true
        disconnect(targetConnections)
        disconnect(connections)
        self:_overlayUnregister("NavigationGuide", layer)
        self._guideOpen = false
        self._navigationGuide = nil
        if remember and not self._destroyed then
            self._guideSeen = true
            self:_savePref("NavigationGuideSeen", true)
        end
        if layer.Parent then layer:Destroy() end
    end

    local function place()
        if closed or self._destroyed or not layer.Parent then return end
        local current = steps[stepIndex]
        local target = current and current.Target
        local scale = math.max(self._scale or 1, .01)
        local available = viewport() / scale
        local width = math.max(220, math.min(290, available.X - 24))
        local height = math.min(174, available.Y - 24)
        card.Size = UDim2.fromOffset(width, height)
        if target and target.Parent then
            local targetPos = target.AbsolutePosition / scale
            local targetSize = target.AbsoluteSize / scale
            outline.Visible = true
            outline.Position = UDim2.fromOffset(targetPos.X - 4, targetPos.Y - 4)
            outline.Size = UDim2.fromOffset(targetSize.X + 8, targetSize.Y + 8)
            local cx = math.clamp(targetPos.X + targetSize.X / 2 - width / 2,
                12, math.max(12, available.X - width - 12))
            local below = targetPos.Y + targetSize.Y + 18
            local above = targetPos.Y - height - 18
            local cy = below + height <= available.Y - 12 and below or above
            cy = math.clamp(cy, 12, math.max(12, available.Y - height - 12))
            card.Position = UDim2.fromOffset(cx, cy)
        else
            outline.Visible = false
            card.Position = UDim2.fromOffset(
                math.max(12, (available.X - width) / 2),
                math.max(12, (available.Y - height) / 2))
        end
    end
    local function show(index)
        if closed then return end
        stepIndex = index
        disconnect(targetConnections)
        local info = steps[index]
        progress.Text = string.format("NAVIGATION  ·  %d / %d", index, #steps)
        heading.Text = info.Name
        description.Text = info.Text
        back.Visible = index > 1
        advance.Text = index == #steps and "完成" or "下一步"
        local target = info.Target
        if target and target.Parent then
            connect(target:GetPropertyChangedSignal("AbsolutePosition"), place, targetConnections)
            connect(target:GetPropertyChangedSignal("AbsoluteSize"), place, targetConnections)
        end
        place()
    end
    connect(advance.MouseButton1Click, function()
        if stepIndex < #steps then show(stepIndex + 1) else close(true) end
    end)
    connect(back.MouseButton1Click, function()
        if stepIndex > 1 then show(stepIndex - 1) end
    end)
    connect(skip.MouseButton1Click, function() close(true) end)
    connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), place)
    connect(self.UIScale:GetPropertyChangedSignal("Scale"), place)
    connect(layer.Destroying, function() close(false) end)
    show(1)
    task.defer(place)
    return true
end
