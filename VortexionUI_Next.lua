--!nonstrict
-- VortexionUI Next / Clean Room - Step 1
-- Independent native Roblox Luau implementation.
-- Visual references: Cascade, WindUI, Starlight (no third-party code copied).
-- Strict executor mount: gethui(). No implicit PlayerGui fallback.

local UI = {Name = "VortexionUI Next", Version = "0.3.0-surface-preview"}
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local C = {
    Window = Color3.fromRGB(22, 23, 27),
    Header = Color3.fromRGB(31, 32, 37),
    Sidebar = Color3.fromRGB(43, 47, 57),
    SidebarLow = Color3.fromRGB(39, 42, 51),
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
    Amber = Color3.fromRGB(244, 195, 113),
    Red = Color3.fromRGB(242, 140, 145),
    Purple = Color3.fromRGB(181, 165, 233),
    SurfaceRaised = Color3.fromRGB(45, 49, 58),
    SurfaceInset = Color3.fromRGB(26, 29, 36),
}
local IconAtlasURL = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/assets/next-icons-atlas.png"
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
local ICONS = {menu=0,search=1,minus=2,maximize=3,close=4,chevron_right=5,
    chevron_down=6,resize=7,home=8,components=9,settings=10,bell=11,
    check=12,folder=13,info=14,next=15}
local iconImages = setmetatable({}, {__mode = "k"})
local atlasAsset = nil
local function icon(parent, name, size, props)
    local index = ICONS[name] or ICONS.info
    local defaults = {
        Name = "Icon_" .. name,
        Size = UDim2.fromOffset(size or 18, size or 18),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = atlasAsset or "", ImageRectSize = Vector2.new(32, 32),
        ImageRectOffset = Vector2.new((index % 4) * 32, math.floor(index / 4) * 32),
        ScaleType = Enum.ScaleType.Stretch,
    }
    for k,v in pairs(props or {}) do defaults[k]=v end
    local item = new("ImageLabel", parent, defaults)
    iconImages[item] = true
    return item
end
local function downloadAtlas()
    local ok, asset = pcall(function()
        local file = "RelaxUI/next-icons-atlas.png"
        local loadAsset = type(getcustomasset) == "function" and getcustomasset
            or type(getsynasset) == "function" and getsynasset
        if type(loadAsset) ~= "function" then return nil end
        if type(isfile) == "function" and isfile(file) then return loadAsset(file) end
        if type(writefile) ~= "function" then return nil end
        local bytes = game:HttpGet(IconAtlasURL)
        if #bytes < 512 then return nil end
        if type(makefolder) == "function" then pcall(makefolder, "RelaxUI") end
        writefile(file, bytes)
        return loadAsset(file)
    end)
    return ok and type(asset) == "string" and asset or nil
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
    local fallback = new("Frame", holder, {
        Name = "VectorLogoFallback", Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    for index, angle in ipairs({-28, 92, 212}) do
        local blade = new("Frame", fallback, {
            Size = UDim2.fromOffset(math.max(5, math.floor(size*0.18)), math.floor(size*0.65)),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.5,0.5),
            Rotation = angle, BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(215,220,231),
        })
        round(blade, math.max(3,math.floor(size*0.08)))
    end
    local hub = new("Frame",fallback,{
        AnchorPoint = Vector2.new(0.5,0.5),Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.fromOffset(math.floor(size*0.19),math.floor(size*0.19)),
        BackgroundColor3 = C.Sidebar,BorderSizePixel = 0,
    })
    round(hub, size*0.1)
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
    local w = math.min(tonumber(cfg.Width) or 840, math.max(300, vp.X - 20))
    local h = math.min(tonumber(cfg.Height) or 525, math.max(280, vp.Y - 20))
    local self = setmetatable({
        Destroyed = false, Minimized = false, DrawerOpen = false,
        Connections = {}, Groups = {}, Tabs = {}, ActiveTab = nil, Drag = nil, Slider = nil,
        Animations = cfg.Animations ~= false, Motions = {}, Width = w, Height = h,
        MinWidth = math.min(470, math.max(300, vp.X - 20)),
        MinHeight = math.min(375, math.max(270, vp.Y - 20)),
        LogoURL = cfg.IconURL or IconURL,
        SpringOnRestore = cfg.SpringOnRestore ~= false,
        -- The *visible* final HTML MD3 override is a 350ms, 9px fade-up,
        -- not the older 630ms 87%/102.5% window-scale prototype.
        EntranceDuration = math.clamp(tonumber(cfg.EntranceDuration)
            or tonumber(cfg.SpringDuration) or 0.35, 0.15, 1.3),
        _entranceTarget = nil,
        _entranceActive = false,
    }, Window)

    local gui = new("ScreenGui", parent, {
        Name = "Vortexion_Next_Step1",
        ResetOnSpawn = false, IgnoreGuiInset = false,
        DisplayOrder = tonumber(cfg.DisplayOrder) or 990,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = true,
    })
    self.Gui = gui

    -- High-resolution rendering path. CanvasGroup flattens children into an
    -- offscreen texture which may be downsampled by Roblox on Android.
    -- Use native Frame by default; the inset rounded panels preserve corners.
    -- UseCanvasGroup is an explicit opt-in compatibility override only.
    local maskClass = cfg.UseCanvasGroup == true and "CanvasGroup" or "Frame"
    local mainOk, main = pcall(new, maskClass, gui, {
        Name = "VortexionWindow",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(w, h),
        BackgroundColor3 = C.Window,
        BackgroundTransparency = math.clamp(tonumber(cfg.Transparency) or 0.12, 0, 0.38),
        BorderSizePixel = 0, ClipsDescendants = true, Active = true,
    })
    if not mainOk then
        warn("[RelaxUI] CanvasGroup unavailable; using sharp native Frame")
        main = new("Frame", gui, {
            Name = "VortexionWindow",
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
            Size = UDim2.fromOffset(w,h), BackgroundColor3 = C.Window,
            BackgroundTransparency = math.clamp(tonumber(cfg.Transparency) or 0.12,0,0.38),
            BorderSizePixel = 0, ClipsDescendants = true, Active = true,
        })
    end
    self.Main = main
    self._baseWindowTransparency = main.BackgroundTransparency
    self.UsesCanvasMask = main:IsA("CanvasGroup")
    self.RenderMode = self.UsesCanvasMask and "CanvasGroup" or "Sharp"
    round(main, 32)
    border(main, Color3.fromRGB(104, 108, 119), 0.51, 1)

    -- Cascade-inspired spatial organization: a stable, blue-charcoal sidebar
    -- and an independent content titlebar, not a generic list of oversized cards.
    local content = new("Frame", main, {
        Name = "Content", Position = UDim2.fromOffset(198, 7),
        Size = UDim2.new(1, -205, 1, -14),
        BackgroundColor3 = C.Window, BackgroundTransparency = 0.07,
        BorderSizePixel = 0, ZIndex = 1,
    })
    self.Content = content
    round(content, 22)
    local header = new("Frame", content, {
        Name = "Toolbar", Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 0, 52),
        BackgroundColor3 = C.Header, BackgroundTransparency = 0.10,
        BorderSizePixel = 0, Active = true,
    })
    self.Header = header
    round(header, 15)
    new("Frame", header, {
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.Line, BackgroundTransparency = 0.72, BorderSizePixel = 0,
    })
    local title = label(header, cfg.Title or "VortexionLua", {
        Position = UDim2.fromOffset(19, 10), Size = UDim2.new(1, -154, 0, 22),
        Font = Enum.Font.GothamSemibold, TextSize = 16,
    })
    self.TitleLabel = title
    local subtitle = label(header, cfg.Subtitle or "Relax UI · Next", {
        Position = UDim2.fromOffset(19, 32), Size = UDim2.new(1, -154, 0, 16),
        TextSize = 11, TextColor3 = C.Muted,
    })
    self.SubtitleLabel = subtitle

    local function chrome(iconName, offset)
        local b = button(header, "", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offset, 0.5, 0),
            Size = UDim2.fromOffset(30, 30), BackgroundColor3 = C.Row,
            BackgroundTransparency = 0.5, TextSize = 17,
        })
        round(b, 13)
        icon(b, iconName, 18, {AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5)})
        return b
    end
    local minimize = chrome("minus", -77)
    local maximize = chrome("maximize", -44)
    local exit = chrome("close", -11)

    local pages = new("Frame", content, {
        Name = "Pages", Position = UDim2.fromOffset(0, 64),
        Size = UDim2.new(1, 0, 1, -64),
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    })
    self.Pages = pages
    -- Shared lightweight transition shade, not one CanvasGroup per tab.
    -- Reveals pre-rendered text without any font-size transformation.
    self.PageShade = new("Frame", pages, {
        Name = "PageTransitionShade",
        Size = UDim2.fromScale(1,1), BackgroundColor3 = C.Window,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, Active = false, ZIndex = 20,
    })

    local scrim = button(main, "", {
        Position = UDim2.fromOffset(7, 7), Size = UDim2.new(1, -14, 1, -14),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4, Visible = false, ZIndex = 4,
    })
    self.Scrim = scrim
    round(scrim, 21)

    local sidebar = new("Frame", main, {
        Name = "NavigationRail", Position = UDim2.fromOffset(7, 7),
        Size = UDim2.new(0, 185, 1, -14),
        BackgroundColor3 = C.Sidebar, BackgroundTransparency = 0.02,
        BorderSizePixel = 0, ZIndex = 5,
    })
    self.Sidebar = sidebar
    round(sidebar, 22)
    -- Flat tonal sidebar avoids multiplying dark colors in the grouped UI.
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
        Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.Muted,
    })
    -- An ImageLabel inside a TextBox overlaps text on Android. Keep search
    -- icon and TextBox as siblings with explicit non-overlapping hit regions.
    local searchShell = new("Frame", sidebar, {
        Name = "SearchShell", Position = UDim2.fromOffset(13, 70),
        Size = UDim2.new(1, -26, 0, 35),
        BackgroundColor3 = Color3.fromRGB(23, 29, 39),
        BackgroundTransparency = 0.18, BorderSizePixel = 0,
    })
    round(searchShell, 12)
    border(searchShell, C.Line, 0.72, 1)
    icon(searchShell, "search", 16, {
        Position = UDim2.fromOffset(12, 10), ImageTransparency = 0.18,
    })
    local search = new("TextBox", searchShell, {
        Name = "Search", Position = UDim2.fromOffset(37, 0),
        Size = UDim2.new(1, -46, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = C.Text, PlaceholderText = "Search pages",
        PlaceholderColor3 = C.Muted, ClearTextOnFocus = false,
        Text = "", TextXAlignment = Enum.TextXAlignment.Left,
    })
    self.Search = search
    self.SearchShell = searchShell
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
        TextSize = 11, TextColor3 = C.Muted,
    })

    local menu = button(header, "", {
        Position = UDim2.fromOffset(6, 13), Size = UDim2.fromOffset(32, 32),
        BackgroundTransparency = 1, TextSize = 21, Visible = false,
    })
    icon(menu,"menu",21,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5)})
    self.Menu = menu
    local resize = button(main, "", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -5, 1, -5),
        Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1,
        TextSize = 15, TextColor3 = C.Muted, ZIndex = 6,
    })
    icon(resize,"resize",18,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5)})
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

    -- The actual V0.5 HTML video uses the MD3 spring override
    -- (.35s fade-up); the older .63s background-shell animation is removed.
    -- Real content fades as a single CanvasGroup with fixed text sizes.

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
    if self.Animations then
        -- Keep the initial CanvasGroup hidden until the loader has created
        -- its pages and controls, then animate the complete window together.
        if self.UsesCanvasMask then self.Main.GroupTransparency=1 end
        task.defer(function()
            if not self.Destroyed and not self.Minimized then
                self:_playSpringEntrance()
            end
        end)
    end
    task.spawn(function()
        local asset = downloadAtlas()
        if asset and not self.Destroyed then
            atlasAsset = asset
            for item in pairs(iconImages) do
                if item.Parent then item.Image = asset end
            end
        end
    end)
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

-- Reproduce the animation actually visible in the supplied HTML recording:
-- mdWindowEnter: 350ms, opacity 0 -> 1, translateY(+9px -> 0), scale
-- .985 -> 1. CanvasGroup font-scale snapping on Android is avoided by
-- matching the perceptual fade/translation while leaving glyphs at 100%.
-- This is one cancellable Tween on the real window, not an empty visual shell.
function Window:_stopSpring()
    local main=self.Main
    local target=self._entranceTarget
    self._entranceTarget=nil
    self._entranceActive=false
    if not main or not main.Parent then return end
    self:_cancelMotion(main,false)
    if target then main.Position=target end
    if self.UsesCanvasMask then main.GroupTransparency=0 else main.BackgroundTransparency=self._baseWindowTransparency end
end

function Window:_playSpringEntrance()
    if self.Destroyed or not self.Main or not self.Main.Parent
        or not self.Main.Visible then return end
    self:_stopSpring()
    if not self.Animations then return end
    local main=self.Main
    local finalPosition=main.Position
    self._entranceTarget=finalPosition
    self._entranceActive=true
    main.Position=finalPosition+UDim2.fromOffset(0,9)
    local target={Position=finalPosition}
    if self.UsesCanvasMask then
        main.GroupTransparency=1
        target.GroupTransparency=0
    else
        -- Native Frame keeps all text rasterized at full device resolution.
        -- Play the 9px positional entry without flattening or fading glyphs.
        main.BackgroundTransparency=1
        target.BackgroundTransparency=self._baseWindowTransparency or 0.12
    end
    self:_animate(main,target,self.EntranceDuration,
        Enum.EasingStyle.Quint,function()
            if self.Destroyed or self._entranceTarget~=finalPosition then return end
            self._entranceTarget=nil
            self._entranceActive=false
            main.Position=finalPosition
            if self.UsesCanvasMask then main.GroupTransparency=0 end
        end)
end

-- Public compatibility method; replays the new video-matched animation.
function Window:ReplaySpring()
    self:_playSpringEntrance()
end

function Window:_cancelMotion(object, settle)
    local record=self.Motions[object]
    if not record then return end
    self.Motions[object]=nil
    if record.Connection then record.Connection:Disconnect() end
    record.Tween:Cancel()
    record.Tween:Destroy()
    if settle and object.Parent then
        for key,value in pairs(record.Target) do object[key]=value end
    end
end
function Window:_animate(object,properties,duration,easing,done)
    if self.Destroyed or not object or not object.Parent then return end
    self:_cancelMotion(object,false)
    if not self.Animations then
        for key,value in pairs(properties) do object[key]=value end
        if done then done() end
        return
    end
    local tween=TweenService:Create(object,TweenInfo.new(duration or 0.22,
        easing or Enum.EasingStyle.Quart,Enum.EasingDirection.Out),properties)
    local record={Tween=tween,Target=properties}
    self.Motions[object]=record
    record.Connection=tween.Completed:Connect(function(state)
        if self.Motions[object]~=record then return end
        self.Motions[object]=nil
        record.Connection:Disconnect()
        tween:Destroy()
        if state==Enum.PlaybackState.Completed and done then done() end
    end)
    tween:Play()
end
function Window:SetAnimationsEnabled(enabled)
    self.Animations=enabled==true
    if not self.Animations then
        self:_stopSpring()
        local active={}
        for object in pairs(self.Motions) do table.insert(active,object) end
        for _,object in ipairs(active) do self:_cancelMotion(object,true) end
        for _,group in ipairs(self.Groups) do
            if group.Tween then group.Tween:Cancel();group.Tween:Destroy();group.Tween=nil end
            group._animating=false;group:_measure()
        end
    end
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
        self:_stopSpring()
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
    if compact then
        self.Sidebar.Size = UDim2.new(0, math.min(212, self.Width - 42), 1, -14)
        self.Sidebar.Visible = self.DrawerOpen
        self.Scrim.Visible = self.DrawerOpen
        self.Content.Position = UDim2.fromOffset(7, 7)
        self.Content.Size = UDim2.new(1, -14, 1, -14)
        -- Make room for the mobile navigation affordance.
        self.Header:FindFirstChildWhichIsA("TextLabel").Position = UDim2.fromOffset(44, 10)
    else
        self.DrawerOpen = false
        self.Scrim.Visible = false
        self.Sidebar.Visible = true
        self.Sidebar.Size = UDim2.new(0, 185, 1, -14)
        self.Content.Position = UDim2.fromOffset(198, 7)
        self.Content.Size = UDim2.new(1, -205, 1, -14)
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
    if target == self.Main then self:_stopSpring(); self:_cancelMotion(self.Main,false) end
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
        if slider.Control then safeCall(slider.Callback,slider.Control.Value) end
        self.Slider = nil
    end
end
function Window:Minimize()
    if self.Destroyed or self.Minimized then return end
    self.Minimized = true
    self:_stopSpring()
    local pos = self.Main.AbsolutePosition
    local sz = self.Main.AbsoluteSize
    self.Launcher.Position = UDim2.fromOffset(pos.X + sz.X / 2, pos.Y + sz.Y / 2)
    self:_cancelMotion(self.Main,false)
    if self.UsesCanvasMask then self.Main.GroupTransparency = 0 end
    self.Main.Visible = false
    self.Launcher.Visible = true
end
function Window:Restore()
    if self.Destroyed or not self.Minimized then return end
    self.Minimized = false
    self.Drag = nil
    self.Launcher.Visible = false
    self.Main.Visible = true
    if self.SpringOnRestore then
        self:_playSpringEntrance()
    else
        local finalPosition=self.Main.Position
        self:_cancelMotion(self.Main,false)
        if self.Animations then
            self.Main.Position=finalPosition+UDim2.fromOffset(0,10)
            if self.UsesCanvasMask then self.Main.GroupTransparency=1 end
            local target={Position=finalPosition}
            if self.UsesCanvasMask then target.GroupTransparency=0 end
            self:_animate(self.Main,target,0.26)
        end
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
    self:_stopSpring()
    self.Destroyed = true
    if self.CameraConnection then self.CameraConnection:Disconnect() end
    local active={}
    for object in pairs(self.Motions) do table.insert(active,object) end
    for _,object in ipairs(active) do self:_cancelMotion(object,false) end
    for _,group in ipairs(self.Groups) do
        if group.Tween then group.Tween:Cancel();group.Tween:Destroy();group.Tween=nil end
    end
    for _, c in ipairs(self.Connections) do c:Disconnect() end
    table.clear(self.Connections)
    self.Drag, self.Slider = nil, nil
    if self.Gui then self.Gui:Destroy() end
end
function Window:Notify(config)
    config = config or {}
    if self.Destroyed then return end
    local frame = new("Frame", self.Content, {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 70),
        Size = UDim2.fromOffset(286, 61), BackgroundColor3 = C.Header,
        BorderSizePixel = 0, ZIndex = 100,
    })
    round(frame, 18); border(frame, C.Line, 0.5)
    frame.Position=UDim2.new(1,14,0,70)
    self:_animate(frame,{Position=UDim2.new(1,-18,0,70)},0.27)
    label(frame, config.Title or "Relax UI", {Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1,-24,0,20), Font=Enum.Font.GothamSemibold, TextSize=12})
    label(frame, config.Content or "Action complete", {Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1,-24,0,25), TextSize=11, TextWrapped=true, TextColor3=C.Muted})
    task.delay(tonumber(config.Duration) or 3, function()
        if self.Destroyed or not frame.Parent then return end
        self:_animate(frame,{Position=UDim2.new(1,14,0,70)},0.2,nil,function()
            if frame.Parent then frame:Destroy() end
        end)
    end)
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
        local previous = self.ActiveTab
        previous.Page.Visible = false
        self:_animate(previous.NavButton, {BackgroundTransparency = 1}, 0.16)
        self:_animate(previous.NavTitle, {TextColor3 = C.Muted}, 0.16)
        previous.Indicator.Visible = false
    end
    self.ActiveTab = tab
    if self.TitleLabel then self.TitleLabel.Text = tab.Title end
    if self.SubtitleLabel then self.SubtitleLabel.Text = tab.ParentGroup.Name .. "  /  " .. tab.Title end
    local parent = tab.ParentGroup
    while parent do parent:SetExpanded(true, true); parent = parent.ParentGroup end
    local firstPage = self._hasSelectedPage ~= true
    self._hasSelectedPage = true
    tab.Page.Visible = true
    tab.Page.CanvasPosition = Vector2.zero
    tab.NavButton.BackgroundColor3 = C.AccentLow
    self:_animate(tab.NavButton, {BackgroundTransparency = 0.18}, 0.2)
    self:_animate(tab.NavTitle, {TextColor3 = C.Text}, 0.2)
    tab.Indicator.Visible = true
    -- Translation + shade reveal keep every TextLabel at its exact original
    -- TextSize, avoiding harsh UIScale font rasterization on Android.
    self:_cancelMotion(tab.Page,false)
    if self.Animations and not firstPage then
        tab.Page.Position = UDim2.fromOffset(0,10)
        self:_animate(tab.Page,{Position=UDim2.fromOffset(0,0)},0.24)
        local shade=self.PageShade
        shade.BackgroundTransparency=0.42
        shade.Visible=true
        self:_animate(shade,{BackgroundTransparency=1},0.23,nil,function()
            shade.Visible=false
        end)
    else
        tab.Page.Position=UDim2.fromOffset(0,0)
        self:_cancelMotion(self.PageShade,false)
        self.PageShade.Visible=false
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
    local header = button(holder, "", {
        Name = "GroupTitle", Size = UDim2.new(1, 0, 0, 35),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 11, TextColor3 = C.Muted, BackgroundTransparency = 1, LayoutOrder = 1,
    })
    local groupTitle = label(header, string.upper(group.Name), {
        Position = UDim2.fromOffset(11,0), Size = UDim2.new(1,-38,1,0),
        TextSize = 10, Font = Enum.Font.GothamSemibold, TextColor3 = C.Muted,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    group.Header = header
    group.TitleLabel = groupTitle
    local arrow = icon(header,group.Expanded and "chevron_down" or "chevron_right",16,{
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -7, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
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
    self.Arrow.ImageRectOffset = Vector2.new(expanded and 64 or 32,32)
    local h = expanded and self.Layout.AbsoluteContentSize.Y or 0
    if self.Tween then self.Tween:Cancel(); self.Tween:Destroy(); self.Tween = nil end
    self._animating = false
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
    local nav = button(self.Items, "", {
        Name = "Tab_" .. title, Size = UDim2.new(1,0,0,44),
        BackgroundTransparency = 1, LayoutOrder = #self.Tabs + #self.Groups + 1,
    })
    round(nav, 12)
    local navIcon = icon(nav, (string.lower(title):find("overview") or string.lower(title):find("home")) and "home" or "components",18,{
        Position=UDim2.fromOffset(14,13), ZIndex=2,
    })
    local navTitle = label(nav, title, {
        Position = UDim2.fromOffset(48,0),
        Size = UDim2.new(1,-56,1,0),
        TextSize = 12, TextColor3 = C.Muted,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2,
    })
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
    local tab = setmetatable({
        Window=win, ParentGroup=self, Title=title, Page=page,
        NavButton=nav, NavTitle=navTitle, NavIcon=navIcon, Indicator=indicator, RowOrder=0,
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
    round(row, 16)
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
    round(box, 16); border(box, C.Line, 0.81, 1)
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
    round(action, 14)
    local normal = action.BackgroundColor3
    self.Window:_connect(action.InputBegan,function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Window:_animate(action,{BackgroundColor3=C.AccentLow},0.11,Enum.EasingStyle.Quad)
        end
    end)
    self.Window:_connect(action.InputEnded,function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Window:_animate(action,{BackgroundColor3=normal},0.22)
        end
    end)
    self.Window:_connect(action.Activated,function()
        self.Window:_animate(action,{BackgroundColor3=normal},0.20)
        safeCall(config.Callback)
    end)
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
    local function render(animate)
        local target = ctrl.Value and C.Accent or C.Line
        local thumbPos = ctrl.Value and UDim2.fromOffset(25,4) or UDim2.fromOffset(4,4)
        if animate then
            self.Window:_animate(track,{BackgroundColor3=target},0.23)
            self.Window:_animate(thumb,{Position=thumbPos},0.25,Enum.EasingStyle.Quint)
        else
            track.BackgroundColor3=target;thumb.Position=thumbPos
        end
    end
    function ctrl:SetValue(value,quiet)
        self.Value=value==true;render(not quiet);if not quiet then safeCall(config.Callback,self.Value) end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    self.Window:_connect(track.Activated,function()ctrl:SetValue(not ctrl.Value)end)
    render(false)
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
    round(row,16);border(row,C.Line,0.84,1)
    label(row,config.Title or "Slider",{Position=UDim2.fromOffset(13,7),Size=UDim2.new(1,-105,0,23),TextSize=12,Font=Enum.Font.GothamMedium})
    local valueLabel=label(row,"",{Position=UDim2.new(1,-96,0,7),Size=UDim2.fromOffset(83,23),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.Muted,TextSize=11})
    local hit=button(row,"",{Position=UDim2.fromOffset(13,39),Size=UDim2.new(1,-26,0,30),BackgroundTransparency=1})
    local rail=new("Frame",hit,{Position=UDim2.new(0,0,0.5,-2),Size=UDim2.new(1,0,0,4),BackgroundColor3=C.Line,BorderSizePixel=0})
    round(rail,2)
    local fill=new("Frame",rail,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Accent,BorderSizePixel=0})
    round(fill,2)
    local knob=new("Frame",rail,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.Inverse,BorderSizePixel=0})
    round(knob,7)
    local ctrl={Value=min,Window=self.Window,LastCallback=0}
    function ctrl:SetValue(value,quiet)
        local raw=math.clamp(tonumber(value) or min,min,max)
        self.Value=math.clamp(min+math.floor((raw-min)/step+0.5)*step,min,max)
        local alpha=max==min and 0 or (self.Value-min)/(max-min)
        if quiet or self.Window == nil then
            fill.Size=UDim2.new(alpha,0,1,0);knob.Position=UDim2.fromScale(alpha,0.5)
        else
            fill.Size=UDim2.new(alpha,0,1,0)
            knob.Position=UDim2.fromScale(alpha,0.5)
        end
        valueLabel.Text=tostring(self.Value)..tostring(config.Suffix or "")
        if not quiet then
            local now=os.clock()
            if now-self.LastCallback>=0.05 then
                self.LastCallback=now
                safeCall(config.Callback,self.Value)
            end
        end
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
        self.Window.Slider={Pointer=input,Update=update,Control=ctrl,Callback=config.Callback}
        update(input.Position.X)
    end)
    ctrl:SetValue(config.Default == nil and min or config.Default,true)
    return ctrl
end
function Tab:CreateInput(config)
    config=config or {}
    local row=self:_row(config.Title or "Input",config.Description or "",72)
    local input=new("TextBox",row,{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(156,38),BackgroundColor3=C.Panel,
        BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.Text,
        PlaceholderColor3=C.Muted,PlaceholderText=tostring(config.Placeholder or "Enter value"),
        Text=tostring(config.Default or ""),ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
    })
    round(input,12);border(input,C.Line,0.45,1)
    new("UIPadding",input,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8)})
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


-- V0.3 visual vocabulary: these are separate compositions, not variants of
-- the old "label left / action right" control row.
local function paletteTone(name)
    if name == "success" then return C.Green end
    if name == "warning" then return C.Amber end
    if name == "danger" then return C.Red end
    if name == "purple" then return C.Purple end
    return C.Accent
end
function Tab:_surface(height, name)
    self.RowOrder=self.RowOrder+1
    local card=new("Frame",self.Page,{
        Name=name or "Surface",
        Size=UDim2.new(1,-3,0,height),
        LayoutOrder=self.RowOrder,
        BackgroundColor3=C.SurfaceRaised,
        BackgroundTransparency=0.10,
        BorderSizePixel=0,
    })
    round(card,17)
    border(card,C.Line,0.72,1)
    return card
end
function Tab:CreateHero(config)
    config=config or {}
    local card=self:_surface(116,"HeroSurface")
    card.BackgroundColor3=C.Sidebar
    local stripe=new("Frame",card,{
        Size=UDim2.fromOffset(4,54),Position=UDim2.fromOffset(15,24),
        BackgroundColor3=paletteTone(config.Tone),BorderSizePixel=0,
    })
    round(stripe,3)
    label(card,tostring(config.Eyebrow or "VORTEXION / OVERVIEW"),{
        Position=UDim2.fromOffset(31,12),Size=UDim2.new(1,-54,0,17),
        TextSize=10,Font=Enum.Font.GothamSemibold,TextColor3=C.Muted,
    })
    label(card,tostring(config.Title or "Your workspace"),{
        Position=UDim2.fromOffset(31,35),Size=UDim2.new(1,-56,0,31),
        Font=Enum.Font.GothamBold,TextSize=20,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    label(card,tostring(config.Description or "Your controls and status at a glance."),{
        Position=UDim2.fromOffset(31,77),Size=UDim2.new(1,-56,0,22),
        TextSize=11,TextColor3=C.Muted,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    return card
end
function Tab:CreateStatCard(config)
    config=config or {}
    local card=self:_surface(94,"StatCard")
    local accent=paletteTone(config.Tone)
    local glyph=icon(card,tostring(config.Icon or "chart"),22,{
        Position=UDim2.fromOffset(16,17),ImageColor3=accent,
    })
    local title=label(card,tostring(config.Title or "Metric"),{
        Position=UDim2.fromOffset(49,12),Size=UDim2.new(1,-63,0,20),
        TextSize=11,TextColor3=C.Muted,Font=Enum.Font.GothamMedium,
    })
    local value=label(card,tostring(config.Value or "0"),{
        Position=UDim2.fromOffset(16,37),Size=UDim2.new(0.58,-16,0,39),
        TextSize=24,Font=Enum.Font.GothamBold,
    })
    local trend=label(card,tostring(config.Trend or ""),{
        Position=UDim2.new(0.58,0,0,47),Size=UDim2.new(0.42,-15,0,24),
        TextSize=11,TextColor3=accent,
        TextXAlignment=Enum.TextXAlignment.Right,
    })
    return {
        SetValue=function(_,v) value.Text=tostring(v) end,
        SetTrend=function(_,v) trend.Text=tostring(v) end,
        Frame=card,
    }
end
function Tab:CreateNotice(config)
    config=config or {}
    local tone=paletteTone(config.Tone)
    local card=self:_surface(73,"Notice")
    card.BackgroundColor3=C.SurfaceInset
    local stripe=new("Frame",card,{
        Position=UDim2.fromOffset(0,12),Size=UDim2.fromOffset(3,49),
        BorderSizePixel=0,BackgroundColor3=tone,
    })
    round(stripe,2)
    icon(card,tostring(config.Icon or "info"),20,{
        Position=UDim2.fromOffset(16,18),ImageColor3=tone,
    })
    label(card,tostring(config.Title or "Notice"),{
        Position=UDim2.fromOffset(49,8),Size=UDim2.new(1,-60,0,24),
        Font=Enum.Font.GothamSemibold,TextSize=12,
    })
    label(card,tostring(config.Content or ""),{
        Position=UDim2.fromOffset(49,33),Size=UDim2.new(1,-60,0,29),
        TextSize=11,TextColor3=C.Muted,TextWrapped=true,
        TextYAlignment=Enum.TextYAlignment.Top,
    })
    return card
end
function Tab:CreateProgress(config)
    config=config or {}
    local card=self:_surface(80,"ProgressSurface")
    label(card,tostring(config.Title or "Progress"),{
        Position=UDim2.fromOffset(14,9),Size=UDim2.new(1,-95,0,22),
        TextSize=12,Font=Enum.Font.GothamSemibold,
    })
    local number=label(card,"0%",{
        Position=UDim2.new(1,-79,0,9),Size=UDim2.fromOffset(64,22),
        TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.Muted,
    })
    local track=new("Frame",card,{
        Position=UDim2.fromOffset(14,49),Size=UDim2.new(1,-28,0,8),
        BackgroundColor3=C.Line,BorderSizePixel=0,
    })
    round(track,4)
    local fill=new("Frame",track,{
        Size=UDim2.fromScale(0,1),
        BackgroundColor3=paletteTone(config.Tone),
        BorderSizePixel=0,
    })
    round(fill,4)
    local control={}
    function control:SetValue(v)
        local n=math.clamp(tonumber(v) or 0,0,100)
        number.Text=tostring(math.floor(n+0.5)).."%"
        self.Value=n
        local window=self.Window
        if window and not window.Destroyed then
            window:_animate(fill,{Size=UDim2.new(n/100,0,1,0)},0.22)
        else fill.Size=UDim2.new(n/100,0,1,0) end
    end
    control.Window=self.Window
    control:SetValue(config.Default or 0)
    return control
end
function Tab:CreateDivider(config)
    config=config or {}
    self.RowOrder=self.RowOrder+1
    local card=new("Frame",self.Page,{
        Name="Divider",Size=UDim2.new(1,-3,0,19),
        BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=self.RowOrder,
    })
    new("Frame",card,{
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromScale(0,0.5),
        Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Line,
        BackgroundTransparency=0.55,BorderSizePixel=0,
    })
    return card
end
function Tab:CreateActionGrid(config)
    config=config or {}
    local items=config.Items or {}
    local columns=2
    local rows=math.max(1,math.ceil(#items/columns))
    self.RowOrder=self.RowOrder+1
    local host=new("Frame",self.Page,{
        Name="ActionGrid",Size=UDim2.new(1,-3,0,rows*66+(rows-1)*7),
        BackgroundTransparency=1,BorderSizePixel=0,
        LayoutOrder=self.RowOrder,
    })
    local grid=new("UIGridLayout",host,{
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirectionMaxCells=2,
        CellPadding=UDim2.fromOffset(7,7),
        CellSize=UDim2.new(0.5,-4,0,66),
    })
    for index,item in ipairs(items) do
        local action=button(host,"",{
            Name="Action_"..index,LayoutOrder=index,
            BackgroundColor3=C.SurfaceInset,
            BackgroundTransparency=0.04,
        })
        round(action,14)
        border(action,C.Line,0.76,1)
        icon(action,tostring(item.Icon or "bolt"),19,{
            Position=UDim2.fromOffset(13,11),
            ImageColor3=paletteTone(item.Tone),
        })
        label(action,tostring(item.Title or "Action"),{
            Position=UDim2.fromOffset(42,6),Size=UDim2.new(1,-48,0,28),
            TextSize=11,Font=Enum.Font.GothamSemibold,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(action,tostring(item.Description or ""),{
            Position=UDim2.fromOffset(13,39),Size=UDim2.new(1,-25,0,16),
            TextSize=10,TextColor3=C.Muted,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        self.Window:_connect(action.Activated,function()
            safeCall(item.Callback)
            self.Window:_animate(action,{BackgroundColor3=C.SurfaceRaised},0.14)
        end)
    end
    return host
end

-- Compatibility aliases for the first-step test. Remaining WindUI/Cascade/
-- Starlight-equivalent widgets are intentionally reserved for later steps.
Tab.Button=Tab.CreateButton
Tab.Toggle=Tab.CreateToggle
Tab.Slider=Tab.CreateSlider
Tab.Input=Tab.CreateInput
Tab.Paragraph=Tab.CreateParagraph
Tab.Section=Tab.CreateSection
Tab.Hero=Tab.CreateHero
Tab.StatCard=Tab.CreateStatCard
Tab.Notice=Tab.CreateNotice
Tab.Progress=Tab.CreateProgress
Tab.Divider=Tab.CreateDivider
Tab.ActionGrid=Tab.CreateActionGrid

return UI
