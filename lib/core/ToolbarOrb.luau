-- RelaxUI Graphite: a restrained rounded-square floating toolbar control.
local ORB_GREEN = Color3.fromRGB(71, 233, 130)
local ORB_BG = Color3.fromRGB(17, 19, 22)
local ORB_BORDER = Color3.fromRGB(78, 82, 89)
local ORB_GLYPH = Color3.fromRGB(240, 241, 243)
local ORB_PRESS = TweenInfo.new(.13, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ORB_SETTLE = TweenInfo.new(.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ORB_MORPH = TweenInfo.new(.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ORB_RIPPLE = TweenInfo.new(.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
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
    -- The Graphite face uses neutral tones independent of theme accents.
    if not self._orbFace or self._destroyed then return end
    self._orbFace.BackgroundColor3 = ORB_BG
    self._orbHorizontal.BackgroundColor3 = ORB_GLYPH
    self._orbVertical.BackgroundColor3 = ORB_GLYPH
    if not self._toolbarOrbHolding then
        self._orbBorder.Color = ORB_BORDER
    end
end

function Hub:_setToolbarOrbSpin(_enabled)
    -- Preserve existing Hub call sites without running idle spin animations.
end

function Hub:_syncToolbarOrbState(animate)
    if not self._orbHorizontal then return end
    -- An open panel shows the reference's white minus; a hidden panel uses
    -- a white plus as a clear affordance for restoring the window.
    local open = self._visible == true
    local verticalGoals = {
        BackgroundTransparency = open and 1 or 0,
        Size = UDim2.fromOffset(2, open and 0 or 14),
    }
    if animate then
        Motion.transition(self, "toolbar-orb-glyph", open and "expanded" or "collapsed", {
            { Target = self._orbVertical, Goals = verticalGoals },
        }, ORB_MORPH)
    else
        Motion.cancel(self, "toolbar-orb-glyph")
        self._orbVertical.BackgroundTransparency = verticalGoals.BackgroundTransparency
        self._orbVertical.Size = verticalGoals.Size
    end
end

function Hub:_toolbarOrbRipple(_color, unlocked)
    if self._destroyed or not self.Restore or not self.Restore.Parent then return end
    -- Short square outline pulse; no circular halo or permanent gradient.
    local ripple = create("Frame", {
        Name = unlocked and "DragUnlockRipple" or "ToggleRipple",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(36, 36), ZIndex = 34, Parent = self.Restore,
    }, { corner(10) })
    local outline = stroke(unlocked and ORB_GREEN or ORB_BORDER, 1.2, .48)
    outline.Parent = ripple
    local target = unlocked and 44 or 41
    tween(ripple, ORB_RIPPLE, { Size = UDim2.fromOffset(target, target) })
    tween(outline, ORB_RIPPLE, { Transparency = 1 })
    task.delay(ORB_RIPPLE.Time + .05, function()
        if ripple.Parent then ripple:Destroy() end
    end)
end

function Hub:_setupToolbarOrb()
    local orb = self.Restore
    create("Frame", {
        Name = "GraphiteShadow", BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = .80, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.new(.5, 0, .5, 2),
        Size = UDim2.fromOffset(38, 38), ZIndex = 33, Parent = orb,
    }, { corner(11) })
    local face = create("Frame", {
        Name = "OrbFace", BackgroundColor3 = ORB_BG,
        BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(36, 36),
        ZIndex = 35, Parent = orb,
    }, { corner(9) })
    self._orbFace = face
    self._orbBorder = stroke(ORB_BORDER, 1, .42)
    self._orbBorder.Name = "GraphiteBorder"
    self._orbBorder.Parent = face
    self._orbScale = create("UIScale", { Scale = 1, Parent = orb })
    self._orbHorizontal = create("Frame", {
        Name = "GlyphHorizontal", BackgroundColor3 = ORB_GLYPH,
        BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(14, 2),
        ZIndex = 37, Parent = orb,
    }, { corner(2) })
    self._orbVertical = create("Frame", {
        Name = "GlyphVertical", BackgroundColor3 = ORB_GLYPH,
        BorderSizePixel = 0, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(2, 14), ZIndex = 37, Parent = orb,
    }, { corner(2) })
    self:_refreshToolbarOrbTheme()
    self:_syncToolbarOrbState(false)

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
        if on then
            tween(self._orbBorder, ORB_PRESS, {
                Color = ORB_GREEN, Thickness = 1.8, Transparency = .06,
            })
            tween(self._orbFace, ORB_PRESS, {
                BackgroundColor3 = Color3.fromRGB(19, 29, 24),
            })
            tween(self._orbScale, ORB_SETTLE, { Scale = 1.055 })
        else
            tween(self._orbBorder, ORB_MORPH, {
                Color = ORB_BORDER, Thickness = 1, Transparency = .42,
            })
            tween(self._orbFace, ORB_MORPH, { BackgroundColor3 = ORB_BG })
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
            tween(self._orbBorder, ORB_MORPH, { Transparency = .42 })
        end
        if not cancelled and not p.unlocked and not p.invalid and not self._destroyed
            and within(orb, position or p.last) then
            self:_toolbarOrbRipple(ORB_BORDER, false)
            self:ToggleToolbar()
        end
    end
    dragBinding.Cancel = function() finish(true) end
    self:Own({ Disconnect = function() finish(true) end })

    self:_connect(orb.InputBegan, function(input)
        if self._destroyed or self._loading or press or self._capturedDrag
            or self:_overlayTop() or not isPointer(input) then return end
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
        tween(self._orbBorder, ORB_PRESS, { Transparency = .18 })
        task.delay(ORB_HOLD_SECONDS, function()
            if self._destroyed or press ~= p or generation ~= token or p.invalid or not orb.Parent then return end
            if self._capturedDrag or self:_overlayTop() then finish(true); return end
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
        if self:_overlayTop() then finish(true); return end
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
                tween(self._orbBorder, ORB_MORPH, { Transparency = .42 })
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
        tween(self._orbBorder, ORB_MORPH, { Transparency = .18 })
    end)
    self:_connect(orb.MouseLeave, function()
        if press or self._destroyed then return end
        tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
        tween(self._orbBorder, ORB_MORPH, { Transparency = .42 })
    end)
end
