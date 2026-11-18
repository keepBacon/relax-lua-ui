-- SPDX-License-Identifier: MPL-2.0
-- Exactly two navigation levels; no secondary navigation tweens or transitions.
-- SubTab objects use Tab's existing Section/controls implementation.
local SUBTAB_TILE = 32
local SUBTAB_STEP = 38

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
    -- The parent page is the optional "All" content; each child has its own page.
    tab.Page.Visible = self._open == tab and sub == nil
    for _, item in tab.SubTabs or {} do
        item.Page.Visible = self._open == tab and item == sub
        if item.Tile then
            item.Tile.BackgroundTransparency = item == sub and 0 or 1
            if item.TileIcon then
                item.TileIcon.ImageColor3 = item == sub and self.Theme.Text or self.Theme.SubText
            elseif item.TileText then
                item.TileText.TextColor3 = item == sub and self.Theme.Text or self.Theme.SubText
            end
        end
    end
    if tab._allSubTile then
        tab._allSubTile.BackgroundTransparency = sub == nil and 0 or 1
    end
    if self._open == tab then
        self:_updateTabHeader(tab)
        nextPage.Scroll.CanvasPosition = Vector2.zero
        self:_fitPanel(tab, false)
    end
    return true
end

function Hub:_closeSubTabs()
    if not self._subTabRailVisible then return end
    self._subTabRailVisible = false
    self._subTabParent = nil
    if self._subTabRail then self._subTabRail.Visible = false end
    if self._subTabFrost then self._subTabFrost.Visible = false end
    self.Tooltip.Visible = false
end

function Hub:_positionSubTabs()
    local tab = self._subTabParent
    local rail = self._subTabRail
    if not tab or not rail or not rail.Visible or not tab.Tile.Parent then return end
    local count = #tab.SubTabs + ((#tab.Sections > 0) and 1 or 0)
    local natural = 10 + count * SUBTAB_STEP
    local dockWidth = self.Dock.AbsoluteSize.X / self._scale
    local maxWidth = math.max(48, dockWidth - 14)
    local width = math.min(natural, maxWidth)
    rail.Size = UDim2.fromOffset(width, 40)
    local scroll = self._subTabScroll
    scroll.CanvasSize = UDim2.fromOffset(natural, 0)
    local p, size = tab.Tile.AbsolutePosition, tab.Tile.AbsoluteSize
    local view = viewport() / self._scale
    local center = (p.X + size.X / 2) / self._scale
    center = math.clamp(center, width / 2 + 8, math.max(width / 2 + 8, view.X - width / 2 - 8))
    local bottom = math.max(44, p.Y / self._scale - 8)
    rail.Position = UDim2.fromOffset(center, bottom)
end

function Hub:_ensureSubTabUI()
    if self._subTabRail then return end
    local theme = self.Theme
    local frost = create("TextButton", {
        Name = "SubTabPanelFrost", Text = "", AutoButtonColor = false,
        BackgroundColor3 = themeColor(theme, "Panel"),
        BackgroundTransparency = 0.37,
        Size = UDim2.fromScale(1, 1), ZIndex = 25,
        Visible = false, Parent = self.PanelHolder,
    }, { corner(14) })
    -- Static frosted overlay, not global Lighting.BlurEffect (which blurs the game).
    local veil = create("Frame", {
        Name = "SubTabFrostVeil", BackgroundColor3 = themeColor(theme, "Scrim"),
        BackgroundTransparency = 0.66, Size = UDim2.fromScale(1, 1),
        ZIndex = 26, Parent = frost,
    }, { corner(14) })
    self:_connect(frost.MouseButton1Click, function() self:_closeSubTabs() end)
    self._subTabFrost = frost

    local rail = create("Frame", {
        Name = "SubTabRail", BackgroundColor3 = themeColor(theme, "Panel"),
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromOffset(160, 40),
        Position = UDim2.fromOffset(0, 0),
        ZIndex = 42, Visible = false,
        Parent = self.Gui,
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
    self._subTabRail = rail
    self._subTabScroll = scroll
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
    for _, child in self._subTabParent and self._subTabParent.SubTabs or {} do
        child.Tile.Parent = self._subTabStorage
    end
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
            self:_connect(all.MouseButton1Click, function()
                self:_setSubTab(tab, nil)
            end)
        end
        tab._allSubTile.Parent = self._subTabScroll
    end
    for _, child in tab.SubTabs do
        child.Tile.Parent = self._subTabScroll
    end
    self._subTabParent = tab
    self._subTabRailVisible = true
    self._subTabFrost.Visible = true
    self._subTabRail.Visible = true
    self.Tooltip.Visible = false
    self:_setSubTab(tab, tab.ActiveSubTab)
    self:_positionSubTabs()
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
    hub:_record(self, "SubTab", options, child)
    return child
end
