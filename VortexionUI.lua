--!nonstrict
-- VortexionUI 0.1.0 — standalone Roblox Luau UI library.
-- Runtime: LocalScript / client executor with standard Roblox Instance APIs.
-- No WindUI dependency. Glass is simulated with translucent layered surfaces;
-- Roblox ScreenGui cannot blur other ScreenGui content with CSS-style backdrop-filter.

local VortexionUI = {
    Name = "VortexionUI",
    Version = "0.1.0-r1",
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

local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 20, 24),
        Surface = Color3.fromRGB(26, 28, 33),
        SurfaceAlt = Color3.fromRGB(34, 36, 42),
        SurfaceHigh = Color3.fromRGB(45, 47, 54),
        Primary = Color3.fromRGB(190, 194, 238),
        OnPrimary = Color3.fromRGB(30, 32, 48),
        Text = Color3.fromRGB(235, 236, 241),
        SubText = Color3.fromRGB(174, 177, 187),
        Outline = Color3.fromRGB(91, 94, 105),
        Success = Color3.fromRGB(139, 205, 166),
        Warning = Color3.fromRGB(242, 197, 121),
        Error = Color3.fromRGB(242, 174, 174),
    },
    Light = {
        Background = Color3.fromRGB(244, 243, 248),
        Surface = Color3.fromRGB(250, 249, 253),
        SurfaceAlt = Color3.fromRGB(238, 237, 244),
        SurfaceHigh = Color3.fromRGB(228, 227, 236),
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

local function makeLogo(parent, size, icon)
    local root = create("Frame", {
        Name = "VortexionMark",
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parent)

    if type(icon) == "string" and icon ~= "" then
        local image = create("ImageLabel", {
            Name = "BrandImage",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = icon,
            ScaleType = Enum.ScaleType.Fit,
        }, root)
        return root, image
    end

    -- Code-drawn fallback mark: three metallic blades around a dark center.
    -- For an exact match to the supplied artwork, pass an uploaded rbxassetid:// icon.
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
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")

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
    local requestedSize = config.Size or UDim2.fromOffset(760, 500)
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
        Groups = {},
        Tabs = {},
        Controls = {},
        Overlays = {},
        Notifications = {},
        ActiveTab = nil,
        _controlOrder = 0,
        MinSize = minSize,
    }, WindowMethods)

    local gui = create("ScreenGui", {
        Name = "VortexionUI_" .. tostring(config.Name or "Window"),
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = tonumber(config.DisplayOrder) or 1000,
    }, playerGui)
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
    corner(main, 22)
    self.MainStroke = stroke(main, initialTheme.Outline, 0.42, 1)
    self.SizeConstraint = create("UISizeConstraint", {
        MinSize = Vector2.new(math.min(minSize.X, maxWidth), math.min(minSize.Y, maxHeight)),
        MaxSize = Vector2.new(maxWidth, maxHeight),
    }, main)
    self:_BindColor(main, "BackgroundColor3", "Background")
    self:_BindColor(self.MainStroke, "Color", "Outline")

    local titlebar = create("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = initialTheme.Surface,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Active = true,
    }, main)
    self.Titlebar = titlebar
    self:_BindColor(titlebar, "BackgroundColor3", "Surface")

    local logo, logoImage = makeLogo(titlebar, 28, config.Icon)
    logo.Position = UDim2.new(0, 15, 0.5, -14)
    self.Logo = logo
    self.LogoImage = logoImage

    local title = textObject(titlebar, {
        Name = "Title",
        Position = UDim2.new(0, 52, 0, 5),
        Size = UDim2.new(1, -142, 0, 22),
        Text = tostring(config.Title or config.Name or "VortexionUI"),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
    })
    self.Title = title
    addTextBinding(self, title, "TextColor3", "Text")

    local subtitle = textObject(titlebar, {
        Name = "Subtitle",
        Position = UDim2.new(0, 52, 0, 26),
        Size = UDim2.new(1, -142, 0, 15),
        Text = tostring(config.Subtitle or "Luau UI Library"),
        TextSize = 10,
    })
    self.Subtitle = subtitle
    addTextBinding(self, subtitle, "TextColor3", "SubText")

    local minimizeButton = buttonObject(titlebar, {
        Name = "Minimize",
        Position = UDim2.new(1, -74, 0.5, -15),
        Size = UDim2.fromOffset(30, 30),
        Text = "—",
        TextSize = 17,
        BackgroundColor3 = initialTheme.SurfaceAlt,
    }, titlebar)
    corner(minimizeButton, 15)
    self:_BindColor(minimizeButton, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(minimizeButton, "TextColor3", "Text")
    local closeButton = buttonObject(titlebar, {
        Name = "Close",
        Position = UDim2.new(1, -38, 0.5, -15),
        Size = UDim2.fromOffset(30, 30),
        Text = "×",
        TextSize = 18,
        BackgroundColor3 = initialTheme.SurfaceAlt,
    }, titlebar)
    corner(closeButton, 15)
    self:_BindColor(closeButton, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(closeButton, "TextColor3", "Text")
    self:_Connect(closeButton.Activated, function() self:Destroy() end)

    local body = create("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 1, -48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, main)
    self.Body = body

    local nav = create("ScrollingFrame", {
        Name = "Navigation",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 172, 1, 0),
        BackgroundColor3 = initialTheme.Surface,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageTransparency = 0.55,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, body)
    self.Navigation = nav
    self:_BindColor(nav, "BackgroundColor3", "Surface")
    local navPadding = create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, nav)
    local navLayout = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, nav)
    self.NavigationLayout = navLayout

    local contentHost = create("Frame", {
        Name = "ContentHost",
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -188, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, body)
    self.ContentHost = contentHost

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
    local navToggle = buttonObject(titlebar, {
        Name = "NavigationToggle",
        Position = UDim2.new(0, 44, 0.5, -14),
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
    nav.ZIndex = 21
    contentHost.ZIndex = 1
    self:_UpdateResponsive()

    self:_Connect(titlebar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_StartMove(input, false, main)
        end
    end)
    self:_Connect(resizeGrip.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_StartMove(input, true, main)
        end
    end)
    self:_Connect(minimizeButton.Activated, function()
        self:Minimize()
    end)

    local camera = workspace.CurrentCamera
    if camera then
        self:_Connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
            self:_FitToViewport()
            self:_UpdateResponsive()
        end)
    end
    self:_Connect(main:GetPropertyChangedSignal("AbsoluteSize"), function()
        self:_UpdateResponsive()
    end)

    if self.AnimationsEnabled then
        local scale = create("UIScale", {Scale = 0.97}, main)
        self.Scale = scale
        local tween = TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1})
        tween:Play()
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
    if self.Destroyed or not self.Main then return end
    local small = self.Main.AbsoluteSize.X < 610 or viewportSize().X < 650
    if not self.NavToggle then return end
    self.NavToggle.Visible = small
    self.Title.Position = small and UDim2.new(0, 82, 0, 5) or UDim2.new(0, 52, 0, 5)
    self.Title.Size = small and UDim2.new(1, -172, 0, 22) or UDim2.new(1, -142, 0, 22)
    self.Subtitle.Position = small and UDim2.new(0, 82, 0, 26) or UDim2.new(0, 52, 0, 26)
    self.Subtitle.Size = small and UDim2.new(1, -172, 0, 15) or UDim2.new(1, -142, 0, 15)
    if small then
        self.Navigation.Visible = self._mobileDrawerOpen
        self.Navigation.Size = UDim2.new(0, math.min(215, math.max(168, self.Main.AbsoluteSize.X - 40)), 1, 0)
        self.Navigation.Position = UDim2.fromOffset(0, 0)
        self.ContentHost.Position = UDim2.fromOffset(0, 0)
        self.ContentHost.Size = UDim2.fromScale(1, 1)
    else
        self._mobileDrawerOpen = false
        self.Navigation.Visible = true
        self.Navigation.Size = UDim2.new(0, 172, 1, 0)
        self.ContentHost.Position = UDim2.fromOffset(180, 0)
        self.ContentHost.Size = UDim2.new(1, -188, 1, 0)
    end
    self._narrowLayout = small
end

function WindowMethods:_FitToViewport()
    if self.Destroyed or not self.Main then return end
    local vp = viewportSize()
    local maxWidth = math.max(260, vp.X - 20)
    local maxHeight = math.max(240, vp.Y - 20)
    self.SizeConstraint.MaxSize = Vector2.new(maxWidth, maxHeight)
    self.SizeConstraint.MinSize = Vector2.new(math.min(self.MinSize.X, maxWidth), math.min(self.MinSize.Y, maxHeight))
    local size = self.Main.AbsoluteSize
    local width = math.clamp(size.X, math.min(self.MinSize.X, maxWidth), maxWidth)
    local height = math.clamp(size.Y, math.min(self.MinSize.Y, maxHeight), maxHeight)
    self.Main.Size = UDim2.fromOffset(width, height)
    local pos = self.Main.AbsolutePosition
    local x = math.clamp(pos.X, 8, math.max(8, vp.X - width - 8))
    local y = math.clamp(pos.Y, 8, math.max(8, vp.Y - height - 8))
    self.Main.Position = UDim2.fromOffset(x + width / 2, y + height / 2)
end

function WindowMethods:_StartMove(input, resizing, target)
    if self.Destroyed then return end
    local startPosition = input.Position
    local startAbsolute = target.AbsolutePosition
    local startSize = target.AbsoluteSize
    local inputType = input.UserInputType
    local moved = false
    local moveConnection, endConnection
    local function finish()
        if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
        if endConnection then endConnection:Disconnect(); endConnection = nil end
    end
    moveConnection = UserInputService.InputChanged:Connect(function(changed)
        local isMove = (inputType == Enum.UserInputType.Touch and changed == input)
            or (inputType == Enum.UserInputType.MouseButton1 and changed.UserInputType == Enum.UserInputType.MouseMovement)
        if not isMove then return end
        local delta = changed.Position - startPosition
        if math.abs(delta.X) + math.abs(delta.Y) > 2 then moved = true end
        if resizing then
            self:SetSize(startSize.X + delta.X, startSize.Y + delta.Y)
        else
            local vp = viewportSize()
            local size = target.AbsoluteSize
            local x = math.clamp(startAbsolute.X + delta.X, 8, math.max(8, vp.X - size.X - 8))
            local y = math.clamp(startAbsolute.Y + delta.Y, 8, math.max(8, vp.Y - size.Y - 8))
            target.Position = UDim2.fromOffset(x + size.X * target.AnchorPoint.X, y + size.Y * target.AnchorPoint.Y)
        end
    end)
    endConnection = UserInputService.InputEnded:Connect(function(ended)
        local isEnd = (inputType == Enum.UserInputType.Touch and ended == input)
            or (inputType == Enum.UserInputType.MouseButton1 and ended.UserInputType == Enum.UserInputType.MouseButton1)
        if isEnd then finish() end
    end)
    table.insert(self._transientConnections, moveConnection)
    table.insert(self._transientConnections, endConnection)
    if target == self.Launcher then
        self._launcherMoved = false
        self._launcherMoveConnection = moveConnection
        local originalMove = moveConnection
        local checkConnection
        checkConnection = UserInputService.InputChanged:Connect(function(changed)
            local isMove = (inputType == Enum.UserInputType.Touch and changed == input)
                or (inputType == Enum.UserInputType.MouseButton1 and changed.UserInputType == Enum.UserInputType.MouseMovement)
            if isMove then
                local delta = changed.Position - startPosition
                if math.abs(delta.X) + math.abs(delta.Y) > 5 then self._launcherMoved = true end
            end
        end)
        local originalFinish = finish
        finish = function()
            originalFinish()
            if checkConnection then checkConnection:Disconnect(); checkConnection = nil end
            if self._launcherMoveConnection == originalMove then self._launcherMoveConnection = nil end
        end
        endConnection:Disconnect()
        endConnection = UserInputService.InputEnded:Connect(function(ended)
            local isEnd = (inputType == Enum.UserInputType.Touch and ended == input)
                or (inputType == Enum.UserInputType.MouseButton1 and ended.UserInputType == Enum.UserInputType.MouseButton1)
            if isEnd then finish() end
        end)
    end
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
    self.AnimationsEnabled = enabled == true
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

function WindowMethods:_RefreshNavigation()
    for _, group in ipairs(self.Groups) do
        group.Header.BackgroundColor3 = self.Theme.SurfaceAlt
        group.Header.TextColor3 = self.Theme.SubText
        group.Chevron.TextColor3 = self.Theme.SubText
    end
    for _, tab in ipairs(self.Tabs) do
        local selected = self.ActiveTab == tab
        tab.Button.BackgroundColor3 = selected and self.Theme.Primary or self.Theme.SurfaceAlt
        tab.Button.BackgroundTransparency = selected and 0.82 or 1
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
        BackgroundTransparency = 0.25,
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
    local tabsContainer = create("Frame", {
        Name = "Tabs",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = options.Collapsed ~= true,
        LayoutOrder = 2,
    }, groupFrame)
    create("UIListLayout", {
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
        Tabs = {},
        Collapsed = options.Collapsed == true,
    }, GroupMethods)
    table.insert(self.Groups, group)
    self:_BindColor(header, "BackgroundColor3", "SurfaceAlt")
    self:_BindColor(header, "TextColor3", "SubText")
    self:_BindColor(chevron, "TextColor3", "SubText")
    self:_Connect(header.Activated, function()
        group:SetCollapsed(not group.Collapsed)
    end)
    return group
end

function GroupMethods:SetCollapsed(collapsed)
    self.Collapsed = collapsed == true
    self.TabsContainer.Visible = not self.Collapsed
    self.Chevron.Text = self.Collapsed and "›" or "⌄"
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
        Text = (options.IconText and tostring(options.IconText) .. "   " or "•   ") .. tostring(title or "Tab"),
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
    }, self.ContentHost)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, page)
    create("UIListLayout", {
        Padding = UDim.new(0, 4),
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
    for _, tab in ipairs(self.Window.Tabs) do
        tab.Page.Visible = tab == self
    end
    self.Window.ActiveTab = self
    if self.Group.Collapsed then self.Group:SetCollapsed(false) end
    self.Window._mobileDrawerOpen = false
    self.Window:_UpdateResponsive()
    self.Window:_RefreshNavigation()
end

function TabMethods:_NextOrder()
    self.Order = self.Order + 1
    return self.Order
end

function TabMethods:_Row(height, automatic)
    local row = create("Frame", {
        Name = "ControlRow",
        Size = automatic and UDim2.new(1, -4, 0, 0) or UDim2.new(1, -4, 0, height),
        AutomaticSize = automatic and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = self:_NextOrder(),
    }, self.Page)
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
    local row = self:_Row(30, false)
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
    local row = self:_Row(12, false)
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
    local row = self:_Row(36, false)
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
    local row = self:_Row(62, false)
    local title = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 8),
        Size = UDim2.new(1, -132, 0, 21),
        Text = tostring(config.Title or config.Name or "Button"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local description = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 30),
        Size = UDim2.new(1, -132, 0, 20),
        Text = tostring(config.Description or ""),
        TextSize = 10,
    }, "SubText")
    local button = buttonObject(row, {
        Position = UDim2.new(1, -112, 0.5, -16),
        Size = UDim2.fromOffset(108, 32),
        Text = tostring(config.ButtonText or "Run"),
        TextSize = 12,
        BackgroundColor3 = self.Window.Theme.Primary,
        TextColor3 = self.Window.Theme.OnPrimary,
    })
    corner(button, 16)
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
    local row = self:_Row(60, false)
    local title = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 8),
        Size = UDim2.new(1, -72, 0, 21),
        Text = tostring(config.Title or config.Name or "Toggle"),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
    }, "Text")
    local description = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 30),
        Size = UDim2.new(1, -72, 0, 18),
        Text = tostring(config.Description or ""),
        TextSize = 10,
    }, "SubText")
    local switch = buttonObject(row, {
        Name = "Switch",
        Position = UDim2.new(1, -52, 0.5, -12),
        Size = UDim2.fromOffset(44, 24),
        BackgroundColor3 = self.Window.Theme.SurfaceHigh,
        Text = "",
    })
    corner(switch, 14)
    local thumb = create("Frame", {
        Name = "Thumb",
        Position = UDim2.new(0, 3, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = self.Window.Theme.SubText,
        BorderSizePixel = 0,
    }, switch)
    corner(thumb, 8)
    self.Window:_BindColor(switch, "BackgroundColor3", "SurfaceHigh")
    self.Window:_BindColor(thumb, "BackgroundColor3", "SubText")
    local value = config.Default == true
    local control = {Value = value}
    local function render(animate)
        local targetPos = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetColor = value and self.Window.Theme.Primary or self.Window.Theme.SubText
        local trackColor = value and self.Window.Theme.Primary or self.Window.Theme.SurfaceHigh
        if animate and self.Window.AnimationsEnabled then
            TweenService:Create(thumb, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
            TweenService:Create(switch, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = trackColor}):Play()
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
    control:Set = control.SetValue
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
    local row = self:_Row(78, false)
    local title = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 4),
        Size = UDim2.new(1, -80, 0, 20),
        Text = tostring(config.Title or config.Name or "Slider"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local valueLabel = self:_Label(row, {
        Position = UDim2.new(1, -74, 0, 4),
        Size = UDim2.fromOffset(72, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(config.Default == nil and minValue or config.Default) .. tostring(config.Suffix or ""),
        TextSize = 12,
    }, "SubText")
    local track = buttonObject(row, {
        Position = UDim2.new(0, 2, 0, 39),
        Size = UDim2.new(1, -4, 0, 20),
        BackgroundTransparency = 1,
        Text = "",
    })
    local rail = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 4),
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
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = self.Window.Theme.Primary,
        BorderSizePixel = 0,
    }, rail)
    corner(knob, 7)
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
        for _, connection in ipairs(dragConnections) do connection:Disconnect() end
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
        sliding = true
        updateFromX(input.Position.X)
        table.insert(dragConnections, UserInputService.InputChanged:Connect(function(changed)
            if sliding and (changed.UserInputType == input.UserInputType or (input.UserInputType == Enum.UserInputType.MouseButton1 and changed.UserInputType == Enum.UserInputType.MouseMovement)) then
                updateFromX(changed.Position.X)
            end
        end))
        table.insert(dragConnections, UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType == input.UserInputType then stopSliding() end
        end))
        for _, connection in ipairs(dragConnections) do table.insert(self.Window._transientConnections, connection) end
    end)
    render()
    return control
end

function TabMethods:CreateInput(config)
    config = config or {}
    local row = self:_Row(78, false)
    local title = self:_Label(row, {
        Position = UDim2.new(0, 2, 0, 3),
        Size = UDim2.new(1, -4, 0, 19),
        Text = tostring(config.Title or config.Name or "Input"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    }, "Text")
    local box = create("TextBox", {
        Name = "Input",
        Position = UDim2.new(0, 0, 0, 27),
        Size = UDim2.new(1, 0, 0, 42),
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
        Size = UDim2.new(1, 0, 0, 38),
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
        BackgroundTransparency = 0.08,
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
    if self.AnimationsEnabled and self.Main then
        local scale = self.Main:FindFirstChildOfClass("UIScale")
        if scale then
            scale.Scale = 0.97
            TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
        end
    end
end

function WindowMethods:Toggle()
    if self.Minimized then self:Restore() else self:Minimize() end
end

function WindowMethods:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
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

return VortexionUI
