-- SPDX-License-Identifier: MPL-2.0
-- Real first-level Dock grouping. Each group owns a horizontal layout container;
-- separators belong to the Dock rather than masquerading as tabs.
local DockTabGroup = {}
DockTabGroup.__index = DockTabGroup

function DockTabGroup:Tab(options)
    options = type(options) == "table" and table.clone(options) or { Name = tostring(options) }
    options.Group = self.Name
    return self.Hub:Tab(options)
end

function DockTabGroup:SetOrder(order)
    assert(type(order) == "number", "TabGroup order must be a number")
    self.Order = order
    self.Frame.LayoutOrder = order
    if self.Separator then self.Separator.LayoutOrder = order - 1 end
end

function Hub:TabGroup(options)
    options = type(options) == "table" and options or { Name = tostring(options) }
    local name = options.Name
    assert(type(name) == "string" and name ~= "", "TabGroup requires a non-empty Name")
    self.DockGroups = self.DockGroups or {}
    local existing = self.DockGroups[name]
    if existing then
        assert(existing.Hub == self, "TabGroup belongs to another hub")
        return existing
    end
    local order = options.Order
    if order == nil then
        self._nextDockGroupOrder = (self._nextDockGroupOrder or 0) + 1
        order = self._nextDockGroupOrder * 100
    end
    assert(type(order) == "number", "TabGroup Order must be a number")
    local frame = create("Frame", {
        Name = "DockGroup_" .. name,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 40),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = order,
        ClipsDescendants = false,
        ZIndex = 3,
        Parent = self.Dock,
    }, { list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
    local group = setmetatable({
        Hub = self, Name = name, Order = order, Frame = frame, Tabs = {},
        _internal = options._internal == true,
    }, DockTabGroup)
    if options.Separator == true then
        group.Separator = create("Frame", {
            Name = "DockGroupSeparator_" .. name,
            BackgroundColor3 = themeColor(self.Theme, "TileStroke"),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(1, 24),
            LayoutOrder = order - 1,
            Parent = self.Dock,
        })
    end
    self.DockGroups[name] = group
    if not group._internal then
        self:_record(self, "TabGroup", {
            Name = name, Order = order, Separator = options.Separator == true,
        }, group)
    end
    return group
end
