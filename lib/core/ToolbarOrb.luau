-- RelaxUI: animated compact toolbar orb, event-driven while idle.
local ORB_GREEN = Color3.fromRGB(71, 233, 130)
local ORB_RED = Color3.fromRGB(255, 91, 105)
local ORB_PRESS = TweenInfo.new(.13, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ORB_SETTLE = TweenInfo.new(.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local ORB_MORPH = TweenInfo.new(.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ORB_RIPPLE = TweenInfo.new(.52, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ORB_HOLD_SECONDS = 1
local ORB_CANCEL_DISTANCE = 11

function Hub:_setToolbarOrbPosition(x, y)
    if not self.Restore then return end
    local v = viewport()
    if v.X <= 0 or v.Y <= 0 then return end
    local edge = 22 * (self._scale or 1) + 10
    local minX = math.min(.49, edge / v.X)
    local minY = math.min(.49, (topInset() + edge) / v.Y)
    local maxY = math.max(minY, 1 - edge / v.Y)
    x = math.clamp(x, minX, 1 - minX)
    y = math.clamp(y, minY, maxY)
    self.Restore.Position = UDim2.fromScale(x, y)
    self._toolbarOrbPosition = { X = x, Y = y }
end

function Hub:_refreshToolbarOrbTheme()
    if not self._orbGradient or self._destroyed then return end
    local theme = self.Theme
    local accent = theme.Accent or theme.Text or Color3.fromRGB(245, 245, 245)
    local surface = theme.TileActive or theme.PanelStroke or accent
    local highlight = theme.Highlight or theme.Text or accent
    local h, saturation, value = accent:ToHSV()
    local primary = saturation < .12 and Color3.fromRGB(93, 178, 246) or accent
    local secondary = saturation < .12 and Color3.fromRGB(180, 132, 248)
        or Color3.fromHSV((h + .15) % 1, math.max(.38, saturation * .82), math.max(.72, value))
    local colors = ColorSequence.new({
        ColorSequenceKeypoint.new(0, primary),
        ColorSequenceKeypoint.new(.25, accent:Lerp(highlight, .20)),
        ColorSequenceKeypoint.new(.52, secondary),
        ColorSequenceKeypoint.new(.76, surface:Lerp(primary, .72)),
        ColorSequenceKeypoint.new(1, primary),
    })
    self._orbGradient.Color = colors
    self._orbHaloGradient.Color = colors
    if not self._toolbarOrbHolding then
        self._orbBorder.Color = accent
        self._orbHaloStroke.Color = accent
    end
end

function Hub:_setToolbarOrbSpin(enabled)
    if not self._orbSpinTween then return end
    if enabled and not self._toolbarOrbHolding then
        self._orbSpinTween:Play()
        self._orbHaloSpinTween:Play()
    else
        self._orbSpinTween:Pause()
        self._orbHaloSpinTween:Pause()
    end
end

function Hub:_syncToolbarOrbState(animate)
    if not self._orbHorizontal then return end
    local open = self._visible == true
    local tint = open and ORB_RED or ORB_GREEN
    if animate then
        tween(self._orbHorizontal, ORB_MORPH, { BackgroundColor3 = tint, Rotation = open and 0 or -90 })
        tween(self._orbVertical, ORB_MORPH, {
            BackgroundColor3 = tint, BackgroundTransparency = open and 1 or 0,
            Rotation = open and 90 or 0,
        })
    else
        self._orbHorizontal.BackgroundColor3 = tint
        self._orbHorizontal.Rotation = open and 0 or -90
        self._orbVertical.BackgroundColor3 = tint
        self._orbVertical.BackgroundTransparency = open and 1 or 0
        self._orbVertical.Rotation = open and 90 or 0
    end
end

function Hub:_toolbarOrbRipple(color, unlocked)
    if self._destroyed or not self.Restore or not self.Restore.Parent then return end
    local ripple = create("Frame", {
        Name = unlocked and "DragUnlockRipple" or "ToggleRipple",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(44, 44), ZIndex = 34, Parent = self.Restore,
    }, { corner(100) })
    local ring = stroke(color, unlocked and 2.7 or 1.8, unlocked and .04 or .3)
    ring.Parent = ripple
    local size = unlocked and 94 or 71
    tween(ripple, ORB_RIPPLE, { Size = UDim2.fromOffset(size, size) })
    tween(ring, ORB_RIPPLE, { Transparency = 1, Thickness = .6 })
    task.delay(ORB_RIPPLE.Time + .05, function()
        if ripple.Parent then ripple:Destroy() end
    end)
end

function Hub:_setupToolbarOrb()
    local orb = self.Restore
    local face = create("Frame", {
        Name = "OrbFace", BackgroundColor3 = Color3.fromRGB(8, 9, 12),
        BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(36, 36),
        ZIndex = 35, Parent = orb,
    }, { corner(100) })
    self._orbFace = face
    self._orbBorder = stroke(self.Theme.Accent, 2.1)
    self._orbBorder.Name = "ThemeGradientBorder"
    self._orbBorder.Parent = face
    self._orbGradient = create("UIGradient", { Rotation = 0, Parent = self._orbBorder })
    local halo = create("Frame", {
        Name = "OrbHalo", BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(46, 46), ZIndex = 34, Parent = orb,
    }, { corner(100) })
    self._orbHaloStroke = stroke(self.Theme.Accent, 1.3, .8)
    self._orbHaloStroke.Parent = halo
    self._orbHaloGradient = create("UIGradient", { Rotation = 0, Parent = self._orbHaloStroke })
    self._orbScale = create("UIScale", { Scale = 1, Parent = orb })
    local spin = TweenInfo.new(6.8, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
    local haloSpin = TweenInfo.new(10.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
    self._orbSpinTween = TweenService:Create(self._orbGradient, spin, { Rotation = 360 })
    self._orbHaloSpinTween = TweenService:Create(self._orbHaloGradient, haloSpin, { Rotation = -360 })
    self:Own({ Disconnect = function()
        self._orbSpinTween:Cancel()
        self._orbHaloSpinTween:Cancel()
    end })
    self._orbHorizontal = create("Frame", {
        Name = "GlyphHorizontal", BackgroundColor3 = ORB_RED, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(17, 3), ZIndex = 37, Parent = orb,
    }, { corner(3) })
    self._orbVertical = create("Frame", {
        Name = "GlyphVertical", BackgroundColor3 = ORB_RED, BorderSizePixel = 0,
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(3, 17),
        ZIndex = 37, Parent = orb,
    }, { corner(3) })
    self:_refreshToolbarOrbTheme()
    self:_syncToolbarOrbState(false)
    self:_setToolbarOrbSpin(UserInputService.TouchEnabled)

    local saved = self.SetupData and self.SetupData.ToolbarOrbPosition
    if type(saved) == "table" and type(saved.X) == "number" and type(saved.Y) == "number"
        and saved.X == saved.X and saved.Y == saved.Y then
        self:_setToolbarOrbPosition(saved.X, saved.Y)
    end
    local function reclamp()
        if self._toolbarOrbPosition and not self._destroyed then
            self:_setToolbarOrbPosition(self._toolbarOrbPosition.X, self._toolbarOrbPosition.Y)
        end
    end
    self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), reclamp)
    self:_connect(self.UIScale:GetPropertyChangedSignal("Scale"), reclamp)

    local press, generation = nil, 0
    local dragBinding = {}
    local function dragStyle(on)
        self._toolbarOrbHolding = on
        self._orbGradient.Enabled = not on
        self._orbHaloGradient.Enabled = not on
        self:_setToolbarOrbSpin(not on and UserInputService.TouchEnabled)
        if on then
            self._orbBorder.Color = ORB_GREEN
            self._orbHaloStroke.Color = ORB_GREEN
            tween(self._orbBorder, ORB_PRESS, { Thickness = 2.9 })
            tween(self._orbHaloStroke, ORB_PRESS, { Transparency = .17 })
            tween(self._orbScale, ORB_SETTLE, { Scale = 1.075 })
        else
            self:_refreshToolbarOrbTheme()
            tween(self._orbBorder, ORB_MORPH, { Thickness = 2.1 })
            tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
            tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
        end
    end

    local finish
    finish = function(cancelled, position)
        local p = press
        if not p then return end
        press = nil
        generation += 1 -- invalidates the pending long-press unlock
        if p.stateConn then p.stateConn:Disconnect() end
        if self._capturedDrag == dragBinding then self._capturedDrag = nil end
        if self._activeDrags then self._activeDrags[dragBinding] = nil end
        if p.unlocked then
            dragStyle(false)
            if p.dragged and not self._destroyed then
                local pos = self._toolbarOrbPosition
                if pos then self:_savePref("ToolbarOrbPosition", { X = pos.X, Y = pos.Y }) end
            end
        else
            tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
            tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
        end
        if not cancelled and not p.unlocked and not p.invalid and not self._destroyed
            and within(orb, position or p.last) then
            self:_toolbarOrbRipple(self._visible and ORB_RED or ORB_GREEN, false)
            self:ToggleToolbar()
        end
    end
    dragBinding.Cancel = function() finish(true) end
    self:Own({ Disconnect = function() finish(true) end })

    self:_connect(orb.InputBegan, function(input)
        if self._destroyed or self._loading or press or self._capturedDrag or not isPointer(input) then return end
        generation += 1
        local token = generation
        local down = Vector2.new(input.Position.X, input.Position.Y)
        local origin = self._toolbarOrbPosition
        if not origin then
            local center = orb.AbsolutePosition + orb.AbsoluteSize * .5
            local v = viewport()
            origin = { X = center.X / math.max(v.X, 1), Y = center.Y / math.max(v.Y, 1) }
        end
        press = { input = input, down = down, last = down,
            origin = { X = origin.X, Y = origin.Y }, invalid = false,
            unlocked = false, dragged = false }
        local p = press
        if input.UserInputType == Enum.UserInputType.Touch then
            p.stateConn = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
                if press ~= p then return end
                if input.UserInputState == Enum.UserInputState.Cancel then finish(true)
                elseif input.UserInputState == Enum.UserInputState.End then finish(false, p.last) end
            end)
        end
        tween(self._orbScale, ORB_PRESS, { Scale = .92 })
        tween(self._orbHaloStroke, ORB_PRESS, { Transparency = .43 })
        task.delay(ORB_HOLD_SECONDS, function()
            if self._destroyed or press ~= p or generation ~= token or p.invalid or not orb.Parent then return end
            if self._capturedDrag then finish(true); return end
            p.unlocked = true
            self._capturedDrag = dragBinding
            self._activeDrags = self._activeDrags or {}
            self._activeDrags[dragBinding] = true
            self:_toolbarOrbRipple(ORB_GREEN, true)
            dragStyle(true)
        end)
    end)
    self:_connect(UserInputService.InputChanged, function(input)
        local p = press
        if not p or self._destroyed then return end
        local touch = p.input.UserInputType == Enum.UserInputType.Touch
        if (touch and input ~= p.input)
            or (not touch and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
        local point = Vector2.new(input.Position.X, input.Position.Y)
        p.last = point
        local delta = point - p.down
        if not p.unlocked then
            if delta.Magnitude > ORB_CANCEL_DISTANCE and not p.invalid then
                p.invalid = true
                generation += 1
                tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
                tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
            end
            return
        end
        if delta.Magnitude >= 2 then p.dragged = true end
        local v = viewport()
        self:_setToolbarOrbPosition(p.origin.X + delta.X / math.max(v.X, 1),
            p.origin.Y + delta.Y / math.max(v.Y, 1))
    end)
    self:_connect(UserInputService.InputEnded, function(input)
        local p = press
        if not p then return end
        local touch = p.input.UserInputType == Enum.UserInputType.Touch
        if (touch and input == p.input)
            or (not touch and input.UserInputType == Enum.UserInputType.MouseButton1) then
            finish(input.UserInputState == Enum.UserInputState.Cancel,
                Vector2.new(input.Position.X, input.Position.Y))
        end
    end)
    self:_connect(orb.MouseEnter, function()
        if press or self._destroyed then return end
        tween(self._orbScale, ORB_MORPH, { Scale = 1.065 })
        tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .43 })
    end)
    self:_connect(orb.MouseLeave, function()
        if press or self._destroyed then return end
        tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
        tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
    end)
end
