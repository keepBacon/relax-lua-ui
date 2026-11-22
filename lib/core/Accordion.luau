-- SPDX-License-Identifier: MPL-2.0
-- Accordion: lightweight content-only disclosure; no module toggle or favorite.
do
    local function accordionItems(items)
        assert(type(items) == "table", "Accordion.Items must be an array")
        local out, seen = {}, {}
        for i, source in items do
            assert(type(source) == "table", "Accordion item must be a table")
            local item = table.clone(source)
            item.Id = tostring(item.Id or item.Key or i)
            assert(not seen[item.Id], "Accordion IDs must be unique")
            seen[item.Id] = true
            item.Title = tostring(item.Title or item.Name or item.Id)
            item.Content = tostring(item.Content or item.Description or "")
            out[#out + 1] = item
        end
        return out
    end
    function Section:Accordion(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(0, "Accordion_" .. (options.Name or ""))
        row.AutomaticSize = Enum.AutomaticSize.Y
        local c = self:_control("Accordion", options, row)
        local single = options.Single ~= false
        local items = accordionItems(options.Items or {})
        local expanded = {}
        local searchPeek = false
        local slots = {}
        local connections = {}
        local shell = create("Frame", {
            Name = "AccordionShell", Parent = row,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = hub:GetToken("Color.Surface1"),
            BackgroundTransparency = .36,
        }, { corner(hub:GetToken("Radius.S")),
            stroke(hub:GetToken("Color.BorderSubtle"), 1, .55),
            padding(5, 7), list(Enum.FillDirection.Vertical, 3) })
        local function bind(signal, fn)
            local conn = signal:Connect(fn)
            table.insert(connections, conn)
        end
        local function effective(id)
            return expanded[id] == true or searchPeek == true
        end
        local function contentHeight(slot)
            return math.max(28, math.ceil(slot.Label.TextBounds.Y /
                math.max(hub._scale or 1, .01)) + 20)
        end
        local function refresh(slot, animate)
            local opened = effective(slot.Id)
            local target = opened and contentHeight(slot) or 0
            if opened then slot.Clip.Visible = true end
            local id = "accordion:" .. tostring(slot.Clip)
            local key = id .. ":arrow"
            if animate then
                Motion.play(hub, id, slot.Clip, {
                    Size = UDim2.new(1, 0, 0, target),
                }, Motion.Presets.Control, function()
                    if not slot.Clip.Parent then return end
                    slot.Clip.Visible = effective(slot.Id)
                    slot.Clip.Size = UDim2.new(1, 0, 0,
                        effective(slot.Id) and contentHeight(slot) or 0)
                end)
                if slot.Arrow then Motion.play(hub, key, slot.Arrow,
                    { Rotation = opened and 90 or 0 }, Motion.Presets.Micro) end
            else
                Motion.cancel(hub, id)
                Motion.cancel(hub, key)
                slot.Clip.Size = UDim2.new(1, 0, 0, target)
                slot.Clip.Visible = opened
                if slot.Arrow then slot.Arrow.Rotation = opened and 90 or 0 end
            end
        end
        local function repaint(animate)
            for _, slot in slots do refresh(slot, animate) end
        end
        local function emit()
            c.Value = table.clone(expanded)
            c:_emit(c:GetExpanded())
        end
        function c:GetExpanded() return table.clone(expanded) end
        function c:Get() return self:GetExpanded() end
        function c:IsExpanded(id) return expanded[tostring(id)] == true end
        function c:SetExpanded(id, enabled, silent)
            id = tostring(id)
            local found = false
            for _, item in items do
                if item.Id == id then found = true; break end
            end
            if not found then return false, "unknown accordion item" end
            enabled = enabled == true
            if enabled and single then table.clear(expanded) end
            expanded[id] = enabled or nil
            repaint(true)
            if not silent then emit() end
            return true
        end
        function c:Expand(id, silent) return self:SetExpanded(id, true, silent) end
        function c:Collapse(id, silent) return self:SetExpanded(id, false, silent) end
        function c:Toggle(id, silent)
            return self:SetExpanded(id, not self:IsExpanded(id), silent)
        end
        function c:Set(values, silent)
            if type(values) ~= "table" then return false, "expected table" end
            local known = {}
            for _, item in items do known[item.Id] = true end
            local nextExpanded = {}
            for key, value in values do
                local id = type(key) == "number" and tostring(value) or tostring(key)
                if (type(key) == "number" or value == true) and known[id] then
                    nextExpanded[id] = true
                    if single then break end
                end
            end
            expanded = nextExpanded
            repaint(false)
            if not silent then emit() end
            return true
        end
        function c:_setSearchPeek(on)
            searchPeek = on == true
            repaint(false)
        end
        function c:SetItems(nextItems)
            local newItems = accordionItems(nextItems)
            local available = {}
            for _, item in newItems do available[item.Id] = true end
            for id in expanded do if not available[id] then expanded[id] = nil end end
            items = newItems
            self:Render()
            return true
        end
        function c:Render()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            for _, slot in slots do
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip))
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip) .. ":arrow")
                slot.Holder:Destroy()
            end
            table.clear(slots)
            for i, item in items do
                local holder = create("Frame", {
                    Name = "Item_" .. item.Id, Parent = shell,
                    LayoutOrder = i, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, { list(Enum.FillDirection.Vertical, 0) })
                local head = create("TextButton", {
                    Name = "AccordionHeader", Parent = holder,
                    BackgroundColor3 = hub:GetToken("Color.Surface2"),
                    BackgroundTransparency = .7,
                    Text = "", AutoButtonColor = false,
                    Size = UDim2.new(1, 0, 0, 42),
                }, { corner(6) })
                local arrow = iconLabel("chevron-right", 15,
                    hub:GetToken("Color.TextSecondary"), {
                    Parent = head, AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.new(0, 18, .5, 0),
                })
                local heading = text({
                    Name = "Title", Parent = head,
                    Text = item.Title, TextSize = hub:GetToken("Typography.ControlLabel.Size"),
                    FontFace = inter(Enum.FontWeight.Medium),
                    TextColor3 = hub:GetToken("Color.TextPrimary"),
                    Position = UDim2.fromOffset(38, 0),
                    Size = UDim2.new(1, -48, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                })
                local clip = create("Frame", {
                    Name = "AccordionClip", Parent = holder,
                    BackgroundTransparency = 1, ClipsDescendants = true,
                    Visible = false, Size = UDim2.new(1, 0, 0, 0),
                })
                local content = create("Frame", {
                    Name = "AccordionContent", Parent = clip,
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, { padding(10, 12) })
                local body = text({
                    Name = "Content", Parent = content, Text = item.Content,
                    TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
                    TextSize = hub:GetToken("Typography.ControlDescription.Size"),
                    TextColor3 = hub:GetToken("Color.TextSecondary"),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                })
                local slot = { Id = item.Id, Holder = holder, Clip = clip,
                    Arrow = arrow, Label = body }
                slots[i] = slot
                hub:BindToken(heading, "TextColor3", "Color.TextPrimary")
                hub:BindToken(body, "TextColor3", "Color.TextSecondary")
                bind(body:GetPropertyChangedSignal("TextBounds"), function()
                    if effective(slot.Id) then refresh(slot, false) end
                end)
                bind(head.MouseButton1Click, function()
                    if c:IsAvailable() then c:Toggle(slot.Id) end
                end)
                refresh(slot, false)
            end
        end
        function c:Destroy()
            if self._disposed then return end
            self._disposed = true
            for _, conn in connections do conn:Disconnect() end
            for _, slot in slots do
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip))
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip) .. ":arrow")
            end
            row:Destroy()
        end
        c:Render()
        local defaults = type(options.Default) == "table" and options.Default or {}
        if #defaults == 0 and options.DefaultExpanded then
            for _, item in items do if item.Expanded then defaults[item.Id] = true end end
        end
        c:Set(defaults, true)
        hub:_connect(row.Destroying, function()
            for _, conn in connections do conn:Disconnect() end
            for _, slot in slots do
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip))
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip) .. ":arrow")
            end
        end)
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        hub:BindToken(shell:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
        return hub:_finishRequiredControl(c)
    end
end
