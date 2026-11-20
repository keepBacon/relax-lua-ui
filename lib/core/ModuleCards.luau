-- SPDX-License-Identifier: MPL-2.0
-- Optional module cards and compact information hierarchy for the original Section API.
-- Existing Section controls are reused without wrappers or replacements.
local MODULE_TONES = { Success = true, Danger = true, Warning = true, Accent = true,
    Text = true, SubText = true, Muted = true }

local function moduleTone(value)
    return MODULE_TONES[value] and value or "SubText"
end

local function moduleString(value)
    if value == nil then return "—" end
    return tostring(value)
end

local function moduleCopy(value)
    return type(value) == "table" and table.clone(value) or value
end

-- Legacy versions stored only the collapsed (true) preference. Use explicit
-- strings now so a user can persist an expansion even when Collapsed=true.
local function moduleIsExpanded(saved, initiallyCollapsed)
    if saved == "expanded" or saved == false then return true end
    if saved == "collapsed" or saved == true then return false end
    return not initiallyCollapsed
end

local function moduleInfoIndex(items)
    local index = {}
    for i, item in items do index[item.Key] = i end
    return index
end

local function moduleInfoSnapshot(items)
    local out = {}
    for i, item in items do out[i] = table.clone(item) end
    return out
end

function Section:ModuleCard(options)
    options = type(options) == "table" and options or { Name = moduleString(options) }
    local hub, theme = self.Hub, self.Hub.Theme
    local name = options.Name or "Module"
    local id = self.Id .. "/module/" .. moduleString(options.Id or name)
    local hasToggle = options.Flag ~= nil or options.Toggle == true
    local canCollapse = options.Collapsible ~= false
    local canFavorite = options.Favoritable ~= false
    local originalOrder = self._order + 1
    local saved = hub.SetupData or {}
    local savedFold = nil
    if type(saved.ModuleCards) == "table" then savedFold = saved.ModuleCards[id] end
    local savedFavorite = type(saved.ModuleFavorites) == "table" and saved.ModuleFavorites[id]
    local row = self:_row(0, "ModuleCard_" .. name)
    row.AutomaticSize = Enum.AutomaticSize.Y
    local surface = create("Frame", {
        Name = "ModuleSurface", BackgroundColor3 = themeColor(theme, "Tile"),
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
    }, { corner(10), stroke(themeColor(theme, "TileStroke"), 1) ,
        padding(7, 8, 7, 8),
        list(Enum.FillDirection.Vertical, 1) })
    local head = create("TextButton", {
        Name = "ModuleHead", BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 2, Parent = surface,
    })
    local titleX = 8
    if options.Icon then
        local icon = iconLabel(options.Icon, 17, theme.SubText, {
            AnchorPoint = Vector2.new(0, .5),
            Position = UDim2.new(0, 7, 0, 18),
            ZIndex = 4, Parent = head,
        })
        if icon then titleX = 32 end
    end
    local title = text({
        Parent = head, Name = "ModuleTitle", Text = name,
        FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 13,
        TextColor3 = themeColor(theme, "Text"),
        Position = UDim2.fromOffset(titleX, 4),
        Size = UDim2.new(1, -titleX - 80, 0, 19),
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
    })
    local description = text({
        Parent = head, Name = "ModuleSummary", Text = options.Description or options.Summary or "",
        TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
        Position = UDim2.fromOffset(titleX, 24),
        Size = UDim2.new(1, -titleX - 12, 0, 20),
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
    })
    local badge = text({
        Parent = head, Name = "ModuleBadge", Text = "",
        TextSize = 10, FontFace = inter(Enum.FontWeight.Medium),
        TextColor3 = themeColor(theme, "SubText"),
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 4),
        Size = UDim2.fromOffset(66, 17), ZIndex = 3,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local actionRight = canCollapse and 5 or 0
    local chevron
    if canCollapse then
        chevron = iconLabel("chevron-down", 13, theme.SubText, {
            AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -5, 0, 36),
            ZIndex = 4, Parent = head,
        })
        actionRight += 19
    end
    local favorite, favoriteIcon
    if canFavorite then
        favorite = create("TextButton", {
            Name = "Favorite", BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -actionRight, 0, 35),
            Size = UDim2.fromOffset(25, 28), ZIndex = 5, Parent = head,
        })
        favoriteIcon = iconLabel("star", 14, theme.Muted, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            Parent = favorite, ZIndex = 6,
        })
        actionRight += 27
    end
    local toggle, knob
    if hasToggle then
        toggle = create("TextButton", {
            Name = "ModuleSwitch", BackgroundColor3 = themeColor(theme, "Field"),
            Text = "", AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -actionRight - 3, 0, 35),
            Size = UDim2.fromOffset(28, 17), ZIndex = 5, Parent = head,
        }, { corner(9), stroke(themeColor(theme, "FieldStroke")) })
        knob = create("Frame", {
            Name = "ModuleThumb", BackgroundColor3 = themeColor(theme, "Text"),
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0, .5),
            Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(11, 11),
            ZIndex = 6, Parent = toggle,
        }, { corner(7) })
        actionRight += 36
    end
    local clip = create("Frame", {
        Name = "ModuleClip", BackgroundTransparency = 1,
        ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 2, Parent = surface,
    })
    local body = create("Frame", {
        Name = "ModuleBody", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = clip,
    }, { padding(4, 5, 5, 5), list(Enum.FillDirection.Vertical, 2) })
    local block = create("TextButton", {
        Name = "ModuleLocked", BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .30, Text = "", AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1), Active = true,
        Visible = false, ZIndex = 15, Parent = clip,
    })
    local lockText = text({
        Parent = block, Name = "LockReason", Text = "Module unavailable",
        TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.new(1, -14, 0, 32), TextWrapped = true, ZIndex = 16,
    })
    local parentCard = self._isModuleCard and self or self._moduleCard
    local card = setmetatable({
        Type = "ModuleCard", Name = name, Id = id,
        Hub = hub, Tab = self.Tab, Section = self, Parent = self,
        Rows = body, Frame = row, Surface = surface, Head = head,
        Controls = self.Controls, Requires = mergedRequirements(self.Requires, options.Requires),
        _internal = self._internal, _order = 0, _isModuleCard = true,
        _parentCard = parentCard, _moduleControls = {}, _default = options.Default == true,
        Flag = options.Flag, Value = options.Default == true,
        _expanded = not canCollapse or moduleIsExpanded(savedFold, options.Collapsed == true),
        _favorite = savedFavorite == true,
        _locked = options.Locked == true, _blocked = false, _hidden = false,
        _searchPeek = false, _animating = false,
    }, Section)
    card._moduleCard = parentCard
    card._hasToggle = hasToggle
    card._canCollapse = canCollapse
    card._canFavorite = canFavorite
    local motionKey = "module-card:" .. id
    local callbacks = {}

    local function saveMap(field, value)
        local map = table.clone(type(hub.SetupData and hub.SetupData[field]) == "table"
            and hub.SetupData[field] or {})
        map[id] = value
        hub:_savePref(field, map)
    end
    local function blocked()
        return card._locked or card._blocked
    end
    local function paintBlock()
        local off = blocked()
        block.Visible = off
        lockText.Text = card._locked and (options.LockReason or "Module locked")
            or (options.DependsReason or "Requires another module")
        if toggle then
            setThemed(toggle, "BackgroundColor3",
                themeColor(theme, card.Value and "Accent" or "Field"))
            setThemed(knob, "BackgroundColor3",
                themeColor(theme, card.Value and "AccentText" or "Text"))
            tween(knob, FAST, { Position = UDim2.new(0, card.Value and 14 or 3, .5, 0) })
        end
    end
    function card:Set(value, silent)
        if not self._hasToggle or blocked() then return false end
        value = value == true
        if self.Value == value then return true end
        self.Value = value
        paintBlock()
        -- Structural dependencies must update even on silent config restore.
        for _, fn in self._dependents or {} do
            local ok, err = pcall(fn, value)
            if not ok then warn("[RelaxUI] module dependent: " .. tostring(err)) end
        end
        for _, callback in callbacks do
            task.spawn(function()
                if not hub._destroyed then
                    local ok, err = pcall(callback, value)
                    if not ok then warn("[RelaxUI] module observer: " .. tostring(err)) end
                end
            end)
        end
        if not silent then
            hub:PlayUISound(value and "ToggleOn" or "ToggleOff")
            if type(options.Callback) == "function" then
                task.spawn(function()
                    if not hub._destroyed then
                        local ok, err = pcall(options.Callback, value)
                        if not ok then warn("[RelaxUI] module callback: " .. tostring(err)) end
                    end
                end)
            end
        end
        return true
    end
    function card:Get() return self.Value end
    function card:OnChanged(fn)
        if type(fn) == "function" then table.insert(callbacks, fn) end
        return self
    end
    function card:OffChanged(fn)
        local i = table.find(callbacks, fn)
        if not i then return false end
        table.remove(callbacks, i)
        return true
    end
    function card:SetLocked(on, reason)
        self._locked = on == true
        if reason ~= nil then options.LockReason = tostring(reason) end
        paintBlock()
    end
    function card:IsLocked() return blocked() end
    function card:SetSummary(value)
        description.Text = moduleString(value)
    end
    function card:SetStatus(status, tone)
        badge.Text = status and tostring(status) or ""
        setThemed(badge, "TextColor3", themeColor(theme, moduleTone(tone)))
    end
    local function height()
        return math.max(0, body.AbsoluteSize.Y / math.max(hub._scale, .01))
    end
    local function effective() return not canCollapse or card._expanded or card._searchPeek end
    local function resize(animate)
        local open = effective()
        local target = open and height() or 0
        if chevron then
            Motion.play(hub, motionKey .. ":arrow", chevron,
                { Rotation = open and 0 or -90 }, FAST)
        end
        if animate then
            card._animating = true
            local targetSize = UDim2.new(1, 0, 0, target)
            Motion.play(hub, motionKey, clip, { Size = targetSize }, SETTLE, function()
                card._animating = false
                if not hub._destroyed then
                    clip.Size = UDim2.new(1, 0, 0, effective() and height() or 0)
                end
            end)
        else
            Motion.cancel(hub, motionKey)
            card._animating = false
            clip.Size = UDim2.new(1, 0, 0, target)
        end
    end
    function card:SetExpanded(on, instant)
        if not canCollapse then return end
        on = on == true
        if self._expanded == on then return end
        self._expanded = on
        saveMap("ModuleCards", on and "expanded" or "collapsed")
        resize(not instant)
    end
    function card:IsExpanded() return effective() end
    function card:GetExpandedPreference() return self._expanded end
    function card:_setSearchPeek(on)
        on = on == true
        if self._searchPeek == on then return end
        self._searchPeek = on
        resize(false)
    end
    function card:SetFavorite(on)
        if not canFavorite then return end
        on = on == true
        if self._favorite == on then return end
        self._favorite = on
        row.LayoutOrder = self._favorite and -1000 + originalOrder or originalOrder
        if favoriteIcon then
            setThemed(favoriteIcon, "ImageColor3",
                themeColor(theme, self._favorite and "Accent" or "Muted"))
        end
        saveMap("ModuleFavorites", self._favorite)
    end
    function card:IsFavorite() return self._favorite end
    function card:SetVisible(on)
        self._hidden = on == false
        row.Visible = not self._hidden and not self._dependencyHidden
    end
    function card:Reset()
        if self._hasToggle then
            local locked, dep = self._locked, self._blocked
            self._locked, self._blocked = false, false
            self:Set(self._default, true)
            self._locked, self._blocked = locked, dep
            paintBlock()
        end
        for _, control in self._moduleControls do
            if control.Type == "ModuleCard" then
                control:Reset()
            elseif control.DefaultValue ~= nil and type(control.Set) == "function" then
                pcall(control.Set, control, moduleCopy(control.DefaultValue), true)
            end
        end
        if canCollapse then self:SetExpanded(options.Collapsed ~= true) end
    end
    function card:SetDependencyBlocked(on)
        self._blocked = on == true
        paintBlock()
    end

    if options.Flag then
        assert(type(options.Flag) == "string", "ModuleCard.Flag must be a string")
        RiftUI.Flags[options.Flag] = card
    end
    -- A card is a real search/command entity while its nested controls still
    -- belong to the original Section.  This preserves Flags and existing APIs.
    local function bindDependency(dep)
        if not dep then return end
        local control, equals, behavior
        if type(dep) == "table" and dep.Control == nil and dep.Flag == nil and dep.Get then
            control, equals, behavior = dep, true, "Disable"
        elseif type(dep) == "table" then
            control = dep.Control or (dep.Flag and RiftUI.Flags[dep.Flag])
            equals = dep.Equals
            if equals == nil then equals = true end
            behavior = dep.Behavior or "Disable"
        end
        if not control or type(control.Get) ~= "function" then return end
        local function apply(value)
            local active = value == equals
            if behavior == "Hide" then
                row.Visible = active and not card._hidden
                card._dependencyHidden = not active
            else
                card:SetDependencyBlocked(not active)
            end
        end
        apply(control:Get())
        if control.Type == "ModuleCard" or control.Type == "Toggle" then
            -- Core dependency state must update synchronously, including
            -- config restores performed with silent=true.
            control._dependents = control._dependents or {}
            table.insert(control._dependents, apply)
        elseif type(control.OnChanged) == "function" then
            control:OnChanged(apply)
        end
    end
    bindDependency(options.DependsOn)
    hub:_connect(body:GetPropertyChangedSignal("AbsoluteSize"), function()
        if not hub._destroyed and not card._animating and effective() then
            clip.Size = UDim2.new(1, 0, 0, height())
        end
    end)
    hub:_connect(head.MouseButton1Click, function()
        if canCollapse then card:SetExpanded(not card._expanded) end
    end)
    if favorite then
        hub:_connect(favorite.MouseButton1Click, function()
            card:SetFavorite(not card._favorite)
        end)
    end
    if toggle then
        hub:_connect(toggle.MouseButton1Click, function()
            card:Set(not card.Value)
        end)
    end
    card:SetStatus(options.Status, options.Tone)
    paintBlock()
    if card._favorite then
        row.LayoutOrder = -1000 + originalOrder
        if favoriteIcon then
            setThemed(favoriteIcon, "ImageColor3", themeColor(theme, "Accent"))
        end
    end
    if chevron then chevron.Rotation = effective() and 0 or -90 end
    resize(false)
    task.defer(function()
        if not hub._destroyed and row.Parent then resize(false) end
    end)
    table.insert(self.Controls, card)
    if parentCard then table.insert(parentCard._moduleControls, card) end
    hub:_record(self, "ModuleCard", options, card)
    return card
end

local function infoNormalize(items)
    local out = {}
    for i, item in type(items) == "table" and items or {} do
        if type(item) == "table" then
            local key = moduleString(item.Key or item.Id or item.Name or item.Label or i)
            table.insert(out, {
                Key = key, Label = moduleString(item.Label or item.Name or key),
                Value = moduleString(item.Value), Detail = item.Detail or item.Hint or "",
                Tone = moduleTone(item.Tone),
            })
        else
            table.insert(out, {
                Key = tostring(i), Label = tostring(i), Value = moduleString(item),
                Detail = "", Tone = "Text",
            })
        end
    end
    return out
end

function Section:InfoGrid(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local row = self:_row(0, "InfoGrid_" .. (options.Name or "Metrics"))
    local control = self:_control("InfoGrid", options, row)
    control.Items = {}
    local indexByKey = {}
    local captionH = options.Name and 22 or 0
    local caption
    if options.Name then
        caption = text({
            Parent = row, Text = options.Name, FontFace = inter(Enum.FontWeight.SemiBold),
            TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
            Size = UDim2.new(1, 0, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd,
        })
    end
    local grid = create("Frame", {
        Name = "MetricGrid", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, captionH),
        Size = UDim2.new(1, 0, 0, 0), Parent = row,
    })
    local tiles = {}
    local cellH, gap = 66, 6
    local function layout()
        if hub._destroyed then return end
        local width = grid.AbsoluteSize.X / math.max(hub._scale, .01)
        local maxColumns = math.clamp(math.floor(tonumber(options.Columns) or 2), 1, 4)
        local minWidth = math.max(74, tonumber(options.MinCellWidth) or 90)
        local cols = math.clamp(math.floor((width + gap) / (minWidth + gap)), 1, maxColumns)
        for i, tile in tiles do
            local col = (i - 1) % cols
            local nrow = math.floor((i - 1) / cols)
            tile.Position = UDim2.new(col / cols, col * gap / cols, 0, nrow * (cellH + gap))
            tile.Size = UDim2.new(1 / cols, -(cols - 1) * gap / cols, 0, cellH)
        end
        local count = math.ceil(#tiles / cols)
        local height = count > 0 and count * cellH + (count - 1) * gap or 0
        grid.Size = UDim2.new(1, 0, 0, height)
        row.Size = UDim2.new(1, 0, 0, captionH + height + (height > 0 and 4 or 0))
    end
    local function rebuild()
        for _, tile in tiles do tile:Destroy() end
        table.clear(tiles)
        for i, item in control.Items do
            local tile = create("Frame", {
                Name = "Metric_" .. item.Key,
                BackgroundColor3 = themeColor(theme, "Section"),
                BackgroundTransparency = .1, Parent = grid,
            }, { corner(8), stroke(themeColor(theme, "SectionStroke"), 1) })
            table.insert(tiles, tile)
            text({
                Parent = tile, Name = "Label", Text = item.Label, TextSize = 10,
                TextColor3 = themeColor(theme, "Muted"), Position = UDim2.fromOffset(9, 6),
                Size = UDim2.new(1, -18, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd,
            })
            text({
                Parent = tile, Name = "Value", Text = item.Value,
                FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 16,
                TextColor3 = themeColor(theme, item.Tone),
                Position = UDim2.fromOffset(9, 23),
                Size = UDim2.new(1, -18, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd,
            })
            text({
                Parent = tile, Name = "Hint", Text = tostring(item.Detail),
                TextSize = 10, TextColor3 = themeColor(theme, "Muted"),
                Position = UDim2.fromOffset(9, 46),
                Size = UDim2.new(1, -18, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd,
            })
        end
        layout()
    end
    -- Reuse tiles when keys/order are unchanged: live telemetry should not
    -- rebuild every GuiObject or trigger a layout pass for each value refresh.
    function control:Set(items)
        local nextItems = infoNormalize(items)
        local stable = #nextItems == #self.Items
        if stable then
            for i, item in nextItems do
                if self.Items[i].Key ~= item.Key then stable = false; break end
            end
        end
        self.Items = nextItems
        indexByKey = moduleInfoIndex(nextItems)
        if stable then
            for i, item in nextItems do
                local tile = tiles[i]
                if tile then
                    local label = tile:FindFirstChild("Label")
                    local readout = tile:FindFirstChild("Value")
                    local hint = tile:FindFirstChild("Hint")
                    if label and label.Text ~= item.Label then label.Text = item.Label end
                    if readout then
                        if readout.Text ~= item.Value then readout.Text = item.Value end
                        setThemed(readout, "TextColor3", themeColor(theme, item.Tone))
                    end
                    if hint and hint.Text ~= tostring(item.Detail) then
                        hint.Text = tostring(item.Detail)
                    end
                end
            end
        else
            rebuild()
        end
    end
    function control:Update(key, value, tone)
        local i = indexByKey[tostring(key)]
        local item = i and self.Items[i]
        if not item then return false end
        local nextValue = moduleString(value)
        if item.Value ~= nextValue then
            item.Value = nextValue
            local tile = tiles[i]
            local readout = tile and tile:FindFirstChild("Value")
            if readout then readout.Text = nextValue end
        end
        if tone and item.Tone ~= moduleTone(tone) then
            item.Tone = moduleTone(tone)
            local tile = tiles[i]
            local readout = tile and tile:FindFirstChild("Value")
            if readout then setThemed(readout, "TextColor3", themeColor(theme, item.Tone)) end
        end
        return true
    end
    function control:UpdateMany(values)
        for key, update in type(values) == "table" and values or {} do
            if type(update) == "table" and update.Value ~= nil then
                self:Update(key, update.Value, update.Tone)
            else
                self:Update(key, update)
            end
        end
    end
    function control:Upsert(item)
        assert(type(item) == "table" and item.Key ~= nil, "InfoGrid:Upsert needs a Key")
        local entry = infoNormalize({ item })[1]
        local current = indexByKey[entry.Key]
        local nextItems = moduleInfoSnapshot(self.Items)
        if current then nextItems[current] = entry else table.insert(nextItems, entry) end
        self:Set(nextItems)
        return true
    end
    function control:Remove(key)
        local i = indexByKey[tostring(key)]
        if not i then return false end
        local nextItems = moduleInfoSnapshot(self.Items)
        table.remove(nextItems, i)
        self:Set(nextItems)
        return true
    end
    function control:Clear() self:Set({}) end
    function control:Get() return moduleInfoSnapshot(self.Items) end
    hub:_connect(grid:GetPropertyChangedSignal("AbsoluteSize"), function()
        if row.Parent then layout() end
    end)
    control:Set(options.Items or {})
    return hub:_finishRequiredControl(control)
end

function Section:InfoList(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local row = self:_row(0, "InfoList_" .. (options.Name or "Details"))
    row.AutomaticSize = Enum.AutomaticSize.Y
    local control = self:_control("InfoList", options, row)
    control.Items = {}
    local indexByKey = {}
    local panel = create("Frame", {
        Name = "InfoListPanel", BackgroundColor3 = themeColor(theme, "Section"),
        BackgroundTransparency = .25, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
    }, { corner(8), padding(8, 9, 8, 9), list(Enum.FillDirection.Vertical, 2) })
    if options.Name then
        text({
            Parent = panel, Text = options.Name,
            TextColor3 = themeColor(theme, "SubText"),
            TextSize = 11, FontFace = inter(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20),
        })
    end
    local lines = {}
    local function rebuild()
        for _, line in lines do line:Destroy() end
        table.clear(lines)
        for i, item in control.Items do
            local line = create("Frame", {
                Name = "Detail_" .. item.Key, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 29), LayoutOrder = i,
                Parent = panel,
            })
            table.insert(lines, line)
            text({
                Parent = line, Name = "Key", Text = item.Label,
                TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
                Position = UDim2.fromOffset(1, 0), Size = UDim2.new(.49, -3, 1, 0),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            text({
                Parent = line, Name = "Value", Text = item.Value,
                TextColor3 = themeColor(theme, item.Tone),
                TextXAlignment = Enum.TextXAlignment.Right, TextSize = 12,
                Position = UDim2.new(.5, 0, 0, 0),
                Size = UDim2.new(.5, -2, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
            })
            if i < #control.Items then
                create("Frame", {
                    Name = "Separator", BackgroundColor3 = themeColor(theme, "Divider"),
                    BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1),
                    Size = UDim2.new(1, 0, 0, 1), Parent = line,
                })
            end
        end
    end
    function control:Set(items)
        local nextItems = infoNormalize(items)
        local stable = #nextItems == #self.Items
        if stable then
            for i, item in nextItems do
                if self.Items[i].Key ~= item.Key then stable = false; break end
            end
        end
        self.Items = nextItems
        indexByKey = moduleInfoIndex(nextItems)
        if stable then
            for i, item in nextItems do
                local line = lines[i]
                if line then
                    local label = line:FindFirstChild("Key")
                    local value = line:FindFirstChild("Value")
                    if label and label.Text ~= item.Label then label.Text = item.Label end
                    if value then
                        if value.Text ~= item.Value then value.Text = item.Value end
                        setThemed(value, "TextColor3", themeColor(theme, item.Tone))
                    end
                end
            end
        else
            rebuild()
        end
    end
    function control:Update(key, value, tone)
        local i = indexByKey[tostring(key)]
        local item = i and self.Items[i]
        if not item then return false end
        local nextValue = moduleString(value)
        if item.Value ~= nextValue then
            item.Value = nextValue
            local label = lines[i] and lines[i]:FindFirstChild("Value")
            if label then label.Text = nextValue end
        end
        if tone and item.Tone ~= moduleTone(tone) then
            item.Tone = moduleTone(tone)
            local label = lines[i] and lines[i]:FindFirstChild("Value")
            if label then setThemed(label, "TextColor3", themeColor(theme, item.Tone)) end
        end
        return true
    end
    function control:UpdateMany(values)
        for key, update in type(values) == "table" and values or {} do
            if type(update) == "table" and update.Value ~= nil then
                self:Update(key, update.Value, update.Tone)
            else
                self:Update(key, update)
            end
        end
    end
    function control:Upsert(item)
        assert(type(item) == "table" and item.Key ~= nil, "InfoList:Upsert needs a Key")
        local entry = infoNormalize({ item })[1]
        local current = indexByKey[entry.Key]
        local nextItems = moduleInfoSnapshot(self.Items)
        if current then nextItems[current] = entry else table.insert(nextItems, entry) end
        self:Set(nextItems)
        return true
    end
    function control:Remove(key)
        local i = indexByKey[tostring(key)]
        if not i then return false end
        local nextItems = moduleInfoSnapshot(self.Items)
        table.remove(nextItems, i)
        self:Set(nextItems)
        return true
    end
    function control:Clear() self:Set({}) end
    function control:Get() return moduleInfoSnapshot(self.Items) end
    control:Set(options.Items or {})
    return hub:_finishRequiredControl(control)
end
