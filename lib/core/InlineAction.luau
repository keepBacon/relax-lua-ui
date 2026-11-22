-- SPDX-License-Identifier: MPL-2.0
-- Compact row-level actions: no second popup manager, no hover-only mobile controls.
do
    local function normalizeInlineActions(actions)
        assert(type(actions) == "table", "InlineAction.Actions must be an array")
        local out, seen = {}, {}
        for index, entry in actions do
            assert(type(entry) == "table", "InlineAction action must be a table")
            local action = table.clone(entry)
            action.Id = tostring(action.Id or index)
            assert(not seen[action.Id], "InlineAction duplicate action Id " .. action.Id)
            seen[action.Id] = true
            action.Text = tostring(action.Text or action.Name or action.Id)
            out[#out + 1] = action
        end
        return out
    end

    function Section:InlineAction(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(48, "InlineAction_" .. tostring(options.Name or ""))
        local c = self:_control("InlineAction", options, row)
        local actions = normalizeInlineActions(options.Actions or {})
        local buttons, connections = {}, {}
        local openMenu
        c.Value = nil
        local title = text({
            Name = "InlineTitle", Parent = row, Text = c.Name,
            TextSize = hub:GetToken("Typography.ControlLabel.Size"),
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            FontFace = inter(Enum.FontWeight.Medium),
            Position = UDim2.fromOffset(0, 2),
            Size = UDim2.new(1, -120, 0, 20),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local subtitle = text({
            Name = "InlineDescription", Parent = row,
            Text = tostring(options.Description or ""),
            TextColor3 = hub:GetToken("Color.TextMuted"),
            TextSize = hub:GetToken("Typography.ControlDescription.Size"),
            Position = UDim2.fromOffset(0, 23),
            Size = UDim2.new(1, -120, 0, 17),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Visible = options.Description ~= nil,
        })
        hub:BindToken(title, "TextColor3", "Color.TextPrimary")
        hub:BindToken(subtitle, "TextColor3", "Color.TextMuted")
        local rail = create("Frame", {
            Name = "InlineRail", Parent = row, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, 0, .5, 0),
            Size = UDim2.fromOffset(150, 42),
        }, { list(Enum.FillDirection.Horizontal, 5,
            Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center) })
        local more = create("TextButton", {
            Name = "InlineMore", Parent = rail, Text = "···",
            TextSize = 21, FontFace = inter(Enum.FontWeight.Bold),
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            BackgroundColor3 = hub:GetToken("Color.Surface2"),
            Size = UDim2.fromOffset(42, 40), Visible = false,
            AutoButtonColor = false, LayoutOrder = 1000,
        }, { corner(8) })
        hub:BindToken(more, "BackgroundColor3", "Color.Surface2")
        hub:BindToken(more, "TextColor3", "Color.TextPrimary")
        local function connect(signal, fn)
            local conn = signal:Connect(fn)
            connections[#connections + 1] = conn
            return conn
        end
        local function findAction(id)
            for _, entry in actions do
                if entry.Id == tostring(id) then return entry end
            end
            return nil
        end
        local function allowed(action)
            if not c:IsAvailable() then return false end
            if not action or action.Disabled or action.Locked then return false end
            if type(action.CanRun) == "function" then
                local ok, yes = pcall(action.CanRun, action)
                return ok and yes == true
            end
            return true
        end
        function c:Trigger(id)
            local action = findAction(id)
            if not action then return false, "unknown action" end
            if not allowed(action) then
                if self:IsAvailable() and (action.Locked or action.Disabled) then
                    hub:OpenActionDialog({
                        Title = "操作不可用", Content = action.Reason or "此操作暂不可用",
                        Icon = "lock",
                    })
                    return false, action.Reason or "操作暂不可用"
                end
                return false, "control unavailable"
            end
            local callback = action.Callback or options.Callback
            if type(callback) == "function" then
                local ok, err = pcall(callback, action.Id, action, self)
                if not ok then return false, tostring(err) end
            end
            self.Value = action.Id
            self:_emit(action.Id, action)
            return true
        end
        function c:Get() return self.Value end
        function c:SetActionLocked(id, locked, reason)
            local action = findAction(id)
            if not action then return false end
            action.Locked = locked == true
            if reason ~= nil then action.Reason = tostring(reason) end
            self:_layout()
            return true
        end
        function c:_layout()
            if self._disposed or hub._destroyed then return end
            local width = row.AbsoluteSize.X / math.max(hub._scale or 1, .01)
            if width < 1 then width = tonumber(options.FallbackWidth) or 300 end
            local reserve = math.max(108, math.floor(width * .38))
            local space = math.max(42, width - reserve - 8)
            local all = #actions
            local buttonsFit = math.floor((space + 5) / 85)
            local showCount = all
            if all > buttonsFit then
                showCount = math.max(0, math.min(all - 1, math.floor((space - 47) / 85)))
            end
            local overflow = all > showCount
            rail.Size = UDim2.fromOffset(math.max(42, showCount * 85 + (overflow and 47 or 0)), 42)
            title.Size = UDim2.new(1, -(rail.Size.X.Offset + 9), 0, 20)
            subtitle.Size = UDim2.new(1, -(rail.Size.X.Offset + 9), 0, 17)
            for i, item in buttons do
                item.Visible = i <= showCount
                local spec = actions[i]
                item.Active = self:IsAvailable()
                item.TextTransparency = allowed(spec) and 0 or .48
            end
            more.Visible = overflow
            more.Active = self:IsAvailable()
        end
        local function closeMenu()
            if openMenu and openMenu:IsOpen() then openMenu:Close() end
            openMenu = nil
        end
        local function redraw()
            closeMenu()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            for _, node in buttons do node:Destroy() end
            table.clear(buttons)
            for i, spec in actions do
                local btn = create("TextButton", {
                    Name = "Inline_" .. spec.Id, Parent = rail,
                    Text = spec.Text, AutoButtonColor = false,
                    TextColor3 = hub:GetToken(spec.Danger and "Color.Danger" or "Color.TextPrimary"),
                    BackgroundColor3 = hub:GetToken("Color.Surface2"),
                    FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                    Size = UDim2.fromOffset(80, 40), LayoutOrder = i,
                }, { corner(8) })
                hub:BindToken(btn, "BackgroundColor3", "Color.Surface2")
                hub:BindToken(btn, "TextColor3",
                    spec.Danger and "Color.Danger" or "Color.TextPrimary")
                buttons[i] = btn
                connect(btn.MouseButton1Click, function() c:Trigger(spec.Id) end)
            end
            connect(more.MouseButton1Click, function()
                if not c:IsAvailable() then return end
                local visible = 0
                for _, item in buttons do if item.Visible then visible += 1 end end
                local menuActions = {}
                for i = visible + 1, #actions do
                    local item = actions[i]
                    menuActions[#menuActions + 1] = {
                        Id = item.Id, Text = item.Text, Icon = item.Icon,
                        Danger = item.Danger, Disabled = not allowed(item),
                    }
                end
                if #menuActions == 0 then return end
                openMenu = hub:OpenContextMenu(more, menuActions, {
                    Callback = function(id) c:Trigger(id) end,
                })
            end)
            c:_layout()
        end
        function c:SetActions(newActions)
            actions = normalizeInlineActions(newActions)
            redraw()
            return true
        end
        function c:GetActions()
            local copy = {}
            for i, item in actions do copy[i] = table.clone(item) end
            return copy
        end
        function c:Destroy()
            if self._disposed then return end
            self._disposed = true
            closeMenu()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            if self.Flag and RiftUI.Flags[self.Flag] == self then RiftUI.Flags[self.Flag] = nil end
            local index = table.find(self.Section.Controls, self)
            if index then table.remove(self.Section.Controls, index) end
            local parent = self._moduleCard
            if parent and parent._moduleControls then
                local idx = table.find(parent._moduleControls, self)
                if idx then table.remove(parent._moduleControls, idx) end
            end
            for i = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[i].Result == self then table.remove(hub._recipe, i) end
            end
            for subscription in self._dataSubscriptions or {} do subscription:Disconnect() end
            row:Destroy()
        end
        hub:_connect(row:GetPropertyChangedSignal("AbsoluteSize"), function()
            if not c._disposed then c:_layout() end
        end)
        hub:_connect(row.Destroying, function()
            closeMenu()
            for _, conn in connections do conn:Disconnect() end
            c._disposed = true
        end)
        redraw()
        return hub:_finishRequiredControl(c)
    end
end
