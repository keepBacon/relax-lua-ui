-- SPDX-License-Identifier: MPL-2.0
-- An accessible command surface using the existing ContextMenu + InputFocus.
do
    local function normalizeCommands(values)
        assert(type(values) == "table", "AdaptiveCommandBar.Commands must be an array")
        local seen, result = {}, {}
        for index, original in values do
            assert(type(original) == "table", "command must be a table")
            local item = table.clone(original)
            item.Id = tostring(item.Id or index)
            assert(not seen[item.Id], "duplicate command Id: " .. item.Id)
            seen[item.Id] = true
            item.Text = tostring(item.Text or item.Name or item.Id)
            result[#result + 1] = item
            assert(#result <= 80, "AdaptiveCommandBar supports up to 80 commands")
        end
        return result
    end
    function Section:AdaptiveCommandBar(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(52, "AdaptiveCommandBar_" .. tostring(options.Name or ""))
        local c = self:_control("AdaptiveCommandBar", options, row)
        local commands = normalizeCommands(options.Commands or {})
        local filtered, buttons, buttonConns = {}, {}, {}
        local popup, disposed = nil, false
        c.Value = nil
        local shell = create("Frame", { Name = "CommandSurface", Parent = row,
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = hub:GetToken("Color.Surface1") },
            { corner(10), stroke(hub:GetToken("Color.BorderSubtle"), 1, .4) })
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        local search = create("TextBox", { Name = "CommandSearch", Parent = shell,
            Text = "", PlaceholderText = tostring(options.Placeholder or "搜索命令…"),
            ClearTextOnFocus = false,
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            PlaceholderColor3 = hub:GetToken("Color.TextMuted"),
            TextXAlignment = Enum.TextXAlignment.Left, FontFace = inter(),
            BackgroundTransparency = 1, TextSize = 12,
            Position = UDim2.fromOffset(12, 4),
            Size = UDim2.new(1, -64, 0, 40) })
        hub:BindToken(search, "TextColor3", "Color.TextPrimary")
        hub:BindToken(search, "PlaceholderColor3", "Color.TextMuted")
        local rail = create("Frame", { Name = "CommandRail", Parent = shell,
            BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -4, 0, 4),
            Size = UDim2.fromOffset(40, 40) }, {
            list(Enum.FillDirection.Horizontal, 4,
                Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
        })
        local more = create("TextButton", { Name = "CommandMore", Parent = rail,
            BackgroundColor3 = hub:GetToken("Color.Surface2"),
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            Text = "···", FontFace = inter(Enum.FontWeight.Bold), TextSize = 20,
            Size = UDim2.fromOffset(40, 40), LayoutOrder = 999,
            AutoButtonColor = false, Visible = false }, { corner(7) })
        hub:BindToken(more, "BackgroundColor3", "Color.Surface2")
        hub:BindToken(more, "TextColor3", "Color.TextPrimary")
        local function closeMenu()
            if popup and popup.IsOpen and popup:IsOpen() then popup:Close() end
            popup = nil
        end
        local function canRun(command)
            if not c:IsAvailable() or command.Disabled or command.Locked then return false end
            if type(command.CanRun) == "function" then
                local ok, value = pcall(command.CanRun, command)
                return ok and value == true
            end
            return true
        end
        local function find(id)
            for _, item in commands do
                if item.Id == tostring(id) then return item end
            end
            return nil
        end
        function c:Run(id)
            if disposed then return false, "destroyed" end
            local cmd = find(id)
            if not cmd then return false, "unknown command" end
            if not canRun(cmd) then return false, cmd.Reason or "command unavailable" end
            local callback = cmd.Callback or options.OnExecute
            if type(callback) == "function" then
                local ok, value = pcall(callback, cmd.Id, cmd, self)
                if not ok then return false, tostring(value) end
                if value == false then return false, "command rejected" end
            end
            self.Value = cmd.Id
            self:_emit(cmd.Id, cmd)
            return true
        end
        function c:Get() return self.Value end
        function c:GetCommands()
            local result = {}
            for i, command in commands do result[i] = table.clone(command) end
            return result
        end
        function c:GetQuery() return search.Text end
        local function filter()
            table.clear(filtered)
            local query = string.lower(search.Text)
            for _, item in commands do
                if query == "" or string.find(string.lower(item.Text .. " " ..
                    tostring(item.Description or "") .. " " .. item.Id), query, 1, true) then
                    filtered[#filtered + 1] = item
                end
            end
        end
        local shown = 0
        function c:_layout()
            if disposed or hub._destroyed then return end
            local width = shell.AbsoluteSize.X / math.max(hub._scale or 1, .01)
            if width < 1 then width = tonumber(options.FallbackWidth) or 320 end
            -- Search keeps >= 116px (or 42% at larger sizes).
            local budget = math.max(42, math.min(250, width - math.max(116, width * .42) - 12))
            local count = math.min(#filtered, 3)
            local fit = math.floor((budget + 4) / 86)
            shown = #filtered <= fit and math.min(count, fit)
                or math.max(0, math.min(count, math.floor((budget - 44) / 86)))
            local overflow = #filtered > shown
            rail.Size = UDim2.fromOffset(shown * 86 + (overflow and 44 or 0), 40)
            search.Size = UDim2.new(1, -(rail.Size.X.Offset + 20), 0, 40)
            for i, btn in buttons do btn.Visible = i <= shown end
            more.Visible = overflow
            more.Active = c:IsAvailable()
        end
        local function clearButtons()
            closeMenu()
            for _, conn in buttonConns do conn:Disconnect() end
            table.clear(buttonConns)
            for _, button in buttons do button:Destroy() end
            table.clear(buttons)
        end
        local function redraw()
            clearButtons()
            filter()
            for i = 1, math.min(3, #filtered) do
                local command = filtered[i]
                local btn = create("TextButton", { Name = "Command_" .. command.Id,
                    Parent = rail, Text = command.Text,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    FontFace = inter(Enum.FontWeight.Medium), TextSize = 11,
                    TextColor3 = hub:GetToken(command.Danger and "Color.Danger"
                        or "Color.TextPrimary"),
                    BackgroundColor3 = hub:GetToken("Color.Surface2"),
                    Size = UDim2.fromOffset(82, 40), LayoutOrder = i,
                    AutoButtonColor = false }, { corner(7) })
                hub:BindToken(btn, "BackgroundColor3", "Color.Surface2")
                hub:BindToken(btn, "TextColor3", command.Danger
                    and "Color.Danger" or "Color.TextPrimary")
                btn.TextTransparency = canRun(command) and 0 or .5
                buttons[i] = btn
                buttonConns[#buttonConns + 1] = btn.MouseButton1Click:Connect(function()
                    c:Run(command.Id)
                end)
            end
            c:_layout()
        end
        function c:SetCommands(nextCommands)
            if disposed then return false end
            commands = normalizeCommands(nextCommands)
            redraw()
            return true
        end
        function c:SetQuery(value)
            if disposed then return false end
            search.Text = tostring(value or "")
            redraw()
            return true
        end
        function c:Focus()
            if disposed then return false end
            search:CaptureFocus()
            return true
        end
        local connections = {}
        local function connect(signal, fn)
            local conn = signal:Connect(fn)
            connections[#connections + 1] = conn
        end
        connect(more.MouseButton1Click, function()
            if not c:IsAvailable() then return end
            closeMenu()
            local entries = {}
            for i = shown + 1, #filtered do
                local cmd = filtered[i]
                entries[#entries + 1] = {
                    Id = cmd.Id, Text = cmd.Text, Icon = cmd.Icon,
                    Disabled = not canRun(cmd), Danger = cmd.Danger }
            end
            if #entries == 0 then return end
            popup = hub:OpenContextMenu(more, entries, {
                Callback = function(id) c:Run(id) end,
            })
        end)
        connect(search:GetPropertyChangedSignal("Text"), redraw)
        connect(search.FocusLost, function(enter)
            if not enter or not c:IsAvailable() then return end
            for _, command in filtered do
                if canRun(command) then c:Run(command.Id); break end
            end
        end)
        connect(shell:GetPropertyChangedSignal("AbsoluteSize"), function()
            if not disposed then c:_layout() end
        end)
        function c:Destroy()
            if disposed then return end
            disposed, self._disposed = true, true
            clearButtons()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            if self.Flag and RiftUI.Flags[self.Flag] == self then RiftUI.Flags[self.Flag] = nil end
            local i = table.find(self.Section.Controls, self)
            if i then table.remove(self.Section.Controls, i) end
            for j = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[j].Result == self then table.remove(hub._recipe, j) end
            end
            for sub in self._dataSubscriptions or {} do sub:Disconnect() end
            row:Destroy()
        end
        connect(row.Destroying, function()
            disposed = true
            clearButtons()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            c._disposed = true
        end)
        redraw()
        return hub:_finishRequiredControl(c)
    end
end
