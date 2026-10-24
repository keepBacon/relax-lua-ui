--!nonstrict
-- VortexionUI Next / Clean Room - Step 1
-- Independent native Roblox Luau implementation.
-- Visual references: Cascade, WindUI, Starlight (no third-party code copied).
-- Strict executor mount: gethui(). No implicit PlayerGui fallback.

local UI = {Name = "VortexionUI Next", Version = "0.3.4-surface-layout"}
UI.DesignTokens = {
    Space={XS=4,SM=8,MD=12,LG=16,XL=24,XXL=32},
    Radius={SM=8,MD=12,LG=16,XL=22,Window=32,Pill=999},
    Type={Caption=11,Label=12,Body=14,Subheading=16,Heading=20,Display=28},
    Motion={Fast=0.14,Standard=0.24,Emphasized=0.38,Spring=0.42},
    Icon={Small=14,Medium=18,Large=24,Hero=32},
}
function UI.GetDesignTokens()
    local out={}
    for group,values in pairs(UI.DesignTokens) do
        out[group]={};for key,value in pairs(values) do out[group][key]=value end
    end
    return out
end
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
-- Damped response sampled by a NumberValue Tween. Unlike a UIScale-based
-- entrance, the native UI keeps TextSize constant and avoids offscreen blur.
local function springEase(t)
    t=math.clamp(t,0,1)
    if t<=0 then return 0 end
    if t>=1 then return 1 end
    local decay=7.0
    local oscillation=9.0
    local function sample(x)
        return 1-math.exp(-decay*x)*(math.cos(oscillation*x)
            +(decay/oscillation)*math.sin(oscillation*x))
    end
    return sample(t)/sample(1)
end
local function smoothEase(t)
    t=math.clamp(t,0,1)
    return 1-(1-t)*(1-t)*(1-t)
end
local function compactViewport(width,v)
    return width<620 or v.X<680 or v.Y>v.X*1.12
end
local function lerpProperty(a,b,t,key)
    local kind=typeof(a)
    if kind=="UDim2" then
        return UDim2.new(a.X.Scale+(b.X.Scale-a.X.Scale)*t,a.X.Offset+(b.X.Offset-a.X.Offset)*t,
            a.Y.Scale+(b.Y.Scale-a.Y.Scale)*t,a.Y.Offset+(b.Y.Offset-a.Y.Offset)*t)
    elseif kind=="Color3" then
        return Color3.new(
            math.clamp(a.R+(b.R-a.R)*t,0,1),
            math.clamp(a.G+(b.G-a.G)*t,0,1),
            math.clamp(a.B+(b.B-a.B)*t,0,1))
    elseif kind=="number" then
        local v=a+(b-a)*t
        if string.find(key,"Transparency",1,true) then return math.clamp(v,0,1) end
        return v
    end
    return t>=1 and b or a
end

local C = {
    Window = Color3.fromRGB(22, 23, 27),
    Header = Color3.fromRGB(31, 32, 37),
    Sidebar = Color3.fromRGB(43, 47, 57),
    SidebarLow = Color3.fromRGB(39, 42, 51),
    Panel = Color3.fromRGB(29, 30, 35),
    Row = Color3.fromRGB(38, 39, 45),
    RowHover = Color3.fromRGB(46, 47, 54),
    Elevated = Color3.fromRGB(47, 51, 62),
    Hero = Color3.fromRGB(37, 43, 61),
    SurfaceSoft = Color3.fromRGB(32, 35, 42),
    Text = Color3.fromRGB(245, 246, 248),
    Muted = Color3.fromRGB(160, 163, 174),
    Faint = Color3.fromRGB(116, 120, 131),
    Line = Color3.fromRGB(70, 74, 83),
    Accent = Color3.fromRGB(76, 145, 242),
    AccentLow = Color3.fromRGB(34, 77, 133),
    Inverse = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(101, 211, 163),
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

-- Native line-art icon pack. Paths use 24x24 points and render at device
-- resolution, avoiding tiny raster atlas scaling and external icon fonts.
local PATHS={
home={"3,11 12,3 21,11","6,10 6,20 18,20 18,10"},
check={"4,12 10,18 20,6"},
maximize={"5,5 19,5 19,19 5,19 5,5"},
search={"14,14 20,20","14,14 18,10 18,6 14,3 10,3 6,6 6,10 10,14 14,14"},
settings={"12,3 12,21","3,12 21,12","6,6 18,18","18,6 6,18"},
menu={"4,6 20,6","4,12 20,12","4,18 20,18"},
close={"5,5 19,19","19,5 5,19"},
minus={"4,12 20,12"},plus={"12,4 12,20","4,12 20,12"},
chevron_right={"8,4 16,12 8,20"},chevron_down={"4,8 12,16 20,8"},
resize={"5,19 19,5","12,19 19,19 19,12"},
play={"5,3 19,12 5,21 5,3"},pause={"7,4 7,20","17,4 17,20"},
stop={"5,5 19,5 19,19 5,19 5,5"},
refresh={"19,8 19,4 15,4","19,5 16,8","18,12 17,16 13,19 8,19 4,15 4,10 7,6"},
copy={"8,8 19,8 19,20 8,20 8,8","4,15 4,4 15,4"},
edit={"5,18 7,13 16,4 20,8 11,17 5,18"},
save={"4,4 20,4 20,20 4,20 4,4","8,4 8,10 16,10 16,4"},
trash={"5,7 19,7","8,7 8,20 16,20 16,7","8,4 16,4"},
upload={"12,16 12,4","7,9 12,4 17,9","4,17 4,20 20,20 20,17"},
download={"12,4 12,16","7,11 12,16 17,11","4,17 4,20 20,20 20,17"},
keyboard={"3,6 21,6 21,18 3,18 3,6","7,10 7,10","12,10 12,10","17,10 17,10","8,14 16,14"},
palette={"12,4 19,7 20,13 17,17 12,20 6,18 4,13 5,8 12,4"},
monitor={"3,4 21,4 21,16 3,16 3,4","12,16 12,20","8,20 16,20"},
chart={"4,20 4,4","4,20 20,20","6,16 10,12 14,15 20,7"},
list={"7,5 20,5","7,12 20,12","7,19 20,19","3,5 3,5","3,12 3,12","3,19 3,19"},
grid={"4,4 10,4 10,10 4,10 4,4","14,4 20,4 20,10 14,10 14,4","4,14 10,14 10,20 4,20 4,14","14,14 20,14 20,20 14,20 14,14"},
filter={"4,5 20,5 14,12 14,19 10,21 10,12 4,5"},
clock={"12,4 12,12 17,15","12,3 12,3"},
calendar={"5,5 19,5 19,20 5,20 5,5","8,3 8,7","16,3 16,7","5,9 19,9"},
zap={"14,3 6,13 12,13 9,21 18,10 12,10 14,3"},
wifi={"4,9 8,6 12,5 16,6 20,9","7,13 10,11 14,11 17,13","11,17 13,17"},
bug={"8,7 16,7 18,12 16,18 8,18 6,12 8,7","12,7 12,20","4,9 7,10","17,10 20,9","4,16 7,15","17,15 20,16"},
database={"4,6 12,3 20,6 12,9 4,6","4,6 4,18 12,21 20,18 20,6","4,12 12,15 20,12"},
lock={"6,10 18,10 18,20 6,20 6,10","8,10 8,7 10,4 14,4 16,7 16,10"},
unlock={"6,10 18,10 18,20 6,20 6,10","8,10 8,7 10,4 14,4 16,6"},
heart={"12,20 4,12 4,8 7,5 12,9 17,5 20,8 20,12 12,20"},
star={"12,3 14,9 21,9 15,13 17,20 12,16 7,20 9,13 3,9 10,9 12,3"},
sparkles={"8,3 8,13","3,8 13,8","17,12 17,21","13,16 21,16"},
target={"12,4 12,20","4,12 20,12","7,7 17,7 17,17 7,17 7,7"},
compass={"12,3 20,12 12,21 4,12 12,3","9,15 15,9 13,14 9,15"},
box={"4,7 12,3 20,7 12,12 4,7","4,7 4,17 12,21 20,17 20,7","12,12 12,21"},
wrench={"18,4 14,8 17,11 10,18 7,18 7,15 14,8","18,4 21,7 18,10"},
plug={"8,4 8,9","16,4 16,9","6,9 18,9 18,14 6,14 6,9","12,14 12,20"},
sliders={"4,6 20,6","4,12 20,12","4,18 20,18","9,3 9,9","15,9 15,15","7,15 7,21"},
shield={"12,3 20,6 19,14 12,21 5,14 4,6 12,3"},
eye={"3,12 7,7 12,5 17,7 21,12 17,17 12,19 7,17 3,12"},
code={"9,6 4,12 9,18","15,6 20,12 15,18","14,4 10,20"},
terminal={"4,5 20,5 20,19 4,19 4,5","7,9 10,12 7,15","12,15 17,15"},
player={"10,4 14,4 16,7 14,10 10,10 8,7 10,4","12,10 12,15 8,20","12,15 17,20"},
world={"12,4 12,20","4,12 20,12","6,6 18,18","18,6 6,18","12,4 16,5 19,8 20,12 19,16 16,19 12,20 8,19 5,16 4,12 5,8 8,5 12,4"},
gamepad={"4,8 20,8 22,14 18,18 15,14 9,14 6,18 2,14 4,8","8,10 8,13","6,11 10,11"},
activity={"4,12 8,12 10,6 14,18 16,12 20,12"},
folder={"3,6 10,6 12,8 21,8 21,19 3,19 3,6"},
info={"12,10 12,19","12,4 12,4"},
bell={"6,17 6,10 8,6 12,4 16,6 18,10 18,17 4,17 20,17","10,20 14,20"},
components={"4,4 10,4 10,10 4,10 4,4","14,4 20,4 20,10 14,10 14,4","4,14 10,14 10,20 4,20 4,14","14,14 20,14 20,20 14,20 14,14"},
}
local ALIASES={dashboard="home",overview="home",run="play",execute="play",executor="play",stop="stop",pause="pause",refresh="refresh",reload="refresh",warning="info",error="close",success="check",users="player",character="player",players="player",
map="world",environment="world",scripts="code",editor="code",source="code",executor="play",
run="play",execute="play",performance="activity",fps="activity",stats="chart",analytics="chart",
memory="database",storage="database",network="wifi",connection="plug",security="shield",
privacy="lock",visual="eye",graphics="monitor",render="monitor",theme="palette",colors="palette",
appearance="palette",control="sliders",controls="sliders",options="settings",config="settings",
configuration="settings",logs="terminal",console="terminal",output="terminal",tools="wrench",
utilities="wrench",modules="components",library="components",assets="folder",files="folder",
favorites="star",recent="clock",history="clock",help="info",about="info",notification="bell",
search="search",reload="refresh",add="plus",create="plus",remove="minus",delete="trash",
import="download",export="upload",keybind="keyboard",hotkeys="keyboard",game="gamepad",
games="gamepad",status="activity"}
UI.Icons={}
for name in pairs(PATHS) do UI.Icons[name]=name end
for name,target in pairs(ALIASES) do UI.Icons[name]=target end

local function icon(parent,name,size,props)
    name=string.lower(tostring(name or "info"))
    local semantic=PATHS[name] and name or ALIASES[name]
    if semantic and PATHS[semantic] then
        -- The icon root is a Frame. Never assign ImageLabel-only properties
        -- (ImageTransparency, ImageColor3, ImageRectOffset, etc.) to a Frame.
        -- Instead translate tint and opacity into its native stroke segments.
        local p={Name="Icon_"..name,Size=UDim2.fromOffset(size or 18,size or 18),
            BackgroundTransparency=1,BorderSizePixel=0}
        local color=C.Text
        local opacity=0
        for k,v in pairs(props or {}) do
            -- Frame-backed icons never accept ImageLabel-only properties.
            if k=="ImageColor3" or k=="Color" then
                color=v
            elseif k=="ImageTransparency" then
                opacity=math.clamp(tonumber(v) or 0,0,1)
            elseif k=="Image" or k=="ImageRectSize" or k=="ImageRectOffset"
                or k=="ScaleType" then
                -- Image-only properties are irrelevant to native vector art.
            else
                p[k]=v
            end
        end
        local root=new("Frame",parent,p)
        local thickness=math.max(1,math.floor((size or 18)/12))
        local function drawPath(path)
            local pts={}
            for token in string.gmatch(path,"[^%s]+") do
                local x,y=string.match(token,"^(%-?%d+),(%-?%d+)$")
                if x then table.insert(pts,{tonumber(x),tonumber(y)}) end
            end
            for i=1,#pts-1 do
                local a,b=pts[i],pts[i+1]
                local dx,dy=b[1]-a[1],b[2]-a[2]
                local length=math.sqrt(dx*dx+dy*dy)
                if length==0 then
                    local dot=new("Frame",root,{AnchorPoint=Vector2.new(.5,.5),
                        Position=UDim2.fromScale(a[1]/24,a[2]/24),Size=UDim2.fromOffset(thickness+1,thickness+1),
                        BackgroundColor3=color,BackgroundTransparency=opacity,BorderSizePixel=0})
                    round(dot,thickness)
                else
                    new("Frame",root,{AnchorPoint=Vector2.new(.5,.5),
                        Position=UDim2.fromScale((a[1]+b[1])/48,(a[2]+b[2])/48),
                        Size=UDim2.new(length/24,0,0,thickness),Rotation=math.deg(math.atan2(dy,dx)),
                        BackgroundColor3=color,BackgroundTransparency=opacity,BorderSizePixel=0})
                end
            end
        end
        for _,path in ipairs(PATHS[semantic]) do drawPath(path) end
        return root
    end
    local index=ICONS[name] or ICONS.info
    local defaults={Name="Icon_"..name,Size=UDim2.fromOffset(size or 18,size or 18),
        BackgroundTransparency=1,BorderSizePixel=0,Image=atlasAsset or "",
        ImageRectSize=Vector2.new(32,32),
        ImageRectOffset=Vector2.new((index%4)*32,math.floor(index/4)*32),ScaleType=Enum.ScaleType.Stretch}
    for k,v in pairs(props or {}) do defaults[k]=v end
    local item=new("ImageLabel",parent,defaults);iconImages[item]=true;return item
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
        MotionScale = math.clamp(tonumber(cfg.MotionScale) or 1,0.65,1.45),
        _drawerAnimating = false, _exitRunId = 0,
        MinWidth = math.min(470, math.max(300, vp.X - 20)),
        MinHeight = math.min(375, math.max(270, vp.Y - 20)),
        LogoURL = cfg.IconURL or IconURL,
        SpringOnRestore = cfg.SpringOnRestore ~= false,
        -- The *visible* final HTML MD3 override is a 350ms, 9px fade-up,
        -- not the older 630ms 87%/102.5% window-scale prototype.
        EntranceDuration = math.clamp(tonumber(cfg.EntranceDuration)
            or tonumber(cfg.SpringDuration) or 0.28, 0.15, 0.65),
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
    gui:SetAttribute("VortexionVersion", UI.Version)

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
        Position = UDim2.fromOffset(12, 10), ImageColor3 = C.Muted,
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
        self:SetDrawerOpen(not self.DrawerOpen)
    end)
    self:_connect(scrim.Activated, function()
        self:SetDrawerOpen(false)
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
function Window:_cancelVisualReveal(restore)
    local run=self.VisualReveal
    self.VisualReveal=nil
    if not run then return end
    if run.Update then run.Update:Disconnect();run.Update=nil end
    if run.Connection then run.Connection:Disconnect();run.Connection=nil end
    if run.Tween then run.Tween:Cancel();run.Tween:Destroy();run.Tween=nil end
    if run.Driver then run.Driver:Destroy();run.Driver=nil end
    if restore then
        for object,props in pairs(run.Snapshot or {}) do
            if object.Parent then
                for key,value in pairs(props.Values) do
                    pcall(function() object[key]=value end)
                end
            end
        end
    end
end

function Window:_revealVisualTree(root,duration)
    if not self.Animations or not root or not root.Parent then return end
    self:_cancelVisualReveal(true)
    local snapshot={}
    local function delayFor(object)
        local node=object
        while node and node~=root do
            local parent=node.Parent
            if parent and parent:FindFirstChildWhichIsA("UIListLayout") then
                local order=math.max(1,tonumber(node.LayoutOrder) or 1)
                return math.min((order-1)*0.012,0.18)
            end
            node=parent
        end
        return 0
    end
    local function capture(object,ancestorsVisible)
        for _,child in ipairs(object:GetChildren()) do
            local visible=ancestorsVisible
            if child:IsA("GuiObject") then visible=visible and child.Visible end
            if visible then
                local values={}
                if child:IsA("GuiObject") and child.BackgroundTransparency<0.999 then
                    values.BackgroundTransparency=child.BackgroundTransparency
                end
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    if child.TextTransparency<0.999 then values.TextTransparency=child.TextTransparency end
                    if child.TextStrokeTransparency<0.999 then values.TextStrokeTransparency=child.TextStrokeTransparency end
                end
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    if child.ImageTransparency<0.999 then values.ImageTransparency=child.ImageTransparency end
                end
                if child:IsA("ScrollingFrame") and child.ScrollBarImageTransparency<0.999 then
                    values.ScrollBarImageTransparency=child.ScrollBarImageTransparency
                end
                if child:IsA("UIStroke") and child.Transparency<0.999 then
                    values.Transparency=child.Transparency
                end
                if next(values) then
                    snapshot[child]={Values=values,Delay=delayFor(child)}
                    for key in pairs(values) do pcall(function() child[key]=1 end) end
                end
                capture(child,visible)
            end
        end
    end
    capture(root,root.Visible)
    if not next(snapshot) then return end
    local driver=Instance.new("NumberValue")
    driver.Value=0
    local tween=TweenService:Create(driver,TweenInfo.new(
        math.max(0.16,(duration or 0.40)*(self.MotionScale or 1)),
        Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Value=1})
    local run={Driver=driver,Tween=tween,Snapshot=snapshot}
    self.VisualReveal=run
    local function render(progress)
        for object,entry in pairs(snapshot) do
            if object.Parent then
                local localT=math.clamp((progress-entry.Delay)/(1-entry.Delay),0,1)
                local eased=smoothEase(localT)
                for key,target in pairs(entry.Values) do
                    local value=1+(target-1)*eased
                    if string.find(key,"Transparency",1,true) then value=math.clamp(value,0,1) end
                    pcall(function() object[key]=value end)
                end
            end
        end
    end
    run.Update=driver:GetPropertyChangedSignal("Value"):Connect(function()
        if self.VisualReveal==run then render(driver.Value) end
    end)
    run.Connection=tween.Completed:Connect(function(state)
        if self.VisualReveal~=run then return end
        self.VisualReveal=nil
        if run.Update then run.Update:Disconnect();run.Update=nil end
        if run.Connection then run.Connection:Disconnect();run.Connection=nil end
        if state==Enum.PlaybackState.Completed then
            for object,entry in pairs(snapshot) do
                if object.Parent then
                    for key,value in pairs(entry.Values) do pcall(function() object[key]=value end) end
                end
            end
        end
        tween:Destroy();driver:Destroy()
        run.Tween=nil;run.Driver=nil
    end)
    tween:Play()
end

function Window:_stopSpring()
    local main=self.Main
    local target=self._entranceTarget
    self._entranceTarget=nil
    self._entranceActive=false
    self:_cancelVisualReveal(true)
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
    self:_revealVisualTree(main,0.30)
    self:_animate(main,target,self.EntranceDuration,Enum.EasingStyle.Quart,function()
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

function Window:_cancelMotion(object,settle)
    local record=self.Motions[object]
    if not record then return end
    self.Motions[object]=nil
    if record.Connection then record.Connection:Disconnect();record.Connection=nil end
    if record.Update then record.Update:Disconnect();record.Update=nil end
    if record.Tween then
        record.Tween:Cancel();record.Tween:Destroy();record.Tween=nil
    end
    if record.Driver then record.Driver:Destroy();record.Driver=nil end
    if settle and object.Parent then
        for key,value in pairs(record.Target) do
            pcall(function() object[key]=value end)
        end
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
    local tween=TweenService:Create(object,TweenInfo.new(
        math.max(0.04,(duration or 0.22)*self.MotionScale),
        easing or Enum.EasingStyle.Sine,Enum.EasingDirection.Out),properties)
    local record={Tween=tween,Target=properties}
    self.Motions[object]=record
    record.Connection=tween.Completed:Connect(function(state)
        if self.Motions[object]~=record then return end
        self.Motions[object]=nil
        record.Connection:Disconnect()
        record.Connection=nil
        tween:Destroy()
        record.Tween=nil
        if state==Enum.PlaybackState.Completed and done then done() end
    end)
    tween:Play()
end

function Window:_spring(object,properties,duration,done)
    if self.Destroyed or not object or not object.Parent then return end
    self:_cancelMotion(object,false)
    if not self.Animations then
        for key,value in pairs(properties) do object[key]=value end
        if done then done() end
        return
    end
    local from={}
    for key in pairs(properties) do from[key]=object[key] end
    local driver=Instance.new("NumberValue")
    local tween=TweenService:Create(driver,TweenInfo.new(
        math.max(0.08,(duration or 0.36)*self.MotionScale),
        Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Value=1})
    local record={Driver=driver,Tween=tween,Target=properties}
    self.Motions[object]=record
    record.Update=driver:GetPropertyChangedSignal("Value"):Connect(function()
        if self.Motions[object]~=record or not object.Parent then return end
        local t=smoothEase(driver.Value)
        for key,value in pairs(properties) do
            object[key]=lerpProperty(from[key],value,t,key)
        end
    end)
    record.Connection=tween.Completed:Connect(function(state)
        if self.Motions[object]~=record then return end
        self.Motions[object]=nil
        if record.Update then record.Update:Disconnect() end
        record.Connection:Disconnect()
        tween:Destroy();driver:Destroy()
        record.Update=nil;record.Connection=nil;record.Tween=nil;record.Driver=nil
        if state==Enum.PlaybackState.Completed then
            if object.Parent then
                for key,value in pairs(properties) do object[key]=value end
            end
            if done then done() end
        end
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
    local compact = compactViewport(self.Width,v)
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
        self._drawerAnimating = false
        self.Scrim.Visible = false
        self.Sidebar.Visible = true
        self.Sidebar.Position = UDim2.fromOffset(7,7)
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

function Window:SetDrawerOpen(open)
    if self.Destroyed then return end
    local compact=compactViewport(self.Width,viewport())
    if not compact then
        self.DrawerOpen=false
        self:_layout()
        return
    end
    open=open==true
    if self.DrawerOpen==open and not self._drawerAnimating then return end
    self.DrawerOpen=open
    self._drawerAnimating=true
    local sidebar=self.Sidebar
    local scrim=self.Scrim
    self:_cancelMotion(sidebar,false)
    self:_cancelMotion(scrim,false)
    local width=math.min(212,self.Width-42)
    if open then
        sidebar.Visible=true
        scrim.Visible=true
        scrim.BackgroundTransparency=1
        sidebar.Position=UDim2.fromOffset(-width+7,7)
        sidebar.Size=UDim2.new(0,width,1,-14)
        self:_animate(scrim,{BackgroundTransparency=0.4},0.28,Enum.EasingStyle.Sine)
        self:_animate(sidebar,{Position=UDim2.fromOffset(7,7)},0.24,Enum.EasingStyle.Quart,function()
            if not self.Destroyed and self.DrawerOpen then self._drawerAnimating=false end
        end)
    else
        self:_animate(scrim,{BackgroundTransparency=1},0.20,Enum.EasingStyle.Sine,function()
            if scrim.Parent and not self.DrawerOpen then scrim.Visible=false end
        end)
        self:_animate(sidebar,{Position=UDim2.fromOffset(-width+7,7)},0.19,Enum.EasingStyle.Quart,function()
            if sidebar.Parent and not self.DrawerOpen then
                sidebar.Visible=false
                sidebar.Position=UDim2.fromOffset(7,7)
                self._drawerAnimating=false
            end
        end)
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
    if self.Destroyed or self.Minimized or self._minimizing then return end
    self.Minimized=true
    self._minimizing=true
    self:_stopSpring()
    local main,launcher=self.Main,self.Launcher
    local pos=main.AbsolutePosition
    local sz=main.AbsoluteSize
    local center=Vector2.new(pos.X+sz.X/2,pos.Y+sz.Y/2)
    self._restoreGeometry={Position=main.Position,Size=main.Size}
    launcher.Position=UDim2.fromOffset(center.X,center.Y)
    if self.Animations then
        self:_spring(main,{
            Position=UDim2.fromOffset(center.X,center.Y),
            Size=UDim2.fromOffset(54,54),
            BackgroundTransparency=1,
        },0.28,function()
            if self.Destroyed or not self.Minimized then return end
            main.Visible=false
            main.Position=self._restoreGeometry.Position
            main.Size=self._restoreGeometry.Size
            main.BackgroundTransparency=self._baseWindowTransparency
            self._minimizing=false
            launcher.Visible=true
            launcher.Size=UDim2.fromOffset(42,42)
            self:_spring(launcher,{Size=UDim2.fromOffset(58,58)},0.20)
        end)
    else
        main.Visible=false
        launcher.Visible=true
        self._minimizing=false
    end
end
function Window:Restore()
    if self.Destroyed or not self.Minimized then return end
    self.Minimized=false
    self.Drag=nil
    local main,launcher=self.Main,self.Launcher
    self:_cancelMotion(main,false)
    self:_cancelMotion(launcher,false)
    local lp=launcher.AbsolutePosition
    local ls=launcher.AbsoluteSize
    local center=Vector2.new(lp.X+ls.X/2,lp.Y+ls.Y/2)
    launcher.Visible=false
    main.Visible=true
    local geometry=self._restoreGeometry
    if geometry then
        main.Position=UDim2.fromOffset(center.X,center.Y)
        main.Size=UDim2.fromOffset(math.min(56,geometry.Size.X.Offset),math.min(56,geometry.Size.Y.Offset))
        main.BackgroundTransparency=1
    end
    if self.SpringOnRestore and geometry and self.Animations then
        local target={Position=geometry.Position,Size=geometry.Size,
            BackgroundTransparency=self._baseWindowTransparency}
        self:_spring(main,target,0.40,function()
            if self.Destroyed then return end
            main.Position=geometry.Position
            main.Size=geometry.Size
            self._minimizing=false
        end)
    else
        if geometry then main.Position=geometry.Position;main.Size=geometry.Size end
        main.BackgroundTransparency=self._baseWindowTransparency
        self._minimizing=false
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
    local previous=self.ActiveTab
    if previous then
        self:_cancelMotion(previous.Page,false)
        previous.Page.Visible=false
        previous.Page.Position=UDim2.fromOffset(0,0)
        self:_animate(previous.NavButton,{BackgroundTransparency=1,BackgroundColor3=C.Row},0.22)
        self:_animate(previous.NavTitle,{TextColor3=C.Muted},0.22)
        previous.Indicator.Visible=false
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
    tab.NavButton.BackgroundColor3=C.AccentLow
    tab.NavButton.BackgroundTransparency=0.18
    self:_animate(tab.NavButton,{BackgroundTransparency=0.12},0.26)
    self:_animate(tab.NavTitle,{TextColor3=C.Text},0.24)
    tab.Indicator.Visible=true
    self:_cancelMotion(tab.Page,false)
    if self.Animations and not firstPage then
        local direction=(self._lastTabOrder and tab.Page.LayoutOrder<self._lastTabOrder) and -1 or 1
        tab.Page.Position=UDim2.fromOffset(direction*8,0)
        self:_animate(tab.Page,{Position=UDim2.fromOffset(0,0)},0.22,Enum.EasingStyle.Quart)
    else
        tab.Page.Position=UDim2.fromOffset(0,0)
    end
    self._lastTabOrder=tab.Page.LayoutOrder
    if compactViewport(self.Width,viewport()) then
        if self.DrawerOpen then
            self:SetDrawerOpen(false)
        else
            self.DrawerOpen=false
            self:_layout()
        end
    else
        self.DrawerOpen=false
        self:_layout()
    end
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
    local arrowTarget=expanded and 0 or -90
    if self.Window.Animations and not immediate then
        self.Window:_animate(self.Arrow,{Rotation=arrowTarget},0.22)
    else
        self.Arrow.Rotation=arrowTarget
    end
    local h = expanded and self.Layout.AbsoluteContentSize.Y or 0
    if self.Tween then self.Tween:Cancel(); self.Tween:Destroy(); self.Tween=nil end
    self._animating=false
    if immediate or not self.Window.Animations then
        self.Clip.Size=UDim2.new(1,0,0,h)
    else
        self._animating=true
        local target=UDim2.new(1,0,0,h)
        local start=self.Clip.Size
        local driver=Instance.new("NumberValue")
        driver.Value=0
        local tween=TweenService:Create(driver,TweenInfo.new(0.25*self.Window.MotionScale,
            Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Value=1})
        self.Tween=tween
        local update=driver:GetPropertyChangedSignal("Value"):Connect(function()
            if self.Tween~=tween then return end
            local t=springEase(driver.Value)
            self.Clip.Size=UDim2.new(1,0,start.Y.Offset+(target.Y.Offset-start.Y.Offset)*t)
        end)
        tween.Completed:Once(function()
            update:Disconnect()
            if self.Tween==tween then
                self.Tween=nil;self._animating=false
                self.Clip.Size=target
                self:_measure()
            end
            tween:Destroy();driver:Destroy()
        end)
        tween:Play()
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
    local lowerTitle=string.lower(title)
    local iconName="components"
    local semanticKeywords={
        {"performance","activity"},{"analytics","chart"},{"settings","settings"},
        {"player","player"},{"character","player"},{"world","world"},{"environment","world"},
        {"script","code"},{"editor","code"},{"executor","play"},{"visual","eye"},
        {"graphic","monitor"},{"render","monitor"},{"theme","palette"},{"color","palette"},
        {"network","wifi"},{"memory","database"},{"storage","database"},{"security","shield"},
        {"console","terminal"},{"log","terminal"},{"tool","wrench"},{"asset","folder"},
        {"file","folder"},{"search","search"},{"notification","bell"},
        {"overview","home"},{"dashboard","home"},{"home","home"},{"game","gamepad"},
    }
    for _,entry in ipairs(semanticKeywords) do
        if lowerTitle:find(entry[1],1,true) then iconName=entry[2];break end
    end
    local navIcon = icon(nav, iconName,18,{
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


-- Vortexion Surface layout primitives. All layouts use native Frames so
-- TextLabels remain sharp on Android; only the data/action grids reflow.
function Tab:_surface(name,height,background,alpha)
    self.RowOrder=self.RowOrder+1
    local frame=new("Frame",self.Page,{
        Name=name,Size=UDim2.new(1,-3,0,height),
        BackgroundColor3=background or C.SurfaceSoft,
        BackgroundTransparency=alpha or 0,
        BorderSizePixel=0,LayoutOrder=self.RowOrder,
    })
    round(frame,UI.DesignTokens.Radius.LG)
    border(frame,C.Line,0.77,1)
    return frame
end

function Tab:_responsiveGrid(name,items,maxColumns,cellHeight,draw)
    local count=#items
    local gap=10
    local root=self:_surface(name,cellHeight,C.Window,1)
    local grid=new("UIGridLayout",root,{
        CellPadding=UDim2.fromOffset(gap,gap),
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirection=Enum.FillDirection.Horizontal,
        FillDirectionMaxCells=2,
        CellSize=UDim2.new(0.5,-gap/2,0,cellHeight),
    })
    local function recalc()
        if self.Window.Destroyed then return end
        local width=root.AbsoluteSize.X
        if width<1 then return end
        local columns=math.max(1,math.min(maxColumns or 3,
            width<325 and 1 or (width<535 and 2 or (maxColumns or 3))))
        grid.FillDirectionMaxCells=columns
        grid.CellSize=UDim2.new(1/columns,-gap*(columns-1)/columns,0,cellHeight)
        local rows=math.ceil(count/columns)
        root.Size=UDim2.new(1,-3,0,math.max(0,rows*cellHeight+math.max(0,rows-1)*gap))
    end
    for i,entry in ipairs(items) do
        local card=new("Frame",root,{
            Name=name.."_"..i,BackgroundColor3=C.Panel,
            BackgroundTransparency=0.03,BorderSizePixel=0,
            LayoutOrder=i,
        })
        round(card,16)
        border(card,C.Line,0.72,1)
        draw(card,entry,i)
    end
    self.Window:_connect(root:GetPropertyChangedSignal("AbsoluteSize"),recalc)
    task.defer(recalc)
    return root,recalc
end

function Tab:CreateHero(config)
    config=config or {}
    local frame=self:_surface("HeroSurface",174,C.Hero,0.02)
    round(frame,22)
    local stroke=frame:FindFirstChildWhichIsA("UIStroke")
    if stroke then stroke.Color=C.AccentLow;stroke.Transparency=0.42 end
    new("Frame",frame,{
        Position=UDim2.fromOffset(17,20),Size=UDim2.fromOffset(3,28),
        BackgroundColor3=C.Accent,BorderSizePixel=0,
    })
    label(frame,string.upper(tostring(config.Eyebrow or "VORTEXION SURFACE")),{
        Position=UDim2.fromOffset(30,15),Size=UDim2.new(1,-48,0,16),
        TextSize=10,Font=Enum.Font.GothamSemibold,TextColor3=C.Accent,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    label(frame,config.Title or "Workspace ready",{
        Position=UDim2.fromOffset(20,42),Size=UDim2.new(1,-40,0,32),
        TextSize=20,Font=Enum.Font.GothamSemibold,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    label(frame,config.Description or "Your interface and tools in one place.",{
        Position=UDim2.fromOffset(20,76),Size=UDim2.new(1,-40,0,43),
        TextSize=12,TextColor3=C.Muted,TextWrapped=true,
        TextYAlignment=Enum.TextYAlignment.Top,
    })
    local primary=button(frame,config.ActionText or "Explore tools",{
        Position=UDim2.fromOffset(20,130),Size=UDim2.fromOffset(126,31),
        BackgroundColor3=C.Accent,TextColor3=C.Window,
        TextSize=11,
    })
    round(primary,10)
    icon(primary,config.ActionIcon or "play",14,{
        Position=UDim2.fromOffset(10,8),ImageColor3=C.Window,
    })
    new("UIPadding",primary,{PaddingLeft=UDim.new(0,19)})
    self.Window:_connect(primary.Activated,function() safeCall(config.Callback) end)
    return {Frame=frame,Button=primary}
end

function Tab:CreateStatGrid(config)
    config=config or {}
    local items=config.Items or {}
    local out={}
    local root=self:_responsiveGrid("StatGrid",items,config.Columns or 3,104,function(card,item,index)
        local glyph=icon(card,item.Icon or "activity",19,{
            Position=UDim2.fromOffset(13,11),
            ImageColor3=item.Color or C.Accent,
        })
        label(card,item.Title or "Metric",{
            Position=UDim2.fromOffset(40,11),Size=UDim2.new(1,-48,0,22),
            TextColor3=C.Muted,TextSize=11,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        local value=label(card,tostring(item.Value or "—"),{
            Position=UDim2.fromOffset(13,37),Size=UDim2.new(1,-26,0,31),
            TextSize=23,Font=Enum.Font.GothamSemibold,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(card,item.Footnote or "",{
            Position=UDim2.fromOffset(13,76),Size=UDim2.new(1,-26,0,18),
            TextSize=10,TextColor3=C.Muted,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        out[index]={Frame=card,SetValue=function(_,v) value.Text=tostring(v) end}
    end)
    return {Frame=root,Items=out}
end

function Tab:CreateActionGrid(config)
    config=config or {}
    local items=config.Items or {}
    local root=self:_responsiveGrid("ActionGrid",items,config.Columns or 2,94,function(card,item,index)
        local action=button(card,"",{
            Name="Action_"..index,Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,
        })
        local tileIcon=icon(action,item.Icon or "play",22,{
            Position=UDim2.fromOffset(14,14),ImageColor3=item.Color or C.Accent,
        })
        label(action,item.Title or "Action",{
            Position=UDim2.fromOffset(47,10),Size=UDim2.new(1,-61,0,26),
            TextSize=13,Font=Enum.Font.GothamSemibold,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(action,item.Description or "",{
            Position=UDim2.fromOffset(14,48),Size=UDim2.new(1,-28,0,31),
            TextSize=11,TextColor3=C.Muted,TextWrapped=true,
            TextYAlignment=Enum.TextYAlignment.Top,
        })
        self.Window:_connect(action.Activated,function()
            self.Window:_animate(card,{BackgroundColor3=C.Elevated},0.12,nil,function()
                self.Window:_animate(card,{BackgroundColor3=C.Panel},0.2)
            end)
            safeCall(item.Callback,index)
        end)
    end)
    return root
end

function Tab:CreateCompactRow(config)
    config=config or {}
    local row=self:_surface("CompactRow",56,C.SurfaceSoft,0.14)
    local glyph=icon(row,config.Icon or "settings",18,{
        Position=UDim2.fromOffset(13,19),ImageColor3=C.Accent,
    })
    label(row,config.Title or "Setting",{
        Position=UDim2.fromOffset(44,6),Size=UDim2.new(1,-168,0,23),
        TextSize=12,Font=Enum.Font.GothamMedium,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    label(row,config.Description or "",{
        Position=UDim2.fromOffset(44,29),Size=UDim2.new(1,-168,0,17),
        TextSize=10,TextColor3=C.Muted,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    local action=button(row,config.Action or "Open",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(82,30),BackgroundColor3=C.Elevated,
        TextSize=11,
    })
    round(action,9)
    self.Window:_connect(action.Activated,function()
        self.Window:_animate(action,{BackgroundColor3=C.AccentLow},0.1,nil,function()
            self.Window:_animate(action,{BackgroundColor3=C.Elevated},0.2)
        end)
        safeCall(config.Callback)
    end)
    return {Frame=row,Button=action}
end

function Tab:CreateSelectionGrid(config)
    config=config or {}
    local items=config.Items or {}
    local selected=config.Default or (items[1] and items[1].Value)
    local controls={}
    local root=self:_responsiveGrid("SelectionGrid",items,config.Columns or 3,98,function(card,item,index)
        local entry=button(card,"",{
            Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        })
        icon(entry,item.Icon or "palette",22,{
            Position=UDim2.fromOffset(14,12),ImageColor3=C.Accent,
        })
        label(entry,item.Title or tostring(item.Value or "Option"),{
            Position=UDim2.fromOffset(14,42),Size=UDim2.new(1,-28,0,20),
            TextSize=12,Font=Enum.Font.GothamMedium,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(entry,item.Description or "",{
            Position=UDim2.fromOffset(14,64),Size=UDim2.new(1,-28,0,17),
            TextSize=10,TextColor3=C.Muted,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        controls[index]={Item=item,Card=card}
        self.Window:_connect(entry.Activated,function()
            selected=item.Value
            for _,data in ipairs(controls) do
                if data then
                    self.Window:_animate(data.Card,{
                        BackgroundColor3=data.Item.Value==selected and C.AccentLow or C.Panel,
                    },0.2)
                end
            end
            safeCall(config.Callback,selected,index)
        end)
    end)
    local function setValue(v,quiet)
        selected=v
        for _,data in ipairs(controls) do
            if data then
                data.Card.BackgroundColor3=(data.Item.Value==selected) and C.AccentLow or C.Panel
            end
        end
        if not quiet then safeCall(config.Callback,selected) end
    end
    setValue(selected,true)
    return {
        Frame=root,
        GetValue=function() return selected end,
        SetValue=function(_,v,quiet) setValue(v,quiet) end,
    }
end

function Tab:CreateExpandablePanel(config)
    config=config or {}
    local details=config.Lines or {}
    local detailHeight=math.max(56,18+#details*25)
    local headerHeight=58
    local panel=self:_surface("ExpandablePanel",headerHeight,C.SurfaceSoft,0.10)
    panel.ClipsDescendants=true
    local toggle=button(panel,"",{
        Name="ExpandHeader",Size=UDim2.new(1,0,0,headerHeight),BackgroundTransparency=1,
    })
    icon(toggle,config.Icon or "sliders",20,{
        Position=UDim2.fromOffset(14,18),ImageColor3=C.Accent,
    })
    label(toggle,config.Title or "Advanced settings",{
        Position=UDim2.fromOffset(46,8),Size=UDim2.new(1,-86,0,24),
        Font=Enum.Font.GothamMedium,TextSize=13,
    })
    label(toggle,config.Description or "Show more",{
        Position=UDim2.fromOffset(46,31),Size=UDim2.new(1,-86,0,19),
        TextSize=10,TextColor3=C.Muted,
    })
    local arrow=icon(toggle,"chevron_down",16,{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-16,0.5,0),
    })
    local body=new("Frame",panel,{
        Name="DetailBody",Position=UDim2.fromOffset(12,headerHeight),
        Size=UDim2.new(1,-24,0,detailHeight),
        BackgroundTransparency=1,BorderSizePixel=0,
    })
    for i,item in ipairs(details) do
        label(body,tostring(item),{
            Position=UDim2.fromOffset(5,9+(i-1)*25),
            Size=UDim2.new(1,-12,0,23),
            TextSize=11,TextColor3=C.Muted,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
    end
    local opened=config.Expanded==true
    local function setExpanded(value,instant)
        opened=value==true
        local target=UDim2.new(1,-3,0,headerHeight+(opened and detailHeight or 0))
        if instant or not self.Window.Animations then
            panel.Size=target;arrow.Rotation=opened and 0 or -90
        else
            self.Window:_animate(panel,{Size=target},0.22,Enum.EasingStyle.Quart)
            self.Window:_animate(arrow,{Rotation=opened and 0 or -90},0.18,Enum.EasingStyle.Quart)
        end
        safeCall(config.OnExpanded,opened)
    end
    self.Window:_connect(toggle.Activated,function() setExpanded(not opened,false) end)
    setExpanded(opened,true)
    return {
        Frame=panel,
        SetExpanded=function(_,v) setExpanded(v,false) end,
        GetExpanded=function() return opened end,
    }
end

function Tab:CreateActivityFeed(config)
    config=config or {}
    local items=config.Items or {}
    local height=22+#items*42+12
    local frame=self:_surface("ActivityFeed",height,C.SurfaceSoft,0.08)
    label(frame,config.Title or "Recent activity",{
        Position=UDim2.fromOffset(14,9),Size=UDim2.new(1,-28,0,23),
        TextSize=12,Font=Enum.Font.GothamSemibold,
    })
    for i,item in ipairs(items) do
        local y=33+(i-1)*42
        local marker=new("Frame",frame,{
            Position=UDim2.fromOffset(15,y+9),Size=UDim2.fromOffset(7,7),
            BackgroundColor3=item.Color or C.Green,BorderSizePixel=0,
        })
        round(marker,8)
        label(frame,item.Title or "Activity",{
            Position=UDim2.fromOffset(34,y),Size=UDim2.new(1,-128,0,19),
            TextSize=11,Font=Enum.Font.GothamMedium,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(frame,item.Time or "",{
            Position=UDim2.new(1,-91,0,y),Size=UDim2.fromOffset(77,18),
            TextSize=10,TextColor3=C.Muted,TextXAlignment=Enum.TextXAlignment.Right,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(frame,item.Description or "",{
            Position=UDim2.fromOffset(34,y+18),Size=UDim2.new(1,-48,0,17),
            TextSize=10,TextColor3=C.Muted,TextTruncate=Enum.TextTruncate.AtEnd,
        })
    end
    return frame
end

function Tab:_row(text, desc, height)
    self.RowOrder=self.RowOrder+1
    local row=new("Frame",self.Page,{
        Name="ControlRow",Size=UDim2.new(1,-3,0,height or 66),
        BackgroundColor3=C.Row,BackgroundTransparency=0.42,
        BorderSizePixel=0,LayoutOrder=self.RowOrder,
    })
    round(row,16);border(row,C.Line,0.80,1)
    local titleLabel=label(row,text,{
        Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-166,0,23),
        Font=Enum.Font.GothamMedium,TextSize=12,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    local descLabel=label(row,desc or "",{
        Position=UDim2.fromOffset(14,32),Size=UDim2.new(1,-166,0,18),
        TextSize=10,TextColor3=C.Muted,TextTruncate=Enum.TextTruncate.AtEnd,
    })
    return row,titleLabel,descLabel
end

function Tab:_fitControlRow(row,titleLabel,descLabel,control,controlWidth,baseHeight,controlHeight)
    local function update()
        if not row.Parent then return end
        local width=row.AbsoluteSize.X
        local stacked=width<370
        local height=stacked and math.max(baseHeight or 66,92) or (baseHeight or 66)
        row.Size=UDim2.new(1,-3,0,height)
        if stacked then
            titleLabel.Position=UDim2.fromOffset(13,7)
            titleLabel.Size=UDim2.new(1,-26,0,21)
            descLabel.Position=UDim2.fromOffset(13,29)
            descLabel.Size=UDim2.new(1,-26,0,17)
            control.AnchorPoint=Vector2.new(1,0)
            control.Position=UDim2.new(1,-10,0,51)
            control.Size=UDim2.fromOffset(math.min(controlWidth,width-24),math.min(controlHeight or 30,30))
        else
            titleLabel.Position=UDim2.fromOffset(13,8)
            titleLabel.Size=UDim2.new(1,-controlWidth-42,0,23)
            descLabel.Position=UDim2.fromOffset(13,32)
            descLabel.Size=UDim2.new(1,-controlWidth-42,0,18)
            control.AnchorPoint=Vector2.new(1,0.5)
            control.Position=UDim2.new(1,-12,0.5,0)
            control.Size=UDim2.fromOffset(controlWidth,controlHeight or 32)
        end
    end
    self.Window:_connect(row:GetPropertyChangedSignal("AbsoluteSize"),update)
    task.defer(update)
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
function Tab:CreateBadge(config)
    config=config or {}
    self.RowOrder=self.RowOrder+1
    local variant=tostring(config.Variant or "Neutral")
    local colors={
        Neutral={bg=C.Row,fg=C.Muted},Primary={bg=C.AccentLow,fg=C.Accent},
        Success={bg=Color3.fromRGB(35,74,61),fg=C.Green},
        Warning={bg=Color3.fromRGB(78,59,32),fg=Color3.fromRGB(240,195,116)},
        Danger={bg=Color3.fromRGB(84,42,48),fg=Color3.fromRGB(246,139,151)},
    }
    local theme=colors[variant] or colors.Neutral
    local chip=new("Frame",self.Page,{
        Name="Badge",Size=UDim2.fromOffset(math.max(84,tonumber(config.Width) or 120),30),
        BackgroundColor3=theme.bg,BorderSizePixel=0,LayoutOrder=self.RowOrder,
    })
    round(chip,999)
    if config.Icon then icon(chip,config.Icon,14,{Position=UDim2.fromOffset(9,8),ImageColor3=theme.fg}) end
    local left=config.Icon and 29 or 11
    label(chip,config.Text or config.Title or "Status",{
        Position=UDim2.fromOffset(left,0),Size=UDim2.new(1,-left-9,1,0),
        TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=theme.fg,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    return chip
end

function Tab:CreateDivider(config)
    config=config or {}
    self.RowOrder=self.RowOrder+1
    local holder=new("Frame",self.Page,{
        Name="Divider",Size=UDim2.new(1,-4,0,config.Label and 28 or 13),
        BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=self.RowOrder,
    })
    local line=new("Frame",holder,{
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
        Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Line,
        BackgroundTransparency=0.3,BorderSizePixel=0,
    })
    if config.Label then
        line.Position=UDim2.new(0,0,0.5,7)
        local txt=label(holder,config.Label,{
            Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,18),
            TextSize=11,Font=Enum.Font.GothamSemibold,TextColor3=C.Muted,
        })
    end
    return holder
end

function Tab:CreateProgress(config)
    config=config or {}
    self.RowOrder=self.RowOrder+1
    local row=new("Frame",self.Page,{
        Name="ProgressCard",Size=UDim2.new(1,-3,0,76),LayoutOrder=self.RowOrder,
        BackgroundColor3=C.Panel,BackgroundTransparency=0.12,BorderSizePixel=0,
    })
    round(row,14);border(row,C.Line,0.78,1)
    label(row,config.Title or "Progress",{
        Position=UDim2.fromOffset(13,9),Size=UDim2.new(1,-105,0,20),
        TextSize=12,Font=Enum.Font.GothamMedium,
    })
    local valueLabel=label(row,"",{
        Position=UDim2.new(1,-84,0,9),Size=UDim2.fromOffset(70,20),
        TextSize=11,TextColor3=C.Muted,TextXAlignment=Enum.TextXAlignment.Right,
    })
    local rail=new("Frame",row,{
        Position=UDim2.new(0,13,0,42),Size=UDim2.new(1,-26,0,7),
        BackgroundColor3=C.Line,BorderSizePixel=0,
    })
    round(rail,999)
    local fill=new("Frame",rail,{Size=UDim2.new(0,0,1,0),BackgroundColor3=config.Color or C.Accent,BorderSizePixel=0})
    round(fill,999)
    local ctrl={Value=0}
    function ctrl:SetValue(value,animate)
        self.Value=math.clamp(tonumber(value) or 0,0,100)
        valueLabel.Text=tostring(math.floor(self.Value+0.5)).."%"
        local target={Size=UDim2.new(self.Value/100,0,1,0)}
        if animate and self.Window and self.Window.Animations then
            self.Window:_animate(fill,target,0.24,Enum.EasingStyle.Quint)
        else fill.Size=target.Size end
    end
    ctrl.Window=self.Window
    ctrl:SetValue(config.Value or 0,false)
    return ctrl
end

function Tab:CreateButton(config)
    config = config or {}
    local row,titleLabel,descLabel=self:_row(config.Title or "Button",config.Description or "",66)
    local action=button(row,config.ButtonText or "Run",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(110,32),BackgroundColor3=C.Accent,TextColor3=C.Inverse,
    })
    round(action,14)
    self:_fitControlRow(row,titleLabel,descLabel,action,110,66,32)
    local normal=action.BackgroundColor3
    self.Window:_connect(action.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            self.Window:_spring(action,{Size=UDim2.fromOffset(106,30),BackgroundColor3=C.AccentLow},0.12)
        end
    end)
    self.Window:_connect(action.InputEnded,function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            self.Window:_spring(action,{Size=UDim2.fromOffset(110,32),BackgroundColor3=normal},0.20)
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
    local row,titleLabel,descLabel=self:_row(config.Title or "Toggle",config.Description or "",66)
    local track=button(row,"",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-13,0.5,0),
        Size=UDim2.fromOffset(47,26),BackgroundColor3=C.Line,
    })
    round(track,13)
    self:_fitControlRow(row,titleLabel,descLabel,track,47,66,26)
    local thumb=new("Frame",track,{
        Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(18,18),
        BackgroundColor3=C.Inverse,BorderSizePixel=0,
    })
    round(thumb,9)
    local ctrl={Value=config.Default==true}
    local function render(animate)
        local target=ctrl.Value and C.Accent or C.Line
        local thumbPos=ctrl.Value and UDim2.fromOffset(25,4) or UDim2.fromOffset(4,4)
        local thumbSize=ctrl.Value and UDim2.fromOffset(20,18) or UDim2.fromOffset(18,18)
        if animate then
            self.Window:_animate(track,{BackgroundColor3=target},0.25)
            self.Window:_spring(thumb,{Position=thumbPos,Size=thumbSize},0.28)
        else
            track.BackgroundColor3=target;thumb.Position=thumbPos;thumb.Size=thumbSize
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
    local sliderTitle=label(row,config.Title or "Slider",{Position=UDim2.fromOffset(13,7),Size=UDim2.new(1,-105,0,23),TextSize=12,Font=Enum.Font.GothamMedium})
    local valueLabel=label(row,"",{Position=UDim2.new(1,-96,0,7),Size=UDim2.fromOffset(83,23),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.Muted,TextSize=11})
    local hit=button(row,"",{Position=UDim2.fromOffset(13,39),Size=UDim2.new(1,-26,0,30),BackgroundTransparency=1})
    self.Window:_connect(row:GetPropertyChangedSignal("AbsoluteSize"),function()
        local narrow=row.AbsoluteSize.X<370
        row.Size=UDim2.new(1,-3,0,narrow and 91 or 82)
        sliderTitle.Size=UDim2.new(1,-105,0,23)
        valueLabel.Position=UDim2.new(1,-96,0,7)
        hit.Position=UDim2.fromOffset(13,narrow and 54 or 39)
        hit.Size=UDim2.new(1,-26,0,30)
    end)
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
    local row,titleLabel,descLabel=self:_row(config.Title or "Input",config.Description or "",72)
    local input=new("TextBox",row,{
        Name="InputControl",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(156,38),BackgroundColor3=C.Panel,
        BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.Text,
        PlaceholderColor3=C.Muted,PlaceholderText=tostring(config.Placeholder or "Enter value"),
        Text=tostring(config.Default or ""),ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
    })
    round(input,12);border(input,C.Line,0.45,1)
    self:_fitControlRow(row,titleLabel,descLabel,input,156,72,38)
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

-- Compatibility aliases for the first-step test. Remaining WindUI/Cascade/
-- Starlight-equivalent widgets are intentionally reserved for later steps.
Tab.Button=Tab.CreateButton
Tab.Toggle=Tab.CreateToggle
Tab.Slider=Tab.CreateSlider
Tab.Input=Tab.CreateInput
Tab.Paragraph=Tab.CreateParagraph
Tab.Section=Tab.CreateSection
Tab.Badge=Tab.CreateBadge
Tab.Divider=Tab.CreateDivider
Tab.Progress=Tab.CreateProgress
Tab.Hero=Tab.CreateHero
Tab.StatGrid=Tab.CreateStatGrid
Tab.ActionGrid=Tab.CreateActionGrid
Tab.CompactRow=Tab.CreateCompactRow
Tab.SelectionGrid=Tab.CreateSelectionGrid
Tab.ExpandablePanel=Tab.CreateExpandablePanel
Tab.ActivityFeed=Tab.CreateActivityFeed


return UI
