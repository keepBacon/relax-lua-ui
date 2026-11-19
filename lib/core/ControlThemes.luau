-- SPDX-License-Identifier: MPL-2.0
-- RelaxUI control themes: default preserves the original RiftUI controls;
-- Rounded uses independent graphics/indicator motion, never text-container scaling.
-- Skins attach after each control is constructed, so flags, callbacks and saved
-- values remain on the original control instances. Runtime switching is reversible.

RiftUI.ControlThemes = { "Default", "Rounded" }
local CONTROL_SKIN_TWEEN = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local CONTROL_SKIN_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function skinTween(inst, goals, animate)
    if not inst then return end
    if animate then
        tween(inst, CONTROL_SKIN_TWEEN, goals)
    else
        for prop, value in goals do inst[prop] = value end
    end
end

local function skinCorner(inst, radius)
    if not inst then return end
    local c = inst:FindFirstChildOfClass("UICorner")
    if c then c.CornerRadius = UDim.new(0, radius) end
end

local function skinRow(row, height)
    if row.Size.Y.Offset ~= height then
        row.Size = UDim2.new(1, 0, 0, height)
    end
end

local function skinNode(row, name)
    return row:FindFirstChild(name, true)
end

local function skinSource(control)
    local hub, row, kind = control.Section.Hub, control.Frame, control.Type
    local theme = hub.Theme

    if kind == "Toggle" then
        local box = skinNode(row, "Check")
        if not box then return nil end
        local mark = box:FindFirstChildWhichIsA("ImageLabel")
        local pop = box:FindFirstChildOfClass("UIScale")
        local labels = skinNode(row, "Labels")
        local knob = create("Frame", {
            Name = "RoundedThumb",
            BackgroundColor3 = themeColor(theme, "Text"),
            BorderSizePixel = 0, Visible = false,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            ZIndex = box.ZIndex + 1, Parent = box,
        }, { corner(7) })
        local lastValue
        return function(rounded, changed, animate)
            if changed then
                if pop then cancelMotion(pop); pop.Scale = 1 end
                box.Size = UDim2.fromOffset(rounded and 30 or 16, rounded and 18 or 16)
                skinCorner(box, rounded and 9 or 4)
                if labels then
                    labels.Size = UDim2.new(1, rounded and -43 or -32, 1, 0)
                end
                knob.Visible = rounded
                if mark then
                    mark.Visible = not rounded
                    mark.ImageTransparency = control.Value and 0 or 1
                end
            end
            if rounded then
                local on = control.Value == true
                -- Thumb moves independently; no scale on text-bearing containers.
                local goal = UDim2.new(0, on and 15 or 2, 0.5, 0)
                if changed or on ~= lastValue then
                    skinTween(knob, { Position = goal }, animate and not changed)
                end
                setThemed(knob, "BackgroundColor3", themeColor(theme, on and "AccentText" or "Text"))
            end
            lastValue = control.Value == true
        end
    end

    if kind == "Slider" or kind == "RangeSlider" then
        local track = skinNode(row, "Track")
        if not track then return nil end
        local fill = track:FindFirstChild("Fill")
        local hit = skinNode(row, "Hit")
        local knob = kind == "Slider" and track:FindFirstChild("Notch") or nil
        local low = kind == "RangeSlider" and track:FindFirstChild("Low") or nil
        local high = kind == "RangeSlider" and track:FindFirstChild("High") or nil
        local bubble
        local bubbleText
        local dragging = false
        local hideVersion = 0
        if kind == "Slider" then
            bubble = create("CanvasGroup", {
                Name = "RoundedValueBubble",
                Size = UDim2.fromOffset(42, 18),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromOffset(24, 34),
                BackgroundColor3 = themeColor(theme, "TileActive"),
                GroupTransparency = 1, Visible = false,
                ZIndex = 6, Parent = row,
            }, { corner(8), stroke(themeColor(theme, "TileActiveStroke")) })
            bubbleText = text({
                Parent = bubble, Name = "BubbleValue",
                Text = "", TextSize = 11, FontFace = MONO,
                TextColor3 = themeColor(theme, "Text"),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Size = UDim2.fromScale(1, 1), ZIndex = 7,
            })
        end
        local function updateBubble()
            if not bubble or not bubbleText then return end
            local min, max = control.Min or 0, control.Max or 100
            local ratio = max > min and math.clamp((control.Value - min) / (max - min), 0, 1) or 0
            local available = math.max(44, row.AbsoluteSize.X / math.max(hub._scale, .01))
            local x = math.clamp(ratio * available, 22, math.max(22, available - 22))
            bubble.Position = UDim2.fromOffset(math.floor(x + 0.5), 34)
            bubbleText.Text = formatNumber(control.Value, control.Step or 1)
        end
        if kind == "Slider" then
            -- The actual slider's bindPointerDrag is the authoritative lifecycle.
            -- A separate InputBegan/Ended pair previously leaked a floating
            -- bubble after pointer release and could move it above the title.
            control._skinDrag = function(on)
                if hub._destroyed or not bubble then return end
                hideVersion += 1
                local ticket = hideVersion
                dragging = on == true and hub:GetControlTheme() == "Rounded"
                if dragging then
                    updateBubble()
                    bubble.Visible = true
                    skinTween(bubble, { GroupTransparency = 0 }, true)
                else
                    skinTween(bubble, { GroupTransparency = 1 }, true)
                    task.delay(CONTROL_SKIN_FAST.Time + .03, function()
                        if not hub._destroyed and ticket == hideVersion and not dragging then
                            bubble.Visible = false
                        end
                    end)
                end
            end
            hub:_connect(row.Destroying, function()
                hideVersion += 1
                dragging = false
            end)
        end
        return function(rounded, changed, animate)
            if changed then
                -- Keep the readout/title in their original position and use a
                -- comfortably sized, non-overlapping track and thumb.
                skinRow(row, rounded and 52 or 46)
                skinTween(track, {
                    Position = UDim2.fromOffset(0, rounded and 39 or 34),
                    Size = UDim2.new(1, 0, 0, rounded and 5 or 2),
                }, animate)
                skinCorner(track, rounded and 3 or 1)
                skinCorner(fill, rounded and 3 or 1)
                if hit then
                    hit.Position = UDim2.fromOffset(-6, rounded and 27 or 24)
                    hit.Size = UDim2.new(1, 12, 0, rounded and 27 or 22)
                end
                for _, handle in { knob, low, high } do
                    if handle then
                        skinTween(handle, { Size = UDim2.fromOffset(rounded and 12 or 4, rounded and 12 or 14) }, animate)
                        skinCorner(handle, rounded and 6 or 2)
                    end
                end
                if bubble and not rounded then
                    hideVersion += 1
                    dragging = false
                    cancelMotion(bubble)
                    bubble.Visible = false
                    bubble.GroupTransparency = 1
                end
            end
            if rounded and bubble and dragging then updateBubble() end
        end
    end

    if kind == "Button" then
        local button = skinNode(row, "Button")
        if not button then return nil end
        local press = button:FindFirstChildOfClass("UIScale")
        local base = button.BackgroundColor3
        control._skinPress = function(down)
            if hub:GetControlTheme() ~= "Rounded" then return end
            skinTween(button, {
                BackgroundColor3 = down and themeColor(theme, "TileActive") or base,
            }, true)
        end
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 38 or 36)
            skinTween(button, { Size = UDim2.new(1, 0, 0, rounded and 30 or 28) }, animate)
            skinCorner(button, rounded and 10 or 6)
            -- No 1px highlight stripe or full-button UIScale: both made this
            -- widget look detached and caused its caption to rasterize poorly.
            if press then cancelMotion(press); press.Scale = 1 end
            local border = button:FindFirstChildOfClass("UIStroke")
            if border then border.Thickness = rounded and 1 or 1 end
        end
    end

    if kind == "Dropdown" or kind == "PlayerPicker" or kind == "Keybind" then
        local chip = skinNode(row, kind == "Keybind" and "Key" or "Chip")
        if not chip then return nil end
        local originalHeight = chip.Size.Y.Offset
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 40 or 34)
            skinTween(chip, {
                Size = UDim2.new(chip.Size.X.Scale, chip.Size.X.Offset, 0, rounded and 30 or originalHeight),
            }, animate)
            skinCorner(chip, rounded and 12 or 6)
            local border = chip:FindFirstChildOfClass("UIStroke")
            if border then border.Thickness = rounded and 1.15 or 1 end
            local limits = chip:FindFirstChildOfClass("UISizeConstraint")
            if limits then
                if limits.MaxSize.X < 10000 then
                    limits.MaxSize = Vector2.new(limits.MaxSize.X, rounded and 30 or originalHeight)
                end
                if limits.MinSize.X > 0 then
                    limits.MinSize = Vector2.new(limits.MinSize.X, rounded and 30 or originalHeight)
                end
            end
        end
    end

    if kind == "Segmented" then
        local track, pill = skinNode(row, "Track"), skinNode(row, "Pill")
        if not track or not pill then return nil end
        local labeled = skinNode(row, "Title") ~= nil
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, labeled and (rounded and 66 or 58) or (rounded and 42 or 34))
            skinTween(track, { Size = UDim2.new(1, 0, 0, rounded and 36 or 28) }, animate)
            skinCorner(track, rounded and 13 or 7)
            skinCorner(pill, rounded and 11 or 5)
            local border = track:FindFirstChildOfClass("UIStroke")
            if border then border.Thickness = rounded and 1.15 or 1 end
        end
    end

    if kind == "Input" then
        local box = skinNode(row, "Box")
        if not box then return nil end
        local originalHeight = box.Size.Y.Offset
        local originalRow = row.Size.Y.Offset
        local focus = create("Frame", {
            Name = "RoundedFocusIndicator",
            BackgroundColor3 = themeColor(theme, "Accent"),
            BackgroundTransparency = .2,
            BorderSizePixel = 0, Visible = false,
            AnchorPoint = Vector2.new(.5, 1),
            Position = UDim2.new(.5, 0, 1, -2),
            Size = UDim2.new(1, -20, 0, 2),
            ZIndex = box.ZIndex + 1, Parent = box,
        }, { corner(1) })
        hub:_connect(box.Focused, function()
            if hub:GetControlTheme() == "Rounded" then focus.Visible = true end
        end)
        hub:_connect(box.FocusLost, function() focus.Visible = false end)
        return function(rounded, changed, animate)
            if not changed then return end
            local height = rounded and originalHeight + 6 or originalHeight
            skinRow(row, rounded and originalRow + 8 or originalRow)
            skinTween(box, { Size = UDim2.new(1, 0, 0, height) }, animate)
            skinCorner(box, rounded and 12 or 6)
            focus.Visible = rounded and box:IsFocused()
        end
    end

    if kind == "ColorPicker" then
        local swatch = skinNode(row, "Swatch")
        if not swatch then return nil end
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 40 or 34)
            skinTween(swatch, { Size = UDim2.fromOffset(rounded and 44 or 36, rounded and 26 or 20) }, animate)
            skinCorner(swatch, rounded and 13 or 6)
        end
    end

    if kind == "Stepper" then
        local box = skinNode(row, "Stepper")
        if not box then return nil end
        local labels = skinNode(row, "Labels")
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 40 or 34)
            skinTween(box, { Size = UDim2.fromOffset(rounded and 104 or 92, rounded and 30 or 24) }, animate)
            skinCorner(box, rounded and 13 or 6)
            if labels then labels.Size = UDim2.new(1, rounded and -119 or -104, 1, 0) end
            for _, name in { "Decrease", "Increase" } do
                skinCorner(box:FindFirstChild(name), rounded and 13 or 6)
            end
        end
    end

    if kind == "Progress" then
        local bar = skinNode(row, "Bar")
        if not bar then return nil end
        local titled = skinNode(row, "Title") ~= nil
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, titled and (rounded and 46 or 42) or (rounded and 26 or 22))
            skinTween(bar, { Size = UDim2.new(1, 0, 0, rounded and 9 or 6) }, animate)
            for _, child in bar:GetDescendants() do
                if child:IsA("Frame") and child.Name ~= "Bar" then
                    skinCorner(child, rounded and 5 or (child.Name == "Segment" and 2 or 3))
                end
            end
        end
    end
    return nil
end

function Hub:GetControlTheme()
    return self._controlTheme == "Rounded" and "Rounded" or "Default"
end

function Hub:_attachControlTheme(control)
    -- Defer to the end of control construction: visual objects and Set() now exist.
    task.defer(function()
        if self._destroyed or not control.Frame.Parent then return end
        local style = skinSource(control)
        if not style then return end
        self._skinEntries = self._skinEntries or setmetatable({}, { __mode = "k" })
        local current
        local function refresh(animate)
            if self._destroyed or not control.Frame.Parent then return end
            local nextTheme = self:GetControlTheme()
            local changed = nextTheme ~= current
            current = nextTheme
            style(nextTheme == "Rounded", changed, animate)
        end
        self._skinEntries[control] = refresh
        local original = control.Set
        if type(original) == "function" then
            control.Set = function(instance, ...)
                local result = table.pack(original(instance, ...))
                if not self._destroyed then refresh(true) end
                return table.unpack(result, 1, result.n)
            end
        end
        refresh(false)
    end)
end

function Hub:SetControlTheme(value)
    if self._destroyed then return false, "hub destroyed" end
    if value ~= "Default" and value ~= "Rounded" then
        return false, "control theme must be Default or Rounded"
    end
    if self:GetControlTheme() == value then return true end
    self._controlTheme = value
    self.Options.ControlTheme = value
    self:_savePref("ControlTheme", value)
    for _, refresh in self._skinEntries or {} do
        local ok, err = pcall(refresh, true)
        if not ok then warn("[RelaxUI] control theme refresh: " .. tostring(err)) end
    end
    if self._controlThemeControl and self._controlThemeControl.Value ~= value then
        self._controlThemeControl:Set(value, true)
    end
    return true
end

function Hub:RefreshControlTheme()
    for _, refresh in self._skinEntries or {} do
        pcall(refresh, false)
    end
end

function Hub:GetColorTheme()
    return self.ThemeName
end

function Hub:SetColorTheme(name)
    -- Keep the existing theme API working for third-party hubs.
    return self:SetTheme(name)
end
