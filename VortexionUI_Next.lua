--!nonstrict
-- VortexionUI Next / Clean Room - Step 1
-- Independent native Roblox Luau implementation.
-- Visual references: Cascade, WindUI, Starlight (no third-party code copied).
-- Strict executor mount: gethui(). No implicit PlayerGui fallback.

local UI = {Name = "VortexionUI Next", Version = "0.1.0-rebuild-step1"}
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local C = {
    Window = Color3.fromRGB(22, 23, 27),
    Header = Color3.fromRGB(31, 32, 37),
    Sidebar = Color3.fromRGB(36, 43, 54),
    SidebarLow = Color3.fromRGB(31, 37, 47),
    Panel = Color3.fromRGB(29, 30, 35),
    Row = Color3.fromRGB(38, 39, 45),
    RowHover = Color3.fromRGB(46, 47, 54),
    Text = Color3.fromRGB(245, 246, 248),
    Muted = Color3.fromRGB(160, 163, 174),
    Faint = Color3.fromRGB(116, 120, 131),
    Line = Color3.fromRGB(70, 74, 83),
    Accent = Color3.fromRGB(76, 145, 242),
    AccentLow = Color3.fromRGB(34, 77, 133),
    Inverse = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(101, 211, 163),
}
local IconURL = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/assets/vortexion-mark.png"
local Window = {}
Window.__index = Window
local Group = {}
Group.__index = Group
local Tab = {}
Tab.__index = Tab

local function new(className, parent, props)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end
local function round(parent, radius)
    return new("UICorner", parent, {CornerRadius = UDim.new(0, radius)})
end
local function border(parent, color, alpha, thickness)
    return new("UIStroke", parent, {Color = color or C.Line, Transparency = alpha or 0.5, Thickness = thickness or 1})
end
local function label(parent, text, props)
    local p = {
        Text = tostring(text or ""),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = C.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BorderSizePixel = 0,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return new("TextLabel", parent, p)
end
local function button(parent, text, props)
    local p = {
        Text = tostring(text or ""),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = C.Text,
        BackgroundColor3 = C.Row,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Active = true,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return new("TextButton", parent, p)
end
local function viewport()
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(900, 570)
end
local function hiddenParent(config)
    if config.GuiParent then
        assert(typeof(config.GuiParent) == "Instance", "GuiParent must be Instance")
        return config.GuiParent
    end
    assert(type(gethui) == "function", "[VortexionUI Next] gethui() not available")
    local ok, root = pcall(gethui)
    assert(ok and typeof(root) == "Instance", "[VortexionUI Next] gethui() must return an Instance")
    return root
end
local function safeCall(callback, ...)
    if type(callback) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(callback, table.unpack(args, 1, args.n))
        if not ok then warn("[VortexionUI Next] callback: " .. tostring(err)) end
    end)
end

local function resolveLogo()
    local ok, asset = pcall(function()
        local filename = "RelaxUI/vortexion-mark.png"
        local loader = type(getcustomasset) == "function" and getcustomasset
            or type(getsynasset) == "function" and getsynasset
        if type(loader) ~= "function" then return nil end
        if type(isfile) == "function" and isfile(filename) then
            return loader(filename)
        end
        if type(writefile) ~= "function" then return nil end
        local bytes = game:HttpGet(IconURL)
        if type(bytes) ~= "string" or #bytes < 16 then return nil end
        if type(makefolder) == "function" then pcall(makefolder, "RelaxUI") end
        writefile(filename, bytes)
        return loader(filename)
    end)
    return ok and type(asset) == "string" and asset or nil
end
local function logo(parent, size)
    local holder = new("Frame", parent, {Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, BorderSizePixel = 0})
    local fallback = label(holder, "V", {
        Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = math.floor(size * 0.56),
        TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Color3.fromRGB(224, 228, 239),
    })
    local img = new("ImageLabel", holder, {
        Name = "VortexionMark", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Visible = false,
    })
    return holder, img, fallback
end

function UI.CreateWindow(cfg)
    cfg = cfg or {}
    local parent = hiddenParent(cfg)
    local vp = viewport()
    local w = math.min(tonumber(cfg.Width) or 790, math.max(300, vp.X - 20))
    local h = math.min(tonumber(cfg.Height) or 492, math.max(280, vp.Y - 20))
    local self = setmetatable({
        Destroyed = false, Minimized = false, DrawerOpen = false,
        Connections = {}, Groups = {}, Tabs = {}, ActiveTab = nil, Drag = nil, Slider = nil,
        Animations = cfg.Animations ~= false, _tweens = {}, Width = w, Height = h,
        MinWidth = math.min(350, math.max(300, vp.X - 20)),
        MinHeight = math.min(300, math.max(260, vp.Y - 20)),
        LogoURL = cfg.IconURL or IconURL,
    }, Window)

    local gui = new("ScreenGui", parent, {
        Name = "Vortexion_Next_Step1",
        ResetOnSpawn = false, IgnoreGuiInset = false,
        DisplayOrder = tonumber(cfg.DisplayOrder) or 990,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = true,
    })
    self.Gui = gui

    local main = new("Frame", gui, {
        Name = "VortexionWindow",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(w, h),
        BackgroundColor3 = C.Window,
        BackgroundTransparency = math.clamp(tonumber(cfg.Transparency) or 0.12, 0, 0.38),
        BorderSizePixel = 0, ClipsDescendants = true, Active = true,
    })
    self.Main = main
    round(main, 15)
    border(main, Color3.fromRGB(92, 96, 110), 0.53, 1)

    -- Cascade-inspired spatial organization: a stable, blue-charcoal sidebar
    -- and an independent content titlebar, not a generic list of oversized cards.
    local content = new("Frame", main, {
        Name = "Content", Position = UDim2.fromOffset(194, 0),
        Size = UDim2.new(1, -194, 1, 0),
        BackgroundColor3 = C.Window, BackgroundTransparency = 0.07,
        BorderSizePixel = 0, ZIndex = 1,
    })
    self.Content = content
    local header = new("Frame", content, {
        Name = "Toolbar", Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = C.Header, BackgroundTransparency = 0.10,
        BorderSizePixel = 0, Active = true,
    })
    self.Header = header
    new("Frame", header, {
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.Line, BackgroundTransparency = 0.72, BorderSizePixel = 0,
    })
    local title = label(header, cfg.Title or "VortexionLua", {
        Position = UDim2.fromOffset(19, 10), Size = UDim2.new(1, -154, 0, 22),
        Font = Enum.Font.GothamSemibold, TextSize = 16,
    })
    local subtitle = label(header, cfg.Subtitle or "Relax UI · Next", {
        Position = UDim2.fromOffset(19, 32), Size = UDim2.new(1, -154, 0, 16),
        TextSize = 11, TextColor3 = C.Muted,
    })

    local function chrome(text, offset)
        local b = button(header, text, {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offset, 0.5, 0),
            Size = UDim2.fromOffset(30, 30), BackgroundColor3 = C.Row,
            BackgroundTransparency = 0.5, TextSize = 17,
        })
        round(b, 10)
        return b
    end
    local minimize = chrome("−", -77)
    local maximize = chrome("□", -44)
    local exit = chrome("×", -11)

    local pages = new("Frame", content, {
        Name = "Pages", Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(1, 0, 1, -58),
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    })
    self.Pages = pages

    local scrim = button(main, "", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.38, Visible = false, ZIndex = 4,
    })
    self.Scrim = scrim

    local sidebar = new("Frame", main, {
        Name = "NavigationRail", Size = UDim2.new(0, 194, 1, 0),
        BackgroundColor3 = C.Sidebar, BackgroundTransparency = 0.04,
        BorderSizePixel = 0, ZIndex = 5,
    })
    self.Sidebar = sidebar
    new("UIGradient", sidebar, {Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.Sidebar),
        ColorSequenceKeypoint.new(1, C.SidebarLow),
    })})
    local brandArea = new("Frame", sidebar, {
        Name = "Brand", Size = UDim2.new(1, 0, 0, 63),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    local brandLogo, brandImage, brandFallback = logo(brandArea, 34)
    brandLogo.Position = UDim2.fromOffset(15, 14)
    self.BrandImage, self.BrandFallback = brandImage, brandFallback
    label(brandArea, "VortexionLua", {
        Position = UDim2.fromOffset(55, 13), Size = UDim2.new(1, -61, 0, 21),
        Font = Enum.Font.GothamSemibold, TextSize = 13,
    })
    label(brandArea, "INTERFACE", {
        Position = UDim2.fromOffset(55, 35), Size = UDim2.new(1, -61, 0, 14),
        Font = Enum.Font.GothamMedium, TextSize = 9, TextColor3 = C.Muted,
    })
    local search = new("TextBox", sidebar, {
        Name = "Search", Position = UDim2.fromOffset(13, 70),
        Size = UDim2.new(1, -26, 0, 31),
        BackgroundColor3 = Color3.fromRGB(17, 22, 29),
        BackgroundTransparency = 0.38, BorderSizePixel = 0,
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Text,
        PlaceholderText = "Search pages", PlaceholderColor3 = C.Muted,
        ClearTextOnFocus = false, Text = "", TextXAlignment = Enum.TextXAlignment.Left,
    })
    round(search, 8)
    border(search, C.Line, 0.68, 1)
    new("UIPadding", search, {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 8)})
    self.Search = search
    local navScroll = new("ScrollingFrame", sidebar, {
        Name = "Navigation", Position = UDim2.fromOffset(0, 113),
        Size = UDim2.new(1, 0, 1, -174),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.Faint,
        ScrollBarImageTransparency = 0.35,
        CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    self.NavScroll = navScroll
    new("UIPadding", navScroll, {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 13), PaddingBottom = UDim.new(0, 12)})
    new("UIListLayout", navScroll, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

    new("Frame", sidebar, {
        Position = UDim2.new(0, 13, 1, -59), Size = UDim2.new(1, -26, 0, 1),
        BackgroundColor3 = C.Line, BackgroundTransparency = 0.58, BorderSizePixel = 0,
    })
    label(sidebar, "●  Interface ready", {
        Position = UDim2.new(0, 14, 1, -52), Size = UDim2.new(1, -28, 0, 22),
        TextSize = 11, TextColor3 = C.Green,
    })
    label(sidebar, "Clean-room preview • Step 1", {
        Position = UDim2.new(0, 14, 1, -29), Size = UDim2.new(1, -28, 0, 16),
        TextSize = 9, TextColor3 = C.Muted,
    })

    local menu = button(header, "≡", {
        Position = UDim2.fromOffset(6, 13), Size = UDim2.fromOffset(32, 32),
        BackgroundTransparency = 1, TextSize = 21, Visible = false,
    })
    self.Menu = menu
    local resize = button(main, "◢", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -5, 1, -5),
        Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1,
        TextSize = 15, TextColor3 = C.Muted, ZIndex = 6,
    })
    self.Resize = resize

    -- Minimized state: only the mark is visible and the launcher is reusable.
    local launcher = button(gui, "", {
        Name = "MarkLauncher", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(58, 58),
        BackgroundTransparency = 1, Visible = false, ZIndex = 30,
    })
    local launchLogo, launchImage, launchFallback = logo(launcher, 51)
    launchLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    launchLogo.Position = UDim2.fromScale(0.5, 0.5)
    self.Launcher, self.LaunchImage, self.LaunchFallback = launcher, launchImage, launchFallback

    local scale = new("UIScale", main, {Scale = self.Animations and 0.96 or 1})
    self.Scale = scale
    if self.Animations then
        local t = TweenService:Create(scale, TweenInfo.new(0.23, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1})
        t:Play()
    end

    self:_connect(minimize.Activated, function() self:Minimize() end)
    self:_connect(exit.Activated, function() self:Destroy() end)
    self:_connect(maximize.Activated, function() self:Maximize() end)
    self:_connect(menu.Activated, function()
        self.DrawerOpen = not self.DrawerOpen; self:_layout()
    end)
    self:_connect(scrim.Activated, function()
        self.DrawerOpen = false; self:_layout()
    end)
    self:_connect(search:GetPropertyChangedSignal("Text"), function()
        self:_filter(search.Text)
    end)
    self:_connect(launcher.Activated, function()
        if not self._dragMoved then self:Restore() end
    end)

    self:_connect(header.InputBegan, function(input)
        local typ = input.UserInputType
        if typ ~= Enum.UserInputType.Touch and typ ~= Enum.UserInputType.MouseButton1 then return end
        local x = input.Position.X - header.AbsolutePosition.X
        if x > header.AbsoluteSize.X - 124 then return end
        if menu.Visible and x < 44 then return end
        self:_beginDrag(input, "move", main)
    end)
    self:_connect(resize.InputBegan, function(input)
        local typ = input.UserInputType
        if typ == Enum.UserInputType.Touch or typ == Enum.UserInputType.MouseButton1 then
            self:_beginDrag(input, "resize", main)
        end
    end)
    self:_connect(launcher.InputBegan, function(input)
        local typ = input.UserInputType
        if typ == Enum.UserInputType.Touch or typ == Enum.UserInputType.MouseButton1 then
            self._dragMoved = false
            self:_beginDrag(input, "launcher", launcher)
        end
    end)
    self:_connect(UIS.InputChanged, function(input)
        self:_pointerMove(input)
    end)
    self:_connect(UIS.InputEnded, function(input)
        self:_pointerEnd(input)
    end)
    self:_connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
        self:_attachCamera()
        self:_layout()
    end)
    self:_attachCamera()
    self:_layout()
    task.spawn(function()
        local asset = resolveLogo()
        if self.Destroyed or not asset then return end
        for _, pair in ipairs({{self.BrandImage, self.BrandFallback}, {self.LaunchImage, self.LaunchFallback}}) do
            if pair[1] and pair[1].Parent then
                pair[1].Image = asset
                pair[1].Visible = true
                pair[2].Visible = false
            end
        end
    end)
    return self
end

function Window:_connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(self.Connections, c)
    return c
end

function Window:_attachCamera()
    if self.CameraConnection then self.CameraConnection:Disconnect(); self.CameraConnection = nil end
    local cam = workspace.CurrentCamera
    if cam then
        self.CameraConnection = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not self.Destroyed then
                task.defer(function() if not self.Destroyed then self:_layout(true) end end)
            end
        end)
    end
end

function Window:_layout(fit)
    if self.Destroyed then return end
    local v = viewport()
    if fit then
        self.Width = math.clamp(self.Width, math.min(self.MinWidth, v.X - 12), math.max(280, v.X - 12))
        self.Height = math.clamp(self.Height, math.min(self.MinHeight, v.Y - 12), math.max(260, v.Y - 12))
        self.Main.Size = UDim2.fromOffset(self.Width, self.Height)
        local old = self.Main.AbsolutePosition
        local x = math.clamp(old.X, 5, math.max(5, v.X - self.Width - 5))
        local y = math.clamp(old.Y, 5, math.max(5, v.Y - self.Height - 5))
        self.Main.Position = UDim2.fromOffset(x + self.Width / 2, y + self.Height / 2)
    end
    local compact = self.Width < 620 or v.X < 680
    self.Menu.Visible = compact
    self.Title = self.Title or nil
    if compact then
        self.Sidebar.Size = UDim2.new(0, math.min(212, self.Width - 42), 1, 0)
        self.Sidebar.Visible = self.DrawerOpen
        self.Scrim.Visible = self.DrawerOpen
        self.Content.Position = UDim2.fromOffset(0, 0)
        self.Content.Size = UDim2.fromScale(1, 1)
        -- Make room for the mobile navigation affordance.
        self.Header:FindFirstChildWhichIsA("TextLabel").Position = UDim2.fromOffset(44, 10)
    else
        self.DrawerOpen = false
        self.Scrim.Visible = false
        self.Sidebar.Visible = true
        self.Sidebar.Size = UDim2.new(0, 194, 1, 0)
        self.Content.Position = UDim2.fromOffset(194, 0)
        self.Content.Size = UDim2.new(1, -194, 1, 0)
        self.Header:FindFirstChildWhichIsA("TextLabel").Position = UDim2.fromOffset(19, 10)
    end
    if self.Launcher.Visible then
        local lp = self.Launcher.AbsolutePosition
        local sz = self.Launcher.AbsoluteSize
        local x = math.clamp(lp.X + sz.X / 2, 30, math.max(30, v.X - 30))
        local y = math.clamp(lp.Y + sz.Y / 2, 30, math.max(30, v.Y - 30))
        self.Launcher.Position = UDim2.fromOffset(x, y)
    end
end

function Window:_beginDrag(input, kind, target)
    self.Drag = {
        Pointer = input, Kind = kind, Target = target,
        Origin = input.Position, WindowPosition = target.AbsolutePosition,
        WindowSize = target.AbsoluteSize, Moved = false,
    }
end
local function pointerMatches(active, input)
    if not active then return false end
    local typ = active.Pointer.UserInputType
    return (typ == Enum.UserInputType.Touch and input == active.Pointer)
        or (typ == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
end
function Window:_pointerMove(input)
    if self.Destroyed then return end
    local d = self.Drag
    if d and pointerMatches(d, input) then
        local delta = input.Position - d.Origin
        if delta.Magnitude < 5 and not d.Moved then return end
        d.Moved = true
        if d.Kind == "launcher" then self._dragMoved = true end
        if d.Kind == "resize" then
            local vp = viewport()
            self.Width = math.clamp(math.floor(d.WindowSize.X + delta.X), self.MinWidth, math.max(self.MinWidth, vp.X - 12))
            self.Height = math.clamp(math.floor(d.WindowSize.Y + delta.Y), self.MinHeight, math.max(self.MinHeight, vp.Y - 12))
            self.Main.Size = UDim2.fromOffset(self.Width, self.Height)
            self.Main.Position = UDim2.fromOffset(d.WindowPosition.X + self.Width / 2, d.WindowPosition.Y + self.Height / 2)
            self:_layout()
        else
            local vp = viewport()
            local sz = d.Target.AbsoluteSize
            local nx = math.clamp(d.WindowPosition.X + delta.X, 5, math.max(5, vp.X - sz.X - 5))
            local ny = math.clamp(d.WindowPosition.Y + delta.Y, 5, math.max(5, vp.Y - sz.Y - 5))
            d.Target.Position = UDim2.fromOffset(nx + sz.X / 2, ny + sz.Y / 2)
        end
    end
    local slider = self.Slider
    if slider and pointerMatches(slider, input) then
        slider.Update(input.Position.X)
    end
end
function Window:_pointerEnd(input)
    local drag = self.Drag
    if drag and ((drag.Pointer.UserInputType == Enum.UserInputType.Touch and input == drag.Pointer)
        or (drag.Pointer.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then
        self.Drag = nil
    end
    local slider = self.Slider
    if slider and ((slider.Pointer.UserInputType == Enum.UserInputType.Touch and input == slider.Pointer)
        or (slider.Pointer.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then
        self.Slider = nil
    end
end
function Window:Minimize()
    if self.Destroyed or self.Minimized then return end
    self.Minimized = true
    local pos = self.Main.AbsolutePosition
    local sz = self.Main.AbsoluteSize
    self.Launcher.Position = UDim2.fromOffset(pos.X + sz.X / 2, pos.Y + sz.Y / 2)
    self.Main.Visible = false
    self.Launcher.Visible = true
end
function Window:Restore()
    if self.Destroyed or not self.Minimized then return end
    self.Minimized = false
    self.Drag = nil
    self.Launcher.Visible = false
    self.Main.Visible = true
    self.Scale.Scale = self.Animations and 0.96 or 1
    if self.Animations then
        TweenService:Create(self.Scale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end
function Window:Maximize()
    if self.Destroyed then return end
    if self._previousSize then
        self.Width, self.Height = self._previousSize.X, self._previousSize.Y
        self._previousSize = nil
    else
        self._previousSize = Vector2.new(self.Width, self.Height)
        local vp = viewport()
        self.Width = math.max(self.MinWidth, vp.X - 16)
        self.Height = math.max(self.MinHeight, vp.Y - 16)
    end
    self.Main.Size = UDim2.fromOffset(self.Width, self.Height)
    self.Main.Position = UDim2.fromScale(0.5, 0.5)
    self:_layout(true)
end
function Window:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self.CameraConnection then self.CameraConnection:Disconnect() end
    for _, c in ipairs(self.Connections) do c:Disconnect() end
    table.clear(self.Connections)
    self.Drag, self.Slider = nil, nil
    if self.Gui then self.Gui:Destroy() end
end
function Window:Notify(config)
    config = config or {}
    if self.Destroyed then return end
    local frame = new("Frame", self.Gui, {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 70),
        Size = UDim2.fromOffset(286, 61), BackgroundColor3 = C.Header,
        BorderSizePixel = 0, ZIndex = 100,
    })
    round(frame, 11); border(frame, C.Line, 0.5)
    label(frame, config.Title or "Relax UI", {Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1,-24,0,20), Font=Enum.Font.GothamSemibold, TextSize=12})
    label(frame, config.Content or "Action complete", {Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1,-24,0,25), TextSize=11, TextWrapped=true, TextColor3=C.Muted})
    task.delay(tonumber(config.Duration) or 3, function() if frame.Parent then frame:Destroy() end end)
end

function Window:_filter(text)
    local q = string.lower(tostring(text or ""))
    for _, tab in ipairs(self.Tabs) do
        tab.NavButton.Visible = (q == "" or string.find(string.lower(tab.Title), q, 1, true) ~= nil)
    end
    for _, group in ipairs(self.Groups) do
        if q ~= "" then group:SetExpanded(true, true) end
        group:_measure()
    end
end
function Window:_select(tab)
    if self.Destroyed or self.ActiveTab == tab then return end
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        self.ActiveTab.NavButton.BackgroundTransparency = 1
        self.ActiveTab.NavButton.TextColor3 = C.Muted
        self.ActiveTab.Indicator.Visible = false
    end
    self.ActiveTab = tab
    local parent = tab.ParentGroup
    while parent do parent:SetExpanded(true, true); parent = parent.ParentGroup end
    tab.Page.Visible = true
    tab.Page.CanvasPosition = Vector2.zero
    tab.NavButton.BackgroundColor3 = C.AccentLow
    tab.NavButton.BackgroundTransparency = 0.18
    tab.NavButton.TextColor3 = C.Text
    tab.Indicator.Visible = true
    if self.Animations then
        tab.PageScale.Scale = 0.983
        TweenService:Create(tab.PageScale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
    self.DrawerOpen = false
    self:_layout()
end

function Window:CreateTabGroup(name, opts)
    opts = opts or {}
    local parentGroup = opts.Parent
    local parentContainer = parentGroup and parentGroup.Items or self.NavScroll
    local group = setmetatable({
        Window = self, Name = tostring(name or "Group"), ParentGroup = parentGroup,
        Depth = parentGroup and (parentGroup.Depth + 1) or 0, Expanded = opts.Collapsed ~= true,
        Tabs = {}, Groups = {},
    }, Group)
    local holder = new("Frame", parentContainer, {
        Name = "Group_" .. group.Name, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0,
        LayoutOrder = parentGroup and (#parentGroup.Tabs + #parentGroup.Groups + 1) or (#self.Groups + 1),
    })
    group.Holder = holder
    new("UIListLayout", holder, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)})
    local header = button(holder, group.Name, {
        Name = "GroupTitle", Size = UDim2.new(1, 0, 0, 29),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, TextColor3 = C.Muted, BackgroundTransparency = 1, LayoutOrder = 1,
    })
    new("UIPadding", header, {PaddingLeft = UDim.new(0, 8)})
    group.Header = header
    local arrow = label(header, group.Expanded and "⌄" or "›", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -7, 0.5, 0),
        Size = UDim2.fromOffset(16, 23), TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 15, TextColor3 = C.Muted,
    })
    group.Arrow = arrow
    local viewportFrame = new("Frame", holder, {
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
        ClipsDescendants = true, BorderSizePixel = 0, LayoutOrder = 2,
    })
    group.Clip = viewportFrame
    local items = new("Frame", viewportFrame, {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    group.Items = items
    local list = new("UIListLayout", items, {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder})
    group.Layout = list
    group.Holder.Visible = true
    self:_connect(list:GetPropertyChangedSignal("AbsoluteContentSize"), function() group:_measure() end)
    self:_connect(header.Activated, function() group:SetExpanded(not group.Expanded) end)
    table.insert(self.Groups, group)
    if parentGroup then table.insert(parentGroup.Groups, group) end
    task.defer(function() if not self.Destroyed then group:_measure() end end)
    return group
end
function Group:_measure()
    if self.Window.Destroyed then return end
    local desired = self.Layout.AbsoluteContentSize.Y
    if not self.Expanded then desired = 0 end
    if not self.Window.Animations then
        self.Clip.Size = UDim2.new(1, 0, 0, desired)
    elseif not self._animating then
        self.Clip.Size = UDim2.new(1, 0, 0, desired)
    end
    if self.ParentGroup then self.ParentGroup:_measure() end
end
function Group:SetExpanded(value, immediate)
    local expanded = value == true
    if self.Expanded == expanded and not immediate then return end
    self.Expanded = expanded
    self.Arrow.Text = expanded and "⌄" or "›"
    local h = expanded and self.Layout.AbsoluteContentSize.Y or 0
    if self.Tween then self.Tween:Cancel(); self.Tween:Destroy(); self.Tween = nil end
    if immediate or not self.Window.Animations then
        self.Clip.Size = UDim2.new(1, 0, 0, h)
    else
        self._animating = true
        local t = TweenService:Create(self.Clip, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,h)})
        self.Tween = t
        t.Completed:Once(function()
            if self.Tween == t then
                self.Tween = nil
                self._animating = false
                t:Destroy()
                self:_measure()
            end
        end)
        t:Play()
    end
    if self.ParentGroup then self.ParentGroup:_measure() end
end
function Group:CreateGroup(name, options)
    options = options or {}
    options.Parent = self
    return self.Window:CreateTabGroup(name, options)
end
Group.CreateSubGroup = Group.CreateGroup
function Group:CreateTab(name, options)
    options = options or {}
    local win = self.Window
    local title = tostring(name or "Page")
    local nav = button(self.Items, title, {
        Name = "Tab_" .. title, Size = UDim2.new(1,0,0,32),
        BackgroundTransparency = 1, TextColor3 = C.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 12, LayoutOrder = #self.Tabs + #self.Groups + 1,
    })
    round(nav, 7)
    new("UIPadding", nav, {PaddingLeft = UDim.new(0, 17)})
    local indicator = new("Frame", nav, {
        Position = UDim2.new(0, 5, 0.5, -10), Size = UDim2.fromOffset(3, 20),
        BackgroundColor3 = C.Accent, BorderSizePixel = 0, Visible = false,
    })
    round(indicator, 2)
    local page = new("ScrollingFrame", win.Pages, {
        Name = "Page_" .. title, Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.Faint,
        CanvasSize = UDim2.fromOffset(0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    new("UIPadding", page, {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 17)})
    new("UIListLayout", page, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
    local pageScale = new("UIScale", page, {Scale = 1})
    local tab = setmetatable({
        Window=win, ParentGroup=self, Title=title, Page=page, PageScale=pageScale,
        NavButton=nav, Indicator=indicator, RowOrder=0,
    }, Tab)
    table.insert(win.Tabs, tab); table.insert(self.Tabs, tab)
    win:_connect(nav.Activated, function() win:_select(tab) end)
    task.defer(function() if not win.Destroyed then self:_measure() end end)
    if options.Selected or not win.ActiveTab then win:_select(tab) end
    return tab
end
function Window:CreateTab(name, options)
    if not self.DefaultGroup then self.DefaultGroup = self:CreateTabGroup("PAGES") end
    return self.DefaultGroup:CreateTab(name, options)
end

function Tab:_row(text, desc, height)
    self.RowOrder = self.RowOrder + 1
    local row = new("Frame", self.Page, {
        Name = "Row", Size = UDim2.new(1, -3, 0, height or 61),
        BackgroundColor3 = C.Row, BackgroundTransparency = 0.52,
        BorderSizePixel = 0, LayoutOrder = self.RowOrder,
    })
    round(row, 9)
    border(row, C.Line, 0.84, 1)
    label(row, text, {
        Position = UDim2.fromOffset(13, 8), Size = UDim2.new(1,-166,0,23),
        Font = Enum.Font.GothamMedium, TextSize = 12,
    })
    label(row, desc or "", {
        Position = UDim2.fromOffset(13, 31), Size = UDim2.new(1,-166,0,20),
        TextSize = 10, TextColor3 = C.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    return row
end
function Tab:CreateSection(title)
    self.RowOrder = self.RowOrder + 1
    local h = label(self.Page, title or "SECTION", {
        Name = "Section", Size = UDim2.new(1,-4,0,33), LayoutOrder = self.RowOrder,
        Font = Enum.Font.GothamSemibold, TextSize = 12, TextColor3 = C.Muted,
    })
    return h
end
function Tab:CreateParagraph(config)
    config = config or {}
    self.RowOrder = self.RowOrder + 1
    local box = new("Frame", self.Page, {
        Size = UDim2.new(1,-3,0,78), LayoutOrder = self.RowOrder,
        BackgroundColor3 = C.Panel, BackgroundTransparency = 0.20, BorderSizePixel = 0,
    })
    round(box, 10); border(box, C.Line, 0.81, 1)
    label(box, config.Title or "Information", {Position=UDim2.fromOffset(14,9),Size=UDim2.new(1,-28,0,23),Font=Enum.Font.GothamSemibold,TextSize=13})
    label(box, config.Content or "", {Position=UDim2.fromOffset(14,34),Size=UDim2.new(1,-28,0,33),TextSize=11,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=C.Muted})
    return box
end
function Tab:CreateButton(config)
    config = config or {}
    local row = self:_row(config.Title or "Button", config.Description or "", 61)
    local action = button(row, config.ButtonText or "Run", {
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(110,32), BackgroundColor3=C.Accent, TextColor3=C.Inverse,
    })
    round(action, 8)
    self.Window:_connect(action.Activated,function() safeCall(config.Callback) end)
    return {Click=function() safeCall(config.Callback) end}
end
function Tab:CreateToggle(config)
    config = config or {}
    local row = self:_row(config.Title or "Toggle", config.Description or "", 61)
    local track = button(row, "", {
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-13,0.5,0),
        Size=UDim2.fromOffset(47,26), BackgroundColor3=C.Line,
    })
    round(track, 13)
    local thumb = new("Frame", track, {
        Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(18,18),
        BackgroundColor3=C.Inverse,BorderSizePixel=0,
    })
    round(thumb,9)
    local ctrl={Value=config.Default == true}
    local function render()
        track.BackgroundColor3=ctrl.Value and C.Accent or C.Line
        thumb.Position=ctrl.Value and UDim2.fromOffset(25,4) or UDim2.fromOffset(4,4)
    end
    function ctrl:SetValue(value,quiet)
        self.Value=value==true;render();if not quiet then safeCall(config.Callback,self.Value) end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    self.Window:_connect(track.Activated,function()ctrl:SetValue(not ctrl.Value)end)
    render()
    return ctrl
end
function Tab:CreateSlider(config)
    config = config or {}
    local min=tonumber(config.Min) or 0;local max=tonumber(config.Max) or 100
    if max<min then min,max=max,min end
    local step=math.max(0.00001,tonumber(config.Step) or 1)
    self.RowOrder=self.RowOrder+1
    local row=new("Frame",self.Page,{
        Size=UDim2.new(1,-3,0,82),LayoutOrder=self.RowOrder,
        BackgroundColor3=C.Row,BackgroundTransparency=0.52,BorderSizePixel=0,
    })
    round(row,9);border(row,C.Line,0.84,1)
    label(row,config.Title or "Slider",{Position=UDim2.fromOffset(13,7),Size=UDim2.new(1,-105,0,23),TextSize=12,Font=Enum.Font.GothamMedium})
    local valueLabel=label(row,"",{Position=UDim2.new(1,-96,0,7),Size=UDim2.fromOffset(83,23),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.Muted,TextSize=11})
    local hit=button(row,"",{Position=UDim2.fromOffset(13,39),Size=UDim2.new(1,-26,0,30),BackgroundTransparency=1})
    local rail=new("Frame",hit,{Position=UDim2.new(0,0,0.5,-2),Size=UDim2.new(1,0,0,4),BackgroundColor3=C.Line,BorderSizePixel=0})
    round(rail,2)
    local fill=new("Frame",rail,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Accent,BorderSizePixel=0})
    round(fill,2)
    local knob=new("Frame",rail,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.Inverse,BorderSizePixel=0})
    round(knob,7)
    local ctrl={Value=min}
    function ctrl:SetValue(value,quiet)
        local raw=math.clamp(tonumber(value) or min,min,max)
        self.Value=math.clamp(min+math.floor((raw-min)/step+0.5)*step,min,max)
        local alpha=max==min and 0 or (self.Value-min)/(max-min)
        fill.Size=UDim2.new(alpha,0,1,0)
        knob.Position=UDim2.fromScale(alpha,0.5)
        valueLabel.Text=tostring(self.Value)..tostring(config.Suffix or "")
        if not quiet then safeCall(config.Callback,self.Value) end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    self.Window:_connect(hit.InputBegan,function(input)
        local typ=input.UserInputType
        if typ~=Enum.UserInputType.Touch and typ~=Enum.UserInputType.MouseButton1 then return end
        local function update(x)
            local width=rail.AbsoluteSize.X
            if width>0 then ctrl:SetValue(min+(max-min)*math.clamp((x-rail.AbsolutePosition.X)/width,0,1)) end
        end
        self.Window.Slider={Pointer=input,Update=update}
        update(input.Position.X)
    end)
    ctrl:SetValue(config.Default == nil and min or config.Default,true)
    return ctrl
end
function Tab:CreateInput(config)
    config=config or {}
    local row=self:_row(config.Title or "Input",config.Description or "",64)
    local input=new("TextBox",row,{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(132,34),BackgroundColor3=C.Panel,
        BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.Text,
        PlaceholderColor3=C.Muted,PlaceholderText=tostring(config.Placeholder or "Enter value"),
        Text=tostring(config.Default or ""),ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
    })
    round(input,7);border(input,C.Line,0.45,1)
    new("UIPadding",input,{PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,6)})
    local ctrl={Value=input.Text}
    function ctrl:SetValue(value,quiet)
        input.Text=tostring(value or "");self.Value=input.Text
        if not quiet then safeCall(config.Callback,self.Value)end
    end
    function ctrl:GetValue()return input.Text end
    ctrl.Set=ctrl.SetValue
    self.Window:_connect(input.FocusLost,function(enter)
        ctrl.Value=input.Text;safeCall(config.Callback,input.Text,enter)
    end)
    return ctrl
end

-- Compatibility aliases for the first-step test. Remaining WindUI/Cascade/
-- Starlight-equivalent widgets are intentionally reserved for later steps.
Tab.Button=Tab.CreateButton
Tab.Toggle=Tab.CreateToggle
Tab.Slider=Tab.CreateSlider
Tab.Input=Tab.CreateInput
Tab.Paragraph=Tab.CreateParagraph
Tab.Section=Tab.CreateSection

return UI
