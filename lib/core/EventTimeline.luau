-- SPDX-License-Identifier: MPL-2.0
-- Bounded, read-only event feed for diagnostics, activity and operation history.
-- Keeps data separate from pooled GUI rows and never starts a frame loop.
do
    local EVENT_TONES = {
        info = "SubText", success = "Success", warning = "Warning",
        error = "Danger", danger = "Danger", debug = "Muted",
    }
    local function eventCopy(event)
        return {
            Id = tostring(event.Id or event.Key),
            Title = tostring(event.Title or event.Name or "Event"),
            Detail = tostring(event.Detail or event.Description or ""),
            Category = tostring(event.Category or "Info"),
            Time = event.Time,
            Tone = event.Tone,
        }
    end
    function Section:EventTimeline(options)
        options = type(options) == "table" and options or {}
        local hub, theme = self.Hub, self.Hub.Theme
        local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 5), 2, 12)
        local maxRecords = math.clamp(math.floor(tonumber(options.MaxRecords) or 300), 10, 2000)
        local lineHeight = 52
        local headerHeight = options.Name and 26 or 0
        local row = self:_row(headerHeight + maxVisible * lineHeight + 12,
            "EventTimeline_" .. tostring(options.Name or "Events"))
        local c = self:_control("EventTimeline", options, row)
        local items, byId, filtered, slots = {}, {}, {}, {}
        local alive, serial = true, 0
        c.Filter, c.Paused, c.Loading, c.Error = "All", false, false, nil
        if options.Name then
            text({ Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
                FontFace = inter(Enum.FontWeight.SemiBold), TextTruncate = Enum.TextTruncate.AtEnd,
                Size = UDim2.new(1, 0, 0, 21) })
        end
        local shell = create("Frame", {
            Name = "TimelineShell", Parent = row, Position = UDim2.fromOffset(0, headerHeight),
            BackgroundColor3 = themeColor(theme, "Field"),
            Size = UDim2.new(1, 0, 0, maxVisible * lineHeight + 8),
            ClipsDescendants = true,
        }, { corner(8), stroke(themeColor(theme, "FieldStroke")) })
        local scroll = create("ScrollingFrame", {
            Name = "TimelineScroll", Parent = shell, BackgroundTransparency = 1,
            BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
            ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
            ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(),
        })
        local message = text({ Name = "TimelineMessage", Parent = shell,
            Text = options.EmptyText or "No events", TextColor3 = themeColor(theme, "Muted"),
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.fromScale(1, 1), Visible = false })
        local function makeSlot(n)
            local frame = create("Frame", {
                Name = "TimelineEvent", Parent = scroll, BackgroundColor3 = themeColor(theme, "Tile"),
                BackgroundTransparency = n % 2 == 0 and .68 or .78,
                Size = UDim2.new(1, -9, 0, lineHeight - 3),
            }, { corner(5) })
            local dot = create("Frame", { Name = "Tone", Parent = frame,
                BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0,
                Position = UDim2.fromOffset(8, 12), Size = UDim2.fromOffset(6, 6),
            }, { corner(100) })
            local title = text({ Name = "EventTitle", Parent = frame, Text = "",
                TextColor3 = themeColor(theme, "Text"), TextSize = 12,
                Position = UDim2.fromOffset(21, 5), Size = UDim2.new(1, -105, 0, 18),
                TextTruncate = Enum.TextTruncate.AtEnd })
            local detail = text({ Name = "EventDetail", Parent = frame, Text = "",
                TextColor3 = themeColor(theme, "Muted"), TextSize = 10,
                Position = UDim2.fromOffset(21, 25), Size = UDim2.new(1, -29, 0, 17),
                TextTruncate = Enum.TextTruncate.AtEnd })
            local stamp = text({ Name = "EventTime", Parent = frame, Text = "",
                TextColor3 = themeColor(theme, "SubText"), TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -87, 0, 5), Size = UDim2.fromOffset(80, 18) })
            slots[n] = { Frame = frame, Dot = dot, Title = title, Detail = detail, Stamp = stamp }
        end
        local function visibleItems()
            filtered = {}
            for _, item in items do
                if c.Filter == "All" or c.Filter == item.Category then
                    table.insert(filtered, item)
                end
            end
        end
        local function render()
            if not alive or hub._destroyed then return end
            visibleItems()
            local count = #filtered
            local height = math.min(maxVisible, math.max(2, count)) * lineHeight + 8
            shell.Size = UDim2.new(1, 0, 0, height)
            row.Size = UDim2.new(1, 0, 0, headerHeight + height + 5)
            scroll.CanvasSize = UDim2.fromOffset(0, count * lineHeight + 8)
            message.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No events"))
            message.Visible = c.Error ~= nil or c.Loading or count == 0
            scroll.Visible = not message.Visible
            local first = math.clamp(math.floor(scroll.CanvasPosition.Y / math.max(lineHeight * hub._scale, 1)) + 1,
                1, math.max(1, count - maxVisible + 1))
            local total = math.min(count, maxVisible + 2)
            for i = 1, math.max(total, #slots) do
                local item = i <= total and filtered[first + i - 1] or nil
                local slot = slots[i]
                if item then
                    if not slot then makeSlot(i); slot = slots[i] end
                    slot.Frame.Visible = true
                    slot.Frame.Position = UDim2.fromOffset(4, (first + i - 2) * lineHeight + 3)
                    slot.Title.Text, slot.Detail.Text = item.Title, item.Detail
                    slot.Stamp.Text = item.Time == nil and "" or tostring(item.Time)
                    local tone = item.Tone or EVENT_TONES[string.lower(item.Category)] or "SubText"
                    if not theme[tone] then tone = "SubText" end
                    setThemed(slot.Dot, "BackgroundColor3", themeColor(theme, tone))
                elseif slot then
                    slot.Frame.Visible = false
                end
            end
        end
        local function insert(item)
            serial += 1
            local source = table.clone(item)
            source.Id = source.Id or source.Key or ("event-" .. serial)
            local entry = eventCopy(source)
            assert(entry.Id ~= "" and not byId[entry.Id], "EventTimeline requires unique event IDs")
            table.insert(items, entry)
            byId[entry.Id] = entry
            while #items > maxRecords do
                local removed = table.remove(items, 1)
                byId[removed.Id] = nil
            end
        end
        function c:Append(event)
            if not alive then return false end
            assert(type(event) == "table", "EventTimeline:Append requires event table")
            insert(event)
            if not self.Paused then render() end
            self:_dataEvent("Data", { Operation = "Append", Id = tostring(event.Id or event.Key or ("event-" .. serial)) })
            return true
        end
        function c:Set(events)
            if not alive then return false end
            assert(type(events) == "table", "EventTimeline:Set requires array")
            local nextItems, nextLookup, nextSerial = {}, {}, serial
            for _, event in events do
                assert(type(event) == "table", "EventTimeline item must be a table")
                nextSerial += 1
                local source = table.clone(event)
                source.Id = source.Id or source.Key or ("event-" .. nextSerial)
                local item = eventCopy(source)
                assert(item.Id ~= "" and not nextLookup[item.Id], "EventTimeline duplicate ID")
                table.insert(nextItems, item)
                nextLookup[item.Id] = item
            end
            while #nextItems > maxRecords do
                local removed = table.remove(nextItems, 1)
                nextLookup[removed.Id] = nil
            end
            items, byId, serial = nextItems, nextLookup, nextSerial
            if not self.Paused then render() end
            return true
        end
        function c:Get()
            local result = {}
            for i, item in items do result[i] = table.clone(item) end
            return result
        end
        function c:Remove(id)
            id = tostring(id)
            local item = byId[id]
            if not item then return false end
            byId[id] = nil
            local index = table.find(items, item)
            if index then table.remove(items, index) end
            if not self.Paused then render() end
            return true
        end
        function c:SetFilter(category)
            self.Filter = category and tostring(category) or "All"
            scroll.CanvasPosition = Vector2.zero
            render()
            self:_dataEvent("Filter", self.Filter)
            return true
        end
        function c:SetPaused(value)
            self.Paused = value == true
            if not self.Paused then render() end
        end
        function c:SetLoading(value)
            self.Loading = value == true
            if self.Loading then self.Error = nil end
            render()
        end
        function c:SetError(value)
            self.Loading = false
            self.Error = value == nil and nil or tostring(value)
            render()
        end
        function c:Clear() return self:Set({}) end
        function c:Destroy()
            if not alive then return end
            alive = false
            complexForgetControl(self)
            row:Destroy()
        end
        hub:_connect(scroll:GetPropertyChangedSignal("CanvasPosition"), render)
        hub:_connect(row.Destroying, function()
            alive = false
            table.clear(slots)
        end)
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
        c:Set(options.Events or options.Items or {})
        return hub:_finishRequiredControl(c)
    end
end
