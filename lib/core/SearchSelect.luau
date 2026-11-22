-- SPDX-License-Identifier: MPL-2.0
-- SearchSelect: searchable single/multiple selection with bounded recycled rows.
do
    local function normalizeChoices(source)
        assert(type(source) == "table", "SearchSelect.Options must be an array")
        local result, ids = {}, {}
        for i, value in source do
            local item = type(value) == "table" and table.clone(value)
                or { Value = value, Label = tostring(value) }
            item.Value = item.Value ~= nil and item.Value or item.Id or item.Label or item.Name or tostring(i)
            item.Label = tostring(item.Label or item.Name or item.Value)
            assert(not ids[item.Value], "SearchSelect requires unique option values")
            ids[item.Value] = true
            result[#result + 1] = item
        end
        return result
    end
    local function copySelection(value)
        if type(value) ~= "table" then return value end
        return table.clone(value)
    end
    function Section:SearchSelect(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local multi = options.Multi == true
        local row = self:_row(43, "SearchSelect_" .. (options.Name or ""))
        local c = self:_control("SearchSelect", options, row)
        c.Options = normalizeChoices(options.Options or options.Values or {})
        c.Multi = multi
        c.Value = multi and {} or nil
        local label = self:_labels(row, c.Name, options.Description, 150)
        local chip = create("TextButton", {
            Name = "SearchSelectChip", Parent = row,
            Text = "", AutoButtonColor = false,
            BackgroundColor3 = hub:GetToken("Color.InputSurface"),
            AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5),
            Size = UDim2.fromOffset(150, 32),
        }, { corner(hub:GetToken("Components.Input.Radius")),
            stroke(hub:GetToken("Color.InputBorder"), 1, .35) })
        local shown = text({ Name = "Value", Parent = chip, Text = options.Placeholder or "请选择",
            TextSize = hub:GetToken("Typography.ControlLabel.Size"),
            TextColor3 = hub:GetToken("Color.TextSecondary"),
            Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -32, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local arrow = iconLabel("chevron-down", 14, hub:GetToken("Color.TextSecondary"), {
            Parent = chip, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(1, -15, .5, 0),
        })
        local popup, popupConns, optionsViewport, queryBox, emptyLabel
        local filtered, nodes = {}, {}
        local rowHeight = 34
        local maxVisible = math.clamp(tonumber(options.MaxVisible) or 6, 3, 10)
        local recent = {}
        local function selected(item)
            if multi then return c.Value[item.Value] == true end
            return c.Value == item.Value
        end
        local function getValue()
            return copySelection(c.Value)
        end
        local function refreshLabel()
            if multi then
                local count = 0
                local names = {}
                for _, item in c.Options do
                    if selected(item) then
                        count += 1
                        if #names < 2 then table.insert(names, item.Label) end
                    end
                end
                shown.Text = count == 0 and (options.Placeholder or "请选择")
                    or count > 2 and (tostring(count) .. " 已选择")
                    or table.concat(names, ", ")
            else
                shown.Text = options.Placeholder or "请选择"
                for _, item in c.Options do
                    if selected(item) then shown.Text = item.Label; break end
                end
            end
        end
        function c:Get() return getValue() end
        function c:Set(value, silent)
            if multi then
                local picked = {}
                if type(value) == "table" then
                    for k, v in value do
                        if type(k) == "number" then picked[v] = true
                        elseif v then picked[k] = true end
                    end
                end
                self.Value = picked
            else
                self.Value = value
            end
            refreshLabel()
            if not silent then self:_emit(getValue()) end
            if popup and optionsViewport then c:_filter(queryBox and queryBox.Text or "") end
            return true
        end
        function c:SetOptions(source, silent)
            local replacement = normalizeChoices(source)
            local known = {}
            for _, item in replacement do known[item.Value] = true end
            -- Replacing a data source must not retain a selection that the
            -- user can no longer find or clear from the visible options.
            local changed = false
            if multi then
                local kept = {}
                for value, enabled in self.Value do
                    if enabled and known[value] then kept[value] = true
                    elseif enabled then changed = true end
                end
                self.Value = kept
            elseif self.Value ~= nil and not known[self.Value] then
                self.Value = nil
                changed = true
            end
            self.Options = replacement
            for i = #recent, 1, -1 do
                if not known[recent[i]] then table.remove(recent, i) end
            end
            refreshLabel()
            if popup then c:_filter(queryBox and queryBox.Text or "") end
            if changed and not silent then self:_emit(getValue()) end
            return true
        end
        local function disconnectPopup()
            popup = nil
            for _, connection in popupConns or {} do connection:Disconnect() end
            popupConns = nil
            for _, node in nodes do node:Destroy() end
            table.clear(nodes)
            queryBox, optionsViewport, emptyLabel = nil, nil, nil
        end
        function c:_filter(query)
            if not optionsViewport then return end
            local needle = string.lower(tostring(query or ""))
            table.clear(filtered)
            local seen = {}
            if needle == "" then
                for _, value in recent do
                    for _, item in self.Options do
                        if item.Value == value and not seen[item.Value] then
                            seen[item.Value] = true
                            table.insert(filtered, item)
                            break
                        end
                    end
                end
            end
            for _, item in self.Options do
                if not seen[item.Value] and (string.find(string.lower(item.Label), needle, 1, true)
                    or string.find(string.lower(tostring(item.Value)), needle, 1, true)) then
                    table.insert(filtered, item)
                end
            end
            optionsViewport.CanvasPosition = Vector2.zero
            self:_render()
        end
        function c:_render()
            if not optionsViewport then return end
            local scale = math.max(hub._scale or 1, .01)
            local start = math.floor(optionsViewport.CanvasPosition.Y /
                math.max(rowHeight * scale, 1)) + 1
            -- The shared popup may shrink to fit a short landscape viewport:
            -- never clamp scrolling based on the configured MaxVisible count.
            local viewportHeight = optionsViewport.AbsoluteSize.Y
            local visibleRows = viewportHeight > 0
                and math.max(1, math.floor(viewportHeight / (rowHeight * scale)))
                or maxVisible
            visibleRows = math.min(maxVisible, visibleRows)
            start = math.clamp(start, 1, math.max(1, #filtered - visibleRows + 1))
            local capacity = math.min(maxVisible + 2, #filtered)
            for i = 1, math.max(capacity, #nodes) do
                local item = filtered[start + i - 1]
                local hit = nodes[i]
                if item then
                    if not hit then
                        hit = create("TextButton", {
                            Name = "SearchRow", Parent = optionsViewport,
                            AutoButtonColor = false, Text = "",
                            BackgroundColor3 = hub:GetToken("Color.PopupItemSelected"),
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -8, 0, rowHeight - 1),
                            ZIndex = 45,
                        }, { corner(6) })
                        local valueText = text({ Name = "Label", Parent = hit,
                            Text = "", TextSize = hub:GetToken("Typography.PopupItem.Size"),
                            TextColor3 = hub:GetToken("Color.PopupItemText"),
                            Position = UDim2.fromOffset(10, 0),
                            Size = UDim2.new(1, -45, 1, 0), ZIndex = 46,
                            TextTruncate = Enum.TextTruncate.AtEnd })
                        text({ Name = "Check", Parent = hit, Text = "✓",
                            TextSize = 13, TextColor3 = hub:GetToken("Color.Accent"),
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Position = UDim2.new(1, -30, 0, 0),
                            Size = UDim2.fromOffset(20, rowHeight), ZIndex = 46 })
                        hub:BindToken(valueText, "TextColor3", "Color.PopupItemText")
                        local connection = hit.MouseButton1Click:Connect(function()
                            local chosen = hit:GetAttribute("OptionIndex")
                            local selectedItem = chosen and filtered[chosen]
                            if not selectedItem or selectedItem.Disabled == true
                                or not c:IsAvailable() then return end
                            if multi then
                                local nextValue = table.clone(c.Value)
                                nextValue[selectedItem.Value] = not nextValue[selectedItem.Value] or nil
                                c:Set(nextValue)
                            else
                                c:Set(selectedItem.Value)
                                hub:_closePopup()
                            end
                            table.insert(recent, 1, selectedItem.Value)
                            if #recent > 8 then table.remove(recent) end
                        end)
                        table.insert(popupConns, connection)
                        nodes[i] = hit
                    end
                    hit.Visible = true
                    hit.Position = UDim2.fromOffset(4, (start + i - 2) * rowHeight + 2)
                    hit:SetAttribute("OptionIndex", start + i - 1)
                    local chosen = selected(item)
                    hit.BackgroundTransparency = chosen and .78 or 1
                    hit:FindFirstChild("Label").Text = item.Label
                    hit:FindFirstChild("Check").Visible = chosen
                    hit.Active = item.Disabled ~= true
                elseif hit then
                    hit.Visible = false
                    hit:SetAttribute("OptionIndex", nil)
                end
            end
            optionsViewport.CanvasSize = UDim2.fromOffset(0, #filtered * rowHeight + 8)
            if emptyLabel then emptyLabel.Visible = #filtered == 0 end
        end
        function c:Open()
            if not self:IsAvailable() or hub._destroyed then return nil end
            if popup then return popup end
            local pane = create("Frame", {
                Name = "SearchSelectPopup", BackgroundColor3 = hub:GetToken("Color.PopupSurface"),
                -- Keep the popup visually attached to the 150px field. A
                -- wider menu remains available explicitly via options.Width.
                Size = UDim2.fromOffset(math.clamp(tonumber(options.Width) or 176,
                    150, 340), 44 + maxVisible * rowHeight), ZIndex = 42,
            }, { corner(hub:GetToken("Components.Popup.Radius")),
                stroke(hub:GetToken("Color.PopupBorder"), 1, .3) })
            queryBox = create("TextBox", {
                Name = "SearchQuery", Parent = pane,
                BackgroundColor3 = hub:GetToken("Color.InputSurface"),
                TextColor3 = hub:GetToken("Color.InputText"),
                PlaceholderText = options.SearchPlaceholder or "搜索选项…",
                PlaceholderColor3 = hub:GetToken("Color.TextMuted"),
                Text = "", ClearTextOnFocus = false,
                TextSize = 13, FontFace = inter(),
                Position = UDim2.fromOffset(7, 7),
                Size = UDim2.new(1, -14, 0, 30), ZIndex = 44,
            }, { corner(7), padding(0, 9) })
            optionsViewport = create("ScrollingFrame", {
                Name = "SearchResults", Parent = pane,
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Position = UDim2.fromOffset(4, 44),
                Size = UDim2.new(1, -8, 1, -48),
                CanvasSize = UDim2.new(), ZIndex = 43,
            })
            emptyLabel = text({ Name = "EmptyResults", Parent = pane,
                Text = options.EmptyText or "没有匹配的选项",
                TextSize = 12, TextColor3 = hub:GetToken("Color.TextMuted"),
                TextXAlignment = Enum.TextXAlignment.Center,
                Position = UDim2.fromOffset(5, 48),
                Size = UDim2.new(1, -10, 0, 40), Visible = false, ZIndex = 46 })
            popupConns = {}
            popup = pane
            table.insert(popupConns, queryBox:GetPropertyChangedSignal("Text"):Connect(function()
                c:_filter(queryBox.Text)
            end))
            table.insert(popupConns, optionsViewport:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                c:_render()
            end))
            table.insert(popupConns, optionsViewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                c:_render()
            end))
            table.insert(popupConns, hub.UIScale:GetPropertyChangedSignal("Scale"):Connect(function()
                c:_render()
            end))
            hub:_openPopup(chip, pane, disconnectPopup, {
                Align = "Center",
                Gap = 3,
                PreferBelow = true,
                MinimumBelowHeight = 96,
            })
            if not hub._popup or hub._popup.Frame ~= pane then
                disconnectPopup()
                return nil
            end
            hub:BindToken(pane, "BackgroundColor3", "Color.PopupSurface")
            hub:BindToken(queryBox, "BackgroundColor3", "Color.InputSurface")
            hub:BindToken(queryBox, "TextColor3", "Color.InputText")
            c:_filter("")
            return pane
        end
        function c:Close()
            if popup and hub._popup and hub._popup.Frame == popup then hub:_closePopup() end
        end
        function c:GetRecent() return table.clone(recent) end
        refreshLabel()
        c:Set(options.Default ~= nil and options.Default or (multi and {} or nil), true)
        hub:BindToken(chip, "BackgroundColor3", "Color.InputSurface")
        hub:BindToken(chip:FindFirstChildOfClass("UIStroke"), "Color", "Color.InputBorder")
        hub:BindToken(shown, "TextColor3", "Color.TextSecondary")
        hub:_connect(chip.MouseButton1Click, function()
            if popup then c:Close() else c:Open() end
        end)
        hub:_connect(row.Destroying, function()
            c:Close()
            c._disposed = true
            if popup then disconnectPopup() end
        end)
        return hub:_finishRequiredControl(c)
    end
end
