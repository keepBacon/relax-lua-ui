-- SPDX-License-Identifier: MPL-2.0
-- Read-only, keyed status records with bounded visible rows and incremental rendering.
local COMPLEX_STATUS_TONES = {
    healthy = "Success", online = "Success", success = "Success", ready = "Success",
    warning = "Warning", degraded = "Warning", pending = "Warning",
    error = "Danger", failed = "Danger", offline = "Danger",
    info = "SubText", idle = "Muted", unknown = "Muted",
}

local function complexStatusItem(value, index)
    assert(type(value) == "table", "StatusList items must be tables")
    local id = tostring(value.Id or value.Key or index)
    assert(id ~= "", "StatusList requires non-empty id")
    return {
        Id = id, Label = complexString(value.Label or value.Name or id),
        State = complexString(value.State or value.Status or "Unknown"),
        Detail = complexString(value.Detail or value.Description or ""),
        Tone = value.Tone or COMPLEX_STATUS_TONES[string.lower(complexString(value.State or value.Status or "unknown"))] or "SubText",
    }
end

function Section:StatusList(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 6), 2, 16)
    local rowHeight = 42
    local header = options.Name and 26 or 0
    local row = self:_row(header + rowHeight * math.min(maxVisible, 2) + 9,
        "StatusList_" .. (options.Name or "Statuses"))
    local c = self:_control("StatusList", options, row)
    local entries, byId, filtered, slots = {}, {}, {}, {}
    local alive = true
    c.Filter = "All"
    c.Loading = false
    c.Error = nil
    if options.Name then
        text({ Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
            FontFace = inter(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
    end
    local shell = create("Frame", {
        Name = "StatusBox", Parent = row, BackgroundColor3 = themeColor(theme, "Field"),
        Position = UDim2.fromOffset(0, header),
        Size = UDim2.new(1, 0, 0, rowHeight * 2 + 8), ClipsDescendants = true,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke")) })
    local scroll = create("ScrollingFrame", {
        Name = "StatusRows", Parent = shell, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3,
        ScrollBarImageColor3 = themeColor(theme, "Knob"),
        ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(),
    })
    local message = text({ Name = "StatusMessage", Parent = shell,
        Text = options.EmptyText or "No statuses",
        TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
        Visible = false })
    local function buildSlot(slot)
        local frame = create("Frame", {
            Name = "StatusRow", Parent = scroll,
            Position = UDim2.fromOffset(4, (slot - 1) * rowHeight + 3),
            Size = UDim2.new(1, -8, 0, rowHeight - 2),
            BackgroundColor3 = themeColor(theme, "Tile"),
            BackgroundTransparency = slot % 2 == 0 and .64 or .78,
        }, { corner(5) })
        local name = text({ Name = "Label", Parent = frame, Text = "",
            TextSize = 12, TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.fromOffset(9, 3), Size = UDim2.new(1, -105, 0, 18),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local detail = text({ Name = "Detail", Parent = frame, Text = "",
            TextSize = 10, TextColor3 = themeColor(theme, "Muted"),
            Position = UDim2.fromOffset(9, 21), Size = UDim2.new(1, -18, 0, 15),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local badge = create("Frame", {
            Name = "Badge", Parent = frame,
            BackgroundColor3 = themeColor(theme, "TileActive"),
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -7, 0, 5),
            Size = UDim2.fromOffset(86, 21),
        }, { corner(6) })
        local value = text({ Name = "State", Parent = badge, Text = "",
            TextSize = 10, FontFace = inter(Enum.FontWeight.Medium),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextColor3 = themeColor(theme, "SubText"),
            Size = UDim2.fromScale(1, 1), TextTruncate = Enum.TextTruncate.AtEnd })
        slots[slot] = { Frame = frame, Label = name, Detail = detail, State = value, Badge = badge, Id = nil }
    end
    local function listFilter()
        filtered = {}
        for _, item in entries do
            local tone = COMPLEX_STATUS_TONES[string.lower(item.State)] or item.Tone
            if c.Filter == "All" or c.Filter == item.State or c.Filter == tone then
                table.insert(filtered, item)
            end
        end
    end
    local function render()
        if not alive or hub._destroyed then return end
        listFilter()
        local count = #filtered
        local visible = math.min(maxVisible, math.max(2, count))
        shell.Size = UDim2.new(1, 0, 0, visible * rowHeight + 8)
        row.Size = UDim2.new(1, 0, 0, header + visible * rowHeight + 8)
        message.Visible = c.Error ~= nil or c.Loading or count == 0
        message.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No statuses"))
        scroll.Visible = not message.Visible
        -- Render the first bounded batch. For large sets use native ScrollingFrame
        -- CanvasPosition as the virtualization source; offscreen instances are pooled.
        scroll.CanvasSize = UDim2.fromOffset(0, count * rowHeight + 8)
        local first = math.clamp(math.floor(scroll.CanvasPosition.Y / math.max(rowHeight * hub._scale, 1)) + 1,
            1, math.max(1, count - maxVisible + 1))
        local slotCount = math.min(count, maxVisible + 2)
        for slot = 1, math.max(slotCount, #slots) do
            local item = slot <= slotCount and filtered[first + slot - 1] or nil
            local record = slots[slot]
            if item then
                if not record then buildSlot(slot); record = slots[slot] end
                record.Frame.Visible = true
                record.Frame.Position = UDim2.fromOffset(4, (first + slot - 2) * rowHeight + 3)
                local compact = scroll.AbsoluteSize.X / math.max(hub._scale, .01) < 230
                record.Badge.Size = UDim2.fromOffset(compact and 65 or 86, 21)
                record.Label.Size = UDim2.new(1, compact and -83 or -105, 0, 18)
                if record.Id ~= item.Id or record.Label.Text ~= item.Label then record.Label.Text = item.Label end
                if record.Detail.Text ~= item.Detail then record.Detail.Text = item.Detail end
                if record.State.Text ~= item.State then record.State.Text = item.State end
                setThemed(record.State, "TextColor3", themeColor(theme, item.Tone))
                record.Id = item.Id
            elseif record then
                record.Frame.Visible = false
                record.Id = nil
            end
        end
    end
    function c:Set(items)
        assert(type(items) == "table", "StatusList:Set requires array")
        local all, lookup = {}, {}
        for i, value in items do
            local item = complexStatusItem(value, i)
            assert(not lookup[item.Id], "StatusList duplicate id: " .. item.Id)
            table.insert(all, item)
            lookup[item.Id] = item
        end
        entries, byId = all, lookup
        render()
        c:_dataEvent("Data", { Operation = "Set", Count = #entries })
        return true
    end
    function c:Upsert(item)
        assert(type(item) == "table" and (item.Id or item.Key), "StatusList:Upsert requires Id or Key")
        local id = tostring(item.Id or item.Key)
        local previous = byId[id]
        local updated = complexStatusItem(item, id)
        if previous then
            for k, v in updated do previous[k] = v end
        else
            byId[id] = updated
            table.insert(entries, updated)
        end
        render()
        c:_dataEvent("Data", { Operation = "Upsert", Id = id })
        return true
    end
    function c:Update(id, value)
        local item = byId[tostring(id)]
        if not item or type(value) ~= "table" then return false end
        if value.Label ~= nil then item.Label = complexString(value.Label) end
        if value.State ~= nil or value.Status ~= nil then
            item.State = complexString(value.State or value.Status)
            if value.Tone == nil then
                item.Tone = COMPLEX_STATUS_TONES[string.lower(item.State)] or "SubText"
            end
        end
        if value.Detail ~= nil then item.Detail = complexString(value.Detail) end
        if value.Tone ~= nil then item.Tone = tostring(value.Tone) end
        render()
        c:_dataEvent("Data", { Operation = "Update", Id = tostring(id) })
        return true
    end
    function c:Remove(id)
        id = tostring(id)
        local item = byId[id]
        if not item then return false end
        byId[id] = nil
        local position = table.find(entries, item)
        if position then table.remove(entries, position) end
        render()
        c:_dataEvent("Data", { Operation = "Remove", Id = id })
        return true
    end
    function c:SetFilter(filter)
        self.Filter = filter and tostring(filter) or "All"
        scroll.CanvasPosition = Vector2.zero
        render()
        c:_dataEvent("Filter", self.Filter)
        return true
    end
    function c:SetLoading(value)
        self.Loading = value == true
        if self.Loading then self.Error = nil end
        render()
    end
    function c:SetError(err)
        self.Loading = false
        self.Error = err and tostring(err) or nil
        render()
    end
    function c:Get()
        return complexRowSnapshot(entries)
    end
    function c:Clear() return self:Set({}) end
    function c:Destroy()
        if not alive then return end
        alive = false
        complexForgetControl(self)
        row:Destroy()
    end
    hub:_connect(scroll:GetPropertyChangedSignal("CanvasPosition"), render)
    hub:_connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), render)
    hub:_connect(row.Destroying, function()
        alive = false
        table.clear(slots)
    end)
    hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
    c:Set(options.Items or {})
    return hub:_finishRequiredControl(c)
end
