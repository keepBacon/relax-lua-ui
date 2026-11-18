-- SPDX-License-Identifier: MPL-2.0
-- Animated two-level navigation anchored to the active primary Dock icon.
-- SubTab objects use Tab's existing Section/controls implementation.
local SUBTAB_TILE = 32
local SUBTAB_STEP = 38
local SUBTAB_GAP = 3
local SUBTAB_RISE = 7
local SUBTAB_APPEAR = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SUBTAB_DISMISS = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local SUBTAB_SELECT = TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function Hub:_contentTab(tab)
    return tab and (tab.ActiveSubTab or tab) or nil
end

function Hub:_updateTabHeader(tab)
    local current = self:_contentTab(tab)
    local caption = current and current.IsSubTab and current.Name
        or (tab and tab.Description) or ""
    self.HeaderSub.Text = caption
    self.HeaderSub.Visible = not self.Search.Visible and caption ~= ""
    self.HeaderTitle.Position = UDim2.fromOffset(44, caption ~= "" and 12 or 20)
end

function Hub:_setSubTab(tab, sub)
    if self._destroyed or not tab or tab.IsSubTab then return false end
    if sub and sub.ParentTab ~= tab then return false end
    local old = self:_contentTab(tab)
    tab.ActiveSubTab = sub
    local nextPage = self:_contentTab(tab)
    if old and old ~= nextPage then old.Page.Visible = false end
    tab.Page.Visible = self._open == tab and sub == nil
    local animate = self._subTabRailVisible and self._subTabParent == tab
    for _, item in tab.SubTabs or {} do
        item.Page.Visible = self._open == tab and item == sub
        if item.Tile then
            local selected = item == sub
            local background = selected and 0 or 1
            local foreground = selected and self.Theme.Text or self.Theme.SubText
            if animate then
                tween(item.Tile, SUBTAB_SELECT, { BackgroundTransparency = background })
                if item.TileIcon then
                    tween(item.TileIcon, SUBTAB_SELECT, { ImageColor3 = foreground })
                elseif item.TileText then
                    tween(item.TileText, SUBTAB_SELECT, { TextColor3 = foreground })
                end
            else
                item.Tile.BackgroundTransparency = background
                if item.TileIcon then item.TileIcon.ImageColor3 = foreground end
                if item.TileText then item.TileText.TextColor3 = foreground end
            end
        end
    end
    if tab._allSubTile then
        local selected = sub == nil
        if animate then
            tween(tab._allSubTile, SUBTAB_SELECT, { BackgroundTransparency = selected and 0 or 1 })
        else
            tab._allSubTile.BackgroundTransparency = selected and 0 or 1
        end
    end
    if self._open == tab then
        self:_updateTabHeader(tab)
        if old ~= nextPage then nextPage.Scroll.CanvasPosition = Vector2.zero end
        self:_fitPanel(tab, false)
    end
    return true
end

function Hub:_closeSubTabs()
    if not self._subTabRailVisible then return end
    self._subTabRailVisible = false
    self._subTabParent = nil
    self._subTabMotionId = (self._subTabMotionId or 0) + 1
    local motionId = self._subTabMotionId
    local rail, frost, veil = self._subTabRail, self._subTabFrost, self._subTabVeil
    if not rail or not frost then return end
    self.Tooltip.Visible = false
    frost.Active = false
    local target = self._subTabTarget or rail.Position
    tween(rail, SUBTAB_DISMISS, {
        GroupTransparency = 1,
        Position = target + UDim2.fromOffset(0, SUBTAB_RISE),
    })
    tween(frost, SUBTAB_DISMISS, { BackgroundTransparency = 1 })
    if veil then tween(veil, SUBTAB_DISMISS, { BackgroundTransparency = 1 }) end
    -- Only the newest close request may hide these layers.
    task.delay(SUBTAB_DISMISS.Time + 0.02, function()
        if self._destroyed or self._subTabMotionId ~= motionId then return end
        rail.Visible = false
        frost.Visible = false
    end)
end

function Hub:_positionSubTabs()
    local tab, rail = self._subTabParent, self._subTabRail
    if not self._subTabRailVisible or not tab or not rail or not tab.Tile.Parent then return end
    -- Tile AbsolutePosition is physical screen pixels; root UIScale offsets are logical pixels.
    local scale = math.max(self._scale or 1, 0.01)
    local count = #tab.SubTabs + ((#tab.Sections > 0) and 1 or 0)
    local natural = 10 + count * SUBTAB_STEP
    local dockWidth = self.Dock.AbsoluteSize.X / scale
    local width = math.min(natural, math.max(48, dockWidth - 14))
    local p, size = tab.Tile.AbsolutePosition, tab.Tile.AbsoluteSize
    local view = viewport() / scale
    local center = (p.X + size.X * 0.5) / scale
    center = math.clamp(center, width * 0.5 + 5, math.max(width * 0.5 + 5, view.X - width * 0.5 - 5))
    local tileTop = p.Y / scale
    local bottom = math.max(41, tileTop - SUBTAB_GAP)
    local target = UDim2.fromOffset(math.floor(center + 0.5), math.floor(bottom + 0.5))
    self._subTabTarget = target
    rail.Size = UDim2.fromOffset(width, 40)
    self._subTabScroll.CanvasSize = UDim2.fromOffset(natural, 0)
    if not self._subTabAnimating then rail.Position = target end
end

function Hub:_ensureSubTabUI()
    if self._subTabRail then return end
    local theme = self.Theme
    local frost = create("TextButton", {
        Name = "SubTabPanelFrost", Text = "", AutoButtonColor = false,
        BackgroundColor3 = themeColor(theme, "Panel"),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 25,
        Visible = false, Parent = self.PanelHolder,
    }, { corner(14) })
    -- UI-only scrim, rather than a global Lighting blur affecting the game.
    local veil = create("Frame", {
        Name = "SubTabFrostVeil", BackgroundColor3 = themeColor(theme, "Scrim"),
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        ZIndex = 26, Parent = frost,
    }, { corner(14) })
    self:_connect(frost.MouseButton1Click, function() self:_closeSubTabs() end)
    self._subTabFrost, self._subTabVeil = frost, veil

    -- CanvasGroup opacity composites the icon row; the glyphs never scale.
    local rail = create("CanvasGroup", {
        Name = "SubTabRail", BackgroundColor3 = themeColor(theme, "Panel"),
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromOffset(160, 40),
        Position = UDim2.fromOffset(0, 0),
        GroupTransparency = 1,
        ZIndex = 42, Visible = false, Parent = self.Gui,
    }, { corner(10), stroke(themeColor(theme, "PanelStroke"), 1) })
    local scroll = create("ScrollingFrame", {
        Name = "SubTabItems", BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(5, 4),
        Size = UDim2.new(1, -10, 1, -8),
        ZIndex = 43, Parent = rail,
    }, { list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
    self._subTabRail, self._subTabScroll = rail, scroll
    self._subTabStorage = Instance.new("Folder")
    self._subTabStorage.Name = "SubTabStorage"
    self._subTabStorage.Parent = self.Gui
    self:_connect(self.Dock:GetPropertyChangedSignal("AbsoluteSize"), function()
        if self._subTabRailVisible then self:_positionSubTabs() end
    end)
    self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
        if self._subTabRailVisible then self:_positionSubTabs() end
    end)
end

function Hub:_toggleSubTabs(tab)
    if self._destroyed or self._open ~= tab or #(tab.SubTabs or {}) == 0 then return end
    if self._subTabRailVisible and self._subTabParent == tab then
        self:_closeSubTabs()
        return
    end
    self:_closeSubTabs()
    self:_ensureSubTabUI()
    for _, tile in self._subTabScroll:GetChildren() do
        if tile:IsA("TextButton") then tile.Parent = self._subTabStorage end
    end
    if #tab.Sections > 0 then
        if not tab._allSubTile then
            local all = create("TextButton", {
                Name = "All", Text = "All", TextSize = 10,
                FontFace = inter(Enum.FontWeight.Medium),
                TextColor3 = themeColor(self.Theme, "Text"),
                BackgroundColor3 = themeColor(self.Theme, "TileActive"),
                AutoButtonColor = false,
                Size = UDim2.fromOffset(SUBTAB_TILE, SUBTAB_TILE),
                ZIndex = 44, Parent = self._subTabStorage,
            }, { corner(8) })
            tab._allSubTile = all
            self:_connect(all.MouseButton1Click, function() self:_setSubTab(tab, nil) end)
        end
        tab._allSubTile.Parent = self._subTabScroll
    end
    for _, child in tab.SubTabs do child.Tile.Parent = self._subTabScroll end
    self._subTabParent = tab
    self._subTabRailVisible = true
    self._subTabMotionId = (self._subTabMotionId or 0) + 1
    local motionId = self._subTabMotionId
    local rail, frost, veil = self._subTabRail, self._subTabFrost, self._subTabVeil
    self._subTabAnimating = true
    rail.Visible = true
    frost.Visible = true
    frost.Active = true
    self.Tooltip.Visible = false
    self:_positionSubTabs()
    local target = self._subTabTarget
    -- A seven-pixel rise and quintic fade, without resizing glyphs or the main panel.
    rail.Position = target + UDim2.fromOffset(0, SUBTAB_RISE)
    rail.GroupTransparency = 1
    frost.BackgroundTransparency = 1
    veil.BackgroundTransparency = 1
    self:_setSubTab(tab, tab.ActiveSubTab)
    tween(rail, SUBTAB_APPEAR, { GroupTransparency = 0, Position = target })
    tween(frost, SUBTAB_APPEAR, { BackgroundTransparency = 0.37 })
    tween(veil, SUBTAB_APPEAR, { BackgroundTransparency = 0.66 })
    task.delay(SUBTAB_APPEAR.Time + 0.02, function()
        if self._destroyed or self._subTabMotionId ~= motionId then return end
        self._subTabAnimating = false
        if self._subTabRailVisible then self:_positionSubTabs() end
    end)
end

function Tab:SubTab(options)
    assert(not self.IsSubTab, "SubTab only supports two navigation levels")
    options = type(options) == "table" and options or { Name = tostring(options) }
    local hub = self.Hub
    local theme = hub.Theme
    self.SubTabs = self.SubTabs or {}
    local name = options.Name or ("SubTab " .. tostring(#self.SubTabs + 1))
    for _, existing in self.SubTabs do
        assert(existing.Name ~= name, "duplicate SubTab name: " .. tostring(name))
    end
    hub:_ensureSubTabUI()
    local child = setmetatable({
        Hub = hub, ParentTab = self, IsSubTab = true,
        Name = name, Description = options.Description, Icon = options.Icon,
        Sections = {}, Requires = mergedRequirements(self.Requires, options.Requires),
        _internal = options._internal or self._internal,
        _count = 0,
    }, Tab)

    local tile = create("TextButton", {
        Name = "SubTile_" .. name,
        Text = "", AutoButtonColor = false,
        BackgroundColor3 = themeColor(theme, "TileActive"),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(SUBTAB_TILE, SUBTAB_TILE),
        LayoutOrder = #self.SubTabs + 1,
        ZIndex = 44, Parent = hub._subTabStorage,
    }, { corner(8) })
    child.Tile = tile
    child.TileIcon = iconLabel(child.Icon, 16, theme.SubText, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ZIndex = 45, Parent = tile,
    })
    if not child.TileIcon then
        child.TileText = text({
            Parent = tile, Text = string.sub(name, 1, 2),
            TextSize = 12, TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.fromScale(1, 1), ZIndex = 45,
        })
    end
    hub:_connect(tile.MouseButton1Click, function()
        -- Selecting a child does not dismiss the secondary rail.
        hub:_setSubTab(self, child)
    end)
    local page = create("Frame", {
        Name = "SubPage_" .. name, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), Visible = false, Parent = hub.Pages,
    })
    local scroll = create("ScrollingFrame", {
        Name = "Scroll", BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        ScrollBarImageTransparency = .4,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = page,
    })
    local columns = create("Frame", {
        Name = "Columns", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = scroll,
    }, { padding(10, 16, 12, 16) })
    local function column(side)
        return create("Frame", {
            Name = side == 0 and "Left" or "Right",
            BackgroundTransparency = 1,
            Position = UDim2.new(side * .5, side == 0 and 0 or 9, 0, 0),
            Size = UDim2.new(.5, -9, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = columns,
        }, { list(Enum.FillDirection.Vertical, 10) })
    end
    child.Page, child.Scroll = page, scroll
    child.Columns = { column(0), column(1), Frame = columns }
    hub:_connect(columns:GetPropertyChangedSignal("AbsoluteSize"), function()
        if hub._open == self and self.ActiveSubTab == child then
            hub:_requestPanelFit()
        end
    end)
    table.insert(self.SubTabs, child)
    if not self.ActiveSubTab then self.ActiveSubTab = child end
    if hub._open == self then hub:_setSubTab(self, self.ActiveSubTab) end
    if not self._subTabLayoutConn then
        self._subTabLayoutConn = hub:_connect(self.Tile:GetPropertyChangedSignal("AbsolutePosition"), function()
            if hub._subTabRailVisible and hub._subTabParent == self then hub:_positionSubTabs() end
        end)
    end
    hub:_record(self, "SubTab", options, child)
    return child
end
