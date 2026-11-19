-- SPDX-License-Identifier: MPL-2.0
-- Weather backdrops modeled on the Rain/Snow/Ember/Sakura/Fireflies/Matrix
-- particle systems in AsterUI and FlowUI. Uses Roblox GUI, no executor assets.
-- Particle rendering lives BEHIND the RelaxUI screen (or under its Panel);
-- it never captures clicks or changes text-container layout.
local WEATHER_DEFS = {
    Rain = { Count = 70, Image = "rbxassetid://241868005" },
    Snow = { Count = 55, Image = "rbxassetid://99851851" },
    Ember = { Count = 42, Image = "rbxassetid://242205518" },
    Sakura = { Count = 38 },
    Fireflies = { Count = 28 },
    Matrix = { Count = 30 },
}
local WEATHER_ORDER = { "None", "Rain", "Snow", "Ember", "Sakura", "Fireflies", "Matrix" }
local WEATHER_ALIASES = {
    none = "None", off = "None", rain = "Rain", snow = "Snow",
    ember = "Ember", embers = "Ember", fire = "Ember",
    sakura = "Sakura", petals = "Sakura", fireflies = "Fireflies",
    firefly = "Fireflies", matrix = "Matrix", code = "Matrix",
}
local WX_GLYPHS = "0123456789ABCDEF+-*<>"
local WX_RANDOM = Random.new()
local function wxRoll(min, max) return WX_RANDOM:NextNumber(min, max) end
local function wxName(raw)
    if type(raw) ~= "string" then return nil end
    return WEATHER_ALIASES[raw:lower():gsub("[%s_%-]", "")]
end

function Hub:ListWeather()
    return table.clone(WEATHER_ORDER)
end

function Hub:GetWeather()
    local value = self._weatherKind
        or (self.SetupData and self.SetupData.Weather)
        or (self.Options and self.Options.Weather)
        or "None"
    return wxName(value) or "None"
end

function Hub:GetWeatherMode()
    local mode = self._weatherMode
        or (self.SetupData and self.SetupData.WeatherMode)
        or (self.Options and self.Options.WeatherMode)
    return mode == "UI" and "UI" or "Screen"
end

function Hub:GetWeatherDensity()
    return math.clamp(tonumber(self._weatherDensity
        or (self.SetupData and self.SetupData.WeatherDensity)
        or (self.Options and self.Options.WeatherDensity)) or 1, 0, 2)
end

function Hub:GetWeatherSpeed()
    return math.clamp(tonumber(self._weatherSpeed
        or (self.SetupData and self.SetupData.WeatherSpeed)
        or (self.Options and self.Options.WeatherSpeed)) or 1, 0.25, 2.5)
end

function Hub:_weatherSize()
    if self:GetWeatherMode() == "UI" then
        local size = self.Panel.AbsoluteSize / math.max(self._scale, .01)
        return Vector2.new(math.max(size.X, 300), math.max(size.Y, 120))
    end
    local size = viewport()
    return Vector2.new(math.max(size.X, 320), math.max(size.Y, 200))
end

function Hub:_clearWeatherParticles()
    for _, particle in self._weatherParticles or {} do
        if particle.Gui then particle.Gui:Destroy() end
    end
    self._weatherParticles = {}
end

function Hub:_seedWeatherParticle(kind, particle, anywhere)
    local size = self:_weatherSize()
    local width, height = size.X, size.Y
    local p = particle
    p.Clock = wxRoll(0, 10)
    p.Phase = wxRoll(0, math.pi * 2)
    p.Freq = wxRoll(.5, 1.5)
    p.Life = nil
    p.Age = 0
    p.Sway = 0
    p.Twirl = 0
    p.Alpha = wxRoll(.05, .3)
    if kind == "Rain" then
        p.Width, p.Height = wxRoll(2, 3.5), wxRoll(25, 52)
        p.VY = wxRoll(940, 1340)
        p.VX = p.VY * .10
        p.Rot = -math.deg(math.atan2(p.VX, p.VY))
        p.Alpha = wxRoll(.12, .42)
    elseif kind == "Snow" then
        local d = wxRoll(6, 16)
        p.Width, p.Height = d, d
        p.VY = wxRoll(30, 55) * (.6 + d / 17)
        p.VX = wxRoll(-9, 14)
        p.Sway = wxRoll(12, 34)
        p.Rot = wxRoll(0, 360)
        p.Twirl = wxRoll(-50, 50)
        p.Alpha = wxRoll(.03, .28)
    elseif kind == "Ember" then
        local d = wxRoll(4, 10)
        p.Width, p.Height = d, d
        p.VY, p.VX = -wxRoll(55, 155), wxRoll(-12, 12)
        p.Sway = wxRoll(8, 25)
        p.Twirl = wxRoll(-120, 120)
        p.Rot = wxRoll(0, 360)
        p.Alpha = wxRoll(.08, .40)
        p.Gui.ImageColor3 = Color3.fromRGB(255, math.floor(wxRoll(90, 190)), 55)
    elseif kind == "Sakura" then
        local d = wxRoll(7, 14)
        p.Width, p.Height = d, d * wxRoll(.55, .8)
        p.VY, p.VX = wxRoll(35, 70), wxRoll(18, 42)
        p.Sway, p.Twirl = wxRoll(13, 32), wxRoll(-95, 95)
        p.Rot = wxRoll(0, 360)
        p.Gui.BackgroundColor3 = Color3.fromRGB(255, math.floor(wxRoll(145, 205)), math.floor(wxRoll(175, 220)))
    elseif kind == "Fireflies" then
        local d = wxRoll(10, 23)
        p.Width, p.Height = d, d
        p.VY, p.VX = wxRoll(-12, 8), wxRoll(-12, 12)
        p.Sway = wxRoll(12, 25)
        p.Life = wxRoll(5, 11)
        p.Age = anywhere and wxRoll(0, p.Life) or 0
        p.Alpha = wxRoll(.2, .52)
        p.Gui.BackgroundColor3 = Color3.fromRGB(math.floor(wxRoll(200, 245)), 255, math.floor(wxRoll(105, 165)))
    else -- Matrix, code rain
        local n = math.floor(wxRoll(8, 15))
        p.Width, p.Height = 14, n * 14
        p.VY, p.VX = wxRoll(140, 280), 0
        p.Alpha = wxRoll(.2, .52)
        local chars = {}
        for i = 1, n do
            local j = math.floor(wxRoll(1, #WX_GLYPHS + .999))
            chars[i] = WX_GLYPHS:sub(j, j)
        end
        p.Gui.Text = table.concat(chars, "\n")
    end
    p.X = wxRoll(-math.min(width * .12, 85), width)
    if kind == "Ember" then
        p.Y = anywhere and wxRoll(0, height) or height + wxRoll(10, 80)
    elseif kind == "Fireflies" then
        p.Y = wxRoll(height * .2, height)
    else
        p.Y = anywhere and wxRoll(-p.Height, height) or -p.Height - wxRoll(0, 60)
    end
    p.Gui.Size = UDim2.fromOffset(p.Width, p.Height)
    if kind == "Rain" then p.Gui.Rotation = p.Rot end
end

function Hub:_rebuildWeather()
    if not self._weatherField then return end
    self:_clearWeatherParticles()
    local kind = self:GetWeather()
    local def = WEATHER_DEFS[kind]
    if not def or self:GetWeatherDensity() == 0 then
        self._weatherField.Visible = false
        return
    end
    local touch = UserInputService.TouchEnabled
    local maxParticles = touch and 50 or 100
    local count = math.min(maxParticles, math.floor(def.Count * self:GetWeatherDensity()
        * (self:GetWeatherMode() == "UI" and .45 or 1) + .5))
    for _ = 1, count do
        local gui
        if kind == "Matrix" then
            gui = create("TextLabel", {
                Name = "WeatherMatrix", BackgroundTransparency = 1,
                Text = "", TextColor3 = Color3.fromRGB(80, 230, 130),
                TextSize = 12, FontFace = Font.fromEnum(Enum.Font.Code),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = 1, Parent = self._weatherField,
            })
        elseif kind == "Sakura" or kind == "Fireflies" then
            gui = create("Frame", {
                Name = "Weather" .. kind, BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ZIndex = 1, Parent = self._weatherField,
            }, { corner(kind == "Sakura" and 5 or 20) })
        else
            gui = create("ImageLabel", {
                Name = "Weather" .. kind, BackgroundTransparency = 1,
                Image = def.Image, ImageTransparency = 1,
                ScaleType = Enum.ScaleType.Stretch, ZIndex = 1,
                Parent = self._weatherField,
            })
        end
        local particle = { Gui = gui }
        self:_seedWeatherParticle(kind, particle, true)
        table.insert(self._weatherParticles, particle)
    end
end

function Hub:_ensureWeather()
    if self._weatherField then return end
    local screen = create("ScreenGui", {
        Name = "RelaxUIWeather", ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = math.max(0, self.Gui.DisplayOrder - 1),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = self.Gui.Parent,
    })
    local field = create("Frame", {
        Name = "WeatherField", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true, Visible = false,
        ZIndex = 0, Parent = screen,
    })
    self._weatherScreen, self._weatherField = screen, field
    self._weatherParticles = {}
    self._weatherFrameClock = 0
    self._weatherFrameConn = RunService.RenderStepped:Connect(function(dt)
        if self._destroyed then return end
        if not self._open or not self._visible or self:GetWeather() == "None" then
            self._weatherField.Visible = false
            return
        end
        self._weatherField.Visible = true
        self._weatherFrameClock += math.min(dt, .05)
        -- Capped to 30 updates/sec; particles do not animate a single text container.
        if self._weatherFrameClock < (1 / 30) then return end
        local step = math.min(self._weatherFrameClock, 1 / 15)
        self._weatherFrameClock = 0
        local size = self:_weatherSize()
        local w, h = size.X, size.Y
        local speed = self:GetWeatherSpeed()
        local mode = self:GetWeather()
        for _, particle in self._weatherParticles do
            particle.Clock += step
            particle.X += particle.VX * step * speed
            particle.Y += particle.VY * step * speed
            particle.Rot += particle.Twirl * step * speed
            local margin = math.max(particle.Width, particle.Height)
            if particle.Life then particle.Age += step end
            if (particle.Life and particle.Age >= particle.Life)
                or (not particle.Life and
                    ((particle.VY > 0 and particle.Y > h + margin)
                    or (particle.VY < 0 and particle.Y < -margin))) then
                self:_seedWeatherParticle(mode, particle, false)
            end
            if particle.X > w + margin * 4 then particle.X = -margin end
            if particle.X < -margin * 4 then particle.X = w + margin end
            local x = particle.X
            if particle.Sway > 0 then x += math.sin(particle.Clock * particle.Freq + particle.Phase) * particle.Sway end
            particle.Gui.Position = UDim2.fromOffset(math.floor(x + .5), math.floor(particle.Y + .5))
            if mode ~= "Rain" then particle.Gui.Rotation = particle.Rot end
            local alpha = particle.Alpha
            if mode == "Fireflies" then
                alpha = math.clamp(alpha + math.sin(particle.Clock * 2 + particle.Phase) * .18, 0, .95)
            elseif mode == "Ember" then
                alpha = math.clamp(alpha + (1 - particle.Y / math.max(h, 1)) * .55, 0, .95)
            end
            local transparency = 1 - (1 - alpha) * self:GetWeatherOpacity()
            if mode == "Matrix" then
                particle.Gui.TextTransparency = transparency
            elseif mode == "Sakura" or mode == "Fireflies" then
                particle.Gui.BackgroundTransparency = transparency
            else
                particle.Gui.ImageTransparency = transparency
            end
        end
    end)
end

function Hub:GetWeatherOpacity()
    return math.clamp(tonumber(self._weatherOpacity
        or (self.SetupData and self.SetupData.WeatherOpacity)
        or (self.Options and self.Options.WeatherOpacity)) or .7, .05, 1)
end

function Hub:SetWeather(name)
    if self._destroyed then return false, "hub destroyed" end
    local kind = wxName(name)
    if not kind then return false, "unknown weather effect" end
    self._weatherKind = kind
    self:_savePref("Weather", kind)
    if kind == "None" then
        if self._weatherField then self:_clearWeatherParticles(); self._weatherField.Visible = false end
        return true
    end
    self:_ensureWeather()
    self:_rebuildWeather()
    return true
end

function Hub:SetWeatherMode(mode)
    if self._destroyed then return false, "hub destroyed" end
    if mode ~= "Screen" and mode ~= "UI" then return false, "mode must be Screen or UI" end
    self._weatherMode = mode
    self:_savePref("WeatherMode", mode)
    if self._weatherField then
        self._weatherField.Parent = mode == "UI" and self.Panel or self._weatherScreen
        self._weatherField.ZIndex = 0
        self:_rebuildWeather()
    end
    return true
end

function Hub:SetWeatherDensity(density)
    if self._destroyed then return false, "hub destroyed" end
    local n = tonumber(density)
    if not n then return false, "invalid density" end
    self._weatherDensity = math.clamp(n, 0, 2)
    self:_savePref("WeatherDensity", self._weatherDensity)
    if self._weatherField then self:_rebuildWeather() end
    return true
end

function Hub:SetWeatherSpeed(speed)
    if self._destroyed then return false, "hub destroyed" end
    local n = tonumber(speed)
    if not n then return false, "invalid speed" end
    self._weatherSpeed = math.clamp(n, .25, 2.5)
    self:_savePref("WeatherSpeed", self._weatherSpeed)
    return true
end

function Hub:SetWeatherOpacity(opacity)
    if self._destroyed then return false, "hub destroyed" end
    local n = tonumber(opacity)
    if not n then return false, "invalid opacity" end
    self._weatherOpacity = math.clamp(n, .05, 1)
    self:_savePref("WeatherOpacity", self._weatherOpacity)
    return true
end

function Hub:_disposeWeather()
    if self._weatherFrameConn then
        self._weatherFrameConn:Disconnect()
        self._weatherFrameConn = nil
    end
    if self._weatherField then self:_clearWeatherParticles() end
    if self._weatherScreen then self._weatherScreen:Destroy() end
    self._weatherScreen = nil
    self._weatherField = nil
end
