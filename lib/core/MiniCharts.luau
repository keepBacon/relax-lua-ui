-- SPDX-License-Identifier: MPL-2.0
-- Lightweight, bounded charts: redraw on Set/Append only (no heartbeat/tween loop).
do
    local CHART_TYPES = { Sparkline = true, Bars = true, Progress = true,
        Ring = true, Heatmap = true }
    local function valuesOf(raw)
        assert(type(raw) == "table", "MiniChart.Data must be an array")
        local values = {}
        for _, item in raw do
            local number = type(item) == "table" and item.Value or item
            assert(type(number) == "number" and number == number and
                math.abs(number) < 1000000000, "MiniChart values must be finite numbers")
            values[#values + 1] = number
            if #values >= 60 then break end
        end
        return values
    end
    local function copyValues(items)
        local result = {}
        for i, value in items do result[i] = value end
        return result
    end
    function Section:MiniChart(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local kind = options.Type or "Sparkline"
        assert(CHART_TYPES[kind], "MiniChart Type must be Sparkline, Bars, Progress, Ring or Heatmap")
        local samples = valuesOf(options.Data or {})
        local limit = math.clamp(math.floor(tonumber(options.Capacity) or 32), 2, 60)
        while #samples > limit do table.remove(samples, 1) end
        local height = math.clamp(math.floor(tonumber(options.Height) or 116), 80, 210)
        local row = self:_row(height, "MiniChart_" .. tostring(options.Name or kind))
        local c = self:_control("MiniChart", options, row)
        c.Value = copyValues(samples)
        local title = text({ Name = "ChartTitle", Parent = row,
            Text = tostring(options.Name or kind),
            TextColor3 = hub:GetToken("Color.TextPrimary"), TextSize = 12,
            FontFace = inter(Enum.FontWeight.Medium),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Size = UDim2.new(1, -72, 0, 20) })
        local valueLabel = text({ Name = "ChartValue", Parent = row, Text = "—",
            TextColor3 = hub:GetToken("Color.TextSecondary"), TextSize = 12,
            FontFace = inter(Enum.FontWeight.SemiBold),
            TextXAlignment = Enum.TextXAlignment.Right,
            Position = UDim2.new(1, -76, 0, 0), Size = UDim2.fromOffset(76, 20) })
        hub:BindToken(title, "TextColor3", "Color.TextPrimary")
        hub:BindToken(valueLabel, "TextColor3", "Color.TextSecondary")
        local surface = create("Frame", { Name = "ChartSurface", Parent = row,
            Position = UDim2.fromOffset(0, 25), Size = UDim2.new(1, 0, 1, -25),
            BackgroundTransparency = 1, ClipsDescendants = true })
        local nodes = {}
        local rangeMin = tonumber(options.Min)
        local rangeMax = tonumber(options.Max)
        local function rect(name, pos, size, color, radius, rotation)
            local node = create("Frame", { Name = name, Parent = surface,
                BorderSizePixel = 0, BackgroundColor3 = color,
                Position = pos, Size = size, Rotation = rotation or 0 })
            if radius then corner(radius).Parent = node end
            nodes[#nodes + 1] = node
            return node
        end
        local function bounds()
            local lo, hi = rangeMin, rangeMax
            for _, v in samples do
                lo = lo and math.min(lo, v) or v
                hi = hi and math.max(hi, v) or v
            end
            if kind == "Progress" or kind == "Ring" then
                lo = rangeMin or 0
                hi = rangeMax or 100
            end
            lo = lo or 0
            hi = hi or 1
            if hi <= lo then hi = lo + 1 end
            return lo, hi
        end
        local function norm(v, lo, hi)
            return math.clamp((v - lo) / (hi - lo), 0, 1)
        end
        local function render()
            if c._disposed or hub._destroyed then return end
            for _, node in nodes do node:Destroy() end
            table.clear(nodes)
            local count = #samples
            local current = count > 0 and samples[count] or nil
            valueLabel.Text = current and (string.format("%.1f", current)
                .. tostring(options.Suffix or "")) or "—"
            if count == 0 then
                text({ Name = "ChartEmpty", Parent = surface, Text = "暂无图表数据",
                    TextSize = 11, TextColor3 = hub:GetToken("Color.TextMuted"),
                    Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
                local empty = surface:FindFirstChild("ChartEmpty")
                if empty then nodes[#nodes + 1] = empty end
                return
            end
            local lo, hi = bounds()
            local accent = hub:GetToken("Color.Accent")
            local muted = hub:GetToken("Color.SurfaceActive")
            if kind == "Progress" then
                rect("Track", UDim2.new(0, 4, .5, -6),
                    UDim2.new(1, -8, 0, 12), muted, 6)
                rect("Fill", UDim2.new(0, 4, .5, -6),
                    UDim2.new(norm(current, lo, hi), -8 * norm(current, lo, hi), 0, 12),
                    accent, 6)
            elseif kind == "Ring" then
                local n = 24
                local filled = math.floor(norm(current, lo, hi) * n + .5)
                for i = 1, n do
                    local angle = (i - 1) / n * math.pi * 2 - math.pi / 2
                    local x, y = .5 + math.cos(angle) * .25,
                        .5 + math.sin(angle) * .38
                    rect("Arc_" .. i, UDim2.new(x, -7, y, -3),
                        UDim2.fromOffset(14, 6), i <= filled and accent or muted,
                        3, math.deg(angle) + 90)
                end
            elseif kind == "Heatmap" then
                local columns = math.min(10, count)
                local rows = math.ceil(count / columns)
                for i, v in samples do
                    local col, line = (i - 1) % columns, math.floor((i - 1) / columns)
                    local cell = rect("Cell_" .. i,
                        UDim2.new(col / columns, 2, line / rows, 2),
                        UDim2.new(1 / columns, -4, 1 / rows, -4),
                        norm(v, lo, hi) > .5 and accent or muted, 3)
                    cell.BackgroundTransparency = .15 + (1 - norm(v, lo, hi)) * .65
                end
            elseif kind == "Bars" then
                local columns = math.min(count, 24)
                local start = count - columns
                for i = 1, columns do
                    local fraction = norm(samples[start + i], lo, hi)
                    rect("Bar_" .. i,
                        UDim2.new((i - 1) / columns, 2, 1 - fraction, 0),
                        UDim2.new(1 / columns, -4, fraction, 0), accent, 2)
                end
            else
                -- Line segments are native Frames; at most 59, no image atlas.
                local width = surface.AbsoluteSize.X / math.max(hub._scale or 1, .01)
                local tall = surface.AbsoluteSize.Y / math.max(hub._scale or 1, .01)
                if width < 10 then width = 250 end
                if tall < 10 then tall = height - 25 end
                if count == 1 then
                    rect("Point", UDim2.new(.5, -3, 1 - norm(current, lo, hi), -3),
                        UDim2.fromOffset(6, 6), accent, 3)
                else
                    for i = 2, count do
                        local x1 = (i - 2) / (count - 1) * (width - 8) + 4
                        local x2 = (i - 1) / (count - 1) * (width - 8) + 4
                        local y1 = (1 - norm(samples[i - 1], lo, hi)) * (tall - 8) + 4
                        local y2 = (1 - norm(samples[i], lo, hi)) * (tall - 8) + 4
                        local dx, dy = x2 - x1, y2 - y1
                        local segment = rect("Segment_" .. i,
                            UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
                            UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), 2),
                            accent, 1, math.deg(math.atan2(dy, dx)))
                        segment.AnchorPoint = Vector2.new(.5, .5)
                    end
                end
            end
        end
        function c:Get() return copyValues(samples) end
        function c:GetData() return self:Get() end
        function c:SetData(raw, silent)
            if self._disposed then return false end
            local nextData = valuesOf(raw)
            while #nextData > limit do table.remove(nextData, 1) end
            samples = nextData
            self.Value = copyValues(samples)
            render()
            if not silent then self:_emit(self:Get()) end
            return true
        end
        function c:Set(raw, silent) return self:SetData(raw, silent) end
        function c:Append(value, silent)
            if self._disposed then return false end
            local nextData = self:Get()
            nextData[#nextData + 1] = value
            return self:SetData(nextData, silent)
        end
        function c:SetType(nextType)
            if not CHART_TYPES[nextType] or self._disposed then return false end
            kind = nextType
            render()
            return true
        end
        function c:SetRange(minValue, maxValue)
            if type(minValue) ~= "number" or type(maxValue) ~= "number"
                or maxValue <= minValue then return false end
            rangeMin, rangeMax = minValue, maxValue
            render()
            return true
        end
        function c:GetType() return kind end
        function c:Destroy()
            if self._disposed then return end
            self._disposed = true
            if self.Flag and RiftUI.Flags[self.Flag] == self then RiftUI.Flags[self.Flag] = nil end
            local i = table.find(self.Section.Controls, self)
            if i then table.remove(self.Section.Controls, i) end
            for j = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[j].Result == self then table.remove(hub._recipe, j) end
            end
            for subscription in self._dataSubscriptions or {} do subscription:Disconnect() end
            row:Destroy()
        end
        hub:_connect(surface:GetPropertyChangedSignal("AbsoluteSize"), function()
            if not c._disposed and kind == "Sparkline" then render() end
        end)
        hub:WatchDesignTokens(function()
            if not c._disposed then render() end
        end)
        render()
        return hub:_finishRequiredControl(c)
    end
end
