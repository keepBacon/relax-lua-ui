local cacheBuster = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local VantaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/VantaUI/main/main.lua?v=" .. cacheBuster
))()

local Window = VantaUI:CreateWindow({
    Title = "VantaUI Showcase",
    Icon = VantaUI.Brand.Image,
    Theme = "Salty Special",
    HideSearchBar = false,
    Branding = {
        Name = "VANTA",
        Image = VantaUI.Brand.Image,
        Folder = "VantaUI",
        IconSize = 24,
        IconRadius = 7,
        OpenButtonIconRadius = 8,
        Intro = false,
    },
    OpenButton = {
        Title = "Open VantaUI",
        Icon = VantaUI.Brand.Image,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        OnlyIcon = true,
        CornerRadius = UDim.new(0, 11),
        StrokeThickness = 2,
        ImageZoom = 1,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#000000")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#000000")),
        }),
    },
})

Window:Tag({
    Title = "v" .. VantaUI.Version,
    Icon = "github",
    Color = Color3.fromHex("#151116"),
    Border = true,
})

local Home = Window:Tab({
    Title = "Home",
    Icon = "house",
})

local Themes = Window:Tab({
    Title = "Themes",
    Icon = "palette",
})

local About = Window:Tab({
    Title = "About",
    Icon = "info",
})

Home:Button({
    Title = "VantaUI is alive",
    Desc = "This window is loaded from the VantaUI public loader.",
    Icon = "sparkles",
    Callback = function()
        VantaUI:Notify({
            Content = "VantaUI v" .. VantaUI.Version .. " is running 🎉",
            Icon = "sparkles",
        })
    end,
})

Home:Button({
    Title = "Runtime info",
    Desc = "Shows the current VantaUI runtime version.",
    Icon = "package",
    Callback = function()
        local info = VantaUI:GetInfo()
        VantaUI:Notify({
            Title = "VantaUI Runtime",
            Content = "VantaUI " .. tostring(info.Version) .. " • runtime " .. tostring(VantaUI.RuntimeVersion or info.Version),
            Icon = "package",
        })
    end,
})

local function addThemeButton(themeName, icon)
    Themes:Button({
        Title = themeName,
        Desc = "Switch the whole interface to " .. themeName .. ".",
        Icon = icon,
        Callback = function()
            VantaUI:SetTheme(themeName)
            VantaUI:Notify({
                Content = "Theme changed to " .. themeName,
                Icon = icon,
            })
        end,
    })
end

addThemeButton("Salty Special", "sparkles")
addThemeButton("Vanta Smoked", "cloud-fog")
addThemeButton("Vanta Dark", "moon")
addThemeButton("Vanta AMOLED", "circle-dot")
addThemeButton("Vanta Violet", "wand-sparkles")

About:Button({
    Title = "VantaUI",
    Desc = "Custom Roblox UI library by MrRos3.",
    Icon = "github",
    Callback = function()
        VantaUI:Notify({
            Content = "VantaUI • built by MrRos3 🖤",
            Icon = "heart",
        })
    end,
})
