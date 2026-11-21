-- SPDX-License-Identifier: MPL-2.0
-- RelaxUI TreeView: nested, keyed data with reusable visible rows.
-- Never creates GUI rows for off-screen nodes or starts a frame loop.
do
    local function treeSnapshot(nodes)
        local result = {}
        for i, node in nodes do
            result[i] = {
                Id = node.Id, Label = node.Label, Detail = node.Detail,
                Badge = node.Badge, Disabled = node.Disabled,
                Children = treeSnapshot(node.Children),
            }
        end
        return result
    end

    function Section:TreeView(options)
        options = type(options) == "table" and options or {}
        local hub, theme = self.Hub, self.Hub.Theme
        local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 6), 2, 14)
        local rowHeight = 41
        local header = options.Name and 26 or 0
        local row = self:_row(header + rowHeight * 2 + 10,
            "TreeView_" .. tostring(options.Name or "Tree"))
        local c = self:_control("TreeView", options, row)
        local roots, byId, expanded, flattened, slots = {}, {}, {}, {}, {}
        local connections = {}
        local alive = true
        c.Query, c.SelectedId = "", nil
        c.Loading, c.Error = false, nil
        local persistKey = self.Id .. "/tree/" .. tostring(options.Id or options.Flag or c.Name)
        local savedState = options.Persist ~= false and hub.SetupData
            and type(hub.SetupData.TreeStates) == "table"
            and hub.SetupData.TreeStates[persistKey] or nil
        local restoring = true
        local pendingWrite, writeScheduled = false, false
        c.PersistKey = persistKey
        c.Persist = options.Persist ~= false

        local function connect(signal, callback)
            local conn = signal:Connect(callback)
            table.insert(connections, conn)
            return conn
        end
        if options.Name then
            text({
                Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
                FontFace = inter(Enum.FontWeight.SemiBold),
                TextColor3 = themeColor(theme, "Text"),
                Size = UDim2.new(1, 0, 0, 21),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
        end
        local shell = create("Frame", {
            Name = "TreeShell", Parent = row,
            Position = UDim2.fromOffset(0, header),
            BackgroundColor3 = themeColor(theme, "Field"),
            Size = UDim2.new(1, 0, 0, rowHeight * 2 + 8),
            ClipsDescendants = true,
        }, { corner(8), stroke(themeColor(theme, "FieldStroke")) })
        local scroll = create("ScrollingFrame", {
            Name = "TreeRows", Parent = shell,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
            CanvasSize = UDim2.new(),
        })
        local empty = text({
            Name = "TreeMessage", Parent = shell, Text = options.EmptyText or "No items",
            TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
            TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
            Visible = false,
        })
        local function normalize(nodes)
            assert(type(nodes) == "table", "TreeView nodes must be an array")
            local index, active, initial = {}, {}, {}
            local count = 0
            local function visit(items, depth, parentId)
                assert(depth <= 14, "TreeView depth exceeds 14")
                assert(type(items) == "table", "TreeView Children must be an array")
                assert(not active[items], "TreeView cyclic child table")
                active[items] = true
                local out = {}
                for i, value in items do
                    assert(type(value) == "table", "TreeView nodes must be tables")
                    count += 1
                    assert(count <= 4096, "TreeView supports up to 4096 nodes")
                    local id = value.Id or value.Key
                    assert(id ~= nil and tostring(id) ~= "", "TreeView requires node IDs")
                    id = tostring(id)
                    assert(not index[id], "TreeView duplicate ID: " .. id)
                    local node = {
                        Id = id,
                        Label = tostring(value.Label or value.Name or id),
                        Detail = value.Detail == nil and "" or tostring(value.Detail),
                        Badge = value.Badge == nil and "" or tostring(value.Badge),
                        Disabled = value.Disabled == true,
                        ParentId = parentId,
                        Depth = depth,
                        Children = {},
                    }
                    index[id] = node
                    table.insert(out, node)
                    local children = value.Children or {}
                    node.Children = visit(children, depth + 1, id)
                    if #node.Children > 0 then
                        initial[id] = value.Expanded ~= nil and value.Expanded == true
                            or (value.Expanded == nil and depth == 0 and options.ExpandRoots ~= false)
                    end
                end
                active[items] = nil
                return out
            end
            return visit(nodes, 0, nil), index, initial
        end
        local function makeSlot(slotId)
            local frame = create("Frame", {
                Name = "TreeRow", Parent = scroll,
                BackgroundColor3 = themeColor(theme, "Tile"),
                BackgroundTransparency = .84,
                Size = UDim2.new(1, -9, 0, rowHeight - 2),
            }, { corner(5) })
            -- Reused row slots keep a faint depth rail, avoiding another nested black card.
            local depthRail = create("Frame", {
                Name = "DepthRail", Parent = frame, BorderSizePixel = 0,
                BackgroundColor3 = themeColor(theme, "SubText"),
                BackgroundTransparency = .78, Visible = false,
                Position = UDim2.fromOffset(13, 8), Size = UDim2.fromOffset(1, rowHeight - 18),
            })
            local toggle = create("TextButton", {
                Name = "Expand", Parent = frame, Text = "",
                AutoButtonColor = false, BackgroundTransparency = 1,
                TextColor3 = themeColor(theme, "SubText"), TextSize = 15,
                Size = UDim2.fromOffset(24, rowHeight - 2),
            })
            -- Asset chevrons do not depend on Android's glyph fallback.
            local arrow = iconLabel("chevron-right", 14, theme.SubText, {
                Parent = toggle, AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5), ZIndex = 3,
            })
            local selectButton = create("TextButton", {
                Name = "Select", Parent = frame, Text = "",
                AutoButtonColor = false, BackgroundTransparency = 1,
                Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0),
            })
            local label = text({
                Name = "TreeLabel", Parent = selectButton, Text = "",
                TextSize = 12, TextColor3 = themeColor(theme, "Text"),
                Position = UDim2.fromOffset(0, 2),
                Size = UDim2.new(1, -86, 0, 18),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local detail = text({
                Name = "TreeDetail", Parent = selectButton, Text = "",
                TextSize = 10, TextColor3 = themeColor(theme, "Muted"),
                Position = UDim2.fromOffset(0, 20),
                Size = UDim2.new(1, -8, 0, 15),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local badge = text({
                Name = "TreeBadge", Parent = selectButton, Text = "",
                TextSize = 10, TextColor3 = themeColor(theme, "SubText"),
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -82, 0, 3),
                Size = UDim2.fromOffset(76, 17),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local slot = {
                Frame = frame, DepthRail = depthRail, Toggle = toggle, Arrow = arrow, Select = selectButton,
                Label = label, Detail = detail, Badge = badge, Id = nil,
            }
            slots[slotId] = slot
            connect(toggle.MouseButton1Click, function()
                if slot.Id and c:IsAvailable() then c:SetExpanded(slot.Id, not expanded[slot.Id]) end
            end)
            connect(selectButton.MouseButton1Click, function()
                if slot.Id and c:IsAvailable() then c:Select(slot.Id) end
            end)
            return slot
        end
        local function rebuild()
            flattened = {}
            local query = string.lower(c.Query)
            local matching = {}
            if query ~= "" then
                local function contains(node)
                    local found = string.find(string.lower(node.Label), query, 1, true) ~= nil
                        or string.find(string.lower(node.Detail), query, 1, true) ~= nil
                        or string.find(string.lower(node.Badge), query, 1, true) ~= nil
                    for _, child in node.Children do
                        if contains(child) then found = true end
                    end
                    matching[node.Id] = found
                    return found
                end
                for _, root in roots do contains(root) end
            end
            local function append(nodes)
                for _, node in nodes do
                    if query == "" or matching[node.Id] then
                        table.insert(flattened, node)
                        if query ~= "" or expanded[node.Id] then append(node.Children) end
                    end
                end
            end
            append(roots)
        end
        local function render()
            if not alive or hub._destroyed then return end
            local count = #flattened
            local visibleCount = math.min(maxVisible, math.max(2, count))
            local height = visibleCount * rowHeight + 8
            shell.Size = UDim2.new(1, 0, 0, height)
            row.Size = UDim2.new(1, 0, 0, header + height + 5)
            scroll.CanvasSize = UDim2.fromOffset(0, count * rowHeight + 8)
            empty.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No items"))
            empty.Visible = c.Error ~= nil or c.Loading or count == 0
            scroll.Visible = not empty.Visible
            local first = math.clamp(
                math.floor(scroll.CanvasPosition.Y / math.max(rowHeight * hub._scale, 1)) + 1,
                1, math.max(1, count - maxVisible + 1))
            local amount = math.min(count, maxVisible + 2)
            for i = 1, math.max(#slots, amount) do
                local node = i <= amount and flattened[first + i - 1] or nil
                local slot = slots[i]
                if node then
                    if not slot then slot = makeSlot(i) end
                    local sameNode = slot.Id == node.Id
                    slot.Id = node.Id
                    slot.Frame.Visible = true
                    slot.Frame.Position = UDim2.fromOffset(4, (first + i - 2) * rowHeight + 3)
                    -- Keep a minimum readable label area at deep levels on mobile.
                    local logicalWidth = math.max(0, scroll.AbsoluteSize.X / math.max(hub._scale, .01))
                    local indent = math.min(node.Depth * 12, math.max(0, logicalWidth - 180))
                    local hasChildren = #node.Children > 0
                    slot.Toggle.Visible = hasChildren
                    slot.Toggle.Position = UDim2.fromOffset(indent + 2, 0)
                    slot.Toggle.Text = ""
                    if slot.Arrow then
                        slot.Arrow.Visible = hasChildren
                        local targetAngle = (expanded[node.Id] or c.Query ~= "") and 90 or 0
                        local arrowKey = "tree-arrow:" .. tostring(slot.Toggle)
                        if sameNode and slot.Arrow.Rotation ~= targetAngle then
                            Motion.play(hub, arrowKey, slot.Arrow, { Rotation = targetAngle }, Motion.Presets.Micro)
                        elseif not sameNode then
                            Motion.cancel(hub, arrowKey)
                            slot.Arrow.Rotation = targetAngle
                        end
                    end
                    slot.DepthRail.Visible = node.Depth > 0
                    slot.DepthRail.Position = UDim2.fromOffset(math.max(8, indent - 5), 8)
                    slot.Label.FontFace = inter(node.Depth == 0 and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular)
                    slot.Select.Position = UDim2.fromOffset(indent + 26, 0)
                    slot.Select.Size = UDim2.new(1, -indent - 26, 1, 0)
                    -- Badge competes with labels on narrow panels; hide it, not the title.
                    local showBadge = logicalWidth >= 245 and node.Badge ~= ""
                    slot.Badge.Visible = showBadge
                    slot.Label.Size = UDim2.new(1, showBadge and -86 or -8, 0, 18)
                    slot.Label.Text = node.Label
                    slot.Detail.Text = node.Detail
                    slot.Badge.Text = node.Badge
                    local rowTone = c.SelectedId == node.Id and .32
                        or (node.Depth == 0 and .72 or .86)
                    local toneKey = "tree-row:" .. tostring(slot.Frame)
                    if sameNode and slot.Frame.BackgroundTransparency ~= rowTone then
                        Motion.play(hub, toneKey, slot.Frame, { BackgroundTransparency = rowTone }, Motion.Presets.Micro)
                    elseif not sameNode then
                        Motion.cancel(hub, toneKey)
                        slot.Frame.BackgroundTransparency = rowTone
                    end
                    setThemed(slot.Label, "TextColor3",
                        themeColor(theme, node.Disabled and "Muted" or "Text"))
                elseif slot then
                    slot.Id = nil
                    slot.Frame.Visible = false
                end
            end
        end
        local function refresh()
            rebuild()
            render()
        end
        local function stateSnapshot()
            return { Version = 1, Expanded = table.clone(expanded), SelectedId = c.SelectedId }
        end
        local function flushPersistence()
            if not pendingWrite or hub._destroyed then return false end
            pendingWrite = false
            hub:_savePref("TreeStates", hub.SetupData.TreeStates)
            return true
        end
        function c:FlushState()
            return flushPersistence()
        end
        local function persistState()
            if restoring or options.Persist == false or hub._replaying or hub._destroyed then return end
            hub.SetupData = hub.SetupData or {}
            local prefs = hub.SetupData.TreeStates
            if type(prefs) ~= "table" then
                prefs = {}
                hub.SetupData.TreeStates = prefs
            end
            prefs[persistKey] = stateSnapshot()
            pendingWrite = true
            -- Mutate the in-memory snapshot immediately, but coalesce disk writes
            -- while the user expands or selects several nodes in rapid succession.
            if not writeScheduled then
                writeScheduled = true
                task.delay(.35, function()
                    writeScheduled = false
                    if alive and not hub._destroyed then flushPersistence() end
                end)
            end
        end
        local function stateChanged(kind, payload, silent)
            c.Value = stateSnapshot()
            persistState()
            if not silent then
                c:_dataEvent(kind, payload)
                c:_dataEvent("State", c:GetState())
            end
        end
        function c:GetState() return stateSnapshot() end
        function c:GetSelection() return self.SelectedId end
        function c:OnStateChanged(fn)
            return self:OnDataEvent("State", fn)
        end
        function c:SetState(state, silent)
            if not alive then return false, "destroyed" end
            if type(state) ~= "table" then return false, "state must be a table" end
            if state.Expanded ~= nil and type(state.Expanded) ~= "table" then
                return false, "Expanded must be a map"
            end
            if state.SelectedId ~= nil and type(state.SelectedId) ~= "string" then
                return false, "SelectedId must be a string"
            end
            local nextExpanded = table.clone(expanded)
            for id, value in state.Expanded or {} do
                if type(id) ~= "string" or type(value) ~= "boolean" then
                    return false, "Expanded must contain string IDs and boolean states"
                end
                if nextExpanded[id] ~= nil then nextExpanded[id] = value end
            end
            local chosen = state.SelectedId
            if chosen ~= nil and (not byId[chosen] or byId[chosen].Disabled) then chosen = nil end
            expanded = nextExpanded
            self.SelectedId = chosen
            refresh()
            stateChanged("StateRestored", self:GetState(), silent)
            return true
        end
        function c:SetNodes(nodes)
            if not alive then return false end
            -- Build the replacement completely before touching live state.
            local newRoots, newIndex, defaults = normalize(nodes)
            local newExpanded = {}
            for id, default in defaults do
                newExpanded[id] = expanded[id] == nil and default or expanded[id]
            end
            roots, byId, expanded = newRoots, newIndex, newExpanded
            if self.SelectedId and (not byId[self.SelectedId] or byId[self.SelectedId].Disabled) then self.SelectedId = nil end
            scroll.CanvasPosition = Vector2.zero
            refresh()
            stateChanged("Data", { Operation = "SetNodes", Count = #flattened }, restoring)
            return true
        end
        c.Set = c.SetNodes
        function c:GetTree() return treeSnapshot(roots) end
        function c:Get() return self:GetTree() end
        function c:GetVisible()
            local result = {}
            for i, node in flattened do
                result[i] = { Id = node.Id, Label = node.Label, Depth = node.Depth }
            end
            return result
        end
        function c:GetExpanded(id)
            if id ~= nil then return expanded[tostring(id)] == true end
            return table.clone(expanded)
        end
        function c:SetExpanded(id, value)
            id = tostring(id)
            local node = byId[id]
            if not node or #node.Children == 0 then return false end
            local nextState = value == true
            if expanded[id] ~= nextState then
                expanded[id] = nextState
                refresh()
                stateChanged("Expansion", { Id = id, Expanded = nextState })
            end
            return true
        end
        function c:ExpandAll()
            for id in expanded do expanded[id] = true end
            refresh()
            stateChanged("Expansion", { All = true, Expanded = true })
            return true
        end
        function c:CollapseAll()
            for id in expanded do expanded[id] = false end
            refresh()
            stateChanged("Expansion", { All = true, Expanded = false })
            return true
        end
        function c:SetQuery(query)
            self.Query = string.lower(tostring(query or ""))
            scroll.CanvasPosition = Vector2.zero
            refresh()
            self:_dataEvent("Filter", self.Query)
            return true
        end
        function c:Select(id, silent)
            id = id == nil and nil or tostring(id)
            if id and (not byId[id] or byId[id].Disabled) then return false end
            if not self:IsAvailable() then return false end
            self.SelectedId = id
            render()
            stateChanged("Selection", id, silent)
            if not silent then
                self:_emit(id, id and {
                    Id = byId[id].Id, Label = byId[id].Label,
                    Detail = byId[id].Detail, Badge = byId[id].Badge,
                } or nil)
            end
            return true
        end
        function c:Update(id, change)
            id = tostring(id)
            local node = byId[id]
            if not node or type(change) ~= "table" then return false end
            -- Structural changes use SetNodes to ensure index integrity.
            if change.Id ~= nil or change.Key ~= nil or change.Children ~= nil then return false end
            if change.Label ~= nil then node.Label = tostring(change.Label) end
            if change.Detail ~= nil then node.Detail = tostring(change.Detail) end
            if change.Badge ~= nil then node.Badge = tostring(change.Badge) end
            if change.Disabled ~= nil then node.Disabled = change.Disabled == true end
            if self.SelectedId == id and node.Disabled then self.SelectedId = nil end
            refresh()
            self:_dataEvent("Data", { Operation = "Update", Id = id })
            return true
        end
        function c:Remove(id)
            id = tostring(id)
            if not byId[id] then return false end
            local function prune(nodes)
                for i = #nodes, 1, -1 do
                    if nodes[i].Id == id then table.remove(nodes, i); return true end
                    if prune(nodes[i].Children) then return true end
                end
                return false
            end
            local remainder = treeSnapshot(roots)
            prune(remainder)
            return self:SetNodes(remainder)
        end
        function c:SetLoading(value)
            self.Loading = value == true
            if self.Loading then self.Error = nil end
            render()
        end
        function c:SetError(err)
            self.Loading = false
            self.Error = err == nil and nil or tostring(err)
            render()
        end
        local function dispose()
            if not alive then return end
            -- A parent Section can destroy the row without calling c:Destroy().
            -- Flush any debounced tree preference before disconnecting it,
            -- then remove stale registry and cross-component references.
            flushPersistence()
            alive = false
            c._disposed = true
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            table.clear(slots)
            -- Hub:_teardown() preserves the recipe for Reinitialize().
            -- Removing controls from that live recipe while destroying the
            -- entire hub would erase steps and break forwarded data links.
            if not hub._destroyed then complexForgetControl(c) end
        end
        function c:Destroy()
            if not alive then return end
            dispose()
            row:Destroy()
        end
        connect(scroll:GetPropertyChangedSignal("CanvasPosition"), render)
        connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), render)
        connect(row.Destroying, dispose)
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
        c:SetNodes(options.Nodes or options.Items or {})
        if type(savedState) == "table" then c:SetState(savedState, true) end
        restoring = false
        c.Value = stateSnapshot()
        hub._treeControls = hub._treeControls or {}
        table.insert(hub._treeControls, c)
        return hub:_finishRequiredControl(c)
    end
end
