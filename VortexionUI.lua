--!nonstrict
-- VortexionUI 0.1.0 — standalone Roblox Luau UI library.
-- Runtime: LocalScript / client executor with standard Roblox Instance APIs.
-- No WindUI dependency. Glass is simulated with translucent layered surfaces;
-- Roblox ScreenGui cannot blur other ScreenGui content with CSS-style backdrop-filter.

local VortexionUI = {
    Name = "VortexionUI",
    Version = "0.6.1-md3-r3plus",
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local WindowMethods = {}
WindowMethods.__index = WindowMethods
local GroupMethods = {}
GroupMethods.__index = GroupMethods
local TabMethods = {}
TabMethods.__index = TabMethods

-- MD3 V0.5 HTML reference: geometry and surface tokens for native Luau.
-- Layered translucent surfaces approximate CSS glass; no real backdrop-filter.
local Design = {
    HeaderHeight = 58,
    SidebarWidth = 202,
    NavigationHeaderHeight = 39,
    NavigationFooterHeight = 57,
    ContentToolbarHeight = 41,
    WindowRadius = 24,
    CompactBreakPoint = 600,
    WidgetRadius = 16,
    WidgetInset = 14,
    WidgetSurfaceTransparency = 0.68,
    WidgetOutlineTransparency = 0.88,
    ControlTouchHeight = 42,
    MotionFast = 0.16,
    MotionNormal = 0.24,
    MotionExpand = 0.26,
    MotionPage = 0.19,
    NavigationDepthIndent = 12,
    MobileNavigationWidth = 218,
    MinTapSize = 44,
    PageInsetSmall = 12,
}
local Themes = {
    Dark = {
        Background = Color3.fromRGB(23, 25, 33),
        Surface = Color3.fromRGB(37, 40, 48),
        SurfaceAlt = Color3.fromRGB(45, 48, 57),
        SurfaceHigh = Color3.fromRGB(53, 56, 68),
        Primary = Color3.fromRGB(184, 185, 219),
        OnPrimary = Color3.fromRGB(35, 38, 52),
        Text = Color3.fromRGB(241, 240, 245),
        SubText = Color3.fromRGB(176, 178, 192),
        Outline = Color3.fromRGB(111, 115, 130),
        Success = Color3.fromRGB(139, 205, 166),
        Warning = Color3.fromRGB(242, 197, 121),
        Error = Color3.fromRGB(242, 174, 174),
    },
    Light = {
        Background = Color3.fromRGB(246, 245, 250),
        Surface = Color3.fromRGB(240, 239, 245),
        SurfaceAlt = Color3.fromRGB(232, 232, 240),
        SurfaceHigh = Color3.fromRGB(222, 223, 234),
        Primary = Color3.fromRGB(75, 79, 125),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(28, 29, 36),
        SubText = Color3.fromRGB(93, 95, 108),
        Outline = Color3.fromRGB(190, 190, 202),
        Success = Color3.fromRGB(34, 112, 72),
        Warning = Color3.fromRGB(135, 89, 17),
        Error = Color3.fromRGB(164, 45, 55),
    },
}

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return
    end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not ok then
            warn("[VortexionUI] Callback error: " .. tostring(err))
        end
    end)
end

local function create(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 12),
    }, parent)
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(100, 100, 110),
        Transparency = transparency == nil and 0.35 or transparency,
        Thickness = thickness or 1,
    }, parent)
end

local function textObject(parent, properties)
    local defaults = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(235, 236, 241),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
    }
    for key, value in pairs(properties or {}) do
        defaults[key] = value
    end
    return create("TextLabel", defaults, parent)
end

local function buttonObject(parent, properties)
    local defaults = {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(34, 36, 42),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(235, 236, 241),
        TextWrapped = false,
    }
    for key, value in pairs(properties or {}) do
        defaults[key] = value
    end
    return create("TextButton", defaults, parent)
end

local function viewportSize()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(900, 650)
end

local DEFAULT_ICON_URL = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/assets/vortexion-mark.png"
local DEFAULT_ICON_PATH = "RelaxUI/vortexion-mark.png"
local CachedIconAssets = {}

local function executorFunction(name)
    local environment
    pcall(function()
        if type(getgenv) == "function" then
            environment = getgenv()
        end
    end)
    if type(environment) == "table" and type(environment[name]) == "function" then
        return environment[name]
    end
    if type(_G) == "table" and type(_G[name]) == "function" then
        return _G[name]
    end

    -- Direct global lookup covers executors which expose APIs outside getgenv().
    local ok, value = pcall(function()
        if name == "gethui" then return gethui end
        if name == "getcustomasset" then return getcustomasset end
        if name == "getsynasset" then return getsynasset end
        if name == "writefile" then return writefile end
        if name == "readfile" then return readfile end
        if name == "isfile" then return isfile end
        if name == "makefolder" then return makefolder end
        return nil
    end)
    if ok and type(value) == "function" then return value end
    return nil
end

local function resolveGuiParent(config)
    -- Studio callers can explicitly supply their own parent, but the default
    -- executor path is strictly gethui() — never silently mount to PlayerGui.
    if typeof(config.GuiParent) == "Instance" then
        return config.GuiParent, config.GuiParentMode == "gethui" and "gethui" or "custom"
    end
    local getHiddenGui = executorFunction("gethui")
    assert(type(getHiddenGui) == "function", "[RelaxUI] gethui() unavailable; hidden GUI mount is required")
    local ok, hiddenGui = pcall(getHiddenGui)
    assert(ok and typeof(hiddenGui) == "Instance",
        "[RelaxUI] gethui() returned no Instance: " .. tostring(hiddenGui))
    return hiddenGui, "gethui"
end

local function resolveIconAsset(icon)
    if type(icon) == "string" then
        if icon:match("^rbxassetid://")
            or icon:match("^rbxasset://")
            or icon:match("^rbxgameasset://") then
            return icon
        end
        if icon:match("^%d+$") then
            return "rbxassetid://" .. icon
        end
    end

    local url = (type(icon) == "string" and icon:match("^https?://")) and icon or DEFAULT_ICON_URL
    if CachedIconAssets[url] then return CachedIconAssets[url] end

    local assetLoader = executorFunction("getcustomasset") or executorFunction("getsynasset")
    if not assetLoader then
        return nil
    end

    local cachePath = url == DEFAULT_ICON_URL and DEFAULT_ICON_PATH or "RelaxUI/custom-mark.png"
    local fileExists = executorFunction("isfile")
    if fileExists then
        local existsOk, exists = pcall(fileExists, cachePath)
        if existsOk and exists then
            local assetOk, asset = pcall(assetLoader, cachePath)
            if assetOk and type(asset) == "string" and asset ~= "" then
                CachedIconAssets[url] = asset
                return asset
            end
        end
    end

    -- ImageLabel.Image cannot display an arbitrary HTTP URL. Download the PNG
    -- to the executor's local asset cache, then resolve it with getcustomasset.
    local requestOk, bytes = pcall(function()
        return game:HttpGet(url)
    end)
    if not requestOk or type(bytes) ~= "string" or #bytes < 8 then
        warn("[VortexionUI] Logo download failed; using the code-drawn fallback.")
        return nil
    end

    local createFolder = executorFunction("makefolder")
    if createFolder then pcall(createFolder, "RelaxUI") end
    local writeFile = executorFunction("writefile")
    if not writeFile then
        warn("[VortexionUI] writefile unavailable; using the code-drawn logo fallback.")
        return nil
    end
    local writeOk, writeError = pcall(writeFile, cachePath, bytes)
    if not writeOk then
        warn("[VortexionUI] Could not cache logo: " .. tostring(writeError))
        return nil
    end

    local assetOk, asset = pcall(assetLoader, cachePath)
    if assetOk and type(asset) == "string" and asset ~= "" then
        CachedIconAssets[url] = asset
        return asset
    end
    warn("[VortexionUI] Local logo asset could not be resolved; using the code-drawn fallback.")
    return nil
end

local function makeLogo(parent, size, icon)
    local root = create("Frame", {
        Name = "VortexionMark",
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parent)

    -- Never block window creation on a second network request for a logo.
    local imageAsset = nil
    if type(icon) == "string" then
        if icon:match("^rbxassetid://") or icon:match("^rbxasset://") or icon:match("^rbxgameasset://") then
            imageAsset = icon
        elseif icon:match("^%d+$") then
            imageAsset = "rbxassetid://" .. icon
        end
    end
    if not imageAsset then
        local url = (type(icon) == "string" and icon:match("^https?://")) and icon or DEFAULT_ICON_URL
        imageAsset = CachedIconAssets[url]
    end
    if imageAsset then
        local image = create("ImageLabel", {
            Name = "BrandImage",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = imageAsset,
            ScaleType = Enum.ScaleType.Fit,
        }, root)
        return root, image
    end

    -- Code-drawn fallback keeps the library usable when executor file APIs are absent.
    local bladeColors = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 78, 87)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(245, 246, 249)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 139, 148)),
    })
    for index, rotation in ipairs({-28, 92, 212}) do
        local blade = create("Frame", {
            Name = "Blade" .. tostring(index),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, math.max(4, math.floor(size * 0.19)), 0, math.floor(size * 0.68)),
            Rotation = rotation,
            BackgroundColor3 = Color3.fromRGB(220, 222, 228),
            BorderSizePixel = 0,
        }, root)
        corner(blade, math.max(2, math.floor(size * 0.08)))
        create("UIGradient", {
            Rotation = 35,
            Color = bladeColors,
        }, blade)
    end
    local core = create("Frame", {
        Name = "Core",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, math.floor(size * 0.22), 0, math.floor(size * 0.22)),
        BackgroundColor3 = Color3.fromRGB(20, 22, 26),
        BorderSizePixel = 0,
    }, root)
    corner(core, math.floor(size * 0.11))
    task.spawn(function()
        local ok, asset = pcall(resolveIconAsset, icon)
        if not ok then
            warn("[VortexionUI] Deferred logo error: " .. tostring(asset))
        end
        if ok and asset and root.Parent then
            for _, child in ipairs(root:GetChildren()) do
                child:Destroy()
            end
            create("ImageLabel", {
                Name = "BrandImage",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Image = asset,
                ScaleType = Enum.ScaleType.Fit,
            }, root)
        end
    end)
    return root, nil
end
local function addTextBinding(window, object, property, token)
    window:_BindColor(object, property, token)
end

function VortexionUI.GetThemes()
    return {
        Dark = table.clone(Themes.Dark),
        Light = table.clone(Themes.Light),
    }
end

function VortexionUI.CreateWindow(config)
    config = config or {}
    assert(LocalPlayer, "VortexionUI must be created on the client")
    local guiParent, guiParentMode = resolveGuiParent(config)

    local themeName = type(config.Theme) == "string" and config.Theme or "Dark"
    local initialTheme = Themes[themeName] or Themes.Dark
    if type(config.Theme) == "table" then
        initialTheme = table.clone(Themes.Dark)
        for key, value in pairs(config.Theme) do
            if initialTheme[key] ~= nil and typeof(value) == "Color3" then
                initialTheme[key] = value
            end
        end
    end

    local vp = viewportSize()
    local requestedSize = config.Size or UDim2.fromOffset(820, 550)
    local requestedWidth = requestedSize.X.Offset
    local requestedHeight = requestedSize.Y.Offset
    if requestedSize.X.Scale ~= 0 then requestedWidth = math.floor(vp.X * requestedSize.X.Scale + requestedSize.X.Offset) end
    if requestedSize.Y.Scale ~= 0 then requestedHeight = math.floor(vp.Y * requestedSize.Y.Scale + requestedSize.Y.Offset) end
    local maxWidth = math.max(260, vp.X - 20)
    local maxHeight = math.max(240, vp.Y - 20)
    local width = math.clamp(requestedWidth, math.min(520, maxWidth), maxWidth)
    local height = math.clamp(requestedHeight, math.min(340, maxHeight), maxHeight)
    local minSize = config.MinSize or Vector2.new(520, 340)

    local self = setmetatable({
        Config = config,
        GuiParentMode = guiParentMode,
        GuiParent = guiParent,
        Theme = initialTheme,
        ThemeName = themeName,
        Transparency = math.clamp(config.Transparency == nil and 0.1 or config.Transparency, 0, 0.45),
        AnimationsEnabled = config.Animations ~= false,
        Destroyed = false,
        Visible = true,
        Minimized = false,
        Connections = {},
        ThemeBindings = {},
        ThemeRefreshCallbacks = {},
        _transientConnections = {},
        Flags = {},
        _dialogs = {},
        _mobileDrawerOpen = false,
        _viewportFitQueued = false,
        _viewportConnection = nil,
        Groups = {},
        Tabs = {},
        Controls = {},
        Overlays = {},
        Notifications = {},
        ActiveTab = nil,
        _controlOrder = 0,
        MinSize = minSize,
        _motionTweens = {},
    }, WindowMethods)

    local guiOptions = {
        Name = "VortexionUI_" .. tostring(config.Name or "Window"),
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = tonumber(config.DisplayOrder) or 1000,
        Enabled = true,
    }
    local mounted, gui = pcall(create, "ScreenGui", guiOptions, guiParent)
    assert(mounted and typeof(gui) == "Instance",
        "[RelaxUI] Could not mount ScreenGui to gethui(): " .. tostring(gui))
    assert(gui.Parent == guiParent, "[RelaxUI] gethui() parenting did not persist")
    self.Gui = gui

    local main = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = initialTheme.Background,
        BackgroundTransparency = self.Transparency,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    }, gui)
    self.Main = main
    corner(main, Design.WindowRadius)
    self.MainStroke = stroke(main, initialTheme.Outline, 0.67, 1)
    self.SizeConstraint = create("UISizeConstraint", {
        MinSize = Vector2.new(math.min(minSize.X, maxWidth), math.min(minSize.Y, maxHeight)),
        MaxSize = Vector2.new(maxWidth, maxHeight),
    }, main)
    self:_BindColor(main, "BackgroundColor3", "Background")
    self:_BindColor(self.MainStroke, "Color", "Outline")

    local titlebar = create("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1, 0, 0, Design.HeaderHeight),
        BackgroundColor3 = initialTheme.Surface,
        BackgroundTransparency = 0.43,
        BorderSizePixel = 0,
        Active = true,
    }, main)
    self.Titlebar = titlebar
    self:_BindColor(titlebar, "BackgroundColor3", "Surface")

    local logo, logoImage = makeLogo(titlebar, 32, config.Icon)
    logo.Position = UDim2.new(0, 18, 0.5, -16)
    self.Logo = logo
    self.LogoImage = logoImage

    local title = textObject(titlebar, {
        Name = "Title",
        Position = UDim2.new(0, 61, 0, 10),
        Size = UDim2.new(1, -171, 0, 23),
        Text = tostring(config.Title or config.Name or "VortexionUI"),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
    })
    self.Title = title
    addTextBinding(self, title, "TextColor3", "Text")

    local subtitle = textObject(titlebar, {
        Name = "Subtitle",
        Position = UDim2.new(0, 61, 0, 33),
        Size = UDim2.new(1, -171, 0, 15),
        Text = tostring(config.Subtitle or "Luau UI Library"),
        TextSize = 10,
    })
    self.Subtitle = subtitle
    addTextBinding(self, subtitle, "TextColor3", "SubText")

    local minimizeButton = buttonObject(titlebar, {
        Name = "Minimize",
        Position = UDim2.new(1, -78, 0.5, -16),
        Size = UDim2.fromOffset(32, 32),
        Text = "−",
        TextSize = 17,
        BackgroundColor3 = initialTheme.SurfaceAlt,
    }, titlebar)
    corner(minimizeButton, 16)
    self:_BindColor(minimizeButton, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(minimizeButton, "TextColor3", "Text")
    local closeButton = buttonObject(titlebar, {
        Name = "Close",
        Position = UDim2.new(1, -40, 0.5, -16),
        Size = UDim2.fromOffset(32, 32),
        Text = "×",
        TextSize = 18,
        BackgroundColor3 = initialTheme.SurfaceAlt,
    }, titlebar)
    corner(closeButton, 16)
    self:_BindColor(closeButton, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(closeButton, "TextColor3", "Text")
    self:_Connect(closeButton.Activated, function() self:Destroy() end)

    local body = create("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 0, 0, Design.HeaderHeight),
        Size = UDim2.new(1, 0, 1, -Design.HeaderHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, main)
    self.Body = body

    -- The HTML V0.5 reference uses a dedicated, quieter tonal sidebar with
    -- a small context heading and anchored runtime status at the bottom.
    local navPanel = create("Frame", {
        Name = "NavigationPanel",
        Size = UDim2.new(0, Design.SidebarWidth, 1, 0),
        BackgroundColor3 = initialTheme.Surface,
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, body)
    self.NavigationPanel = navPanel
    self:_BindColor(navPanel, "BackgroundColor3", "Surface")
    local navDivider = create("Frame", {
        Name = "NavigationDivider",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = initialTheme.Outline,
        BackgroundTransparency = 0.79,
        BorderSizePixel = 0,
    }, navPanel)
    self:_BindColor(navDivider, "BackgroundColor3", "Outline")
    local navHeader = textObject(navPanel, {
        Name = "NavigationHeader",
        Position = UDim2.fromOffset(15, 3),
        Size = UDim2.new(1, -27, 0, 30),
        Text = "导航  ·  分组",
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
    })
    self:_BindColor(navHeader, "TextColor3", "SubText")

    local nav = create("ScrollingFrame", {
        Name = "Navigation",
        Position = UDim2.fromOffset(0, Design.NavigationHeaderHeight),
        Size = UDim2.new(1, 0, 1, -Design.NavigationHeaderHeight - Design.NavigationFooterHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 0.65,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, navPanel)
    self.Navigation = nav
    create("UIPadding", {
        PaddingTop = UDim.new(0, 1),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, nav)
    self.NavigationLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, nav)

    local footerDivider = create("Frame", {
        Name = "FooterDivider",
        Position = UDim2.new(0, 13, 1, -Design.NavigationFooterHeight),
        Size = UDim2.new(1, -26, 0, 1),
        BackgroundColor3 = initialTheme.Outline,
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
    }, navPanel)
    self:_BindColor(footerDivider, "BackgroundColor3", "Outline")
    local footer = textObject(navPanel, {
        Name = "RuntimeStatus",
        Position = UDim2.new(0, 17, 1, -Design.NavigationFooterHeight + 8),
        Size = UDim2.new(1, -26, 0, 18),
        Text = "●  正在运行",
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
    })
    self:_BindColor(footer, "TextColor3", "SubText")
    local footerName = textObject(navPanel, {
        Position = UDim2.new(0, 17, 1, -Design.NavigationFooterHeight + 27),
        Size = UDim2.new(1, -26, 0, 17),
        Text = "Relax UI  ·  MD3",
        TextSize = 10,
    })
    self:_BindColor(footerName, "TextColor3", "Text")

    local contentHost = create("Frame", {
        Name = "ContentHost",
        Position = UDim2.fromOffset(Design.SidebarWidth, 0),
        Size = UDim2.new(1, -Design.SidebarWidth, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, body)
    self.ContentHost = contentHost

    local contentToolbar = create("Frame", {
        Name = "ContentToolbar",
        Size = UDim2.new(1, 0, 0, Design.ContentToolbarHeight),
        BackgroundColor3 = initialTheme.Surface,
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
    }, contentHost)
    self:_BindColor(contentToolbar, "BackgroundColor3", "Surface")
    local crumb = textObject(contentToolbar, {
        Name = "Breadcrumb",
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -115, 1, 0),
        Text = "Vortexion  /  Overview",
        TextSize = 11,
    })
    self.Breadcrumb = crumb
    self:_BindColor(crumb, "TextColor3", "SubText")
    local contextLabel = textObject(contentToolbar, {
        Name = "Context",
        Position = UDim2.new(1, -104, 0, 0),
        Size = UDim2.fromOffset(90, Design.ContentToolbarHeight),
        Text = "MD3  ·  UI",
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    self:_BindColor(contextLabel, "TextColor3", "SubText")
    local toolbarDivider = create("Frame", {
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = initialTheme.Outline,
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
    }, contentToolbar)
    self:_BindColor(toolbarDivider, "BackgroundColor3", "Outline")
    local pagesHost = create("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(0, Design.ContentToolbarHeight),
        Size = UDim2.new(1, 0, 1, -Design.ContentToolbarHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, contentHost)
    self.PagesHost = pagesHost
    -- Modal touch catcher behind the compact navigation drawer.
    local drawerScrim = buttonObject(body, {
        Name = "NavigationScrim",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.48,
        Text = "",
        Active = true,
        Visible = false,
        ZIndex = 12,
    })
    self.DrawerScrim = drawerScrim
    self:_Connect(drawerScrim.Activated, function()
        self._mobileDrawerOpen = false
        self:_UpdateResponsive()
    end)

    local resizeGrip = buttonObject(main, {
        Name = "ResizeGrip",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -3, 1, -3),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Text = "◢",
        TextSize = 14,
        TextColor3 = initialTheme.SubText,
        ZIndex = 10,
    }, main)
    self:_BindColor(resizeGrip, "TextColor3", "SubText")
    self.ResizeGrip = resizeGrip
    local headerDivider = create("Frame", {
        Name = "TitlebarDivider",
        Position = UDim2.new(0, 0, 0, Design.HeaderHeight - 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = initialTheme.Outline,
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
    }, titlebar)
    self:_BindColor(headerDivider, "BackgroundColor3", "Outline")
    local navToggle = buttonObject(titlebar, {
        Name = "NavigationToggle",
        Position = UDim2.new(0, 49, 0.5, -14),
        Size = UDim2.fromOffset(28, 28),
        Text = "≡",
        TextSize = 19,
        BackgroundTransparency = 1,
        TextColor3 = initialTheme.Text,
        Visible = false,
        ZIndex = 9,
    })
    self.NavToggle = navToggle
    self:_BindColor(navToggle, "TextColor3", "Text")
    self:_Connect(navToggle.Activated, function()
        self._mobileDrawerOpen = not self._mobileDrawerOpen
        self:_UpdateResponsive()
    end)
    contentHost.ZIndex = 1
    self:_UpdateResponsive()

    self:_Connect(titlebar.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local x = input.Position.X - titlebar.AbsolutePosition.X
        if x >= titlebar.AbsoluteSize.X - 102 then return end
        if self.NavToggle.Visible and x >= 42 and x <= 92 then return end
        self:_StartMove(input, false, main)
    end)
    self:_Connect(resizeGrip.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_StartMove(input, true, main)
        end
    end)
    self:_Connect(minimizeButton.Activated, function()
        self:Minimize()
    end)

    self:_Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
        self:_AttachViewportCamera()
        self:_QueueViewportFit()
    end)
    self:_AttachViewportCamera()
    self:_Connect(main:GetPropertyChangedSignal("AbsoluteSize"), function()
        if not self._resizeActive then self:_UpdateResponsive() end
    end)

    local scale = create("UIScale", {Scale = self.AnimationsEnabled and 0.96 or 1}, main)
    self.Scale = scale
    if self.AnimationsEnabled then
        self:_Animate(scale, {Scale = 1}, Design.MotionNormal)
    end

    return self
end

function WindowMethods:_Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function WindowMethods:_BindColor(object, property, token)
    object[property] = self.Theme[token]
    table.insert(self.ThemeBindings, {Object = object, Property = property, Token = token})
end

function WindowMethods:_UpdateResponsive()
    if self.Destroyed or not self.Main or not self.NavToggle then return end
    -- UIScale during entrance should not briefly flip mobile layout.
    local width = self.Main.Size.X.Offset
    if width <= 0 then width = self.Main.AbsoluteSize.X end
    local compact = width < Design.CompactBreakPoint or viewportSize().X < 650
    self.NavToggle.Visible = compact
    self.Title.Position = compact and UDim2.fromOffset(91, 10) or UDim2.fromOffset(61, 10)
    self.Title.Size = UDim2.new(1, compact and -193 or -171, 0, 23)
    self.Subtitle.Position = compact and UDim2.fromOffset(91, 33) or UDim2.fromOffset(61, 33)
    self.Subtitle.Size = UDim2.new(1, compact and -193 or -171, 0, 15)
    if compact then
        self.NavigationPanel.Size = UDim2.new(0, math.min(Design.MobileNavigationWidth, math.max(160, width - 44)), 1, 0)
        self.NavigationPanel.Visible = self._mobileDrawerOpen
        self.DrawerScrim.Visible = self._mobileDrawerOpen
        self.ContentHost.Position = UDim2.fromOffset(0, 0)
        self.ContentHost.Size = UDim2.fromScale(1, 1)
    else
        self._mobileDrawerOpen = false
        self.DrawerScrim.Visible = false
        self.NavigationPanel.Visible = true
        self.NavigationPanel.Size = UDim2.new(0, Design.SidebarWidth, 1, 0)
        self.ContentHost.Position = UDim2.fromOffset(Design.SidebarWidth, 0)
        self.ContentHost.Size = UDim2.new(1, -Design.SidebarWidth, 1, 0)
    end
    local changedMode = self._narrowLayout ~= compact
    self._narrowLayout = compact
    if changedMode then
        for _, tab in ipairs(self.Tabs) do
            if tab.SetCompact then tab:SetCompact(compact) end
        end
    end
end

function WindowMethods:_AttachViewportCamera()
    if self._viewportConnection then self._viewportConnection:Disconnect(); self._viewportConnection = nil end
    local camera = workspace.CurrentCamera
    if camera then
        self._viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            self:_QueueViewportFit()
        end)
    end
end

function WindowMethods:_QueueViewportFit()
    if self.Destroyed or self._viewportFitQueued then return end
    self._viewportFitQueued = true
    task.defer(function()
        self._viewportFitQueued = false
        if self.Destroyed then return end
        if self._activeDragCleanup then self._activeDragCleanup() end
        self:_FitToViewport()
        self:_UpdateResponsive()
    end)
end

function WindowMethods:_FitToViewport()
    if self.Destroyed or not self.Main then return end
    local vp = viewportSize()
    local maxWidth = math.max(260, vp.X - 20)
    local maxHeight = math.max(240, vp.Y - 20)
    local minW = math.min(self.MinSize.X, maxWidth)
    local minH = math.min(self.MinSize.Y, maxHeight)
    local before = self.Main.AbsolutePosition
    local size = self.Main.Size
    local width = math.clamp(size.X.Offset, minW, maxWidth)
    local height = math.clamp(size.Y.Offset, minH, maxHeight)
    self.SizeConstraint.MaxSize = Vector2.new(maxWidth, maxHeight)
    self.SizeConstraint.MinSize = Vector2.new(minW, minH)
    self.Main.Size = UDim2.fromOffset(width, height)
    local x = math.clamp(before.X, 8, math.max(8, vp.X - width - 8))
    local y = math.clamp(before.Y, 8, math.max(8, vp.Y - height - 8))
    self.Main.Position = UDim2.fromOffset(x + width / 2, y + height / 2)
    if self.Launcher then
        local iconSize = self.Launcher.AbsoluteSize
        local center = self.Launcher.AbsolutePosition + iconSize * 0.5
        self.Launcher.Position = UDim2.fromOffset(
            math.clamp(center.X, 8 + iconSize.X * 0.5, math.max(8 + iconSize.X * 0.5, vp.X - 8 - iconSize.X * 0.5)),
            math.clamp(center.Y, 8 + iconSize.Y * 0.5, math.max(8 + iconSize.Y * 0.5, vp.Y - 8 - iconSize.Y * 0.5))
        )
    end
end

-- Single-pointer drag controller shared by window and minimized icon.
-- InputChanged is filtered by the initiating touch, and transient listeners
-- are unregistered on pointer release, replacing the original accumulating table.
function WindowMethods:_StartMove(input, resizing, target)
    if self.Destroyed or not target then return end
    if self._activeDragCleanup then self._activeDragCleanup() end
    local startPointer = input.Position
    local startAbsolute = target.AbsolutePosition
    local startSize = target.AbsoluteSize
    local inputType = input.UserInputType
    local isTouch = inputType == Enum.UserInputType.Touch
    local moved = false
    local changeConnection, endedConnection

    local function removeTracked(connection)
        if not connection then return end
        connection:Disconnect()
        for index = #self._transientConnections, 1, -1 do
            if self._transientConnections[index] == connection then
                table.remove(self._transientConnections, index)
                break
            end
        end
    end

    local function cleanup()
        removeTracked(changeConnection)
        removeTracked(endedConnection)
        changeConnection, endedConnection = nil, nil
        if self._activeDragCleanup == cleanup then
            self._activeDragCleanup = nil
        end
    end
    self._activeDragCleanup = cleanup
    changeConnection = UserInputService.InputChanged:Connect(function(changed)
        if self.Destroyed then cleanup(); return end
        local valid = (isTouch and changed == input)
            or (inputType == Enum.UserInputType.MouseButton1
                and changed.UserInputType == Enum.UserInputType.MouseMovement)
        if not valid then return end
        local delta = changed.Position - startPointer
        if delta.Magnitude > (isTouch and 7 or 3) then moved = true end
        if not moved then return end
        if target == self.Launcher then self._launcherMoved = true end

        if resizing then
            local viewport = viewportSize()
            local maxW = math.max(260, viewport.X - 20)
            local maxH = math.max(240, viewport.Y - 20)
            local w = math.clamp(math.floor(startSize.X + delta.X + 0.5),
                math.min(self.MinSize.X, maxW), maxW)
            local h = math.clamp(math.floor(startSize.Y + delta.Y + 0.5),
                math.min(self.MinSize.Y, maxH), maxH)
            -- Keep upper-left corner fixed when dragging the lower-right grip.
            target.Size = UDim2.fromOffset(w, h)
            target.Position = UDim2.fromOffset(
                startAbsolute.X + w * target.AnchorPoint.X,
                startAbsolute.Y + h * target.AnchorPoint.Y
            )
            self:_UpdateResponsive()
        else
            local viewport = viewportSize()
            local size = target.AbsoluteSize
            local x = math.clamp(startAbsolute.X + delta.X, 6,
                math.max(6, viewport.X - size.X - 6))
            local y = math.clamp(startAbsolute.Y + delta.Y, 6,
                math.max(6, viewport.Y - size.Y - 6))
            target.Position = UDim2.fromOffset(
                x + size.X * target.AnchorPoint.X,
                y + size.Y * target.AnchorPoint.Y
            )
        end
    end)
    endedConnection = UserInputService.InputEnded:Connect(function(ended)
        if (isTouch and ended == input)
            or (inputType == Enum.UserInputType.MouseButton1
                and ended.UserInputType == Enum.UserInputType.MouseButton1) then
            cleanup()
        end
    end)
    table.insert(self._transientConnections, changeConnection)
    table.insert(self._transientConnections, endedConnection)
end

function WindowMethods:SetSize(width, height)
    if self.Destroyed then return end
    local vp = viewportSize()
    local maxWidth = math.max(260, vp.X - 20)
    local maxHeight = math.max(240, vp.Y - 20)
    width = math.clamp(math.floor(width), math.min(self.MinSize.X, maxWidth), maxWidth)
    height = math.clamp(math.floor(height), math.min(self.MinSize.Y, maxHeight), maxHeight)
    self.Main.Size = UDim2.fromOffset(width, height)
    self:_UpdateResponsive()
end

function WindowMethods:SetTitle(value)
    if self.Title then self.Title.Text = tostring(value or "") end
end

function WindowMethods:SetSubtitle(value)
    if self.Subtitle then self.Subtitle.Text = tostring(value or "") end
end

function WindowMethods:SetTransparency(value)
    self.Transparency = math.clamp(tonumber(value) or 0.1, 0, 0.45)
    if self.Main then self.Main.BackgroundTransparency = self.Transparency end
end

function WindowMethods:SetAnimationsEnabled(enabled)
    local nextValue = enabled == true
    if self.AnimationsEnabled == nextValue then return end
    self.AnimationsEnabled = nextValue
    if not nextValue then
        local running = {}
        for object in pairs(self._motionTweens) do
            table.insert(running, object)
        end
        for _, object in ipairs(running) do
            self:_CancelMotion(object, true)
        end
    end
end

function WindowMethods:SetTheme(theme)
    if type(theme) == "string" then
        assert(Themes[theme], "Unknown VortexionUI theme: " .. theme)
        self.ThemeName = theme
        self.Theme = table.clone(Themes[theme])
    elseif type(theme) == "table" then
        local nextTheme = table.clone(self.Theme)
        for key, value in pairs(theme) do
            if nextTheme[key] ~= nil and typeof(value) == "Color3" then
                nextTheme[key] = value
            end
        end
        self.Theme = nextTheme
        self.ThemeName = "Custom"
    else
        error("SetTheme expects a theme name or Color3 token table")
    end
    for _, binding in ipairs(self.ThemeBindings) do
        if binding.Object and binding.Object.Parent then
            binding.Object[binding.Property] = self.Theme[binding.Token]
        end
    end
    self:_RefreshNavigation()
    for _, refresh in ipairs(self.ThemeRefreshCallbacks) do
        pcall(refresh)
    end
end

-- One tracked tween per object; cancelling disconnects the Completed connection
-- and destroys the old tween, preventing retained instances after rapid input.
function WindowMethods:_CancelMotion(object, finish)
    local record = self._motionTweens[object]
    if not record then return end
    self._motionTweens[object] = nil
    if record.Connection then record.Connection:Disconnect() end
    record.Tween:Cancel()
    record.Tween:Destroy()
    if finish and object.Parent then
        for key, value in pairs(record.Target) do
            object[key] = value
        end
    end
end

function WindowMethods:_Animate(object, properties, duration, style, onComplete)
    if not object or self.Destroyed then return nil end
    self:_CancelMotion(object, false)
    if not self.AnimationsEnabled or (duration ~= nil and duration <= 0) then
        for property, value in pairs(properties) do object[property] = value end
        if onComplete then onComplete() end
        return nil
    end
    local tween = TweenService:Create(object, TweenInfo.new(duration or Design.MotionNormal,
        style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    local record = {Tween = tween, Target = properties}
    record.Connection = tween.Completed:Connect(function(playbackState)
        if self._motionTweens[object] ~= record then return end
        self._motionTweens[object] = nil
        record.Connection:Disconnect()
        tween:Destroy()
        if playbackState == Enum.PlaybackState.Completed and onComplete then
            onComplete()
        end
    end)
    self._motionTweens[object] = record
    tween:Play()
    return tween
end

function WindowMethods:_OpenAncestors(group)
    local current = group
    while current do
        if current.Collapsed then current:SetCollapsed(false) end
        current = current.ParentGroup
    end
end

function WindowMethods:_NavigationTrail(group)
    local segments = {}
    local current = group
    while current do
        table.insert(segments, 1, tostring(current.Title))
        current = current.ParentGroup
    end
    return table.concat(segments, " / ")
end

function WindowMethods:_RefreshNavigation()
    for _, group in ipairs(self.Groups) do
        group.Header.BackgroundColor3 = self.Theme.Surface
        group.Header.BackgroundTransparency = 1
        group.Header.TextColor3 = self.Theme.SubText
        group.Chevron.TextColor3 = self.Theme.SubText
    end
    for _, tab in ipairs(self.Tabs) do
        local selected = self.ActiveTab == tab
        tab.Button.BackgroundColor3 = selected and self.Theme.Primary or self.Theme.SurfaceAlt
        tab.Button.BackgroundTransparency = selected and 0.79 or 1
        tab.Button.TextColor3 = selected and self.Theme.Primary or self.Theme.SubText
    end
end

function WindowMethods:CreateTabGroup(title, options)
    options = options or {}
    local groupFrame = create("Frame", {
        Name = "Group_" .. tostring(title),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = #self.Groups + 1,
    }, self.Navigation)
    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, groupFrame)

    local header = buttonObject(groupFrame, {
        Name = "GroupHeader",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        Text = tostring(title or "Group"),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 12,
        TextColor3 = self.Theme.SubText,
        LayoutOrder = 1,
    })
    corner(header, 10)
    local headerPadding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 28),
    }, header)
    local chevron = textObject(header, {
        Name = "Chevron",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        Text = options.Collapsed and "›" or "⌄",
        TextSize = 16,
        TextColor3 = self.Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    local collapseViewport = create("Frame", {
        Name = "CollapseViewport",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 2,
    }, groupFrame)
    local tabsContainer = create("Frame", {
        Name = "Tabs",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, collapseViewport)
    local tabsLayout = create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabsContainer)

    local group = setmetatable({
        Window = self,
        Title = tostring(title or "Group"),
        Frame = groupFrame,
        Header = header,
        Chevron = chevron,
        TabsContainer = tabsContainer,
        CollapseViewport = collapseViewport,
        TabsLayout = tabsLayout,
        _collapseToken = 0,
        Tabs = {},
        Collapsed = options.Collapsed == true,
        ParentGroup = options.Parent,
        Depth = options.Parent and (options.Parent.Depth + 1) or 0,
    }, GroupMethods)
    table.insert(self.Groups, group)
    self:_BindColor(header, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(header, "TextColor3", "SubText")
    self:_BindColor(chevron, "TextColor3", "SubText")
    self:_Connect(header.Activated, function()
        group:SetCollapsed(not group.Collapsed)
    end)
    self:_Connect(tabsContainer:GetPropertyChangedSignal("AbsoluteSize"), function()
        group:_SyncHeight()
    end)
    task.defer(function() if not self.Destroyed then group:_SyncHeight() end end)
    self:_RefreshNavigation()
    return group
end

function GroupMethods:_SyncHeight()
    if self.Window.Destroyed or not self.CollapseViewport.Parent then return end
    local measured = self.TabsLayout.AbsoluteContentSize.Y
    if measured <= 0 then
        measured = self.TabsContainer.AbsoluteSize.Y
    end
    self._measuredHeight = math.max(0, measured)
    if self.Collapsed then
        if not self.Window._motionTweens[self.CollapseViewport] then
            self.CollapseViewport.Size = UDim2.new(1, 0, 0, 0)
        end
    elseif not self.Window._motionTweens[self.CollapseViewport] then
        self.CollapseViewport.Size = UDim2.new(1, 0, 0, self._measuredHeight)
    end
end

function GroupMethods:SetCollapsed(collapsed)
    if self.Window.Destroyed then return end
    collapsed = collapsed == true
    if self.Collapsed == collapsed then return end
    self.Collapsed = collapsed
    self._collapseToken = self._collapseToken + 1
    local targetHeight = collapsed and 0 or math.max(
        self.TabsLayout.AbsoluteContentSize.Y, self.TabsContainer.AbsoluteSize.Y
    )
    self._measuredHeight = targetHeight
    self.Chevron.Text = collapsed and "›" or "⌄"
    self.Window:_Animate(self.CollapseViewport, {
        Size = UDim2.new(1, 0, 0, targetHeight)
    }, Design.MotionExpand)
    self.Window:_Animate(self.Header, {
        BackgroundTransparency = collapsed and 1 or 0.82
    }, Design.MotionFast)
end

function GroupMethods:CreateTab(title, options)
    return self.Window:_CreateTab(self, title, options)
end

function WindowMethods:_CreateTab(group, title, options)
    options = options or {}
    local order = #group.Tabs + 1
    local button = buttonObject(group.TabsContainer, {
        Name = "Tab_" .. tostring(title),
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = self.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        Text = (options.IconText and tostring(options.IconText) .. "   " or "   ") .. tostring(title or "Tab"),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 12,
        TextColor3 = self.Theme.SubText,
        LayoutOrder = order,
    })
    corner(button, 10)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 6),
    }, button)

    local page = create("ScrollingFrame", {
        Name = "Page_" .. tostring(title),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageTransparency = 0.45,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, self.PagesHost)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 18),
        PaddingBottom = UDim.new(0, 22),
        PaddingLeft = UDim.new(0, 19),
        PaddingRight = UDim.new(0, 19),
    }, page)
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    local tab = setmetatable({
        Window = self,
        Group = group,
        Title = tostring(title or "Tab"),
        Button = button,
        Page = page,
        Controls = {},
        Order = 0,
    }, TabMethods)
    table.insert(group.Tabs, tab)
    table.insert(self.Tabs, tab)
    self:_BindColor(button, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(button, "TextColor3", "SubText")
    self:_Connect(button.Activated, function() tab:Select() end)
    task.defer(function() if not self.Destroyed then group:_SyncHeight() end end)
    if options.Selected == true or not self.ActiveTab then
        tab:Select()
    end
    return tab
end

function WindowMethods:CreateTab(title, options)
    if not self._defaultGroup then
        self._defaultGroup = self:CreateTabGroup(self.Config.DefaultGroupTitle or "General")
    end
    return self._defaultGroup:CreateTab(title, options)
end

function TabMethods:Select()
    if self.Window.Destroyed then return end
    local previous = self.Window.ActiveTab
    if previous == self then return end
    if previous and previous.Page then previous.Page.Visible = false end
    self.Page.Visible = true
    self.Page.CanvasPosition = Vector2.zero
    if self.Window.AnimationsEnabled then
        self.Page.ScrollBarImageTransparency = 1
        self.Window:_Animate(self.Page, {ScrollBarImageTransparency = 0.45}, Design.MotionNormal)
    end
    self.Window.ActiveTab = self
    if self.Window.Breadcrumb then
        self.Window.Breadcrumb.Text = self.Window:_NavigationTrail(self.Group) .. "  /  " .. tostring(self.Title)
    end
    self.Window:_OpenAncestors(self.Group)
    self.Window._mobileDrawerOpen = false
    self.Window:_UpdateResponsive()
    self.Window:_RefreshNavigation()
end

function TabMethods:_NextOrder()
    self.Order = self.Order + 1
    return self.Order
end

function TabMethods:_Row(height, automatic, plain)
    local row = create("Frame", {
        Name = "ControlRow",
        Size = automatic and UDim2.new(1, -4, 0, 0) or UDim2.new(1, -4, 0, height),
        AutomaticSize = automatic and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BackgroundTransparency = plain and 1 or Design.WidgetSurfaceTransparency,
        BorderSizePixel = 0,
        LayoutOrder = self:_NextOrder(),
    }, self.Page)
    if not plain then
        corner(row, Design.WidgetRadius)
        local edge = stroke(row, self.Window.Theme.Outline, Design.WidgetOutlineTransparency, 1)
        self.Window:_BindColor(row, "BackgroundColor3", "SurfaceAlt")
        self.Window:_BindColor(edge, "Color", "Outline")
    end
    table.insert(self.Controls, row)
    table.insert(self.Window.Controls, row)
    return row
end

function TabMethods:_Label(parent, properties, token)
    local label = textObject(parent, properties)
    if token then self.Window:_BindColor(label, "TextColor3", token) end
    return label
end

function TabMethods:CreateSection(title)
    local row = self:_Row(30, false, true)
    local label = self:_Label(row, {
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0, 24),
        Text = tostring(title or "Section"),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
    }, "Text")
    local line = create("Frame", {
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Window.Theme.Outline,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
    }, row)
    self.Window:_BindColor(line, "BackgroundColor3", "Outline")
    return {SetTitle = function(_, value) label.Text = tostring(value or "") end}
end

function TabMethods:CreateDivider()
    local row = self:_Row(12, false, true)
    local line = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Window.Theme.Outline,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
    }, row)
    self.Window:_BindColor(line, "BackgroundColor3", "Outline")
    return line
end

function TabMethods:CreateLabel(text)
    local row = self:_Row(36, false, true)
    local label = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        Text = tostring(text or ""),
        TextSize = 12,
    }, "SubText")
    return {
        SetText = function(_, value) label.Text = tostring(value or "") end,
    }
end

function TabMethods:CreateParagraph(config)
    config = config or {}
    local row = self:_Row(0, true)
    row.BackgroundColor3 = self.Window.Theme.SurfaceAlt
    row.BackgroundTransparency = 0.35
    corner(row, 12)
    self.Window:_BindColor(row, "BackgroundColor3", "SurfaceAlt")
    local padding = create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, row)
    create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, row)
    local title = self:_Label(row, {
        Size = UDim2.new(1, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = tostring(config.Title or "Information"),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        LayoutOrder = 1,
    }, "Text")
    local content = self:_Label(row, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = tostring(config.Content or config.Description or ""),
        TextSize = 12,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2,
    }, "SubText")
    return {
        SetTitle = function(_, value) title.Text = tostring(value or "") end,
        SetContent = function(_, value) content.Text = tostring(value or "") end,
    }
end

function TabMethods:CreateButton(config)
    config = config or {}
    local row = self:_Row(74, false)
    local title = self:_Label(row, {
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.new(1, -154, 0, 22),
        Text = tostring(config.Title or config.Name or "Button"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local description = self:_Label(row, {
        Position = UDim2.fromOffset(14, 36),
        Size = UDim2.new(1, -154, 0, 20),
        Text = tostring(config.Description or ""),
        TextSize = 10,
    }, "SubText")
    local button = buttonObject(row, {
        Position = UDim2.new(1, -130, 0.5, -19),
        Size = UDim2.fromOffset(116, 38),
        Text = tostring(config.ButtonText or "Run"),
        TextSize = 12,
        BackgroundColor3 = self.Window.Theme.Primary,
        TextColor3 = self.Window.Theme.OnPrimary,
    })
    corner(button, 19)
    self.Window:_BindColor(button, "BackgroundColor3", "Primary")
    self.Window:_BindColor(button, "TextColor3", "OnPrimary")
    self.Window:_Connect(button.Activated, function()
        safeCall(config.Callback)
    end)
    return {
        SetTitle = function(_, value) title.Text = tostring(value or "") end,
        SetDescription = function(_, value) description.Text = tostring(value or "") end,
        SetButtonText = function(_, value) button.Text = tostring(value or "") end,
        Click = function() safeCall(config.Callback) end,
    }
end

function TabMethods:CreateToggle(config)
    config = config or {}
    local row = self:_Row(74, false)
    local title = self:_Label(row, {
        Position = UDim2.fromOffset(14, 13),
        Size = UDim2.new(1, -92, 0, 21),
        Text = tostring(config.Title or config.Name or "Toggle"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local description = self:_Label(row, {
        Position = UDim2.fromOffset(14, 37),
        Size = UDim2.new(1, -92, 0, 20),
        Text = tostring(config.Description or ""),
        TextSize = 10,
    }, "SubText")
    local switch = buttonObject(row, {
        Name = "Switch",
        Position = UDim2.new(1, -66, 0.5, -15),
        Size = UDim2.fromOffset(52, 30),
        BackgroundColor3 = self.Window.Theme.SurfaceHigh,
        Text = "",
    })
    corner(switch, 15)
    local thumb = create("Frame", {
        Name = "Thumb",
        Position = UDim2.new(0, 5, 0.5, -10),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = self.Window.Theme.SubText,
        BorderSizePixel = 0,
    }, switch)
    corner(thumb, 10)
    self.Window:_BindColor(switch, "BackgroundColor3", "SurfaceHigh")
    self.Window:_BindColor(thumb, "BackgroundColor3", "SubText")
    local value = config.Default == true
    local control = {Value = value}
    local function render(animate)
        local targetPos = value and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 5, 0.5, -10)
        local targetColor = value and self.Window.Theme.Primary or self.Window.Theme.SubText
        local trackColor = value and self.Window.Theme.Primary or self.Window.Theme.SurfaceHigh
        if animate and self.Window.AnimationsEnabled then
            self.Window:_Animate(thumb, {Position = targetPos, BackgroundColor3 = targetColor}, 0.13, Enum.EasingStyle.Quad)
            self.Window:_Animate(switch, {BackgroundColor3 = trackColor}, 0.13, Enum.EasingStyle.Quad)
        else
            thumb.Position = targetPos
            thumb.BackgroundColor3 = targetColor
            switch.BackgroundColor3 = trackColor
        end
    end
    function control:SetValue(nextValue, silent)
        value = nextValue == true
        self.Value = value
        render(true)
        if not silent then safeCall(config.Callback, value) end
    end
    function control:GetValue() return value end
    control.Set = control.SetValue
    self.Window:_Connect(switch.Activated, function() control:SetValue(not value) end)
    render(false)
    table.insert(self.Window.ThemeRefreshCallbacks, function() render(false) end)
    return control
end

function TabMethods:CreateSlider(config)
    config = config or {}
    local minValue = tonumber(config.Min) or 0
    local maxValue = tonumber(config.Max) or 100
    if maxValue < minValue then minValue, maxValue = maxValue, minValue end
    local step = math.max(0.000001, tonumber(config.Step) or 1)
    local row = self:_Row(87, false)
    local title = self:_Label(row, {
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.new(1, -104, 0, 20),
        Text = tostring(config.Title or config.Name or "Slider"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local valueLabel = self:_Label(row, {
        Position = UDim2.new(1, -90, 0, 12),
        Size = UDim2.fromOffset(76, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(config.Default == nil and minValue or config.Default) .. tostring(config.Suffix or ""),
        TextSize = 12,
    }, "SubText")
    local track = buttonObject(row, {
        Position = UDim2.fromOffset(14, 49),
        Size = UDim2.new(1, -28, 0, 26),
        BackgroundTransparency = 1,
        Text = "",
    })
    local rail = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 5),
        BackgroundColor3 = self.Window.Theme.SurfaceHigh,
        BorderSizePixel = 0,
    }, track)
    corner(rail, 3)
    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Window.Theme.Primary,
        BorderSizePixel = 0,
    }, rail)
    corner(fill, 3)
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = self.Window.Theme.Primary,
        BorderSizePixel = 0,
    }, rail)
    corner(knob, 9)
    self.Window:_BindColor(rail, "BackgroundColor3", "SurfaceHigh")
    self.Window:_BindColor(fill, "BackgroundColor3", "Primary")
    self.Window:_BindColor(knob, "BackgroundColor3", "Primary")
    local value = math.clamp(tonumber(config.Default) or minValue, minValue, maxValue)
    local control = {Value = value}
    local function normalize(raw)
        local stepped = minValue + math.floor(((raw - minValue) / step) + 0.5) * step
        stepped = math.clamp(stepped, minValue, maxValue)
        if step >= 1 then return math.floor(stepped + 0.5) end
        return math.floor(stepped * 100000 + 0.5) / 100000
    end
    local function render()
        local alpha = maxValue == minValue and 0 or (value - minValue) / (maxValue - minValue)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. tostring(config.Suffix or "")
    end
    function control:SetValue(nextValue, silent)
        value = normalize(tonumber(nextValue) or minValue)
        self.Value = value
        render()
        if not silent then safeCall(config.Callback, value) end
    end
    function control:GetValue() return value end
    control.Set = control.SetValue
    local sliding = false
    local dragConnections = {}
    local function stopSliding()
        sliding = false
        for _, connection in ipairs(dragConnections) do
            connection:Disconnect()
            for i = #self.Window._transientConnections, 1, -1 do
                if self.Window._transientConnections[i] == connection then
                    table.remove(self.Window._transientConnections, i)
                    break
                end
            end
        end
        table.clear(dragConnections)
    end
    local function updateFromX(x)
        local railX = rail.AbsolutePosition.X
        local railWidth = rail.AbsoluteSize.X
        if railWidth <= 0 then return end
        local alpha = math.clamp((x - railX) / railWidth, 0, 1)
        control:SetValue(minValue + (maxValue - minValue) * alpha)
    end
    self.Window:_Connect(track.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if sliding then stopSliding() end
        sliding = true
        updateFromX(input.Position.X)
        table.insert(dragConnections, UserInputService.InputChanged:Connect(function(changed)
            if sliding and ((input.UserInputType == Enum.UserInputType.Touch and changed == input) or (input.UserInputType == Enum.UserInputType.MouseButton1 and changed.UserInputType == Enum.UserInputType.MouseMovement)) then
                updateFromX(changed.Position.X)
            end
        end))
        table.insert(dragConnections, UserInputService.InputEnded:Connect(function(ended)
            if (input.UserInputType == Enum.UserInputType.Touch and ended == input) or (input.UserInputType == Enum.UserInputType.MouseButton1 and ended.UserInputType == Enum.UserInputType.MouseButton1) then stopSliding() end
        end))
        for _, connection in ipairs(dragConnections) do table.insert(self.Window._transientConnections, connection) end
    end)
    render()
    return control
end

function TabMethods:CreateInput(config)
    config = config or {}
    local row = self:_Row(89, false)
    local title = self:_Label(row, {
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -28, 0, 20),
        Text = tostring(config.Title or config.Name or "Input"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local box = create("TextBox", {
        Name = "Input",
        Position = UDim2.fromOffset(14, 35),
        Size = UDim2.new(1, -28, 0, 42),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClearTextOnFocus = config.ClearOnFocus == true,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.Window.Theme.Text,
        PlaceholderColor3 = self.Window.Theme.SubText,
        PlaceholderText = tostring(config.Placeholder or "Enter a value"),
        Text = tostring(config.Default or ""),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    corner(box, 12)
    local focusEdge = stroke(box, self.Window.Theme.Outline, 0.76, 1)
    self.Window:_BindColor(focusEdge, "Color", "Outline")
    self.Window:_Connect(box.Focused, function()
        focusEdge.Color = self.Window.Theme.Primary
        focusEdge.Transparency = 0.16
        focusEdge.Thickness = 1.5
    end)
    self.Window:_Connect(box.FocusLost, function()
        focusEdge.Color = self.Window.Theme.Outline
        focusEdge.Transparency = 0.76
        focusEdge.Thickness = 1
    end)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, box)
    self.Window:_BindColor(box, "BackgroundColor3", "SurfaceAlt")
    self.Window:_BindColor(box, "TextColor3", "Text")
    self.Window:_BindColor(box, "PlaceholderColor3", "SubText")
    local control = {Value = box.Text}
    function control:SetValue(value, silent)
        box.Text = tostring(value or "")
        self.Value = box.Text
        if not silent then safeCall(config.Callback, box.Text) end
    end
    function control:GetValue() return box.Text end
    control.Set = control.SetValue
    self.Window:_Connect(box.FocusLost, function(enterPressed)
        control.Value = box.Text
        safeCall(config.Callback, box.Text, enterPressed)
    end)
    return control
end

function TabMethods:CreateDropdown(config)
    config = config or {}
    local options = config.Options or {}
    local row = self:_Row(0, true)
    create("UIPadding", {PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, row)
    create("UIListLayout", {
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, row)
    local header = create("Frame", {
        Name = "DropdownHeader",
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
    }, row)
    local title = self:_Label(header, {
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 0, 19),
        Text = tostring(config.Title or config.Name or "Dropdown"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local openButton = buttonObject(header, {
        Position = UDim2.new(0, 0, 0, 26),
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BackgroundTransparency = 0.15,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    corner(openButton, 11)
    self.Window:_BindColor(openButton, "BackgroundColor3", "SurfaceAlt")
    local selectedText = textObject(openButton, {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -42, 1, 0),
        Text = tostring(config.Default or "Select an option"),
        TextSize = 12,
    })
    self.Window:_BindColor(selectedText, "TextColor3", "Text")
    local chevron = textObject(openButton, {
        Position = UDim2.new(1, -32, 0, 0),
        Size = UDim2.fromOffset(22, 38),
        Text = "⌄",
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    self.Window:_BindColor(chevron, "TextColor3", "SubText")
    local list = create("Frame", {
        Name = "DropdownOptions",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
        Visible = false,
        LayoutOrder = 2,
    }, row)
    corner(list, 11)
    self.Window:_BindColor(list, "BackgroundColor3", "SurfaceAlt")
    create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    }, list)
    create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)
    local value = config.Default
    local control = {Value = value}
    local function choose(option)
        value = option
        control.Value = option
        selectedText.Text = tostring(option)
        list.Visible = false
        chevron.Text = "⌄"
        safeCall(config.Callback, option)
    end
    local function populate(newOptions)
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        options = newOptions or {}
        for index, option in ipairs(options) do
            local optionButton = buttonObject(list, {
                Name = "Option_" .. tostring(index),
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = self.Window.Theme.SurfaceHigh,
                BackgroundTransparency = 1,
                Text = tostring(option),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = index,
            })
            corner(optionButton, 8)
            create("UIPadding", {PaddingLeft = UDim.new(0, 10)}, optionButton)
            self.Window:_BindColor(optionButton, "BackgroundColor3", "SurfaceHigh")
            self.Window:_BindColor(optionButton, "TextColor3", "Text")
            self.Window:_Connect(optionButton.Activated, function() choose(option) end)
        end
    end
    function control:SetValue(option, silent)
        value = option
        self.Value = option
        selectedText.Text = tostring(option or "Select an option")
        if not silent then safeCall(config.Callback, option) end
    end
    function control:GetValue() return value end
    function control:SetOptions(newOptions) populate(newOptions) end
    control.Set = control.SetValue
    self.Window:_Connect(openButton.Activated, function()
        list.Visible = not list.Visible
        chevron.Text = list.Visible and "⌃" or "⌄"
    end)
    populate(options)
    if value == nil and options[1] ~= nil then
        value = options[1]
        control.Value = value
        selectedText.Text = tostring(value)
    end
    return control
end

function TabMethods:CreateKeybind(config)
    config = config or {}
    local row = self:_Row(58, false)
    local title = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(1, -110, 1, 0),
        Text = tostring(config.Title or config.Name or "Keybind"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local keyButton = buttonObject(row, {
        Position = UDim2.new(1, -104, 0.5, -16),
        Size = UDim2.fromOffset(102, 32),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        Text = type(config.Default) == "EnumItem" and config.Default.Name or tostring(config.Default or "None"),
        TextSize = 12,
    })
    corner(keyButton, 10)
    self.Window:_BindColor(keyButton, "BackgroundColor3", "SurfaceAlt")
    self.Window:_BindColor(keyButton, "TextColor3", "Text")
    local key = config.Default
    local listening = false
    local control = {Value = key}
    function control:SetValue(nextKey, silent)
        key = nextKey
        self.Value = nextKey
        keyButton.Text = typeof(nextKey) == "EnumItem" and nextKey.Name or tostring(nextKey or "None")
        if not silent then safeCall(config.Changed, nextKey) end
    end
    function control:GetValue() return key end
    control.Set = control.SetValue
    self.Window:_Connect(keyButton.Activated, function()
        listening = true
        keyButton.Text = "Press key…"
    end)
    self.Window:_Connect(UserInputService.InputBegan, function(input, processed)
        if self.Window.Destroyed or processed then return end
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                control:SetValue(input.KeyCode)
            elseif input.KeyCode == Enum.KeyCode.Escape then
                keyButton.Text = typeof(key) == "EnumItem" and key.Name or tostring(key or "None")
            end
            listening = false
            return
        end
        if key and input.KeyCode == key then safeCall(config.Callback, input.KeyCode) end
    end)
    return control
end

function WindowMethods:Notify(config)
    config = config or {}
    if self.Destroyed then return end
    local offset = #self.Notifications
    local frame = create("Frame", {
        Name = "Notification",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 320, 0, 16 + offset * 82),
        Size = UDim2.fromOffset(292, 72),
        BackgroundColor3 = self.Theme.SurfaceHigh,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 40,
    }, self.Gui)
    corner(frame, 14)
    local edge = stroke(frame, self.Theme.Outline, 0.45, 1)
    textObject(frame, {
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -26, 0, 22),
        Text = tostring(config.Title or "VortexionUI"),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextColor3 = self.Theme.Text,
        ZIndex = 41,
    })
    textObject(frame, {
        Position = UDim2.new(0, 14, 0, 31),
        Size = UDim2.new(1, -26, 0, 31),
        Text = tostring(config.Content or config.Description or ""),
        TextSize = 11,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = self.Theme.SubText,
        ZIndex = 41,
    })
    table.insert(self.Notifications, frame)
    table.insert(self.Overlays, frame)
    if self.AnimationsEnabled then
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -14, 0, 16 + offset * 82),
        }):Play()
    else
        frame.Position = UDim2.new(1, -14, 0, 16 + offset * 82)
    end
    local duration = math.max(0.5, tonumber(config.Duration) or 3)
    task.delay(duration, function()
        if self.Destroyed or not frame.Parent then return end
        if self.AnimationsEnabled then
            local tween = TweenService:Create(frame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 320, 0, frame.Position.Y.Offset),
                BackgroundTransparency = 1,
            })
            tween:Play()
            tween.Completed:Wait()
        end
        if frame.Parent then frame:Destroy() end
        for index, item in ipairs(self.Notifications) do
            if item == frame then table.remove(self.Notifications, index); break end
        end
    end)
    return frame
end

function WindowMethods:PlayLoadingAnimation(config)
    config = config or {}
    if self.Destroyed then return nil end
    local theme = self.Theme
    local overlay = create("Frame", {
        Name = "RelaxUILoading",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = math.clamp(tonumber(config.Transparency) or 0.08, 0, 0.8),
        BorderSizePixel = 0,
        ZIndex = 100,
    }, self.Gui)
    local card = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.min(300, math.max(220, viewportSize().X - 48)), 142),
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 101,
    }, overlay)
    corner(card, 20)
    stroke(card, theme.Outline, 0.45, 1)
    local title = textObject(card, {
        Position = UDim2.fromOffset(18, 15),
        Size = UDim2.new(1, -36, 0, 26),
        Text = tostring(config.Title or self.Config.Title or "Relax UI"),
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextColor3 = theme.Text,
        ZIndex = 102,
    })
    local message = textObject(card, {
        Position = UDim2.fromOffset(18, 43),
        Size = UDim2.new(1, -36, 0, 22),
        Text = tostring(config.Status or "Preparing interface…"),
        TextSize = 11,
        TextColor3 = theme.SubText,
        ZIndex = 102,
    })
    local rail = create("Frame", {
        Position = UDim2.new(0, 18, 0, 82),
        Size = UDim2.new(1, -36, 0, 6),
        BackgroundColor3 = theme.SurfaceHigh,
        BorderSizePixel = 0,
        ZIndex = 102,
    }, card)
    corner(rail, 4)
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 103,
    }, rail)
    corner(fill, 4)
    local percent = textObject(card, {
        Position = UDim2.new(0, 18, 0, 96),
        Size = UDim2.new(1, -36, 0, 20),
        Text = "0%",
        TextSize = 10,
        TextColor3 = theme.SubText,
        ZIndex = 102,
    })
    local loading = {Frame = overlay, Value = 0, Closed = false}
    function loading:SetProgress(value, status)
        self.Value = math.clamp(tonumber(value) or 0, 0, 1)
        percent.Text = tostring(math.floor(self.Value * 100 + 0.5)) .. "%"
        if status then message.Text = tostring(status) end
        if self.Window and self.Window.AnimationsEnabled then
            TweenService:Create(fill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromScale(self.Value, 1),
            }):Play()
        else
            fill.Size = UDim2.fromScale(self.Value, 1)
        end
    end
    function loading:Close()
        if self.Closed then return end
        self.Closed = true
        if self.Frame and self.Frame.Parent then
            if self.Window and self.Window.AnimationsEnabled then
                local tween = TweenService:Create(self.Frame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1,
                })
                tween:Play()
                tween.Completed:Wait()
            end
            if self.Frame then self.Frame:Destroy() end
        end
    end
    loading.Window = self
    table.insert(self.Overlays, overlay)
    loading:SetProgress(config.Progress or 0, config.Status)
    return loading
end

function WindowMethods:Confirm(config)
    config = config or {}
    if self.Destroyed then return nil end
    local overlay = create("Frame", {
        Name = "ConfirmOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.48,
        BorderSizePixel = 0,
        ZIndex = 50,
    }, self.Gui)
    local dialog = create("Frame", {
        Name = "ConfirmDialog",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, math.min(360, math.max(280, viewportSize().X - 32)), 0, 188),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, overlay)
    corner(dialog, 22)
    stroke(dialog, self.Theme.Outline, 0.4, 1)
    textObject(dialog, {
        Position = UDim2.new(0, 20, 0, 18),
        Size = UDim2.new(1, -40, 0, 24),
        Text = tostring(config.Title or "Confirm"),
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        TextColor3 = self.Theme.Text,
        ZIndex = 52,
    })
    textObject(dialog, {
        Position = UDim2.new(0, 20, 0, 50),
        Size = UDim2.new(1, -40, 0, 62),
        Text = tostring(config.Content or config.Description or ""),
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 12,
        TextColor3 = self.Theme.SubText,
        ZIndex = 52,
    })
    local cancel = buttonObject(dialog, {
        Position = UDim2.new(1, -204, 1, -52),
        Size = UDim2.fromOffset(88, 34),
        Text = tostring(config.CancelText or "Cancel"),
        BackgroundColor3 = self.Theme.SurfaceAlt,
        TextColor3 = self.Theme.Text,
        ZIndex = 52,
    })
    corner(cancel, 17)
    local confirm = buttonObject(dialog, {
        Position = UDim2.new(1, -106, 1, -52),
        Size = UDim2.fromOffset(86, 34),
        Text = tostring(config.ConfirmText or "Confirm"),
        BackgroundColor3 = self.Theme.Primary,
        TextColor3 = self.Theme.OnPrimary,
        ZIndex = 52,
    })
    corner(confirm, 17)
    local closed = false
    local function close(result)
        if closed then return end
        closed = true
        if overlay.Parent then overlay:Destroy() end
        safeCall(config.Callback, result)
    end
    self:_Connect(cancel.Activated, function() close(false) end)
    self:_Connect(confirm.Activated, function() close(true) end)
    table.insert(self.Overlays, overlay)
    return {Close = close}
end

function WindowMethods:Minimize()
    if self.Destroyed or self.Minimized then return end
    self.Minimized = true
    local oldPosition = self.Main.AbsolutePosition
    local oldSize = self.Main.AbsoluteSize
    self.Main.Visible = false
    local launcher = buttonObject(self.Gui, {
        Name = "MinimizedLauncher",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(oldPosition.X + oldSize.X / 2, oldPosition.Y + oldSize.Y / 2),
        Size = UDim2.fromOffset(54, 54),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 20,
    })
    corner(launcher, 18)
    self:_BindColor(launcher, "BackgroundColor3", "Surface")
    local logo = makeLogo(launcher, 34, self.Config.Icon)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.5)
    self.Launcher = launcher
    self._launcherMoved = false
    self:_Connect(launcher.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._launcherMoved = false
            self:_StartMove(input, false, launcher)
        end
    end)
    self:_Connect(launcher.Activated, function()
        if not self._launcherMoved then self:Restore() end
    end)
end

function WindowMethods:Restore()
    if self.Destroyed then return end
    self.Minimized = false
    if self.Launcher then self.Launcher:Destroy(); self.Launcher = nil end
    if self.Main then self.Main.Visible = true end
    if self.Scale then
        self.Scale.Scale = self.AnimationsEnabled and 0.96 or 1
        self:_Animate(self.Scale, {Scale = 1}, Design.MotionNormal)
    end
end

function WindowMethods:Toggle()
    if self.Minimized then self:Restore() else self:Minimize() end
end

function WindowMethods:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self._viewportConnection then self._viewportConnection:Disconnect(); self._viewportConnection = nil end
    local activeMotions = {}
    for object in pairs(self._motionTweens) do table.insert(activeMotions, object) end
    for _, object in ipairs(activeMotions) do self:_CancelMotion(object, false) end
    if self._activeDragCleanup then self._activeDragCleanup() end
    for _, connection in ipairs(self.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self.Connections)
    for _, connection in ipairs(self._transientConnections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    for _, overlay in ipairs(self.Overlays) do
        pcall(function() overlay:Destroy() end)
    end
    if self.Gui then self.Gui:Destroy() end
    self.Gui = nil
    self.Main = nil
    self.Launcher = nil
end


-- ROUND 2: supplemental MD3 controls, configuration and reusable UI states.
-- Each widget uses native Roblox GUI objects; no HTML APIs or vendor library.

local HttpService = game:GetService("HttpService")

local function clampNumber(value, lo, hi)
    return math.clamp(tonumber(value) or lo, lo, hi)
end

function TabMethods:CreateSpacer(height)
    return self:_Row(math.clamp(tonumber(height) or 12, 0, 240), false, true)
end

function TabMethods:CreateBadge(config)
    config = type(config) == "table" and config or {Text = config}
    local row = self:_Row(36, false)
    local badge = textObject(row, {
        Name = "Badge",
        Position = UDim2.fromOffset(2, 4),
        Size = UDim2.new(1, -4, 0, 28),
        Text = tostring(config.Text or config.Title or "Badge"),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 12,
        BackgroundTransparency = 0.25,
        BackgroundColor3 = self.Window.Theme.SurfaceHigh,
    })
    corner(badge, 14)
    self.Window:_BindColor(badge, "BackgroundColor3", "SurfaceHigh")
    self.Window:_BindColor(badge, "TextColor3", "Primary")
    return {SetText = function(_, value) badge.Text = tostring(value or "") end}
end

function TabMethods:CreateProgressBar(config)
    config = config or {}
    local row = self:_Row(57, false)
    local label = self:_Label(row, {
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -66, 0, 26),
        Text = tostring(config.Title or "Progress"),
        TextSize = 12,
    }, "Text")
    local percent = self:_Label(row, {
        Position = UDim2.new(1, -62, 0, 0),
        Size = UDim2.fromOffset(60, 26),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 11,
        Text = "",
    }, "SubText")
    local rail = create("Frame", {
        Position = UDim2.new(0, 2, 0, 35),
        Size = UDim2.new(1, -4, 0, 7),
        BackgroundColor3 = self.Window.Theme.SurfaceHigh,
        BorderSizePixel = 0,
    }, row)
    corner(rail, 4)
    self.Window:_BindColor(rail, "BackgroundColor3", "SurfaceHigh")
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = self.Window.Theme.Primary,
        BorderSizePixel = 0,
    }, rail)
    corner(fill, 4)
    self.Window:_BindColor(fill, "BackgroundColor3", "Primary")
    local value = 0
    local maxValue = math.max(0.001, tonumber(config.Max) or 100)
    local control = {}
    function control:SetValue(newValue)
        value = math.clamp(tonumber(newValue) or 0, 0, maxValue)
        self.Value = value
        local alpha = value / maxValue
        percent.Text = tostring(math.floor(alpha * 100 + 0.5)) .. "%"
        if self.Window and self.Window.AnimationsEnabled then
            TweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromScale(alpha, 1),
            }):Play()
        else
            fill.Size = UDim2.fromScale(alpha, 1)
        end
    end
    function control:GetValue() return value end
    function control:SetTitle(title) label.Text = tostring(title or "") end
    control.Window = self.Window
    control:SetValue(config.Default or config.Value or 0)
    return control
end

function TabMethods:CreateTextArea(config)
    config = config or {}
    local row = self:_Row(math.max(98, tonumber(config.Height) or 142), false)
    self:_Label(row, {
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -4, 0, 24),
        Text = tostring(config.Title or "Text area"),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
    }, "Text")
    local box = create("TextBox", {
        Name = "TextArea",
        Position = UDim2.fromOffset(0, 29),
        Size = UDim2.new(1, 0, 1, -34),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = tostring(config.Default or ""),
        PlaceholderText = tostring(config.Placeholder or "Write here"),
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Font = Enum.Font.Gotham,
        TextSize = 12,
    }, row)
    corner(box, 12)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 9),
        PaddingBottom = UDim.new(0, 9),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, box)
    self.Window:_BindColor(box, "BackgroundColor3", "SurfaceAlt")
    self.Window:_BindColor(box, "TextColor3", "Text")
    self.Window:_BindColor(box, "PlaceholderColor3", "SubText")
    local control = {Value = box.Text}
    function control:SetValue(value, silent)
        box.Text = tostring(value or "")
        self.Value = box.Text
        if not silent then safeCall(config.Callback, box.Text) end
    end
    function control:GetValue() return box.Text end
    control.Set = control.SetValue
    self.Window:_Connect(box.FocusLost, function(enterPressed)
        control.Value = box.Text
        safeCall(config.Callback, box.Text, enterPressed)
    end)
    return control
end

function TabMethods:CreateCode(config)
    config = type(config) == "table" and config or {Content = config}
    local row = self:_Row(math.max(110, tonumber(config.Height) or 170), false)
    local header = self:_Label(row, {
        Position = UDim2.fromOffset(2, 1),
        Size = UDim2.new(1, -96, 0, 26),
        Text = tostring(config.Title or "Code"),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local copyButton = buttonObject(row, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -2, 0, 2),
        Size = UDim2.fromOffset(80, 26),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        Text = "Copy",
        TextSize = 11,
    })
    corner(copyButton, 10)
    self.Window:_BindColor(copyButton, "BackgroundColor3", "SurfaceAlt")
    self.Window:_BindColor(copyButton, "TextColor3", "Text")
    local content = create("TextBox", {
        Position = UDim2.new(0, 0, 0, 31),
        Size = UDim2.new(1, 0, 1, -36),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = false,
        Text = tostring(config.Content or config.Code or ""),
        Font = Enum.Font.Code,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextEditable = false,
    }, row)
    corner(content, 10)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, content)
    self.Window:_BindColor(content, "BackgroundColor3", "SurfaceAlt")
    self.Window:_BindColor(content, "TextColor3", "Text")
    self.Window:_Connect(copyButton.Activated, function()
        if type(setclipboard) == "function" then
            local ok = pcall(setclipboard, content.Text)
            copyButton.Text = ok and "Copied" or "Unavailable"
        else
            copyButton.Text = "Unavailable"
        end
    end)
    return {SetContent = function(_, value) content.Text = tostring(value or "") end}
end

function TabMethods:CreateCheckbox(config)
    config = config or {}
    local row = self:_Row(40, false)
    local box = buttonObject(row, {
        Position = UDim2.fromOffset(2, 7),
        Size = UDim2.fromOffset(25, 25),
        BackgroundColor3 = self.Window.Theme.SurfaceHigh,
        Text = "",
        TextSize = 15,
    })
    corner(box, 7)
    self.Window:_BindColor(box, "BackgroundColor3", "SurfaceHigh")
    self.Window:_BindColor(box, "TextColor3", "OnPrimary")
    self:_Label(row, {
        Position = UDim2.fromOffset(38, 1),
        Size = UDim2.new(1, -41, 1, 0),
        Text = tostring(config.Title or config.Name or "Checkbox"),
        TextSize = 12,
    }, "Text")
    local control = {Value = config.Default == true}
    local function render()
        box.Text = control.Value and "✓" or ""
        box.BackgroundColor3 = control.Value and self.Window.Theme.Primary or self.Window.Theme.SurfaceHigh
    end
    function control:SetValue(value, silent)
        self.Value = value == true
        render()
        if not silent then safeCall(config.Callback, self.Value) end
    end
    function control:GetValue() return self.Value end
    control.Set = control.SetValue
    self.Window:_Connect(box.Activated, function() control:SetValue(not control.Value) end)
    table.insert(self.Window.ThemeRefreshCallbacks, render)
    render()
    return control
end

function TabMethods:CreateRadioGroup(config)
    config = config or {}
    local choices = config.Options or {}
    local row = self:_Row(0, true)
    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, row)
    self:_Label(row, {
        Size = UDim2.new(1, 0, 0, 24),
        Text = tostring(config.Title or "Radio group"),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        LayoutOrder = 1,
    }, "Text")
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
    }, row)
    create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    local control = {Value = config.Default or choices[1]}
    local rendered = {}
    local keys = {}
    local function render()
        for index, item in ipairs(rendered) do
            local selected = keys[index] == control.Value
            item.TextColor3 = selected and self.Window.Theme.Primary or self.Window.Theme.Text
            item.BackgroundColor3 = selected and self.Window.Theme.SurfaceHigh or self.Window.Theme.SurfaceAlt
        end
    end
    function control:SetValue(value, silent)
        self.Value = value
        render()
        if not silent then safeCall(config.Callback, value) end
    end
    function control:GetValue() return self.Value end
    control.Set = control.SetValue
    for index, choice in ipairs(choices) do
        keys[index] = choice
        local option = buttonObject(container, {
            Size = UDim2.new(1, 0, 0, 33),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "◯   " .. tostring(choice),
            TextSize = 12,
            LayoutOrder = index,
        })
        corner(option, 10)
        create("UIPadding", {PaddingLeft = UDim.new(0, 10)}, option)
        table.insert(rendered, option)
        self.Window:_Connect(option.Activated, function()
            control:SetValue(choice)
        end)
    end
    table.insert(self.Window.ThemeRefreshCallbacks, render)
    render()
    return control
end

function TabMethods:CreateCheckboxGroup(config)
    config = config or {}
    local values = {}
    if type(config.Default) == "table" then
        for _, selected in ipairs(config.Default) do values[selected] = true end
    end
    local choices = config.Options or {}
    local row = self:_Row(0, true)
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, row)
    self:_Label(row, {
        Size = UDim2.new(1, 0, 0, 24),
        Text = tostring(config.Title or "Checkbox group"),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        LayoutOrder = 1,
    }, "Text")
    local buttons = {}
    local control = {}
    local function snapshot()
        local result = {}
        for _, choice in ipairs(choices) do
            if values[choice] then table.insert(result, choice) end
        end
        return result
    end
    local function render()
        for index, button in ipairs(buttons) do
            local active = values[choices[index]] == true
            button.Text = (active and "☑   " or "□   ") .. tostring(choices[index])
            button.TextColor3 = active and self.Window.Theme.Primary or self.Window.Theme.Text
            button.BackgroundColor3 = active and self.Window.Theme.SurfaceHigh or self.Window.Theme.SurfaceAlt
        end
    end
    function control:GetValue() return snapshot() end
    function control:SetValue(selected, silent)
        table.clear(values)
        if type(selected) == "table" then
            for _, choice in ipairs(selected) do values[choice] = true end
        end
        self.Value = snapshot()
        render()
        if not silent then safeCall(config.Callback, self.Value) end
    end
    control.Set = control.SetValue
    for index, choice in ipairs(choices) do
        local button = buttonObject(row, {
            Size = UDim2.new(1, 0, 0, 34),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 12,
            LayoutOrder = index + 1,
        })
        corner(button, 10)
        create("UIPadding", {PaddingLeft = UDim.new(0, 10)}, button)
        table.insert(buttons, button)
        self.Window:_Connect(button.Activated, function()
            values[choice] = not values[choice]
            control.Value = snapshot()
            render()
            safeCall(config.Callback, control.Value)
        end)
    end
    table.insert(self.Window.ThemeRefreshCallbacks, render)
    control.Value = snapshot()
    render()
    return control
end

function TabMethods:CreateMultiDropdown(config)
    -- A compact MD3 check-list is used instead of a detached modal menu.
    return self:CreateCheckboxGroup(config)
end

function TabMethods:CreateSegmentedControl(config)
    config = config or {}
    local choices = config.Options or {"One", "Two"}
    local row = self:_Row(70, false)
    self:_Label(row, {
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -4, 0, 24),
        Text = tostring(config.Title or "Segmented control"),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local holder = create("Frame", {
        Position = UDim2.fromOffset(0, 29),
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
    }, row)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    }, holder)
    local control = {Value = config.Default or choices[1]}
    local buttons = {}
    local function render()
        for index, button in ipairs(buttons) do
            local selected = choices[index] == control.Value
            button.BackgroundColor3 = selected and self.Window.Theme.Primary or self.Window.Theme.SurfaceAlt
            button.TextColor3 = selected and self.Window.Theme.OnPrimary or self.Window.Theme.Text
        end
    end
    function control:SetValue(value, silent)
        self.Value = value
        render()
        if not silent then safeCall(config.Callback, value) end
    end
    function control:GetValue() return self.Value end
    control.Set = control.SetValue
    local share = math.min(1 / math.max(1, #choices), 0.5)
    for index, choice in ipairs(choices) do
        local button = buttonObject(holder, {
            Size = UDim2.new(share, -3, 1, 0),
            Text = tostring(choice),
            TextSize = 11,
            LayoutOrder = index,
        })
        corner(button, 12)
        table.insert(buttons, button)
        self.Window:_Connect(button.Activated, function() control:SetValue(choice) end)
    end
    table.insert(self.Window.ThemeRefreshCallbacks, render)
    render()
    return control
end

function TabMethods:CreateStepper(config)
    config = config or {}
    local minValue = tonumber(config.Min) or 0
    local maxValue = tonumber(config.Max) or 100
    local step = math.max(0.00001, tonumber(config.Step) or 1)
    local row = self:_Row(52, false)
    self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(1, -148, 1, 0),
        Text = tostring(config.Title or "Stepper"),
        TextSize = 12,
    }, "Text")
    local minus = buttonObject(row, {
        Position = UDim2.new(1, -145, 0.5, -16),
        Size = UDim2.fromOffset(36, 32),
        Text = "−",
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
    })
    local valueLabel = self:_Label(row, {
        Position = UDim2.new(1, -105, 0, 0),
        Size = UDim2.new(0, 58, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = "",
    }, "Text")
    local plus = buttonObject(row, {
        Position = UDim2.new(1, -44, 0.5, -16),
        Size = UDim2.fromOffset(36, 32),
        Text = "+",
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
    })
    for _, button in ipairs({minus, plus}) do
        corner(button, 11)
        self.Window:_BindColor(button, "BackgroundColor3", "SurfaceAlt")
        self.Window:_BindColor(button, "TextColor3", "Text")
    end
    local control = {Value = 0}
    function control:SetValue(nextValue, silent)
        local n = tonumber(nextValue) or minValue
        self.Value = math.clamp(math.floor(n / step + 0.5) * step, minValue, maxValue)
        valueLabel.Text = tostring(self.Value)
        if not silent then safeCall(config.Callback, self.Value) end
    end
    function control:GetValue() return self.Value end
    control.Set = control.SetValue
    self.Window:_Connect(minus.Activated, function() control:SetValue(control.Value - step) end)
    self.Window:_Connect(plus.Activated, function() control:SetValue(control.Value + step) end)
    control:SetValue(config.Default or minValue, true)
    return control
end

function TabMethods:CreateColorPicker(config)
    config = config or {}
    local initial = typeof(config.Default) == "Color3" and config.Default or Color3.fromRGB(130, 151, 214)
    local row = self:_Row(0, true)
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, row)
    self:_Label(row, {
        Size = UDim2.new(1, 0, 0, 24),
        Text = tostring(config.Title or "Color picker"),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        LayoutOrder = 1,
    }, "Text")
    local preview = create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundColor3 = initial,
        BorderSizePixel = 0,
        LayoutOrder = 2,
    }, row)
    corner(preview, 8)
    local channels = {}
    local control = {Value = initial}
    local updating = false
    local function render()
        local c = control.Value
        local rgb = {math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)}
        preview.BackgroundColor3 = c
        updating = true
        for index, item in ipairs(channels) do
            item:SetValue(rgb[index], true)
        end
        updating = false
    end
    function control:SetValue(color, silent)
        if typeof(color) ~= "Color3" then return end
        self.Value = color
        render()
        if not silent then safeCall(config.Callback, color) end
    end
    function control:GetValue() return self.Value end
    control.Set = control.SetValue
    -- Slider widgets live as child rows of the tab. Keep the channels in the same
    -- content scroll surface rather than creating a second scrolling view.
    for index, channel in ipairs({"Red", "Green", "Blue"}) do
        local channelControl = self:CreateSlider({
            Title = channel,
            Min = 0, Max = 255, Step = 1,
            Default = math.floor((index == 1 and initial.R or index == 2 and initial.G or initial.B) * 255 + 0.5),
            Callback = function()
                if updating then return end
                local r = channels[1] and channels[1]:GetValue() or math.floor(initial.R * 255)
                local g = channels[2] and channels[2]:GetValue() or math.floor(initial.G * 255)
                local b = channels[3] and channels[3]:GetValue() or math.floor(initial.B * 255)
                control:SetValue(Color3.fromRGB(r, g, b))
            end,
        })
        channels[index] = channelControl
    end
    render()
    return control
end

function TabMethods:CreateAccordion(config)
    config = config or {}
    local row = self:_Row(0, true)
    create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, row)
    local header = buttonObject(row, {
        Size = UDim2.new(1, 0, 0, 40),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "⌄   " .. tostring(config.Title or "Accordion"),
        TextSize = 12,
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        LayoutOrder = 1,
    })
    corner(header, 11)
    create("UIPadding", {PaddingLeft = UDim.new(0, 12)}, header)
    self.Window:_BindColor(header, "BackgroundColor3", "SurfaceAlt")
    self.Window:_BindColor(header, "TextColor3", "Text")
    local content = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = config.Expanded == true,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
    }, row)
    create("UIListLayout", {
        Padding = UDim.new(0, 5),
    }, content)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
    }, content)
    local label = self:_Label(content, {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        Text = tostring(config.Content or ""),
        TextSize = 12,
    }, "SubText")
    local control = {Expanded = config.Expanded == true}
    function control:SetExpanded(value)
        self.Expanded = value == true
        content.Visible = self.Expanded
        header.Text = (self.Expanded and "⌃   " or "⌄   ") .. tostring(config.Title or "Accordion")
        safeCall(config.Callback, self.Expanded)
    end
    function control:SetContent(value) label.Text = tostring(value or "") end
    self.Window:_Connect(header.Activated, function() control:SetExpanded(not control.Expanded) end)
    return control
end

function TabMethods:CreateImage(config)
    config = config or {}
    local imageHeight = math.max(80, math.min(300, tonumber(config.Height) or 145))
    local row = self:_Row(imageHeight + 29, false)
    local header = self:_Label(row, {
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -4, 0, 24),
        Text = tostring(config.Title or "Image"),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local image = create("ImageLabel", {
        Position = UDim2.fromOffset(0, 27),
        Size = UDim2.new(1, 0, 0, imageHeight),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        Image = tostring(config.Image or config.Source or ""),
        ScaleType = Enum.ScaleType.Fit,
        BorderSizePixel = 0,
    }, row)
    corner(image, 10)
    self.Window:_BindColor(image, "BackgroundColor3", "SurfaceAlt")
    return {
        SetImage = function(_, source) image.Image = tostring(source or "") end,
        SetTitle = function(_, title) header.Text = tostring(title or "") end,
    }
end

function TabMethods:CreateVideo(config)
    config = config or {}
    local row = self:_Row(math.max(120, tonumber(config.Height) or 180), false)
    local frame = create("VideoFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BorderSizePixel = 0,
        Video = tostring(config.Video or ""),
        Looped = config.Looped == true,
        Playing = config.Autoplay == true,
        Volume = math.clamp(tonumber(config.Volume) or 0.6, 0, 1),
    }, row)
    corner(frame, 12)
    self.Window:_BindColor(frame, "BackgroundColor3", "SurfaceAlt")
    return {
        SetVideo = function(_, source) frame.Video = tostring(source or "") end,
        Play = function() frame.Playing = true end,
        Pause = function() frame.Playing = false end,
    }
end

function TabMethods:CreateViewport(config)
    config = config or {}
    local row = self:_Row(math.max(110, tonumber(config.Height) or 185), false)
    local viewport = create("ViewportFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        BorderSizePixel = 0,
        Ambient = Color3.fromRGB(200, 200, 205),
        LightColor = Color3.fromRGB(255, 255, 255),
        LightDirection = Vector3.new(-0.3, -1, -0.5),
    }, row)
    corner(viewport, 12)
    self.Window:_BindColor(viewport, "BackgroundColor3", "SurfaceAlt")
    local camera = create("Camera", {}, viewport)
    viewport.CurrentCamera = camera
    local model
    local function setModel(source)
        if model then model:Destroy() end
        model = nil
        if typeof(source) ~= "Instance" then return end
        model = source:Clone()
        model.Parent = viewport
        if model:IsA("Model") then
            local center, size = model:GetBoundingBox()
            local radius = math.max(size.X, size.Y, size.Z) * 1.7
            camera.CFrame = CFrame.lookAt(center.Position + Vector3.new(radius, radius * 0.45, radius), center.Position)
        elseif model:IsA("BasePart") then
            camera.CFrame = CFrame.lookAt(model.Position + Vector3.new(7, 4, 7), model.Position)
        end
    end
    setModel(config.Model)
    return {SetModel = function(_, source) setModel(source) end, Frame = viewport}
end

function TabMethods:CreateStatusCard(config)
    config = config or {}
    local row = self:_Row(64, false)
    row.BackgroundColor3 = self.Window.Theme.SurfaceAlt
    row.BackgroundTransparency = 0.26
    corner(row, 12)
    self.Window:_BindColor(row, "BackgroundColor3", "SurfaceAlt")
    local title = self:_Label(row, {
        Position = UDim2.new(0, 12, 0, 5),
        Size = UDim2.new(1, -24, 0, 25),
        Text = tostring(config.Title or "Status"),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local status = self:_Label(row, {
        Position = UDim2.new(0, 12, 0, 29),
        Size = UDim2.new(1, -24, 0, 24),
        Text = tostring(config.Status or config.Content or "Ready"),
        TextSize = 11,
    }, "Success")
    return {
        SetStatus = function(_, value) status.Text = tostring(value or "") end,
        SetTitle = function(_, value) title.Text = tostring(value or "") end,
    }
end

function TabMethods:CreateStatCard(config)
    config = config or {}
    local row = self:_Row(70, false)
    row.BackgroundColor3 = self.Window.Theme.SurfaceAlt
    row.BackgroundTransparency = 0.22
    corner(row, 12)
    self.Window:_BindColor(row, "BackgroundColor3", "SurfaceAlt")
    local title = self:_Label(row, {
        Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -24, 0, 20),
        Text = tostring(config.Title or "Statistic"),
        TextSize = 11,
    }, "SubText")
    local value = self:_Label(row, {
        Position = UDim2.fromOffset(12, 28),
        Size = UDim2.new(1, -24, 0, 32),
        Text = tostring(config.Value or "0"),
        Font = Enum.Font.GothamSemibold,
        TextSize = 18,
    }, "Text")
    return {SetValue = function(_, nextValue) value.Text = tostring(nextValue or "") end}
end

function TabMethods:CreateTimeline(config)
    config = config or {}
    local events = config.Events or {}
    local row = self:_Row(0, true)
    create("UIListLayout", {Padding = UDim.new(0, 4)}, row)
    self:_Label(row, {
        Size = UDim2.new(1, 0, 0, 26),
        Text = tostring(config.Title or "Timeline"),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        LayoutOrder = 1,
    }, "Text")
    local items = {}
    for index, event in ipairs(events) do
        local item = self:_Label(row, {
            Size = UDim2.new(1, 0, 0, 31),
            Text = "•  " .. tostring(type(event) == "table" and (event.Title or event.Text or event[1]) or event),
            TextSize = 12,
            LayoutOrder = index + 1,
        }, "SubText")
        table.insert(items, item)
    end
    return {Items = items}
end

function TabMethods:CreateChipGroup(config)
    return self:CreateSegmentedControl(config)
end

function TabMethods:CreateMarkdown(config)
    -- Plain rich-text-safe paragraph fallback. Markdown parsing is not supplied.
    return self:CreateParagraph(type(config) == "table" and config or {Content = tostring(config or "")})
end

function WindowMethods:CreateSubGroup(parent, title, options)
    assert(parent and parent.Window == self, "CreateSubGroup: expected group from this window")
    options = options or {}
    options.Parent = parent
    return self:CreateTabGroup(title, options)
end

function GroupMethods:CreateSubGroup(title, options)
    return self.Window:CreateSubGroup(self, title, options)
end

local oldCreateTabGroup = WindowMethods.CreateTabGroup
function WindowMethods:CreateTabGroup(title, options)
    options = options or {}
    local parent = options.Parent
    assert(not parent or parent.Window == self, "Invalid subgroup parent")
    local group = oldCreateTabGroup(self, title, options)
    if parent then
        group.Frame.Parent = parent.TabsContainer
        group.Frame.LayoutOrder = #parent.Tabs + #self.Groups + 1
        group.Header.Text = string.rep("  ", math.min(group.Depth, 4)) .. group.Title
    end
    return group
end

local function serializeValue(value)
    local kind = typeof(value)
    if kind == "Color3" then
        return {__type = "Color3", R = value.R, G = value.G, B = value.B}
    elseif kind == "EnumItem" then
        return {__type = "KeyCode", Name = value.Name}
    elseif type(value) == "number" or type(value) == "boolean" or type(value) == "string" then
        return value
    elseif type(value) == "table" then
        local result = {}
        for key, entry in pairs(value) do
            if type(key) == "string" or type(key) == "number" then
                result[key] = serializeValue(entry)
            end
        end
        return result
    end
    return nil
end

local function deserializeValue(value)
    if type(value) ~= "table" then return value end
    if value.__type == "Color3" then
        return Color3.new(
            clampNumber(value.R, 0, 1),
            clampNumber(value.G, 0, 1),
            clampNumber(value.B, 0, 1)
        )
    elseif value.__type == "KeyCode" then
        return Enum.KeyCode[tostring(value.Name or "")] or Enum.KeyCode.Unknown
    end
    local result = {}
    for key, entry in pairs(value) do result[key] = deserializeValue(entry) end
    return result
end

function WindowMethods:RegisterFlag(flag, control)
    assert(type(flag) == "string" and flag ~= "", "Flag must be a nonempty string")
    assert(control and type(control.GetValue) == "function" and type(control.SetValue) == "function", "Flag requires a value control")
    if self.Flags[flag] and self.Flags[flag] ~= control then
        warn("[VortexionUI] Replacing duplicate flag " .. flag)
    end
    self.Flags[flag] = control
    return control
end

function WindowMethods:GetFlag(flag)
    local control = self.Flags[flag]
    return control and control:GetValue() or nil
end

function WindowMethods:SetFlag(flag, value, silent)
    local control = self.Flags[flag]
    if not control then return false end
    control:SetValue(value, silent)
    return true
end

function WindowMethods:ExportConfig()
    local data = {Schema = 1, Theme = self.ThemeName, Transparency = self.Transparency, Flags = {}}
    for key, control in pairs(self.Flags) do
        data.Flags[key] = serializeValue(control:GetValue())
    end
    return HttpService:JSONEncode(data)
end

function WindowMethods:ImportConfig(jsonString, silent)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, tostring(jsonString or ""))
    if not ok or type(data) ~= "table" or data.Schema ~= 1 or type(data.Flags) ~= "table" then
        return false, "Invalid Relax UI configuration"
    end
    if type(data.Theme) == "string" and Themes[data.Theme] then
        self:SetTheme(data.Theme)
    end
    if type(data.Transparency) == "number" then self:SetTransparency(data.Transparency) end
    local imported = 0
    for key, value in pairs(data.Flags) do
        local control = self.Flags[key]
        if control then
            local decoded = deserializeValue(value)
            local success = pcall(function() control:SetValue(decoded, silent ~= false) end)
            if success then imported = imported + 1 end
        end
    end
    return true, imported
end

local function configPath(name)
    local clean = tostring(name or "default"):gsub("[^%w_%-]", "_"):sub(1, 80)
    return "RelaxUI/" .. clean .. ".json"
end

function WindowMethods:SaveConfig(name)
    local json = self:ExportConfig()
    if type(writefile) ~= "function" then return false, json end
    if type(makefolder) == "function" then pcall(makefolder, "RelaxUI") end
    local ok, err = pcall(writefile, configPath(name), json)
    if not ok then return false, tostring(err) end
    return true, json
end

function WindowMethods:LoadConfig(name, silent)
    if type(readfile) ~= "function" then return false, "readfile unsupported; use ImportConfig()" end
    local ok, data = pcall(readfile, configPath(name))
    if not ok then return false, tostring(data) end
    return self:ImportConfig(data, silent)
end

-- Register the Flag / ID / Key field for all value-style components.
for _, methodName in ipairs({
    "CreateToggle", "CreateSlider", "CreateInput", "CreateDropdown",
    "CreateKeybind", "CreateCheckbox", "CreateRadioGroup",
    "CreateCheckboxGroup", "CreateMultiDropdown", "CreateSegmentedControl",
    "CreateStepper", "CreateColorPicker", "CreateTextArea", "CreateProgressBar",
}) do
    local original = TabMethods[methodName]
    TabMethods[methodName] = function(self, config)
        local control = original(self, config)
        if type(config) == "table" then
            local flag = config.Flag or config.ID or config.Key
            if flag then self.Window:RegisterFlag(tostring(flag), control) end
        end
        return control
    end
end

-- WindUI-like naming aliases for gradual migration. The implementation remains
-- independent of WindUI and does not claim exact argument compatibility.
local aliasMap = {
    Button = "CreateButton", Toggle = "CreateToggle", Slider = "CreateSlider",
    Input = "CreateInput", Dropdown = "CreateDropdown", Keybind = "CreateKeybind",
    Colorpicker = "CreateColorPicker", ColorPicker = "CreateColorPicker",
    Paragraph = "CreateParagraph", Label = "CreateLabel",
    Section = "CreateSection", Divider = "CreateDivider",
    ProgressBar = "CreateProgressBar", Code = "CreateCode",
    Image = "CreateImage", Video = "CreateVideo", Viewport = "CreateViewport",
    TextArea = "CreateTextArea", Checkbox = "CreateCheckbox",
    CheckboxGroup = "CreateCheckboxGroup", RadioGroup = "CreateRadioGroup",
    MultiDropdown = "CreateMultiDropdown", Accordion = "CreateAccordion",
    SegmentedControl = "CreateSegmentedControl", Stepper = "CreateStepper",
    StatusCard = "CreateStatusCard", StatCard = "CreateStatCard",
    Timeline = "CreateTimeline", Badge = "CreateBadge",
    Spacer = "CreateSpacer", ChipGroup = "CreateChipGroup",
}
for alias, target in pairs(aliasMap) do
    TabMethods[alias] = TabMethods[target]
    TabMethods["Add" .. alias] = TabMethods[target]
end

return VortexionUI
