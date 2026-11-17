--[[
    VantaUI v0.3.8
    Roblox UI library by MrRos3.

    Public production loader.
    - Loads the current dist runtime directly.
    - Applies executor compatibility repairs when needed.
    - Restores Vanta branding and Salty Special defaults.
    - Notification open/close sounds are disabled by default.
]]

local PROJECT_VERSION = "0.3.8"
local CACHE_BUSTER = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local RUNTIME_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/dist/main.lua?v=" .. CACHE_BUSTER
local BRAND_IMAGE_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/vanta-brand-v2-original.jpeg?v=original-valid-20261015"
local SALTY_SPECIAL_WALLPAPER_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/crimson01-hq.jpg?v=crimson01-hq-native-20261021"
local SALTY_SPECIAL_WALLPAPER_TRANSPARENCY = 0.32

local function patchRuntime(source)
    local patched = source

    patched = patched:gsub(
        "type%s+ConfigType__DARKLUA_TYPE_[%w_]+%s*=%s*{.-}%s*local",
        "local",
        1
    )

    patched = patched:gsub(
        "local%s+([%a_][%w_]*)%s+%1%s*=",
        "local %1=",
        8
    )

    patched = patched:gsub(
        "([%a_][%w_%.]*)%s*%+=%s*([^;\n]+)",
        "%1=%1+(%2)"
    )

    return patched
end

local ok, source = pcall(function()
    return game:HttpGet(RUNTIME_URL)
end)
assert(ok and type(source) == "string" and #source > 0, "[VantaUI] Failed to download the current runtime")

local loader, loadError = loadstring(source)
if not loader then
    source = patchRuntime(source)
    loader, loadError = loadstring(source)
end
assert(loader, "[VantaUI] Failed to compile the current runtime: " .. tostring(loadError))

-- Retire stale production windows before loading a new UI. Other script GUIs
-- and VantaTest remain untouched.
local function clearPreviousVantaUI()
    local environment
    if type(getgenv) == "function" then
        local ok, result = pcall(getgenv)
        if ok and type(result) == "table" then environment = result end
    end
    if environment and type(environment.__VANTAUI_CLEANUP) == "function" then
        pcall(environment.__VANTAUI_CLEANUP)
        environment.__VANTAUI_CLEANUP = nil
    end
    local owners, seen = {}, {}
    if type(gethui) == "function" then
        local ok, owner = pcall(gethui)
        if ok and owner then owners[#owners + 1] = owner end
    end
    local coreOK, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if coreOK and coreGui then owners[#owners + 1] = coreGui end
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if playerGui then owners[#owners + 1] = playerGui end
    local own = {
        ["VantaUI"] = true, ["VantaUI/Notifications"] = true,
        ["VantaUI/Dropdowns"] = true, ["VantaUI/Tooltips"] = true,
    }
    for _, owner in ipairs(owners) do
        if not seen[owner] then
            seen[owner] = true
            -- Some executors protect CoreGui enumeration. Failure to list
            -- one container must never prevent the library from loading.
            local ok, children = pcall(function() return owner:GetChildren() end)
            if ok and children then
                for _, child in ipairs(children) do
                    if child:IsA("ScreenGui") and own[child.Name] then
                        pcall(function() child:Destroy() end)
                    end
                end
            end
        end
    end
end
clearPreviousVantaUI()

local runtimeOk, VantaUI = pcall(loader)
assert(runtimeOk and type(VantaUI) == "table", "[VantaUI] Current runtime returned an invalid value: " .. tostring(VantaUI))

VantaUI.RuntimeVersion = tostring(VantaUI.Version or PROJECT_VERSION)
VantaUI.Version = PROJECT_VERSION
VantaUI.Name = "VantaUI"
VantaUI.DefaultTheme = "Salty Special"
VantaUI.DefaultStartupTab = 1
VantaUI.TransparencyValue = 0.1

VantaUI.GuiInfo = {
    Name = "VantaUI",
    Version = PROJECT_VERSION,
    Owner = "MrRos3",
    Repository = "MrRos3/VantaUI",
    Runtime = "dist/main.lua",
    License = "MIT",
}

VantaUI.Brand = {
    Name = "VantaUI",
    Owner = "MrRos3",
    Image = BRAND_IMAGE_URL,
    CacheKey = "v3",
    Accent = Color3.fromHex("#929AA7"),
    Cyan = Color3.fromHex("#5DE7FF"),
}

VantaUI.Assets = {
    Brand = BRAND_IMAGE_URL,
    SaltySpecialWallpaper = SALTY_SPECIAL_WALLPAPER_URL,
}

local VantaThemes = {
    {
        Name = "Salty Special",
        Accent = Color3.fromHex("#A1162F"),
        Dialog = Color3.fromHex("#0A0709"),
        Outline = Color3.fromHex("#5A1824"),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#9A9AA3"),
        Background = Color3.fromHex("#000000"),
        Button = Color3.fromHex("#251016"),
        Icon = Color3.fromHex("#E2DDE0"),
        Toggle = Color3.fromHex("#A1162F"),
        Slider = Color3.fromHex("#A1162F"),
        Checkbox = Color3.fromHex("#A1162F"),
        Primary = Color3.fromHex("#A1162F"),
        SliderIcon = Color3.fromHex("#F1E3E7"),
        PanelBackground = Color3.fromHex("#050406"),
        PanelBackgroundTransparency = 0.42,
        LabelBackground = Color3.fromHex("#0A080A"),
        LabelBackgroundTransparency = 0.08,
        ElementBackground = Color3.fromHex("#151116"),
        ElementBackgroundTransparency = 0.16,
        -- Let the Crimson01 artwork show through; selection fades away to the right.
        TabBackgroundActive = Color3.fromHex("#0B0A0C"),
        TabBackgroundActiveTransparency = 1,
        TabBackgroundHover = Color3.fromHex("#151013"),
        TabBackgroundHoverTransparency = 0.82,
        TabSelectionFade = Color3.fromHex("#4A1C2B"),
    },
    {
        Name = "Vanta Smoked",
        Accent = Color3.fromHex("#171A20"),
        Dialog = Color3.fromHex("#121419"),
        Outline = Color3.fromHex("#FFFFFF"),
        Text = Color3.fromHex("#F5F7FA"),
        Placeholder = Color3.fromHex("#8B919C"),
        Background = Color3.fromHex("#0B0D10"),
        Button = Color3.fromHex("#282D35"),
        Icon = Color3.fromHex("#B1B7C1"),
        Toggle = Color3.fromHex("#34C759"),
        Slider = Color3.fromHex("#7C8CFF"),
        Checkbox = Color3.fromHex("#929AA7"),
        Primary = Color3.fromHex("#929AA7"),
        SliderIcon = Color3.fromHex("#B8BEC8"),
        PanelBackground = Color3.fromHex("#FFFFFF"),
        PanelBackgroundTransparency = 0.975,
        LabelBackground = Color3.fromHex("#0A0C0F"),
        LabelBackgroundTransparency = 0.16,
        ElementBackground = Color3.fromHex("#1C2027"),
        ElementBackgroundTransparency = 0,
    },
    {
        Name = "Vanta Dark",
        Accent = Color3.fromHex("#151923"),
        Dialog = Color3.fromHex("#11141C"),
        Outline = Color3.fromHex("#FFFFFF"),
        Text = Color3.fromHex("#F7F9FF"),
        Placeholder = Color3.fromHex("#98A1B3"),
        Background = Color3.fromHex("#0B0E14"),
        Button = Color3.fromHex("#242B3A"),
        Icon = Color3.fromHex("#AEB7C8"),
        Toggle = Color3.fromHex("#34C759"),
        Slider = Color3.fromHex("#7C8CFF"),
        Checkbox = Color3.fromHex("#7C8CFF"),
        Primary = Color3.fromHex("#7C8CFF"),
        SliderIcon = Color3.fromHex("#A9B2C4"),
        PanelBackground = Color3.fromHex("#FFFFFF"),
        PanelBackgroundTransparency = 0.96,
        LabelBackground = Color3.fromHex("#000000"),
        LabelBackgroundTransparency = 0.82,
        ElementBackground = Color3.fromHex("#171C27"),
        ElementBackgroundTransparency = 0,
    },
    {
        Name = "Vanta AMOLED",
        Accent = Color3.fromHex("#0A0A0D"),
        Dialog = Color3.fromHex("#08090C"),
        Outline = Color3.fromHex("#FFFFFF"),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#858B98"),
        Background = Color3.fromHex("#000000"),
        Button = Color3.fromHex("#17191F"),
        Icon = Color3.fromHex("#A8AFBC"),
        Toggle = Color3.fromHex("#34C759"),
        Slider = Color3.fromHex("#7C8CFF"),
        Checkbox = Color3.fromHex("#5DE7FF"),
        Primary = Color3.fromHex("#5DE7FF"),
        SliderIcon = Color3.fromHex("#C4CAD4"),
        PanelBackground = Color3.fromHex("#FFFFFF"),
        PanelBackgroundTransparency = 0.975,
        LabelBackground = Color3.fromHex("#090A0C"),
        LabelBackgroundTransparency = 0.12,
        ElementBackground = Color3.fromHex("#0D0F14"),
        ElementBackgroundTransparency = 0,
    },
    {
        Name = "Vanta Violet",
        Accent = Color3.fromHex("#211B35"),
        Dialog = Color3.fromHex("#171323"),
        Outline = Color3.fromHex("#FFFFFF"),
        Text = Color3.fromHex("#FCF9FF"),
        Placeholder = Color3.fromHex("#A49AB5"),
        Background = Color3.fromHex("#0D0A13"),
        Button = Color3.fromHex("#2C2440"),
        Icon = Color3.fromHex("#C5B8D8"),
        Toggle = Color3.fromHex("#34C759"),
        Slider = Color3.fromHex("#7C8CFF"),
        Checkbox = Color3.fromHex("#D47CFF"),
        Primary = Color3.fromHex("#A98BFF"),
        SliderIcon = Color3.fromHex("#D7CCEA"),
        PanelBackground = Color3.fromHex("#FFFFFF"),
        PanelBackgroundTransparency = 0.965,
        LabelBackground = Color3.fromHex("#120E1B"),
        LabelBackgroundTransparency = 0.12,
        ElementBackground = Color3.fromHex("#1B1628"),
        ElementBackgroundTransparency = 0,
    },
}

local LegacyThemeNames = {
    ["Vanta Smoked"] = "Gui Smoked",
    ["Vanta Dark"] = "Gui Dark",
    ["Vanta AMOLED"] = "Gui AMOLED",
    ["Vanta Violet"] = "Gui Violet",
}

if type(VantaUI.AddTheme) == "function" then
    for _, theme in ipairs(VantaThemes) do
        pcall(function()
            VantaUI:AddTheme(theme)
        end)

        local legacyName = LegacyThemeNames[theme.Name]
        if legacyName then
            local legacyTheme = {}
            for key, value in pairs(theme) do
                legacyTheme[key] = value
            end
            legacyTheme.Name = legacyName
            pcall(function()
                VantaUI:AddTheme(legacyTheme)
            end)
        end
    end
end

-- Notification sounds were intentionally removed from VantaUI production.
-- Keep all other interface sounds available.
if type(VantaUI.SetSoundForEvent) == "function" then
    pcall(function()
        VantaUI:SetSoundForEvent("Notification", false)
        VantaUI:SetSoundForEvent("NotificationClose", false)
    end)
end

-- Crimson01 ambient scene: a SHARP static wallpaper with lightweight native motion.
-- 50 layered particles: falling petals, rising embers, drifting glows and soft glints.
-- One throttled RenderStepped connection per window; never animate the wallpaper.
local RunService = game:GetService("RunService")
local CRIMSON_AMBIENT_FPS = 30
local CRIMSON_PARTICLE_COUNTS = {
    Petal = 18,
    Ember = 17,
    Mote = 10,
    Glint = 5,
}

local function attachCrimsonAmbient(window)
    local main = window and window.UIElements and window.UIElements.Main
    local backdrop = main and main:FindFirstChild("Background")
    if not backdrop then return nil end
    local existing = backdrop:FindFirstChild("Crimson01Ambient")
    if existing then return existing end

    local overlay = Instance.new("Frame")
    overlay.Name = "Crimson01Ambient"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.Position = UDim2.fromScale(0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ClipsDescendants = true
    overlay.Active = false
    -- The window shrinks for 0.9s when minimized; all ambience hides instantly.
    overlay.Visible = not window.Closed and main.Visible
    overlay.ZIndex = math.max(backdrop.ZIndex + 1, 2)
    overlay.Parent = backdrop

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = overlay

    local particles = {}
    local elapsed = 0
    local frameAccumulator = 0

    -- Repeatable, independent seeds avoid bursts of particles starting together.
    local function seed(index, salt)
        return ((index * 83 + salt * 59 + (index * salt * 13)) % 257) / 257
    end

    local function spawn(kind, index)
        local salt = kind == "Petal" and 1 or kind == "Ember" and 2
            or kind == "Mote" and 3 or 4
        local a, b, c = seed(index, salt), seed(index + 7, salt + 4),
            seed(index + 23, salt + 9)
        local particle = Instance.new("Frame")
        particle.Name = kind
        particle.BackgroundTransparency = 1
        particle.BorderSizePixel = 0
        particle.Active = false
        particle.AnchorPoint = Vector2.new(0.5, 0.5)
        particle.ZIndex = overlay.ZIndex + (kind == "Petal" and 2 or 1)
        particle.Parent = overlay

        local p = {
            item = particle, kind = kind,
            phase = b, x = -0.035 + 1.07 * a, y = c,
            drift = ((index % 2 == 0) and 1 or -1) * (0.07 + b * 0.16),
            sway = 0.007 + 0.016 * c,
            rate = 0.02 + 0.024 * b,
            rotation = 10 + 24 * a,
            pulse = 1.2 + 2.2 * b,
        }

        if kind == "Petal" then
            -- Different depths: near petals are larger, brighter and a little faster.
            local near = index % 4 == 0
            local w = near and (8 + index % 4) or (4 + index % 5)
            local h = near and (5 + index % 3) or (3 + index % 3)
            particle.Size = UDim2.fromOffset(w, h)
            particle.BackgroundColor3 = near
                and Color3.fromRGB(213, 38, 63) or Color3.fromRGB(164, 24, 47)
            p.alpha = near and 0.27 or 0.49
            p.rate = near and (0.047 + b * 0.028) or (0.028 + b * 0.020)
            p.sway = 0.012 + c * 0.027
            local shape = Instance.new("UICorner")
            shape.CornerRadius = UDim.new(1, 0)
            shape.Parent = particle
            local gradient = Instance.new("UIGradient")
            gradient.Rotation = 36 + 62 * a
            gradient.Color = ColorSequence.new(
                Color3.fromRGB(248, 83, 96),
                Color3.fromRGB(99, 10, 31)
            )
            gradient.Parent = particle
        elseif kind == "Ember" then
            local bright = index % 3 == 0
            particle.Size = UDim2.fromOffset(bright and 3 or 2, bright and 4 or 3)
            particle.BackgroundColor3 = bright
                and Color3.fromRGB(255, 112, 75) or Color3.fromRGB(228, 46, 65)
            p.alpha = bright and 0.22 or 0.44
            p.rate = 0.065 + b * 0.060
            p.sway = 0.004 + c * 0.015
            local shape = Instance.new("UICorner")
            shape.CornerRadius = UDim.new(1, 0)
            shape.Parent = particle
        elseif kind == "Mote" then
            -- A low-opacity halo surrounding a small glowing center.
            particle.Size = UDim2.fromOffset(10 + index % 5 * 3, 10 + index % 5 * 3)
            particle.BackgroundColor3 = Color3.fromRGB(182, 26, 51)
            p.alpha = 0.87
            p.rate = 0.10 + b * 0.25
            p.sway = 0.018 + c * 0.035
            local outerRound = Instance.new("UICorner")
            outerRound.CornerRadius = UDim.new(1, 0)
            outerRound.Parent = particle
            local core = Instance.new("Frame")
            core.Name = "GlowCore"
            core.AnchorPoint = Vector2.new(0.5, 0.5)
            core.Position = UDim2.fromScale(0.5, 0.5)
            core.Size = UDim2.fromScale(0.23, 0.23)
            core.BorderSizePixel = 0
            core.BackgroundTransparency = 0.42
            core.BackgroundColor3 = Color3.fromRGB(255, 90, 100)
            core.Active = false
            core.ZIndex = particle.ZIndex
            core.Parent = particle
            local coreRound = Instance.new("UICorner")
            coreRound.CornerRadius = UDim.new(1, 0)
            coreRound.Parent = core
            p.core = core
        else
            -- Tiny glints pulse in place instead of streaking across the painting.
            particle.Size = UDim2.fromOffset(2 + index % 2, 2 + index % 2)
            particle.BackgroundColor3 = Color3.fromRGB(255, 129, 122)
            p.alpha = 0.59
            p.rate = 0.2 + b * 0.3
            local shape = Instance.new("UICorner")
            shape.CornerRadius = UDim.new(1, 0)
            shape.Parent = particle
        end

        -- Scatter the initial frame; no stacked particles at the origin.
        particle.Position = UDim2.fromScale(p.x, p.y)
        particles[#particles + 1] = p
    end

    -- Create a fixed pool once. No per-frame instance creation, no UI input capture.
    for _, kind in ipairs({ "Petal", "Ember", "Mote", "Glint" }) do
        for index = 1, CRIMSON_PARTICLE_COUNTS[kind] do
            spawn(kind, index)
        end
    end

    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if window.Destroyed or not overlay.Parent then
            if connection then connection:Disconnect(); connection = nil end
            if overlay.Parent then overlay:Destroy() end
            return
        end
        if window.Closed or not main.Visible then
            overlay.Visible = false
            frameAccumulator = 0
            return
        end
        overlay.Visible = true
        -- Hold particles in place during minimize; never jump ahead on reopening.
        frameAccumulator = frameAccumulator + math.min(tonumber(dt) or 1 / 60, 0.075)
        if frameAccumulator < (1 / CRIMSON_AMBIENT_FPS) then return end
        elapsed = elapsed + frameAccumulator
        frameAccumulator = 0

        for _, p in ipairs(particles) do
            local t = elapsed
            local positionX, positionY, alpha
            if p.kind == "Petal" then
                local progress = (t * p.rate + p.phase) % 1
                positionX = p.x + p.drift * progress
                    + p.sway * math.sin(t * 0.85 + p.phase * 9)
                positionY = -0.10 + 1.19 * progress
                -- Fade at the very top and bottom to prevent popping.
                alpha = math.min(0.94, p.alpha +
                    0.32 * math.abs(2 * progress - 1) +
                    0.08 * math.sin(t * p.pulse + p.phase * 11))
                p.item.Rotation = (t * p.rotation + p.phase * 360) % 360
            elseif p.kind == "Ember" then
                local progress = (t * p.rate + p.phase) % 1
                positionX = p.x + p.drift * progress * 0.55
                    + p.sway * math.sin(t * 1.8 + p.phase * 8)
                positionY = 1.08 - 1.18 * progress
                alpha = math.min(0.94, p.alpha +
                    0.45 * math.abs(2 * progress - 1) +
                    0.08 * math.sin(t * p.pulse + p.phase * 7))
                p.item.Rotation = 12 * math.sin(t * 1.3 + p.phase * 8)
            elseif p.kind == "Mote" then
                positionX = p.x + p.sway * math.sin(t * p.rate + p.phase * 6)
                positionY = p.y + (p.sway * 0.65)
                    * math.cos(t * p.rate * 0.8 + p.phase * 8)
                local pulse = 0.5 + 0.5 * math.sin(t * p.pulse + p.phase * 11)
                alpha = 0.94 - 0.10 * pulse
                p.core.BackgroundTransparency = 0.73 - 0.37 * pulse
            else
                positionX = p.x + 0.009 * math.sin(t * p.rate + p.phase * 13)
                positionY = p.y + 0.009 * math.cos(t * p.rate + p.phase * 11)
                local pulse = math.max(0, math.sin(t * p.pulse + p.phase * 16))
                alpha = 0.96 - 0.43 * pulse * pulse
            end
            p.item.Position = UDim2.fromScale(positionX, positionY)
            p.item.BackgroundTransparency = math.clamp(alpha, 0.05, 0.99)
        end
    end)
    return overlay
end

local ActiveWindows = setmetatable({}, { __mode = "k" })
if type(getgenv) == "function" then
    local ok, environment = pcall(getgenv)
    if ok and type(environment) == "table" then
        environment.__VANTAUI_CLEANUP = function()
            for window in pairs(ActiveWindows) do
                if window and not window.Destroyed and type(window.Destroy) == "function" then
                    pcall(window.Destroy, window)
                end
            end
        end
    end
end

local function applyThemeWallpaper(window, themeName)
    if not window or window.Destroyed or not window._UsesVantaThemeWallpaper then
        return
    end

    local transparency = SALTY_SPECIAL_WALLPAPER_TRANSPARENCY
    if type(window.SetBackgroundImageTransparency) == "function" then
        window:SetBackgroundImageTransparency(transparency)
    end
end

local BaseSetTheme = VantaUI.SetTheme
if type(BaseSetTheme) == "function" then
    function VantaUI:SetTheme(themeName)
        local theme = BaseSetTheme(self, themeName)
        if theme then
            for window in pairs(ActiveWindows) do
                applyThemeWallpaper(window, themeName)
            end
        end
        return theme
    end
end

local function renameRuntimeGui()
    if VantaUI.ScreenGui then
        VantaUI.ScreenGui.Name = "VantaUI"
    end
    if VantaUI.NotificationGui then
        VantaUI.NotificationGui.Name = "VantaUI/Notifications"
    end
    if VantaUI.DropdownGui then
        VantaUI.DropdownGui.Name = "VantaUI/Dropdowns"
    end
    if VantaUI.TooltipGui then
        VantaUI.TooltipGui.Name = "VantaUI/Tooltips"
    end
end

local function copyConfig(source)
    local result = {}
    if type(source) == "table" then
        for key, value in pairs(source) do
            result[key] = value
        end
    end
    return result
end

local function applyDefaultBranding(config)
    if config.Branding == false then
        if config.OpenButton == false then
            config.OpenButton = { Enabled = false }
        end
        return
    end

    local branding = copyConfig(config.Branding)
    if branding.UseDefault ~= false then
        branding.Image = BRAND_IMAGE_URL
        branding.WindowIcon = BRAND_IMAGE_URL
        branding.OpenButtonIcon = BRAND_IMAGE_URL
    end

    if branding.Name == nil then
        branding.Name = "VANTA"
    end
    if branding.Folder == nil then
        branding.Folder = "VantaUI"
    end
    if branding.IconSize == nil then
        branding.IconSize = 24
    end
    if branding.IconRadius == nil then
        branding.IconRadius = 7
    end
    if branding.OpenButtonIconRadius == nil then
        branding.OpenButtonIconRadius = 8
    end

    config.Branding = branding

    local windowBrandIcon = branding.WindowIcon or branding.Image
    if branding.UseAsWindowIcon ~= false and windowBrandIcon then
        config.Icon = windowBrandIcon
    end

    if config.OpenButton == false then
        config.OpenButton = { Enabled = false }
        return
    end

    local openButton = copyConfig(config.OpenButton)
    if openButton.Title == nil then
        openButton.Title = "Open VantaUI"
    end
    if openButton.Enabled == nil then
        openButton.Enabled = true
    end
    if openButton.Draggable == nil then
        openButton.Draggable = true
    end
    if openButton.OnlyMobile == nil then
        openButton.OnlyMobile = false
    end
    if branding.UseDefault ~= false and branding.UseAsOpenButtonIcon ~= false then
        openButton.OnlyIcon = true
    elseif openButton.OnlyIcon == nil then
        openButton.OnlyIcon = true
    end
    if openButton.CornerRadius == nil then
        openButton.CornerRadius = UDim.new(0, 11)
    end
    if openButton.StrokeThickness == nil then
        openButton.StrokeThickness = 2
    end
    if openButton.ImageZoom == nil then
        openButton.ImageZoom = 1
    end
    if openButton.Color == nil then
        openButton.Color = ColorSequence.new(Color3.fromHex("#000000"), Color3.fromHex("#000000"))
    end

    local openButtonBrandIcon = branding.OpenButtonIcon or branding.Image
    if branding.UseAsOpenButtonIcon ~= false and openButtonBrandIcon then
        openButton.Icon = openButtonBrandIcon
    end
    config.OpenButton = openButton
end

renameRuntimeGui()
if type(VantaUI.SetTheme) == "function" then
    VantaUI:SetTheme(VantaUI.DefaultTheme)
end

local BaseCreateWindow = VantaUI.CreateWindow
function VantaUI:CreateWindow(config)
    config = config or {}

    if config.Theme == nil then
        config.Theme = VantaUI.DefaultTheme
    end
    if config.Folder == nil then
        config.Folder = "VantaUI"
    end
    -- Retire legacy flat cards and the old search/sidebar presentation.
    config.NewElements = true
    config.HideSearchBar = true
    if config.Size == nil then
        config.Size = UDim2.fromOffset(620, 420)
    end
    -- Keep explicit shadow preferences; suppress only the default dark rim.
    if config.ShadowTransparency == nil then
        config.ShadowTransparency = 1
    end

    applyDefaultBranding(config)

    local usesThemeWallpaper = config.Background == nil and config.AnimatedBackground == nil
    if usesThemeWallpaper then
        -- Draw the original full-resolution painting once. Never animate its pixels:
        -- shifting and upscaling a 224x126 GIF frame caused visible blur/shaking.
        config.Background = SALTY_SPECIAL_WALLPAPER_URL
        config.BackgroundImageTransparency = SALTY_SPECIAL_WALLPAPER_TRANSPARENCY
    end

    config.Topbar = config.Topbar or {}
    if config.Topbar.Height == nil then
        config.Topbar.Height = 44
    end
    -- Consistent compact three-dot topbar across existing script configs.
    config.Topbar.ButtonsType = "Mac"

    local startupTab = config.StartupTab
    if startupTab == nil then
        startupTab = VantaUI.DefaultStartupTab
    end

    local window = BaseCreateWindow(self, config)
    window._UsesVantaThemeWallpaper = usesThemeWallpaper
    ActiveWindows[window] = true
    applyThemeWallpaper(window, config.Theme)
    if usesThemeWallpaper then
        local ambient = attachCrimsonAmbient(window)
        local closeOriginal = window.Close
        if ambient and type(closeOriginal) == "function" then
            -- Hide immediately on Minimize, Toggle, Close and Destroy.
            -- The library's 0.9s shrink tween must never leave detached-looking petals.
            function window:Close(...)
                ambient.Visible = false
                return closeOriginal(self, ...)
            end
        end
    end

    local BaseTab = window.Tab
    local startupTabSelected = false

    if type(BaseTab) == "function" then
        function window:Tab(tabConfig)
            tabConfig = tabConfig or {}
            local tab = BaseTab(self, tabConfig)

            local matchesStartupTab
            if type(startupTab) == "number" then
                matchesStartupTab = tab.Index == startupTab
            else
                matchesStartupTab = tostring(tabConfig.Title or "") == tostring(startupTab)
            end

            if not startupTabSelected and matchesStartupTab then
                startupTabSelected = true
                task.defer(function()
                    if not self.Destroyed and tab and tab.Index and type(self.SelectTab) == "function" then
                        self:SelectTab(tab.Index)
                    end
                end)
            end

            return tab
        end
    end

    renameRuntimeGui()
    return window
end

local BaseNotify = VantaUI.Notify
if type(BaseNotify) == "function" then
    function VantaUI:Notify(config)
        config = config or {}
        if config.Title == nil then
            config.Title = "VantaUI"
        end
        return BaseNotify(self, config)
    end
end

function VantaUI:GetVantaThemes()
    return { "Salty Special", "Vanta Smoked", "Vanta Dark", "Vanta AMOLED", "Vanta Violet" }
end

function VantaUI:GetGuiThemes()
    return self:GetVantaThemes()
end

function VantaUI:GetInfo()
    return VantaUI.GuiInfo
end

return VantaUI
