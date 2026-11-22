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
        padding(5, 6, 5, 6),
        list(Enum.FillDirection.Vertical, 1) })
    -- Reference layout: circular leading icon, stacked title/summary, and
    -- right-side chevron/star above the switch. No visible status chips.
    local moduleTokens = hub:GetComponentTokens("ModuleCard")
    local iconSize = moduleTokens.IconSize
    local function minimumHeaderHeight()
        if hasToggle then return moduleTokens.HeaderHeight end
        if options.Icon then
            return math.max(moduleTokens.HeaderHeight - 14, iconSize + 20)
        end
        return math.max(70, moduleTokens.HeaderHeight - 22)
    end
    local baseHeight = minimumHeaderHeight()
    -- Top-row action and lower toggle straddle the same vertical center as
    -- the icon and text. With no toggle, the only action row is centered.
    local actionOffset = hasToggle and 21 or 0
    local actionInset = canCollapse and canFavorite and 88
        or ((canCollapse or canFavorite or hasToggle) and 46 or 8)
    local head = create("TextButton", {
        Name = "ModuleHead", BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Size = UDim2.new(1, 0, 0, baseHeight),
        ZIndex = 2, Parent = surface,
    })
    local titleX = 8
    local iconShell, icon
    if options.Icon then
        iconShell = create("Frame", {
            Name = "ModuleIcon", Parent = head, BorderSizePixel = 0,
            BackgroundColor3 = themeColor(theme, "Accent"),
            BackgroundTransparency = .78,
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(0, math.floor(iconSize / 2) + 4, .5, 0),
            Size = UDim2.fromOffset(iconSize, iconSize), ZIndex = 3,
        }, { corner(100) })
        icon = iconLabel(options.Icon, moduleTokens.GlyphSize, theme.Text, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            ZIndex = 4, Parent = iconShell,
        })
        if icon then
            titleX = iconSize + 11
        else
            iconShell:Destroy()
            iconShell = nil
        end
    end
    local title = text({
        Parent = head, Name = "ModuleTitle", Text = name,
        FontFace = inter(Enum.FontWeight[hub:GetToken("Typography.ModuleTitle.Weight")]),
        TextSize = hub:GetToken("Typography.ModuleTitle.Size"),
        TextColor3 = hub:GetToken("Color.TextPrimary"),
        Position = UDim2.fromOffset(titleX, 23),
        Size = UDim2.new(1, -titleX - actionInset, 0, 22),
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3,
    })
    -- The star is on the outside, the chevron immediately to its left.
    -- Invisible 40px targets preserve touch ergonomics without boxed icons.
    local chevron, expandButton
    if canCollapse then
        expandButton = create("TextButton", {
            Name = "ExpandAction", BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, canFavorite and -46 or -4, .5, -actionOffset),
            Size = UDim2.fromOffset(40, 40), ZIndex = 5, Parent = head,
        })
        chevron = iconLabel("chevron-up", 20, theme.Text, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            ZIndex = 6, Parent = expandButton,
        })
    end
    local favorite, favoriteIcon
    if canFavorite then
        favorite = create("TextButton", {
            Name = "Favorite", BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -4, .5, -actionOffset),
            Size = UDim2.fromOffset(40, 40), ZIndex = 5, Parent = head,
        })
        favoriteIcon = iconLabel("star", 21, theme.Muted, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            Parent = favorite, ZIndex = 6,
        })
    end
    local toggle, toggleTrack, knob, togglePress
    if hasToggle then
        toggle = create("TextButton", {
            Name = "ModuleSwitch", BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -4, .5, actionOffset),
            Size = UDim2.fromOffset(44, 44), ZIndex = 5, Parent = head,
        })
        togglePress = create("UIScale", { Name = "PressFeedback", Scale = 1, Parent = toggle })
        toggleTrack = create("Frame", {
            Name = "ModuleSwitchTrack", BackgroundColor3 = themeColor(theme, "Field"),
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromOffset(34, 20), ZIndex = 6, Parent = toggle,
        }, { corner(12), stroke(themeColor(theme, "FieldStroke")) })
        knob = create("Frame", {
            Name = "ModuleThumb", BackgroundColor3 = themeColor(theme, "Text"),
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0, .5),
            Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(14, 14),
            ZIndex = 7, Parent = toggleTrack,
        }, { corner(9) })
    end
    -- Description sits directly below the title; actions occupy a separate
    -- right column, not a full-width action row above the summary.
    local description = text({
        Parent = head, Name = "ModuleSummary",
        Text = options.Description or options.Summary or "",
        TextSize = hub:GetToken("Typography.ModuleSummary.Size"),
        TextColor3 = hub:GetToken("Color.TextSecondary"),
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(titleX, 49),
        Size = UDim2.new(1, -titleX - actionInset, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3,
    })
    hub:BindToken(title, "TextSize", "Typography.ModuleTitle.Size")
    hub:BindToken(description, "TextSize", "Typography.ModuleSummary.Size")
    hub:BindToken(title, "TextColor3", "Color.TextPrimary")
    hub:BindToken(description, "TextColor3", "Color.TextSecondary")
    local function refreshHeaderLayout()
        if not head.Parent then return end
        local scale = math.max(hub._scale or 1, .01)
        local hasSummary = description.Text ~= ""
        description.Visible = hasSummary
        local titleHeight = math.max(22, math.ceil(title.AbsoluteSize.Y / scale),
            math.ceil(title.TextBounds.Y / scale))
        local descHeight = hasSummary and math.max(20,
            math.ceil(description.AbsoluteSize.Y / scale),
            math.ceil(description.TextBounds.Y / scale)) or 0
        local gap = hasSummary and 4 or 0
        local textHeight = titleHeight + gap + descHeight
        local desired = math.max(baseHeight, textHeight + 20)
        if head.Size.Y.Offset ~= desired then
            head.Size = UDim2.new(1, 0, 0, desired)
        end
        -- Center the complete title+description block against the circular
        -- icon and the midpoint between the upper actions and lower toggle.
        local top = math.floor((desired - textHeight) / 2)
        local summaryTop = top + titleHeight + gap
        if title.Position.Y.Offset ~= top or title.Position.X.Offset ~= titleX then
            title.Position = UDim2.fromOffset(titleX, top)
        end
        if description.Position.Y.Offset ~= summaryTop or description.Position.X.Offset ~= titleX then
            description.Position = UDim2.fromOffset(titleX, summaryTop)
        end
    end
    hub:_connect(description:GetPropertyChangedSignal("AbsoluteSize"), refreshHeaderLayout)
    hub:_connect(description:GetPropertyChangedSignal("TextBounds"), refreshHeaderLayout)
    hub:_connect(title:GetPropertyChangedSignal("AbsoluteSize"), refreshHeaderLayout)
    hub:_connect(title:GetPropertyChangedSignal("TextBounds"), refreshHeaderLayout)
    -- Recompute coupled geometry when the public ModuleCard size tokens are
    -- overridden; existing cards update without rebuilding their controls.
    local geometryWatcher = hub:WatchDesignTokens(function()
        moduleTokens = hub:GetComponentTokens("ModuleCard")
        iconSize = moduleTokens.IconSize
        baseHeight = minimumHeaderHeight()
        if iconShell then
            iconShell.Size = UDim2.fromOffset(iconSize, iconSize)
            iconShell.Position = UDim2.new(0, math.floor(iconSize / 2) + 4, .5, 0)
            if icon then
                icon.Size = UDim2.fromOffset(moduleTokens.GlyphSize, moduleTokens.GlyphSize)
            end
            titleX = iconSize + 11
        end
        title.Size = UDim2.new(1, -titleX - actionInset, 0, 22)
        description.Size = UDim2.new(1, -titleX - actionInset, 0, 20)
        refreshHeaderLayout()
    end)
    -- Use a native Frame for text: CanvasGroup composites glyphs to a texture,
    -- reducing clarity on mobile devices and with nested panels.
    local clip = create("Frame", {
        Name = "ModuleClip", BackgroundTransparency = 1, Visible = false,
        ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 2, Parent = surface,
    })
    local body = create("Frame", {
        Name = "ModuleBody", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = clip,
    }, { padding(2, 3, 3, 3), list(Enum.FillDirection.Vertical, 1) })
    -- The shared locked overlay covers the entire row (including heading and
    -- toggle), unlike the legacy body-only lock panel.
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
        _locked = options.Locked == true or options.State == "Locked", _blocked = false, _hidden = false,
        _lockReason = options.LockReason,
        _lockOptions = type(options.Lock) == "table" and table.clone(options.Lock) or {
            Title = options.LockTitle, Details = options.LockDetails,
            Actions = options.LockActions,
        },
        _inheritedBlocked = false,
        _searchPeek = false, _animating = false,
        _dataObservers = {}, _dataSubscriptions = {},
        _summary = options.Description or options.Summary or "",
        _status = options.Status or "", _tone = moduleTone(options.Tone),
    }, Section)
    card._moduleCard = parentCard
    card._hasToggle = hasToggle
    card._canCollapse = canCollapse
    card._canFavorite = canFavorite
    local motionKey = "module-card:" .. id
    local callbacks = {}

    function card:OnDataEvent(event, fn)
        assert(type(event) == "string" and event ~= "", "module event name required")
        assert(type(fn) == "function", "module event callback required")
        assert(not self._disposed and not hub._destroyed, "module card destroyed")
        local listeners = self._dataObservers[event] or {}
        self._dataObservers[event] = listeners
        table.insert(listeners, fn)
        local sub = { Connected = true }
        self._dataSubscriptions[sub] = true
        hub._directDataSubscriptions = hub._directDataSubscriptions or {}
        hub._directDataSubscriptions[sub] = true
        function sub:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            local at = table.find(listeners, fn)
            if at then table.remove(listeners, at) end
            card._dataSubscriptions[self] = nil
            if hub._directDataSubscriptions then hub._directDataSubscriptions[self] = nil end
        end
        return sub
    end
    function card:_dataEvent(event, payload)
        if self._disposed or hub._destroyed then return end
        for _, fn in table.clone(self._dataObservers[event] or {}) do
            local ok, err = xpcall(fn, debug.traceback, payload, self)
            if not ok then warn("[RelaxUI] module event: " .. tostring(err)) end
        end
    end
    function card:GetStatus() return { Status = self._status, Tone = self._tone } end
    function card:GetSummary() return self._summary end
    local function saveMap(field, value)
        local map = table.clone(type(hub.SetupData and hub.SetupData[field]) == "table"
            and hub.SetupData[field] or {})
        map[id] = value
        hub:_savePref(field, map)
    end
    local function blocked()
        return card._locked or card._blocked or card._inheritedBlocked
    end
    function card:IsAvailable()
        if self._locked then return false, self._lockReason or "该模块已锁定" end
        if self._blocked or self._inheritedBlocked then
            return false, options.DependsReason or "需要先启用依赖模块"
        end
        return hub:CanUse(self.Requires)
    end
    function card:GetAvailability()
        local ok, reason = self:IsAvailable()
        return ok and "Available" or "Locked", reason
    end
    function card:SetAvailability(state, reason, lockOptions)
        assert(state == "Available" or state == "Locked", "state must be Available or Locked")
        return self:SetLocked(state == "Locked", reason, lockOptions)
    end
    function card:SetLockActions(actions)
        assert(type(actions) == "table", "lock actions must be a table")
        self._lockOptions = self._lockOptions or {}
        self._lockOptions.Actions = table.clone(actions)
        return self
    end
    function card:ShowLockReason()
        if self:IsAvailable() then return nil end
        return hub:_openLockedReason(self)
    end
    local function paintBlock(animate)
        hub:_syncLockOverlay(card)
        if not toggle then return end
        local trackColor = themeColor(theme, card.Value and "Accent" or "Field")
        local thumbColor = themeColor(theme, card.Value and "AccentText" or "Text")
        local thumbPosition = UDim2.new(0, card.Value and 17 or 3, .5, 0)
        if animate then
            Motion.transition(hub, motionKey .. ":switch",
                card.Value and "on" or "off", {
                    { Target = toggleTrack, Goals = { BackgroundColor3 = trackColor } },
                    { Target = knob, Goals = { BackgroundColor3 = thumbColor,
                        Position = thumbPosition } },
                }, Motion.Presets.Micro)
        else
            Motion.cancel(hub, motionKey .. ":switch")
            setThemed(toggleTrack, "BackgroundColor3", trackColor)
            setThemed(knob, "BackgroundColor3", thumbColor)
            knob.Position = thumbPosition
        end
    end
    local function notifyDependents()
        for _, fn in card._dependents or {} do
            local ok, err = pcall(fn, card.Value)
            if not ok then warn("[RelaxUI] module dependent: " .. tostring(err)) end
        end
    end
    function card:Set(value, silent)
        if not self._hasToggle or not self:IsAvailable() then return false end
        value = value == true
        if self.Value == value then return true end
        self.Value = value
        paintBlock(not silent)
        -- Structural dependencies must update even on silent config restore.
        notifyDependents()
        for _, callback in callbacks do
            task.spawn(function()
                if not hub._destroyed and not card._disposed then
                    local ok, err = pcall(callback, value)
                    if not ok then warn("[RelaxUI] module observer: " .. tostring(err)) end
                end
            end)
        end
        if not silent then
            self:_dataEvent("Value", value)
            hub:PlayUISound(value and "ToggleOn" or "ToggleOff")
            if type(options.Callback) == "function" then
                task.spawn(function()
                    if not hub._destroyed and not card._disposed then
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
    function card:SetLocked(on, reason, lockOptions)
        local old = self._locked
        self._locked = on == true
        if type(reason) == "table" then
            lockOptions = reason
            reason = reason.Reason
        end
        if reason ~= nil then self._lockReason = tostring(reason) end
        if type(lockOptions) == "table" then self._lockOptions = table.clone(lockOptions) end
        paintBlock()
        if old ~= self._locked then
            notifyDependents()
            self:_dataEvent("Locked", self._locked)
        end
    end
    function card:IsLocked() return not self:IsAvailable() end
    function card:SetSummary(value)
        local summary = moduleString(value)
        if self._summary == summary then return end
        self._summary = summary
        description.Text = summary
        refreshHeaderLayout()
        self:_dataEvent("Summary", summary)
    end
    function card:SetStatus(status, tone)
        local nextStatus = status and tostring(status) or ""
        -- Text-only status changes retain the existing semantic color role.
        local nextTone = tone == nil and self._tone or moduleTone(tone)
        if self._status == nextStatus and self._tone == nextTone then return end
        -- Keep status in the public data/event API, never render a badge.
        self._status, self._tone = nextStatus, nextTone
        self:_dataEvent("Status", self:GetStatus())
    end
    local function height()
        return math.max(0, body.AbsoluteSize.Y / math.max(hub._scale, .01))
    end
    local function effective() return not canCollapse or card._expanded or card._searchPeek end
    local function resize(animate)
        local open = effective()
        local target = open and height() or 0
        if chevron then
            if animate then
                Motion.play(hub, motionKey .. ":arrow", chevron,
                    { Rotation = open and 0 or 180 }, Motion.Presets.Micro)
            else
                Motion.cancel(hub, motionKey .. ":arrow")
                chevron.Rotation = open and 0 or 180
            end
        end
        if animate then
            card._animating = true
            local targetSize = UDim2.new(1, 0, 0, target)
            -- Keep the native clip in the UIListLayout until its closing
            -- height finishes. Hiding it now snaps the row shut immediately.
            -- ClipsDescendants trims controls without rasterizing their text.
            clip.Visible = true
            Motion.play(hub, motionKey, clip, { Size = targetSize },
                Motion.Presets.Control, function()
                if hub._destroyed or not clip.Parent then return end
                card._animating = false
                clip.Size = UDim2.new(1, 0, 0, effective() and height() or 0)
                clip.Visible = effective()
            end)
        else
            Motion.cancel(hub, motionKey)
            card._animating = false
            clip.Size = UDim2.new(1, 0, 0, target)
            clip.Visible = open
        end
    end
    function card:SetExpanded(on, instant)
        if not canCollapse then return end
        on = on == true
        if self._expanded == on then return end
        self._expanded = on
        saveMap("ModuleCards", on and "expanded" or "collapsed")
        resize(not instant)
        self:_dataEvent("Expanded", on)
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
            Motion.play(hub, motionKey .. ":favorite", favoriteIcon,
                { ImageColor3 = self._favorite and Color3.fromRGB(255, 211, 65)
                    or themeColor(theme, "Muted") }, Motion.Presets.Micro)
        end
        saveMap("ModuleFavorites", self._favorite)
        self:_dataEvent("Favorite", self._favorite)
    end
    function card:IsFavorite() return self._favorite end
    function card:SetVisible(on)
        self._hidden = on == false
        row.Visible = not self._hidden and not self._dependencyHidden
        self:_dataEvent("Visibility", row.Visible)
    end
    function card:Reset()
        if self._hasToggle then
            local locked, dep, inherited = self._locked, self._blocked, self._inheritedBlocked
            self._locked, self._blocked, self._inheritedBlocked = false, false, false
            self:Set(self._default, true)
            self._locked, self._blocked, self._inheritedBlocked = locked, dep, inherited
            paintBlock()
            notifyDependents()
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
        local blockedNow = on == true
        if self._blocked == blockedNow then return end
        self._blocked = blockedNow
        paintBlock()
        notifyDependents()
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
            hub:_connect(row.Destroying, function()
                local at = table.find(control._dependents or {}, apply)
                if at then table.remove(control._dependents, at) end
            end)
        elseif type(control.OnChanged) == "function" then
            control:OnChanged(apply)
            if type(control.OffChanged) == "function" then
                hub:_connect(row.Destroying, function() control:OffChanged(apply) end)
            end
        end
    end
    -- Optional nested inheritance. No values are changed: inactive or locked
    -- ancestors simply prevent touch through the existing lock overlay.
    if parentCard and options.InheritParentState == true then
        local function syncParentState()
            local nextBlocked = (parentCard._hasToggle and not parentCard:Get())
                or parentCard:IsLocked()
            nextBlocked = nextBlocked == true
            if card._inheritedBlocked ~= nextBlocked then
                card._inheritedBlocked = nextBlocked
                paintBlock()
                notifyDependents()
            end
        end
        parentCard._dependents = parentCard._dependents or {}
        table.insert(parentCard._dependents, syncParentState)
        syncParentState()
        hub:_connect(row.Destroying, function()
            local at = table.find(parentCard._dependents or {}, syncParentState)
            if at then table.remove(parentCard._dependents, at) end
        end)
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
    if expandButton then
        hub:_connect(expandButton.MouseButton1Click, function()
            card:SetExpanded(not card._expanded)
        end)
    end
    if favorite then
        hub:_connect(favorite.MouseButton1Click, function()
            card:SetFavorite(not card._favorite)
        end)
    end
    if toggle then
        hub:_connect(toggle.MouseButton1Down, function()
            Motion.play(hub, motionKey .. ":press", togglePress, { Scale = .94 }, FAST)
        end)
        local function releaseTouch()
            Motion.play(hub, motionKey .. ":press", togglePress, { Scale = 1 }, FAST)
        end
        hub:_connect(toggle.MouseButton1Up, releaseTouch)
        hub:_connect(toggle.MouseLeave, releaseTouch)
        hub:_connect(toggle.InputEnded, function(input)
            if isPointer(input) then releaseTouch() end
        end)
        hub:_connect(toggle.MouseButton1Click, function()
            releaseTouch()
            card:Set(not card.Value)
        end)
    end
    card:SetStatus(options.Status, options.Tone)
    refreshHeaderLayout()
    if #card.Requires > 0 then table.insert(hub._requiredControls, card) end
    paintBlock(false)
    if card._favorite then
        row.LayoutOrder = -1000 + originalOrder
        if favoriteIcon then
            setThemed(favoriteIcon, "ImageColor3", Color3.fromRGB(255, 211, 65))
        end
    end
    if chevron then chevron.Rotation = effective() and 0 or 180 end
    resize(false)
    task.defer(function()
        if not hub._destroyed and row.Parent and not card._animating then resize(false) end
    end)
    table.insert(self.Controls, card)
    if parentCard then table.insert(parentCard._moduleControls, card) end
    hub:BindToken(surface, "BackgroundColor3", "Color.Surface2")
    hub:BindToken(surface:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.M")
    -- The module uses dedicated compact insets, not Spacing.S (8px):
    -- rebinding those tokens here silently inflated the visible card height.
    -- Keep the local 5/6px padding while colors, fonts and radius stay themed.
    -- Keep dedicated ModuleTitle/ModuleSummary typography bindings above.
    -- Generic Body/Meta overrides silently undid the component token roles.
    hub:_connect(row.Destroying, function()
        if geometryWatcher then geometryWatcher:Disconnect() end
        Motion.cancel(hub, motionKey)
        Motion.cancel(hub, motionKey .. ":arrow")
        Motion.cancel(hub, motionKey .. ":press")
        Motion.cancel(hub, motionKey .. ":switch")
        Motion.cancel(hub, motionKey .. ":favorite")
        card._disposed = true
        table.clear(callbacks)
        for sub in table.clone(card._dataSubscriptions) do sub:Disconnect() end
        table.clear(card._dataSubscriptions)
        table.clear(card._dataObservers)
        hub:_dataDetachControl(card)
    end)
    hub:_record(self, "ModuleCard", options, card)
    return card
end

local function infoNormalize(items)
    local out, seen = {}, {}
    for i, item in type(items) == "table" and items or {} do
        if type(item) == "table" then
            local key = moduleString(item.Key or item.Id or item.Name or item.Label or i)
            assert(not seen[key], "duplicate information key: " .. key)
            seen[key] = true
            table.insert(out, {
                Key = key, Label = moduleString(item.Label or item.Name or key),
                Value = moduleString(item.Value), Detail = item.Detail or item.Hint or "",
                Tone = moduleTone(item.Tone),
            })
        else
            local key = tostring(i)
            assert(not seen[key], "duplicate information key: " .. key)
            seen[key] = true
            table.insert(out, {
                Key = key, Label = key, Value = moduleString(item),
                Detail = "", Tone = "Text",
            })
        end
    end
    return out
end

-- Snapshots and stable reordering support live dashboards without reallocating cells.
local function infoPublish(control, operation, key)
    -- Avoid constructing full dashboard snapshots when no Data observers exist.
    local listeners = control._dataObservers and control._dataObservers.Data
    if not listeners or #listeners == 0 or control._disposed then return end
    local payload = { Operation = operation, Key = key }
    if key ~= nil then
        payload.Item = control:GetItem(key)
    else
        payload.Items = control:Get()
    end
    control:_dataEvent("Data", payload)
end

local function infoReorder(items, order)
    if type(order) ~= "table" or #order ~= #items then return nil, "order length mismatch" end
    local index = moduleInfoIndex(items)
    local seen, result = {}, {}
    for _, id in order do
        local key = tostring(id)
        local at = index[key]
        if not at or seen[key] then return nil, "unknown or duplicate information key: " .. key end
        seen[key] = true
        table.insert(result, items[at])
    end
    return result
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
            if options.FillLastRow ~= false and cols > 1 and i == #tiles and col == 0 then
                tile.Position = UDim2.fromOffset(0, nrow * (cellH + gap))
                tile.Size = UDim2.new(1, 0, 0, cellH)
            else
                tile.Position = UDim2.new(col / cols, col * gap / cols, 0, nrow * (cellH + gap))
                tile.Size = UDim2.new(1 / cols, -(cols - 1) * gap / cols, 0, cellH)
            end
        end
        local count = math.ceil(#tiles / cols)
        local height = count > 0 and count * cellH + (count - 1) * gap or 0
        grid.Size = UDim2.new(1, 0, 0, height)
        row.Size = UDim2.new(1, 0, 0, captionH + height + (height > 0 and 4 or 0))
    end
    local function rebuild()
        -- Keyed reconciliation preserves the actual metric tile across inserts,
        -- removals and reorder operations (without rebuilding live animations).
        local previous = {}
        for _, tile in tiles do previous[tile.Name] = tile end
        local arranged = {}
        for _, item in control.Items do
            local tileName = "Metric_" .. item.Key
            local tile = previous[tileName]
            previous[tileName] = nil
            if not tile then
                tile = create("Frame", {
                    Name = tileName, BackgroundColor3 = themeColor(theme, "Section"),
                    BackgroundTransparency = .1, Parent = grid,
                }, { corner(8), stroke(themeColor(theme, "SectionStroke"), 1) })
                text({ Parent = tile, Name = "Label", Text = item.Label, TextSize = 10,
                    TextColor3 = themeColor(theme, "Muted"), Position = UDim2.fromOffset(9, 6),
                    Size = UDim2.new(1, -18, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
                text({ Parent = tile, Name = "Value", Text = item.Value,
                    FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 16,
                    TextColor3 = themeColor(theme, item.Tone), Position = UDim2.fromOffset(9, 23),
                    Size = UDim2.new(1, -18, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd })
                text({ Parent = tile, Name = "Hint", Text = tostring(item.Detail),
                    TextSize = 10, TextColor3 = themeColor(theme, "Muted"),
                    Position = UDim2.fromOffset(9, 46),
                    Size = UDim2.new(1, -18, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
                hub:BindToken(tile, "BackgroundColor3", "Color.Surface1")
                hub:BindToken(tile:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
            end
            local label, value, hint = tile:FindFirstChild("Label"), tile:FindFirstChild("Value"), tile:FindFirstChild("Hint")
            if label and label.Text ~= item.Label then label.Text = item.Label end
            if value then
                if value.Text ~= item.Value then value.Text = item.Value end
                setThemed(value, "TextColor3", themeColor(theme, item.Tone))
            end
            if hint and hint.Text ~= tostring(item.Detail) then hint.Text = tostring(item.Detail) end
            table.insert(arranged, tile)
        end
        for _, tile in previous do tile:Destroy() end
        tiles = arranged
        layout()
    end
    -- Reuse tiles when keys/order are unchanged: live telemetry should not
    -- rebuild every GuiObject or trigger a layout pass for each value refresh.
    function control:Set(items, silent)
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
        if not silent then infoPublish(self, "Set") end
        return true
    end
    function control:Update(key, value, tone, silent)
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
        if not silent then infoPublish(self, "Update", tostring(key)) end
        return true
    end
    -- Strict batching validates every key before mutating any row.
    -- Default mode retains the old best-effort count-based contract.
    function control:UpdateMany(values, strict)
        local requireAll = strict == true or (type(strict) == "table" and strict.Strict == true)
        local silent = type(strict) == "table" and strict.Silent == true
        if type(values) ~= "table" then
            if requireAll then return false, "updates must be a table" end
            return 0
        end
        if requireAll then
            for key, update in values do
                if not indexByKey[tostring(key)] then
                    return false, "unknown information key: " .. tostring(key)
                end
                if type(update) == "table" and update.Value == nil then
                    return false, "batch entry requires Value: " .. tostring(key)
                end
            end
        end
        local count = 0
        for key, update in values do
            local ok
            if type(update) == "table" and update.Value ~= nil then
                ok = self:Update(key, update.Value, update.Tone, true)
            else
                ok = self:Update(key, update, nil, true)
            end
            if ok then count += 1 end
        end
        if count > 0 and not silent then infoPublish(self, "Batch") end
        return count
    end
    function control:UpdateManyStrict(values)
        return self:UpdateMany(values, true)
    end
    function control:Upsert(item)
        assert(type(item) == "table" and item.Key ~= nil, "InfoGrid:Upsert needs a Key")
        local entry = infoNormalize({ item })[1]
        local current = indexByKey[entry.Key]
        local nextItems = moduleInfoSnapshot(self.Items)
        if current then nextItems[current] = entry else table.insert(nextItems, entry) end
        self:Set(nextItems, true)
        infoPublish(self, "Upsert", entry.Key)
        return true
    end
    function control:Remove(key)
        local i = indexByKey[tostring(key)]
        if not i then return false end
        local nextItems = moduleInfoSnapshot(self.Items)
        table.remove(nextItems, i)
        self:Set(nextItems, true)
        infoPublish(self, "Remove", tostring(key))
        return true
    end
    function control:Clear() return self:Set({}) end
    function control:Get() return moduleInfoSnapshot(self.Items) end
    function control:GetItem(key)
        local index = indexByKey[tostring(key)]
        return index and table.clone(self.Items[index]) or nil
    end
    function control:SetOrder(order)
        local arranged, err = infoReorder(self.Items, order)
        if not arranged then return false, err end
        local previous = {}
        for i, item in self.Items do previous[item.Key] = tiles[i] end
        self.Items = arranged
        indexByKey = moduleInfoIndex(arranged)
        local reordered = {}
        for i, item in arranged do reordered[i] = previous[item.Key] end
        tiles = reordered
        layout()
        infoPublish(self, "Order")
        return true
    end
    hub:_connect(row.Destroying, function() hub:_dataDetachControl(control) end)
    hub:_connect(grid:GetPropertyChangedSignal("AbsoluteSize"), function()
        if row.Parent then layout() end
    end)
    control:Set(options.Items or {}, true)
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
        -- Stable keyed rows also preserve native touch/hover state on reorder.
        local previous = {}
        for _, line in lines do previous[line.Name] = line end
        local arranged = {}
        for i, item in control.Items do
            local name = "Detail_" .. item.Key
            local line = previous[name]
            previous[name] = nil
            if not line then
                line = create("Frame", { Name = name, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 29), Parent = panel })
                text({ Parent = line, Name = "Key", Text = item.Label,
                    TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
                    Position = UDim2.fromOffset(1, 0), Size = UDim2.new(.49, -3, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd })
                text({ Parent = line, Name = "Value", Text = item.Value,
                    TextColor3 = themeColor(theme, item.Tone),
                    TextXAlignment = Enum.TextXAlignment.Right, TextSize = 12,
                    Position = UDim2.new(.5, 0, 0, 0),
                    Size = UDim2.new(.5, -2, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
                create("Frame", { Name = "Separator",
                    BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -1),
                    Size = UDim2.new(1, 0, 0, 1), Parent = line })
            end
            line.LayoutOrder = i
            local label, value, separator = line:FindFirstChild("Key"), line:FindFirstChild("Value"), line:FindFirstChild("Separator")
            if label and label.Text ~= item.Label then label.Text = item.Label end
            if value then
                if value.Text ~= item.Value then value.Text = item.Value end
                setThemed(value, "TextColor3", themeColor(theme, item.Tone))
            end
            if separator then separator.Visible = i < #control.Items end
            table.insert(arranged, line)
        end
        for _, line in previous do line:Destroy() end
        lines = arranged
    end
    function control:Set(items, silent)
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
        if not silent then infoPublish(self, "Set") end
        return true
    end
    function control:Update(key, value, tone, silent)
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
        if not silent then infoPublish(self, "Update", tostring(key)) end
        return true
    end
    -- Strict batching validates every key before mutating any row.
    -- Default mode retains the old best-effort count-based contract.
    function control:UpdateMany(values, strict)
        local requireAll = strict == true or (type(strict) == "table" and strict.Strict == true)
        local silent = type(strict) == "table" and strict.Silent == true
        if type(values) ~= "table" then
            if requireAll then return false, "updates must be a table" end
            return 0
        end
        if requireAll then
            for key, update in values do
                if not indexByKey[tostring(key)] then
                    return false, "unknown information key: " .. tostring(key)
                end
                if type(update) == "table" and update.Value == nil then
                    return false, "batch entry requires Value: " .. tostring(key)
                end
            end
        end
        local count = 0
        for key, update in values do
            local ok
            if type(update) == "table" and update.Value ~= nil then
                ok = self:Update(key, update.Value, update.Tone, true)
            else
                ok = self:Update(key, update, nil, true)
            end
            if ok then count += 1 end
        end
        if count > 0 and not silent then infoPublish(self, "Batch") end
        return count
    end
    function control:UpdateManyStrict(values)
        return self:UpdateMany(values, true)
    end
    function control:Upsert(item)
        assert(type(item) == "table" and item.Key ~= nil, "InfoList:Upsert needs a Key")
        local entry = infoNormalize({ item })[1]
        local current = indexByKey[entry.Key]
        local nextItems = moduleInfoSnapshot(self.Items)
        if current then nextItems[current] = entry else table.insert(nextItems, entry) end
        self:Set(nextItems, true)
        infoPublish(self, "Upsert", entry.Key)
        return true
    end
    function control:Remove(key)
        local i = indexByKey[tostring(key)]
        if not i then return false end
        local nextItems = moduleInfoSnapshot(self.Items)
        table.remove(nextItems, i)
        self:Set(nextItems, true)
        infoPublish(self, "Remove", tostring(key))
        return true
    end
    function control:Clear() return self:Set({}) end
    function control:Get() return moduleInfoSnapshot(self.Items) end
    function control:GetItem(key)
        local index = indexByKey[tostring(key)]
        return index and table.clone(self.Items[index]) or nil
    end
    function control:SetOrder(order)
        local arranged, err = infoReorder(self.Items, order)
        if not arranged then return false, err end
        local previous = {}
        for i, item in self.Items do previous[item.Key] = lines[i] end
        self.Items = arranged
        indexByKey = moduleInfoIndex(arranged)
        local reordered = {}
        for i, item in arranged do
            local line = previous[item.Key]
            line.LayoutOrder = i
            reordered[i] = line
            local separator = line:FindFirstChild("Separator")
            if separator then separator.Visible = i < #arranged end
        end
        lines = reordered
        infoPublish(self, "Order")
        return true
    end
    hub:BindToken(panel, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(panel:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
    hub:_connect(row.Destroying, function() hub:_dataDetachControl(control) end)
    control:Set(options.Items or {}, true)
    return hub:_finishRequiredControl(control)
end
