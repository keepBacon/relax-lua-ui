-- SPDX-License-Identifier: MPL-2.0
-- Paginated data grid with key-stable updates and touch-friendly horizontal scroll.
local function complexRowCopy(row)
    local out = {}
    for key, value in row do
        if type(value) == "table" then out[key] = table.clone(value)
        else out[key] = value end
    end
    return out
end

local function complexRowSnapshot(rows)
    local out = {}
    for i, row in rows do out[i] = complexRowCopy(row) end
    return out
end

local function complexCellValue(row, col)
    local cells = row.Cells or row.Values
    if type(cells) == "table" then
        local value = cells[col.Key]
        if value == nil then value = cells[col.Index] end
        return value
    end
    local value = row[col.Key]
    if value == nil then value = row[col.Index] end
    return value
end

function Section:DataTable(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local columns = {}
    for i, option in options.Columns or {} do
        local col = type(option) == "string" and { Key = option, Title = option } or table.clone(option)
        col.Key = tostring(col.Key or col.Id or col.Name or i)
        col.Title = complexString(col.Title or col.Name or col.Key)
        col.Index = i
        col.Width = math.clamp(math.floor(tonumber(col.Width) or 110), 65, 420)
        col.Align = (col.Align == "Right" or col.Align == "Center") and col.Align or "Left"
        col.Sortable = col.Sortable ~= false
        table.insert(columns, col)
    end
    assert(#columns > 0 and #columns <= 16, "DataTable requires 1–16 columns")
    local pageSize = math.clamp(math.floor(tonumber(options.PageSize) or 10), 3, 40)
    local bodyHeight = math.clamp(pageSize * 31 + 12, 105, 400)
    local minWidth = 0
    for _, col in columns do minWidth += col.Width end
    local showTitle = options.Name ~= nil
    local headerY = showTitle and 26 or 0
    local row = self:_row(headerY + 31 + bodyHeight + 32, "DataTable_" .. (options.Name or ""))
    local c = self:_control("DataTable", options, row)
    local alive, entries, byId, visible, nodes = true, {}, {}, {}, {}
    local widgetConnections = {}
    local function connect(signal, fn)
        local conn = signal:Connect(fn)
        table.insert(widgetConnections, conn)
        return conn
    end
    local function disconnectWidget()
        for _, conn in widgetConnections do conn:Disconnect() end
        table.clear(widgetConnections)
    end
    c.Rows = {}
    c.Columns = complexCloneList(columns)
    c.SelectedId = nil
    function c:GetSelection() return self.SelectedId end
    c.Page = 1
    c.Sort = nil
    c.Query = ""
    c.Loading = false
    c.Error = nil
    c.LayoutMode = options.LayoutMode or "Auto"
    assert(c.LayoutMode == "Auto" or c.LayoutMode == "Table" or c.LayoutMode == "Cards", "DataTable layout must be Auto, Table or Cards")
    c.EffectiveLayout = "Table"
    if showTitle then
        text({ Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
            FontFace = inter(Enum.FontWeight.SemiBold), TextTruncate = Enum.TextTruncate.AtEnd,
            Size = UDim2.new(1, 0, 0, 22) })
    end
    local shell = create("Frame", {
        Name = "TableShell", Parent = row, Position = UDim2.fromOffset(0, headerY),
        Size = UDim2.new(1, 0, 0, 31 + bodyHeight),
        BackgroundColor3 = themeColor(theme, "Field"), BackgroundTransparency = .16,
        ClipsDescendants = true,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke"), 1, .34) })
    local horizontal = create("ScrollingFrame", {
        Name = "HorizontalScroll", Parent = shell,
        Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
        BackgroundTransparency = 1, ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.fromOffset(minWidth + 10, 0),
    })
    local wide = create("Frame", {
        Name = "WideContent", BackgroundTransparency = 1,
        Size = UDim2.new(0, minWidth + 10, 1, -4), Parent = horizontal,
    })
    local head = create("Frame", {
        Name = "ColumnHeaders", BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .48, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30),
        Parent = wide,
    })
    local scroll = create("ScrollingFrame", {
        Name = "TableRows", Parent = wide, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 31), Size = UDim2.new(1, 0, 0, bodyHeight - 3),
        ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.None,
    })
    -- Mobile cards use a dedicated, bounded row pool. The table view is
    -- preserved in place so switching modes never rebuilds the data model.
    -- Compact cards display more records without sacrificing scroll gestures.
    -- CardHeight is optional for hubs with unusually long cell content.
    -- Even an explicit CardHeight must leave one readable line per column.
    local cardMinHeight = math.max(52, 12 + #columns * 18)
    local cardHeight = math.clamp(math.floor(tonumber(options.CardHeight) or cardMinHeight), cardMinHeight, 360)
    local cardLineHeight = (cardHeight - 12) / #columns
    local cardTools = create("Frame", {
        Name = "CardTools", Parent = shell, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30), Visible = false,
    })
    local cardSort = create("TextButton", {
        Name = "CardSort", Parent = cardTools, Text = "Sort",
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .3, AutoButtonColor = false,
        TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
        Position = UDim2.fromOffset(5, 2), Size = UDim2.new(1, -65, 0, 26),
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, { corner(6) })
    local cardDirection = create("TextButton", {
        Name = "CardDirection", Parent = cardTools, Text = "↑",
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .3, AutoButtonColor = false,
        TextColor3 = themeColor(theme, "SubText"), TextSize = 13,
        Position = UDim2.new(1, -54, 0, 2), Size = UDim2.fromOffset(48, 26),
    }, { corner(6) })
    local cardScroll = create("ScrollingFrame", {
        Name = "CardRows", Parent = shell, BackgroundTransparency = 1,
        BorderSizePixel = 0, Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, bodyHeight - 3),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.new(), Visible = false,
    })
    local cardNodes = {}
    local touchStart, touchOrigin, touchMoved, touchBlockedUntil
    local function recordTouch(input)
        if input.UserInputType == Enum.UserInputType.Touch and not touchStart then
            touchStart = input
            touchOrigin = Vector2.new(input.Position.X, input.Position.Y)
            touchMoved = false
        end
    end
    -- Native scrolling remains active. Observe motion without capturing it
    -- so row taps are not fired after a drag or swipe.
    local function allowSelect()
        return touchStart == nil and (not touchBlockedUntil or os.clock() > touchBlockedUntil)
    end
    local status = text({
        Name = "EmptyState", Parent = shell, Text = options.EmptyText or "No data",
        TextSize = 12, TextColor3 = themeColor(theme, "Muted"),
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(4, headerY == -1 and 0 or 31),
        Size = UDim2.new(1, -8, 0, bodyHeight - 12), Visible = false,
    })
    local foot = create("Frame", {
        Name = "Pagination", Parent = row,
        Position = UDim2.fromOffset(0, headerY + bodyHeight + 32),
        Size = UDim2.new(1, 0, 0, 27), BackgroundTransparency = 1,
    })
    local info = text({
        Name = "PageInfo", Parent = foot, Text = "0 rows",
        TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -86, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local function pageButton(name, label, offset)
        return create("TextButton", {
            Name = name, Parent = foot, Text = label, AutoButtonColor = false,
            TextColor3 = themeColor(theme, "Text"), TextSize = 14,
            BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = .22,
            Position = UDim2.new(1, offset, 0, 0), Size = UDim2.fromOffset(38, 26),
        }, { corner(6) })
    end
    local back = pageButton("Previous", "‹", -81)
    local forward = pageButton("Next", "›", -39)
    local startX = 0
    for _, col in columns do
        local button = create("TextButton", {
            Name = "Sort_" .. col.Key, Parent = head, Text = col.Title,
            TextSize = 11, FontFace = inter(Enum.FontWeight.Medium),
            TextColor3 = themeColor(theme, col.Sortable and "Text" or "Muted"),
            TextXAlignment = col.Align == "Right" and Enum.TextXAlignment.Right
                or col.Align == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, AutoButtonColor = false,
            Position = UDim2.fromOffset(startX + 6, 0),
            Size = UDim2.fromOffset(col.Width - 10, 30),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        startX += col.Width
        connect(button.MouseButton1Click, function()
            if col.Sortable then
                local nextDesc = c.Sort and c.Sort.Key == col.Key and not c.Sort.Descending
                c:SetSort(col.Key, nextDesc)
            end
        end)
    end

    local function rowId(value, index)
        if type(value) ~= "table" then return tostring(index) end
        return tostring(value.Id or value.Key or value.ID or index)
    end
    local function sortRows()
        visible = {}
        local needle = string.lower(c.Query)
        for _, item in entries do
            if needle == "" then table.insert(visible, item)
            else
                local found = false
                for _, col in columns do
                    local raw = complexCellValue(item, col)
                    if string.find(string.lower(complexString(raw)), needle, 1, true) then
                        found = true
                        break
                    end
                end
                if found then table.insert(visible, item) end
            end
        end
        if c.Sort then
            local col
            for _, candidate in columns do
                if candidate.Key == c.Sort.Key then col = candidate; break end
            end
            if col then
                table.sort(visible, function(a, b)
                    local av, bv = complexCellValue(a, col), complexCellValue(b, col)
                    -- Compare homogeneous types consistently. Mixed values use a
                    -- stable type bucket so sort remains a strict weak ordering.
                    local left, right = tonumber(av), tonumber(bv)
                    local aNumeric = type(av) == "number" or type(av) == "string" and left ~= nil
                    local bNumeric = type(bv) == "number" or type(bv) == "string" and right ~= nil
                    if aNumeric ~= bNumeric then
                        return aNumeric -- numbers are always above non-numbers
                    end
                    if aNumeric and bNumeric and left ~= right then
                        if c.Sort.Descending then return left > right end
                        return left < right
                    end
                    local sa, sb = string.lower(complexString(av)), string.lower(complexString(bv))
                    if sa ~= sb and (not aNumeric or not bNumeric) then
                        if c.Sort.Descending then return sa > sb end
                        return sa < sb
                    end
                    return a._index < b._index
                end)
            end
        end
    end
    local function destroyNode(node)
        for _, connection in node.Connections do connection:Disconnect() end
        node.Frame:Destroy()
    end
    local function paintNode(node, item)
        local sameItem = node.Id == item.Id
        node.Id = item.Id
        node.Frame.Name = "TableRow_" .. item.Id
        local tone = c.SelectedId == item.Id and .32 or .91
        local motionKey = "table-row:" .. tostring(node.Frame)
        if sameItem and node._targetTone ~= tone then
            Motion.play(hub, motionKey, node.Frame, { BackgroundTransparency = tone }, Motion.Presets.Micro)
        elseif not sameItem then
            Motion.cancel(hub, motionKey)
            node.Frame.BackgroundTransparency = tone
        end
        node._targetTone = tone
        for index, col in columns do
            local value = complexCellValue(item, col)
            local printable = complexString(value)
            if type(col.Format) == "function" then
                local ok, formatted = pcall(col.Format, value, item)
                if ok then printable = complexString(formatted) end
            end
            node.Cells[index].Text = printable
            setThemed(node.Cells[index], "TextColor3",
                themeColor(theme, c.SelectedId == item.Id and "Text" or "SubText"))
        end
    end
    local function makeNode(slot)
        local frame = create("TextButton", {
            Name = "TableRow", Parent = scroll, Text = "", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "TileActive"),
            BackgroundTransparency = .91, Size = UDim2.new(1, -6, 0, 29),
            Position = UDim2.fromOffset(2, (slot - 1) * 31 + 2),
        }, { corner(4) })
        local cells, colX = {}, 0
        for i, col in columns do
            cells[i] = text({ Name = "Cell_" .. col.Key, Parent = frame, Text = "",
                TextSize = 11, TextColor3 = themeColor(theme, "SubText"),
                TextXAlignment = col.Align == "Right" and Enum.TextXAlignment.Right
                    or col.Align == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
                Position = UDim2.fromOffset(colX + 7, 0),
                Size = UDim2.fromOffset(col.Width - 12, 29),
                TextTruncate = Enum.TextTruncate.AtEnd })
            colX += col.Width
        end
        local node = { Frame = frame, Cells = cells, Connections = {} }
        table.insert(node.Connections, frame.InputBegan:Connect(recordTouch))
        table.insert(node.Connections, frame.MouseButton1Click:Connect(function()
            if node.Id and c:IsAvailable() and options.Selectable ~= false
                and allowSelect() then
                c:Select(node.Id)
            end
        end))
        nodes[slot] = node
        return node
    end
    local function newCardSlot(slotId)
        local frame = create("TextButton", {
            Name = "TableCard", Parent = cardScroll, Text = "", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "TileActive"),
            BackgroundTransparency = .91, Size = UDim2.new(1, -8, 0, cardHeight - 3),
        }, { corner(6) })
        local fields = {}
        for i, col in columns do
            text({ Parent = frame, Name = "FieldName_" .. col.Key,
                Text = col.Title, TextSize = 10,
                TextColor3 = themeColor(theme, "Muted"),
                Position = UDim2.fromOffset(9, 5 + (i - 1) * cardLineHeight),
                Size = UDim2.new(.43, -12, 0, 17),
                TextTruncate = Enum.TextTruncate.AtEnd })
            fields[i] = text({ Parent = frame, Name = "FieldValue_" .. col.Key,
                Text = "", TextSize = 11,
                TextColor3 = themeColor(theme, "Text"),
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(.43, 0, 0, 5 + (i - 1) * cardLineHeight),
                Size = UDim2.new(.57, -10, 0, 17),
                TextTruncate = Enum.TextTruncate.AtEnd })
        end
        local node = { Frame = frame, Fields = fields, Id = nil }
        node.TouchConnection = frame.InputBegan:Connect(recordTouch)
        node.Connection = frame.MouseButton1Click:Connect(function()
            if node.Id and c:IsAvailable() and options.Selectable ~= false
                and allowSelect() then
                c:Select(node.Id)
            end
        end)
        cardNodes[slotId] = node
        return node
    end
    local function render()
        if not alive or hub._destroyed then return end
        local pages = math.max(1, math.ceil(#visible / pageSize))
        c.Page = math.clamp(c.Page, 1, pages)
        local start = (c.Page - 1) * pageSize + 1
        local count = math.min(pageSize, #visible - start + 1)
        count = math.max(0, count)
        local compact = c.EffectiveLayout == "Cards"
        horizontal.Visible = not compact
        cardTools.Visible = compact
        cardScroll.Visible = compact
        local sortKey = c.Sort and c.Sort.Key
        cardSort.Text = sortKey and ("Sort: " .. sortKey) or "Sort: none"
        cardDirection.Text = c.Sort and (c.Sort.Descending and "↓" or "↑") or "↑"
        cardDirection.Active = c.Sort ~= nil
        cardDirection.TextTransparency = c.Sort and 0 or .6
        if compact then
            cardScroll.CanvasSize = UDim2.fromOffset(0, count * cardHeight + 10)
            local maxInView = math.min(pageSize, math.ceil((bodyHeight - 3) / cardHeight) + 2)
            local first = math.clamp(math.floor(cardScroll.CanvasPosition.Y / math.max(cardHeight * hub._scale, 1)) + 1,
                1, math.max(1, count - maxInView + 1))
            for slot = 1, math.max(#cardNodes, math.min(count, maxInView)) do
                local item = slot <= maxInView and visible[start + first + slot - 2] or nil
                local node = cardNodes[slot]
                if item and start + first + slot - 2 <= start + count - 1 then
                    if not node then node = newCardSlot(slot) end
                    local sameItem = node.Id == item.Id
                    node.Id = item.Id
                    node.Frame.Visible = true
                    node.Frame.Position = UDim2.fromOffset(3, (first + slot - 2) * cardHeight + 2)
                    local tone = c.SelectedId == item.Id and .34 or .91
                    local motionKey = "table-card:" .. tostring(node.Frame)
                    if sameItem and node._targetTone ~= tone then
                        Motion.play(hub, motionKey, node.Frame, { BackgroundTransparency = tone }, Motion.Presets.Micro)
                    elseif not sameItem then
                        Motion.cancel(hub, motionKey)
                        node.Frame.BackgroundTransparency = tone
                    end
                    node._targetTone = tone
                    for index, col in columns do
                        local value = complexCellValue(item, col)
                        local printable = complexString(value)
                        if type(col.Format) == "function" then
                            local ok, formatted = pcall(col.Format, value, item)
                            if ok then printable = complexString(formatted) end
                        end
                        node.Fields[index].Text = printable
                    end
                elseif node then
                    node.Id = nil
                    node.Frame.Visible = false
                end
            end
            for _, node in nodes do
                node.Id = nil
                node.Frame.Visible = false
            end
        else
            for _, node in cardNodes do node.Frame.Visible = false end
            for slot = 1, math.max(#nodes, count) do
                local node = nodes[slot]
                if slot <= count then
                    if not node then node = makeNode(slot) end
                    local item = visible[start + slot - 1]
                    node.Frame.Visible = true
                    paintNode(node, item)
                elseif node then
                    node.Id = nil
                    node.Frame.Visible = false
                end
            end
        end
        scroll.CanvasSize = UDim2.fromOffset(0, count * 31 + 10)
        status.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No data"))
        status.Visible = c.Error ~= nil or c.Loading or #visible == 0
        scroll.Visible = not status.Visible
        if status.Visible then cardScroll.Visible = false end
        info.Text = string.format("%d / %d   ·   page %d/%d", #visible, #entries, c.Page, pages)
        back.Active = c.Page > 1
        forward.Active = c.Page < pages
        -- Hide inert arrows for one-page datasets and return their width to info.
        back.Visible = pages > 1
        forward.Visible = pages > 1
        info.Size = UDim2.new(1, pages > 1 and -86 or 0, 1, 0)
        back.TextTransparency = back.Active and 0 or .65
        forward.TextTransparency = forward.Active and 0 or .65
    end
    local function apply()
        scroll.CanvasPosition = Vector2.zero
        cardScroll.CanvasPosition = Vector2.zero
        sortRows()
        render()
    end
    local function resolveLayout()
        local nextMode = c.LayoutMode
        if nextMode == "Auto" then
            local width = row.AbsoluteSize.X / math.max(hub._scale, .01)
            -- Zero width during initial construction is not meaningful.
            nextMode = width > 0 and width < (tonumber(options.CompactBelow) or 300)
                and "Cards" or "Table"
        end
        if c.EffectiveLayout ~= nextMode then
            c.EffectiveLayout = nextMode
            scroll.CanvasPosition = Vector2.zero
            cardScroll.CanvasPosition = Vector2.zero
            render()
        end
    end
    function c:SetLayoutMode(mode)
        if mode ~= "Auto" and mode ~= "Table" and mode ~= "Cards" then
            return false, "expected Auto, Table or Cards"
        end
        self.LayoutMode = mode
        resolveLayout()
        return true
    end
    function c:GetLayoutMode() return self.EffectiveLayout end
    function c:Set(rows, silent)
        assert(type(rows) == "table", "DataTable:Set requires an array")
        local nextEntries, lookup = {}, {}
        for i, value in rows do
            local item = type(value) == "table" and complexRowCopy(value) or { Value = value }
            local id = rowId(item, i)
            assert(id ~= "" and not lookup[id], "DataTable requires unique row IDs")
            item.Id, item._index = id, i
            lookup[id] = item
            table.insert(nextEntries, item)
        end
        entries, byId = nextEntries, lookup
        if self.SelectedId and not lookup[self.SelectedId] then self.SelectedId = nil end
        self.Rows = complexRowSnapshot(entries)
        self.Page = 1
        apply()
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Set", Count = #entries })
        end
        return true
    end
    function c:Upsert(value, silent)
        assert(type(value) == "table" and (value.Id or value.Key), "DataTable:Upsert requires Id or Key")
        local id = tostring(value.Id or value.Key)
        local item = complexRowCopy(value)
        item.Id = id
        if byId[id] then
            item._index = byId[id]._index
            entries[item._index] = item
        else
            item._index = #entries + 1
            table.insert(entries, item)
        end
        byId[id] = item
        self.Rows = complexRowSnapshot(entries)
        apply()
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Upsert", Id = id })
        end
        return true
    end
    function c:Update(id, changes, silent)
        id = tostring(id)
        local old = byId[id]
        if not old or type(changes) ~= "table" then return false end
        local item = complexRowCopy(old)
        for key, value in changes do
            if key ~= "Id" and key ~= "_index" then
                if (key == "Cells" or key == "Values") and type(value) == "table" then
                    item[key] = item[key] and table.clone(item[key]) or {}
                    for ck, cv in value do item[key][ck] = cv end
                else item[key] = value end
            end
        end
        -- Preserve the existing one-callback behavior, but distinguish an
        -- in-place update from an Upsert in structured data events.
        if not self:Upsert(item, true) then return false end
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Update", Id = id })
        end
        return true
    end
    function c:Remove(id, silent)
        id = tostring(id)
        local old = byId[id]
        if not old then return false end
        table.remove(entries, old._index)
        byId[id] = nil
        for i, entry in entries do entry._index = i end
        if self.SelectedId == id then self.SelectedId = nil end
        self.Rows = complexRowSnapshot(entries)
        apply()
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Remove", Id = id })
        end
        return true
    end
    function c:Get()
        local results = complexRowSnapshot(entries)
        for _, item in results do item._index = nil end
        return results
    end
    function c:GetVisible()
        local results = complexRowSnapshot(visible)
        for _, item in results do item._index = nil end
        return results
    end
    function c:SetPage(page)
        page = tonumber(page)
        if not page or page ~= page or page == math.huge or page == -math.huge then
            return false
        end
        -- Clamp before publishing the event. A swipe beyond either end is a
        -- no-op instead of reporting a page that will never be displayed.
        local pageCount = math.max(1, math.ceil(#visible / pageSize))
        local nextPage = math.clamp(math.floor(page), 1, pageCount)
        if nextPage == self.Page then return true end
        self.Page = nextPage
        scroll.CanvasPosition = Vector2.zero
        cardScroll.CanvasPosition = Vector2.zero
        render()
        self:_dataEvent("Page", self.Page)
        return true
    end
    function c:SetSort(key, descending)
        if key == nil then self.Sort = nil
        else
            local found
            for _, col in columns do
                if col.Key == tostring(key) then
                    if not col.Sortable then return false end
                    found = true
                    break
                end
            end
            if not found then return false end
            self.Sort = { Key = tostring(key), Descending = descending == true }
        end
        self.Page = 1
        apply()
        self:_dataEvent("Sort", self.Sort and table.clone(self.Sort))
        return true
    end
    function c:SetQuery(query)
        self.Query = string.lower(complexString(query))
        self.Page = 1
        apply()
        self:_dataEvent("Filter", self.Query)
        return true
    end
    function c:Select(id, silent)
        id = id == nil and nil or tostring(id)
        if id and not byId[id] then return false end
        self.SelectedId = id
        render()
        if not silent and options.Selectable ~= false then
            self:_emit(id, id and complexRowCopy(byId[id]) or nil)
            self:_dataEvent("Selection", id)
        end
        return true
    end
    function c:SetLoading(value)
        self.Loading = value == true
        if self.Loading then self.Error = nil end
        render()
    end
    function c:SetError(message)
        self.Loading = false
        self.Error = message and tostring(message) or nil
        render()
    end
    function c:Clear() return self:Set({}, true) end
    function c:Destroy()
        if not alive then return end
        alive = false
        disconnectWidget()
        for _, node in nodes do destroyNode(node) end
        for _, node in cardNodes do
            node.Connection:Disconnect()
            node.TouchConnection:Disconnect()
            node.Frame:Destroy()
        end
        table.clear(nodes)
        table.clear(cardNodes)
        complexForgetControl(self)
        row:Destroy()
    end
    local sortable = {}
    for _, col in columns do
        if col.Sortable then table.insert(sortable, col.Key) end
    end
    connect(cardSort.MouseButton1Click, function()
        if #sortable == 0 then return end
        local index = c.Sort and table.find(sortable, c.Sort.Key) or nil
        local nextKey = sortable[(index and index % #sortable or 0) + 1]
        c:SetSort(nextKey, false)
    end)
    connect(cardDirection.MouseButton1Click, function()
        if c.Sort then c:SetSort(c.Sort.Key, not c.Sort.Descending) end
    end)
    -- Only track touches in data areas. Pagination and sorting gestures
    -- must never be interpreted as a card-page swipe.
    connect(cardScroll.InputBegan, recordTouch)
    connect(scroll.InputBegan, recordTouch)
    connect(UserInputService.InputChanged, function(input)
        if not alive or not touchStart or input ~= touchStart then return end
        local distance = (Vector2.new(input.Position.X, input.Position.Y) - touchOrigin).Magnitude
        if distance > 12 then
            touchMoved = true
            touchBlockedUntil = os.clock() + .22
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if not alive or not touchStart or input ~= touchStart then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - touchOrigin
        if math.abs(delta.X) > 65 and math.abs(delta.X) > math.abs(delta.Y) * 1.6
            and c.EffectiveLayout == "Cards" and options.SwipePaging ~= false then
            if delta.X < 0 then c:SetPage(c.Page + 1)
            else c:SetPage(c.Page - 1) end
            touchBlockedUntil = os.clock() + .3
        elseif delta.Magnitude > 12 then
            touchBlockedUntil = os.clock() + .22
        end
        touchStart, touchOrigin = nil, nil
    end)
    connect(back.MouseButton1Click, function()
        if c.Page > 1 then c:SetPage(c.Page - 1) end
    end)
    connect(forward.MouseButton1Click, function()
        if c.Page < math.ceil(#visible / pageSize) then c:SetPage(c.Page + 1) end
    end)
    connect(row.Destroying, function()
        alive = false
        disconnectWidget()
        for _, node in nodes do destroyNode(node) end
        for _, node in cardNodes do
            node.Connection:Disconnect()
            node.TouchConnection:Disconnect()
            node.Frame:Destroy()
        end
        table.clear(nodes)
        table.clear(cardNodes)
    end)
    connect(row:GetPropertyChangedSignal("AbsoluteSize"), resolveLayout)
    connect(cardScroll:GetPropertyChangedSignal("CanvasPosition"), function()
        if c.EffectiveLayout == "Cards" then render() end
    end)
    hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
    c:Set(options.Rows or options.Items or {}, true)
    resolveLayout()
    return hub:_finishRequiredControl(c)
end
