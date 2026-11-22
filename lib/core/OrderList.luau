-- SPDX-License-Identifier: MPL-2.0
-- Ordered, flag-persistable priority control. No extra global input listeners.
local function complexCloneList(items)
    local out = {}
    for i, item in items do out[i] = type(item) == "table" and table.clone(item) or item end
    return out
end

local function complexString(value)
    return value == nil and "" or tostring(value)
end

local function complexObserve(control, fn)
    return control:OnChanged(fn)
end

-- An explicit Destroy must also unregister the control from all registries.
-- Leaving a detached Frame in Section.Controls breaks search and Reinitialize.
local function complexForgetControl(control)
    local section = control.Section
    if not section then return end
    section.Hub:_dataDetachControl(control)
    if control.Type == "TreeView" and section.Hub._treeControls then
        local index = table.find(section.Hub._treeControls, control)
        if index then table.remove(section.Hub._treeControls, index) end
    end
    local index = table.find(section.Controls, control)
    if index then table.remove(section.Controls, index) end
    local moduleCard = control._moduleCard
    if moduleCard and moduleCard._moduleControls then
        local inside = table.find(moduleCard._moduleControls, control)
        if inside then table.remove(moduleCard._moduleControls, inside) end
    end
    if control.Flag and RiftUI.Flags[control.Flag] == control then
        RiftUI.Flags[control.Flag] = nil
    end
    local recipe = section.Hub._recipe
    if recipe then
        for i = #recipe, 1, -1 do
            if recipe[i].Result == control then table.remove(recipe, i) end
        end
    end
end

function Section:OrderList(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 6), 2, 14)
    -- 42px cells + 2px gap provide larger mobile touch targets.
    local rowStep = 44
    local height = 34 + maxVisible * rowStep
    local row = self:_row(height + 6, "OrderList_" .. (options.Name or "Priority"))
    local c = self:_control("OrderList", options, row)
    local title = text({
        Name = "Title", Parent = row, Text = c.Name,
        TextSize = 13, FontFace = inter(Enum.FontWeight.SemiBold),
        Size = UDim2.new(1, -58, 0, 21), TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local count = text({
        Name = "Count", Parent = row, Text = "",
        TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(1, -58, 0, 0), Size = UDim2.fromOffset(58, 20),
    })
    local listBox = create("Frame", {
        Name = "PriorityBox", BackgroundColor3 = themeColor(theme, "Field"),
        BackgroundTransparency = .16,
        Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true, Parent = row,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke"), 1, .34) })
    hub:BindToken(listBox, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(listBox:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
    local scroll = create("ScrollingFrame", {
        Name = "Items", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.new(), Parent = listBox,
    }, { padding(3, 6), list(Enum.FillDirection.Vertical, 2) })
    local empty = text({
        Name = "Empty", Parent = listBox, Text = options.EmptyText or "Nothing to order",
        TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
    })

    local items, byId, nodes = {}, {}, {}
    local order = {}
    local live = true
    local function teardownNodes()
        for _, node in nodes do
            for _, conn in node.Connections do conn:Disconnect() end
            if node.Drag then node.Drag:Disconnect() end
            node.Frame:Destroy()
        end
        table.clear(nodes)
    end
    local function normalize(source)
        assert(type(source) == "table", "OrderList.Items must be an array")
        local out, index = {}, {}
        for i, value in source do
            local item
            if type(value) == "string" then
                item = { Id = value, Label = value, Disabled = false }
            else
                assert(type(value) == "table", "OrderList item must be string or table")
                item = { Id = value.Id or value.Key or tostring(i),
                    Label = complexString(value.Label or value.Name or value.Id or i),
                    Description = complexString(value.Description), Disabled = value.Disabled == true }
            end
            assert(type(item.Id) == "string" and item.Id ~= "" and not index[item.Id], "OrderList requires unique non-empty Id")
            index[item.Id] = item
            table.insert(out, item)
        end
        return out, index
    end
    local function same(a, b)
        if #a ~= #b then return false end
        for i, id in a do if b[i] ~= id then return false end end
        return true
    end
    local function currentOrder()
        return table.clone(order)
    end
    local function layout()
        if not live or hub._destroyed then return end
        local visible = math.max(1, math.min(maxVisible, #order))
        listBox.Size = UDim2.new(1, 0, 0, visible * rowStep + 6)
        row.Size = UDim2.new(1, 0, 0, 26 + visible * rowStep + 10)
        scroll.CanvasSize = UDim2.fromOffset(0, #order * rowStep + 12)
        count.Text = tostring(#order)
        empty.Visible = #order == 0
        for position, id in order do
            local node = nodes[id]
            if node then
                node.Frame.LayoutOrder = position
                node.Pos.Text = string.format("%02d", position)
                node.Up.Visible = not byId[id].Disabled
                node.Down.Visible = not byId[id].Disabled
                local prior, nextId = order[position - 1], order[position + 1]
                node.Up.Active = prior ~= nil and not byId[prior].Disabled
                node.Down.Active = nextId ~= nil and not byId[nextId].Disabled
                node.Up.TextTransparency = node.Up.Active and 0 or .7
                node.Down.TextTransparency = node.Down.Active and 0 or .7
            end
        end
    end
    local function setOrder(nextOrder, silent, strict)
        if type(nextOrder) ~= "table" then return false, "expected array of IDs" end
        local seen, desired = {}, {}
        for _, id in nextOrder do
            if type(id) ~= "string" or seen[id] or not byId[id] then
                if strict then return false, "unknown or duplicate item ID" end
            else
                seen[id] = true
                table.insert(desired, id)
            end
        end
        for _, id in order do
            if not seen[id] and byId[id] then
                seen[id] = true
                table.insert(desired, id)
            end
        end
        -- Locked rows never move: they remain in their original indices even
        -- when a caller supplies a full order with those IDs misplaced.
        local fixed, editable = {}, {}
        for index, id in order do
            if byId[id] and byId[id].Disabled then fixed[index] = id end
        end
        for _, id in desired do
            if not byId[id].Disabled then table.insert(editable, id) end
        end
        local final, nextEditable = {}, 1
        for position = 1, #order do
            final[position] = fixed[position] or editable[nextEditable]
            if not fixed[position] then nextEditable += 1 end
        end
        if same(order, final) then return true end
        order = final
        c.Value = table.clone(order)
        layout()
        if not silent then c:_emit(currentOrder()) end
        return true
    end
    local function createNode(item)
        local cell = create("Frame", {
            Name = "Priority_" .. item.Id, BackgroundColor3 = themeColor(theme, "Tile"),
            BackgroundTransparency = .84, Size = UDim2.new(1, 0, 0, rowStep - 2),
            Parent = scroll,
        }, { corner(6) })
        local num = text({ Name = "Position", Parent = cell, Text = "",
            FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
            Position = UDim2.fromOffset(7, 0), Size = UDim2.fromOffset(21, rowStep - 2) })
        local label = text({ Name = "Label", Parent = cell, Text = item.Label,
            TextSize = 12, TextColor3 = themeColor(theme, item.Disabled and "Muted" or "Text"),
            Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -148, 0, rowStep - 2),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local drag = create("TextButton", {
            Name = "DragHandle", Parent = cell, Text = "≡", AutoButtonColor = false,
            BackgroundTransparency = 1, TextSize = 17,
            TextColor3 = themeColor(theme, "SubText"),
            Position = UDim2.new(1, -112, 0, 0), Size = UDim2.fromOffset(34, rowStep - 2),
            Active = not item.Disabled, Visible = not item.Disabled,
        })
        local up = create("TextButton", {
            Name = "MoveUp", Parent = cell, Text = "↑", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "Field"),
            BackgroundTransparency = .25, TextSize = 15,
            TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.new(1, -76, 0, 3), Size = UDim2.fromOffset(36, 36),
        }, { corner(5) })
        local down = create("TextButton", {
            Name = "MoveDown", Parent = cell, Text = "↓", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "Field"),
            BackgroundTransparency = .25, TextSize = 15,
            TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.new(1, -38, 0, 3), Size = UDim2.fromOffset(36, 36),
        }, { corner(5) })
        local node = { Frame = cell, Pos = num, Label = label, DragHandle = drag,
            Up = up, Down = down, Connections = {} }
        nodes[item.Id] = node
        local function on(signal, fn)
            table.insert(node.Connections, signal:Connect(fn))
        end
        on(up.MouseButton1Click, function() c:Move(item.Id, (table.find(order, item.Id) or 1) - 1) end)
        on(down.MouseButton1Click, function() c:Move(item.Id, (table.find(order, item.Id) or 1) + 1) end)
        if not item.Disabled then
            local startY, target
            node.Drag = bindPointerDrag(hub, drag, {
                Start = function(input)
                    if not c:IsAvailable() then error("OrderList is unavailable") end
                    startY = input.Position.Y
                    target = table.find(order, item.Id)
                    setThemed(cell, "BackgroundColor3", themeColor(theme, "TileActive"))
                end,
                Move = function(input)
                    if not target then return end
                    local offset = math.floor(((input.Position.Y - startY) / math.max(hub._scale, .01)) / rowStep + .5)
                    target = math.clamp((table.find(order, item.Id) or 1) + offset, 1, #order)
                end,
                End = function(cancelled)
                    setThemed(cell, "BackgroundColor3", themeColor(theme, "Tile"))
                    if not cancelled and target then c:Move(item.Id, target) end
                    target = nil
                end,
            }, true)
        end
    end
    function c:GetOrder() return currentOrder() end
    function c:Get() return self:GetOrder() end
    function c:SetOrder(ids, silent)
        return setOrder(ids, silent, true)
    end
    c.Set = c.SetOrder
    function c:Move(id, index, silent)
        if not self:IsAvailable() then return false end
        local at = table.find(order, id)
        if not at or byId[id].Disabled then return false end
        index = math.clamp(math.floor(tonumber(index) or at), 1, #order)
        if at == index then return true end
        -- Block a move that would shift a fixed/disabled item.
        local low, high = math.min(at, index), math.max(at, index)
        for position = low, high do
            if byId[order[position]].Disabled then return false end
        end
        local nextOrder = currentOrder()
        table.remove(nextOrder, at)
        table.insert(nextOrder, index, id)
        return setOrder(nextOrder, silent, true)
    end
    function c:SetItems(nextItems, silent)
        local normalized, lookup = normalize(nextItems)
        local seen, nextOrder = {}, {}
        for _, id in order do
            if lookup[id] then table.insert(nextOrder, id); seen[id] = true end
        end
        for _, item in normalized do
            if not seen[item.Id] then table.insert(nextOrder, item.Id) end
        end
        teardownNodes()
        items, byId, order = normalized, lookup, nextOrder
        for _, item in items do createNode(item) end
        self.Value = currentOrder()
        layout()
        if not silent then self:_emit(currentOrder()) end
        return true
    end
    function c:OnOrderChanged(fn) return complexObserve(self, fn) end
    function c:Reset(silent) return self:SetOrder(self.DefaultValue or {}, silent) end
    function c:Destroy()
        if not live then return end
        live = false
        teardownNodes()
        complexForgetControl(self)
        row:Destroy()
    end
    hub:_connect(row.Destroying, function()
        live = false
        teardownNodes()
    end)
    c:SetItems(options.Items or {}, true)
    c.DefaultValue = type(options.Default) == "table" and table.clone(options.Default) or currentOrder()
    if type(options.Default) == "table" then
        local ok, err = c:SetOrder(options.Default, true)
        assert(ok, "OrderList.Default: " .. tostring(err))
    end
    return hub:_finishRequiredControl(c)
end
