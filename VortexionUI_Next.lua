--!nonstrict
-- VortexionUI Next / Clean Room - Step 1
-- Independent native Roblox Luau implementation.
-- Visual references: Cascade, WindUI, Starlight (no third-party code copied).
-- Strict executor mount: gethui(). No implicit PlayerGui fallback.

local UI = {Name = "VortexionUI Next", Version = "0.4.5-glass-blur-header-spacing"}
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
local Lighting = game:GetService("Lighting")
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
local ICON_ALIASES={arrow_down="chevron_down",dropdown="chevron_down",arrow="chevron_down",chevron="chevron_down",rating="star"}

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
-- Additional native 24x24 semantic paths (drawn as Roblox Frames).
local EXTRA_PATHS={
    arrow_left={"20,12 4,12","10,6 4,12 10,18"},
    arrow_right={"4,12 20,12","14,6 20,12 14,18"},
    chevron_left={"16,4 8,12 16,20"},
    chevron_up={"4,16 12,8 20,16"},
    circle={"12,3 18,6 21,12 18,18 12,21 6,18 3,12 6,6 12,3"},
    check_circle={"12,3 18,6 21,12 18,18 12,21 6,18 3,12 6,6 12,3","7,12 11,16 17,9"},
    alert_triangle={"12,3 22,21 2,21 12,3","12,9 12,15","12,18 12,18"},
    alert_circle={"12,3 18,6 21,12 18,18 12,21 6,18 3,12 6,6 12,3","12,7 12,14","12,17 12,17"},
    help_circle={"12,3 18,6 21,12 18,18 12,21 6,18 3,12 6,6 12,3","9,9 12,7 15,9 12,13 12,15","12,18 12,18"},
    key={"7,12 4,9 5,5 9,3 13,5 14,9 11,12 7,12","11,12 20,21","16,17 19,14"},
    sliders_horizontal={"4,6 20,6","4,12 20,12","4,18 20,18","8,3 8,9","15,9 15,15"},
    palette_2={"12,3 18,5 21,11 19,15 15,15 14,19 10,21 4,18 2,12 6,5 12,3"},
    file_code={"6,3 16,3 20,7 20,21 6,21 6,3","16,3 16,7 20,7","11,11 8,14 11,17","15,11 18,14 15,17"},
    terminal_square={"4,4 20,4 20,20 4,20 4,4","7,9 10,12 7,15","12,15 17,15"},
    image={"3,4 21,4 21,20 3,20 3,4","6,16 10,12 13,15 16,10 20,16","7,8 9,8"},
    camera={"4,8 9,8 11,5 15,5 17,8 20,8 20,19 4,19 4,8","9,13 12,10 15,13 12,16 9,13"},
    music={"9,6 19,4 19,17","9,6 9,18","4,18 7,16 9,18 7,20 4,18","14,17 17,15 19,17 17,19 14,17"},
    globe={"12,3 18,6 21,12 18,18 12,21 6,18 3,12 6,6 12,3","3,12 21,12","12,3 9,8 9,16 12,21","12,3 15,8 15,16 12,21"},
    cloud={"7,18 4,16 4,12 7,9 10,9 12,5 16,5 19,9 22,12 22,16 19,18 7,18"},
    sun={"12,3 12,6","12,18 12,21","3,12 6,12","18,12 21,12","7,7 9,9","15,15 17,17","7,17 9,15","15,9 17,7","8,12 12,8 16,12 12,16 8,12"},
    moon={"18,3 13,8 13,13 18,18 21,18 16,21 10,20 5,16 3,10 7,5 12,3 18,3"},
    next={"14,6 20,12 14,18"},
    bookmark={"6,4 18,4 18,21 12,16 6,21 6,4"},
    tag={"3,12 12,3 21,3 21,12 12,21 3,12","16,8 16,8"},
    layers={"4,9 12,4 20,9 12,14 4,9","4,14 12,19 20,14","4,18 12,23 20,18"},
    cpu={"6,6 18,6 18,18 6,18 6,6","9,9 15,9 15,15 9,15 9,9","9,2 9,6","15,2 15,6","9,18 9,22","15,18 15,22"},
    command={"9,8 9,16","15,8 15,16","8,9 4,9 3,6 5,3 8,4 9,8","15,8 16,4 19,3 21,6 20,9 15,9"},
    filter_x={"4,5 20,5 14,12 14,19 10,21 10,12 4,5","19,17 22,20","22,17 19,20"},
    sort={"6,6 18,6","6,12 15,12","6,18 12,18"},
    link_2={"4,12 8,8 12,8","12,16 16,16 20,12","9,13 15,11"},
}
for name,path in pairs(EXTRA_PATHS) do PATHS[name]=path end
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
games="gamepad",status="activity",rating="star",dropdown="chevron_down",arrow_down="chevron_down",arrow="chevron_down",chevron="chevron_down"}
UI.Icons={}
for name in pairs(PATHS) do UI.Icons[name]=name end
for name,target in pairs(ALIASES) do UI.Icons[name]=target end

local function icon(parent,name,size,props)
    name=string.lower(tostring(name or "info"))
    local semantic=PATHS[name] and name or ALIASES[name] or ICON_ALIASES[name] or name
    local p={Name="Icon_"..name,Size=UDim2.fromOffset(size or 18,size or 18),BackgroundTransparency=1,BorderSizePixel=0}
    local color=C.Text;local opacity=0
    for k,v in pairs(props or {}) do
        if k=="ImageColor3" or k=="Color" then color=v
        elseif k=="ImageTransparency" then opacity=math.clamp(tonumber(v) or 0,0,1)
        elseif k=="Image" or k=="ImageRectSize" or k=="ImageRectOffset" or k=="ScaleType" then
        else p[k]=v end
    end
    local root=new("Frame",parent,p)
    local pathList=PATHS[semantic] or PATHS.info
    local iconSize=tonumber(size) or 18
    local thickness=math.max(1,math.floor(iconSize/12))
    local glyphZ=root.ZIndex+1
    local function drawPath(path)
        local pts={}
        for token in string.gmatch(path,"[^%s]+") do
            local x,y=string.match(token,"^(%-?%d+),(%-?%d+)$")
            if x then table.insert(pts,{tonumber(x),tonumber(y)}) end
        end
        for i=1,#pts-1 do
            local a,b=pts[i],pts[i+1];local dx,dy=b[1]-a[1],b[2]-a[2]
            local length=math.sqrt(dx*dx+dy*dy)
            if length==0 then
                local dot=new("Frame",root,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(a[1]/24,a[2]/24),
                    Size=UDim2.fromOffset(thickness+1,thickness+1),BackgroundColor3=color,
                    BackgroundTransparency=opacity,BorderSizePixel=0,ZIndex=glyphZ})
                round(dot,thickness)
            else
                new("Frame",root,{AnchorPoint=Vector2.new(.5,.5),
                    Position=UDim2.fromScale((a[1]+b[1])/48,(a[2]+b[2])/48),
                    Size=UDim2.new(length/24,0,0,thickness),Rotation=math.deg(math.atan2(dy,dx)),
                    BackgroundColor3=color,BackgroundTransparency=opacity,BorderSizePixel=0,ZIndex=glyphZ})
            end
        end
    end
    for _,path in ipairs(pathList) do drawPath(path) end
    return root
end
local function animateIconTint(window,root,color,duration)
    if not window or window.Destroyed or not root or not root.Parent then return end
    local time=duration or 0.18
    for _,node in ipairs(root:GetDescendants()) do
        if node:IsA("ImageLabel") then
            window:_animate(node,{ImageColor3=color},time,Enum.EasingStyle.Quint)
        elseif node:IsA("Frame") and node.BackgroundTransparency<1 then
            window:_animate(node,{BackgroundColor3=color},time,Enum.EasingStyle.Quint)
        end
    end
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
    local w = math.min(tonumber(cfg.Width) or 760, math.max(300, vp.X - 20))
    local h = math.min(tonumber(cfg.Height) or 450, math.max(280, vp.Y - 20))
    local self = setmetatable({
        Destroyed = false, Minimized = false, DrawerOpen = false,
        Connections = {}, Groups = {}, Tabs = {}, ActiveTab = nil, Drag = nil, Slider = nil,
        Animations = cfg.Animations ~= false,
        BlurEnabled = cfg.BlurEnabled ~= false and cfg.Blur ~= false,
        BlurSize = math.clamp(tonumber(cfg.BlurSize) or 8, 0, 24),
        Motions = {}, Width = w, Height = h,
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

    -- BlurEffect softens the 3D scene behind the translucent ScreenGui.
    -- It does not blur other ScreenGui layers; foreground text stays native/sharp.
    local blurOk, blurEffect = pcall(function()
        local effect = Lighting:FindFirstChild("VortexionUI_BackdropBlur")
        if not effect or not effect:IsA("BlurEffect") then
            effect = Instance.new("BlurEffect")
            effect.Name = "VortexionUI_BackdropBlur"
            effect.Parent = Lighting
        end
        effect.Size = self.BlurEnabled and self.BlurSize or 0
        effect.Enabled = self.BlurEnabled and self.BlurSize > 0
        return effect
    end)
    if blurOk then
        self.BlurEffect = blurEffect
    else
        warn("[RelaxUI] Could not create backdrop blur: " .. tostring(blurEffect))
    end

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
        BackgroundTransparency = math.clamp(tonumber(cfg.Transparency) or 0.20, 0, 0.45),
        BorderSizePixel = 0, ClipsDescendants = true, Active = true,
    })
    if not mainOk then
        warn("[RelaxUI] CanvasGroup unavailable; using sharp native Frame")
        main = new("Frame", gui, {
            Name = "VortexionWindow",
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
            Size = UDim2.fromOffset(w,h), BackgroundColor3 = C.Window,
            BackgroundTransparency = math.clamp(tonumber(cfg.Transparency) or 0.20,0,0.45),
            BorderSizePixel = 0, ClipsDescendants = true, Active = true,
        })
    end
    self.Main = main
    self._baseWindowTransparency = main.BackgroundTransparency
    self.UsesCanvasMask = main:IsA("CanvasGroup")
    self.RenderMode = self.UsesCanvasMask and "CanvasGroup" or "Sharp"
    round(main, 27)
    border(main, Color3.fromRGB(104, 108, 119), 0.51, 1)

    -- Cascade-inspired spatial organization: a stable, blue-charcoal sidebar
    -- and an independent content titlebar, not a generic list of oversized cards.
    local content = new("Frame", main, {
        Name = "Content", Position = UDim2.fromOffset(198, 7),
        Size = UDim2.new(1, -205, 1, -14),
        BackgroundColor3 = C.Window, BackgroundTransparency = 0.16,
        BorderSizePixel = 0, ZIndex = 1,
    })
    self.Content = content
    round(content, 22)
    local header = new("Frame", content, {
        Name = "Toolbar", Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 0, 68),
        BackgroundColor3 = C.Header, BackgroundTransparency = 0.20,
        BorderSizePixel = 0, Active = true,
    })
    self.Header = header
    round(header, 18)
    border(header, C.Line, 0.80, 1)

    -- Soft blue glow + gradient icon tile, matching the supplied page-header reference.
    local titleGlow = new("Frame", header, {
        Name = "PageTitleIconGlow", Position = UDim2.fromOffset(7, 9),
        Size = UDim2.fromOffset(48, 48), BackgroundColor3 = C.Accent,
        BackgroundTransparency = 0.82, BorderSizePixel = 0,
    })
    round(titleGlow, 16)
    local iconShell = new("Frame", header, {
        Name = "PageTitleIconShell", Position = UDim2.fromOffset(10, 12),
        Size = UDim2.fromOffset(42, 42), BackgroundColor3 = C.Accent,
        BackgroundTransparency = 0.03, BorderSizePixel = 0,
    })
    self.PageTitleIconShell = iconShell
    round(iconShell, 13)
    new("UIGradient", iconShell, {
        Color = ColorSequence.new(Color3.fromRGB(42, 133, 255), Color3.fromRGB(20, 75, 164)),
        Rotation = 42,
    })
    border(iconShell, C.Accent, 0.58, 1)
    local titleGlyph = icon(iconShell, "components", 22, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        ImageColor3 = C.Inverse,
    })
    self.PageTitleIcon = titleGlyph
    local title = label(header, cfg.Title or "VortexionLua", {
        Position = UDim2.fromOffset(64, 11), Size = UDim2.new(1, -210, 0, 24),
        Font = Enum.Font.GothamSemibold, TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    self.TitleLabel = title
    local breadcrumbIcon = icon(header, "home", 13, {
        Position = UDim2.fromOffset(64, 39), ImageColor3 = C.Muted,
    })
    self.BreadcrumbIcon = breadcrumbIcon
    local subtitle = label(header, cfg.Subtitle or "Relax UI · Next", {
        Position = UDim2.fromOffset(82, 36), Size = UDim2.new(1, -226, 0, 18),
        TextSize = 10, TextColor3 = C.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    self.SubtitleLabel = subtitle
    self.DefaultSubtitle = cfg.Subtitle or "Relax UI · Next"

    local function chrome(iconName, offset)
        local b = button(header, "", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offset, 0.5, 0),
            Size = UDim2.fromOffset(36, 36), BackgroundColor3 = C.Row,
            BackgroundTransparency = 0.28, TextSize = 16,
        })
        round(b, 12)
        border(b, C.Line, 0.70, 1)
        icon(b, iconName, 16, {AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5)})
        return b
    end
    local minimize = chrome("minus", -100)
    local maximize = chrome("maximize", -56)
    local exit = chrome("close", -12)

    local pages = new("Frame", content, {
        Name = "Pages", Position = UDim2.fromOffset(0, 82),
        Size = UDim2.new(1, 0, 1, -82),
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
        BackgroundColor3 = C.Sidebar, BackgroundTransparency = 0.10,
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
        BackgroundTransparency = 0.25, BorderSizePixel = 0,
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
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.Faint,
        ScrollBarImageTransparency = 0.35,
        CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    self.NavScroll = navScroll
    new("UIPadding", navScroll, {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 13), PaddingBottom = UDim.new(0, 12)})
    new("UIListLayout", navScroll, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

    local footerDivider = new("Frame", sidebar, {
        Name = "FooterDivider",
        Position = UDim2.new(0, 13, 1, -59), Size = UDim2.new(1, -26, 0, 1),
        BackgroundColor3 = C.Line, BackgroundTransparency = 0.58, BorderSizePixel = 0,
    })
    self.FooterDivider = footerDivider
    self.FooterStatus = label(sidebar, "●  Interface ready", {
        Position = UDim2.new(0, 14, 1, -52), Size = UDim2.new(1, -28, 0, 22),
        TextSize = 11, TextColor3 = C.Green,
    })
    self.FooterCaption = label(sidebar, "Native UI • Touch ready", {
        Position = UDim2.new(0, 14, 1, -29), Size = UDim2.new(1, -28, 0, 16),
        TextSize = 10, TextColor3 = C.Muted,
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
                return math.min((order-1)*0.009,0.10)
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
        math.max(0.14,(duration or 0.30)*(self.MotionScale or 1)),
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
    self:_revealVisualTree(main,0.24)
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

function Window:_syncBlur()
    local effect=self.BlurEffect
    if self.Destroyed or not effect or not effect.Parent then return end
    self._blurRunId=(self._blurRunId or 0)+1
    local token=self._blurRunId
    local enabled=self.BlurEnabled and not self.Minimized and self.BlurSize>0
    if enabled then
        effect.Enabled=true
        self:_animate(effect,{Size=self.BlurSize},0.24,Enum.EasingStyle.Quint)
    elseif effect.Enabled then
        self:_animate(effect,{Size=0},0.18,Enum.EasingStyle.Quint,function()
            if self._blurRunId==token and effect.Parent then effect.Enabled=false end
        end)
    else
        effect.Size=0
    end
end

-- Public runtime control: window:SetBlurEnabled(true, 10)
function Window:SetBlurEnabled(enabled,size)
    if self.Destroyed then return end
    if size~=nil then self.BlurSize=math.clamp(tonumber(size) or self.BlurSize,0,24) end
    self.BlurEnabled=enabled==true
    self:_syncBlur()
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
        self:_syncBlur()
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
        -- Reserve a dedicated menu slot without covering the page icon.
        self.Menu.Position = UDim2.fromOffset(5, 18)
        self.Menu.Size = UDim2.fromOffset(28, 32)
        self.PageTitleIconShell.Position = UDim2.fromOffset(38, 12)
        self.TitleLabel.Position = UDim2.fromOffset(88, 11)
        self.TitleLabel.Size = UDim2.new(1, -232, 0, 24)
        self.BreadcrumbIcon.Position = UDim2.fromOffset(88, 39)
        self.SubtitleLabel.Position = UDim2.fromOffset(106, 36)
        self.SubtitleLabel.Size = UDim2.new(1, -250, 0, 18)
    else
        self.DrawerOpen = false
        self._drawerAnimating = false
        self.Scrim.Visible = false
        self.Sidebar.Visible = true
        self.Sidebar.Position = UDim2.fromOffset(7,7)
        self.Sidebar.Size = UDim2.new(0, 185, 1, -14)
        self.Content.Position = UDim2.fromOffset(198, 7)
        self.Content.Size = UDim2.new(1, -205, 1, -14)
        self.PageTitleIconShell.Position = UDim2.fromOffset(10, 12)
        self.TitleLabel.Position = UDim2.fromOffset(64, 11)
        self.TitleLabel.Size = UDim2.new(1, -210, 0, 24)
        self.BreadcrumbIcon.Position = UDim2.fromOffset(64, 39)
        self.SubtitleLabel.Position = UDim2.fromOffset(82, 36)
        self.SubtitleLabel.Size = UDim2.new(1, -226, 0, 18)
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
        if slider.Control and slider.Control.Knob and slider.Control.Knob.Parent then
            self:_spring(slider.Control.Knob,{Size=UDim2.fromOffset(14,14)},.16)
        end
        if slider.Control then safeCall(slider.Callback,slider.Control.Value) end
        self.Slider = nil
    end
end
function Window:Minimize()
    if self.Destroyed or self.Minimized or self._minimizing then return end
    self.Minimized=true
    self:_syncBlur()
    self._minimizing=true
    self:_stopSpring()
    local main,launcher=self.Main,self.Launcher
    local pos=main.AbsolutePosition
    local sz=main.AbsoluteSize
    local center=Vector2.new(pos.X+sz.X/2,pos.Y+sz.Y/2)
    self._restoreGeometry={Position=main.Position,Size=main.Size}
    launcher.Position=UDim2.fromOffset(center.X,center.Y)
    if self.Animations then
        self:_animate(main,{
            Position=UDim2.fromOffset(center.X,center.Y),
            Size=UDim2.fromOffset(54,54),
            BackgroundTransparency=1,
        },0.24,Enum.EasingStyle.Quart,function()
            if self.Destroyed or not self.Minimized then return end
            main.Visible=false
            main.Position=self._restoreGeometry.Position
            main.Size=self._restoreGeometry.Size
            main.BackgroundTransparency=self._baseWindowTransparency
            self._minimizing=false
            launcher.Visible=true
            launcher.Size=UDim2.fromOffset(42,42)
            self:_animate(launcher,{Size=UDim2.fromOffset(54,54)},0.16,Enum.EasingStyle.Quart)
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
    self:_syncBlur()
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
        self:_animate(main,target,0.30,Enum.EasingStyle.Quart,function()
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
    if self.BlurEffect and self.BlurEffect.Parent then
        self.BlurEffect:Destroy()
        self.BlurEffect=nil
    end
    if self.Gui then self.Gui:Destroy() end
end
function Window:Notify(config)
    config = config or {}
    if self.Destroyed then return end

    -- A toast must never sit over the active page. In desktop layout use the
    -- sidebar's existing status slot; on compact/mobile layout use the
    -- subtitle line so the notification remains visible without blocking UI.
    self._notifyToken = (self._notifyToken or 0) + 1
    local token = self._notifyToken
    local titleText = tostring(config.Title or "VortexionLua")
    local bodyText = tostring(config.Content or "Action complete")
    local duration = math.max(1, tonumber(config.Duration) or 3)
    local desktopSidebar = self.Sidebar and self.Sidebar.Visible
        and not compactViewport(self.Width, viewport())

    if self._toastFrame then
        self._toastFrame:Destroy()
        self._toastFrame = nil
    end

    if desktopSidebar then
        if self.FooterStatus then self.FooterStatus.Visible = false end
        if self.FooterCaption then self.FooterCaption.Visible = false end
        if self.FooterDivider then self.FooterDivider.Visible = false end

        local frame = new("Frame", self.Sidebar, {
            Name = "NotificationToast",
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 10, 1, 5),
            Size = UDim2.new(1, -20, 0, 48),
            BackgroundColor3 = C.Header,
            BorderSizePixel = 0,
            ZIndex = 20,
        })
        self._toastFrame = frame
        round(frame, 12)
        border(frame, C.Line, 0.58, 1)
        label(frame, titleText, {
            Position = UDim2.fromOffset(9, 5),
            Size = UDim2.new(1, -18, 0, 15),
            Font = Enum.Font.GothamSemibold,
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 21,
        })
        label(frame, bodyText, {
            Position = UDim2.fromOffset(9, 21),
            Size = UDim2.new(1, -18, 0, 21),
            TextSize = 9,
            TextColor3 = C.Muted,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 21,
        })
        self:_animate(frame, {Position = UDim2.new(0, 10, 1, -58)}, 0.22, Enum.EasingStyle.Quart)
        task.delay(duration, function()
            if self.Destroyed or self._notifyToken ~= token or not frame.Parent then return end
            self:_animate(frame, {Position = UDim2.new(0, 10, 1, 5)}, 0.18, Enum.EasingStyle.Quart, function()
                if frame.Parent then frame:Destroy() end
                if self._toastFrame == frame then self._toastFrame = nil end
                if self._notifyToken == token then
                    if self.FooterStatus then self.FooterStatus.Visible = true end
                    if self.FooterCaption then self.FooterCaption.Visible = true end
                    if self.FooterDivider then self.FooterDivider.Visible = true end
                end
            end)
        end)
        return
    end

    local subtitle = self.SubtitleLabel
    if not subtitle then return end
    subtitle.TextColor3 = C.Accent
    subtitle.Text = titleText .. "  ·  " .. bodyText
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    task.delay(duration, function()
        if self.Destroyed or self._notifyToken ~= token or not subtitle.Parent then return end
        if self.ActiveTab then
            local groupName = self.ActiveTab.ParentGroup and self.ActiveTab.ParentGroup.Name or "Interface"
            if string.lower(groupName) == string.lower(self.ActiveTab.Title) then
                subtitle.Text = "Workspace overview"
            else
                subtitle.Text = string.upper(groupName) .. "  /  " .. self.ActiveTab.Title
            end
        else
            subtitle.Text = self.DefaultSubtitle or "VortexionLua  /  Interface"
        end
        subtitle.TextColor3 = C.Muted
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
    if self.PageTitleIcon then
        local iconName=tab.NavIcon and string.gsub(tab.NavIcon.Name,"^Icon_","") or "components"
        self.PageTitleIcon.Name="PageTitleIcon_"..iconName
        for _,child in ipairs(self.PageTitleIcon:GetChildren()) do child:Destroy() end
        if tab.NavIcon then
            for _,segment in ipairs(tab.NavIcon:GetChildren()) do
                if segment:IsA("Frame") then
                    local copy=segment:Clone()
                    copy.Parent=self.PageTitleIcon
                    copy.BackgroundColor3=C.Accent
                    copy.BackgroundTransparency=0
                    copy.ZIndex=self.PageTitleIcon.ZIndex+1
                    for _,node in ipairs(copy:GetDescendants()) do
                        if node:IsA("Frame") then
                            node.BackgroundColor3=C.Accent
                            node.BackgroundTransparency=0
                            node.ZIndex=self.PageTitleIcon.ZIndex+1
                        end
                    end
                end
            end
        end
    end
    if self.SubtitleLabel then
        local groupName = tab.ParentGroup and tab.ParentGroup.Name or "Interface"
        if string.lower(groupName) == string.lower(tab.Title) then
            self.SubtitleLabel.Text = "Workspace overview"
        else
            self.SubtitleLabel.Text = string.upper(groupName) .. "  /  " .. tab.Title
        end
        self.SubtitleLabel.TextColor3 = C.Muted
    end
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
    -- Page switching is deliberately stationary: no spring, slide, zoom, or rebound.
    tab.Page.Position=UDim2.fromOffset(0,0)
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
        Name = "GroupTitle", Size = UDim2.new(1, 0, 0, 31),
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
        -- Pagination expansion is a plain size tween: no spring curve, overshoot,
        -- rebound, or synthetic scale. Cancellation continues from the current size.
        local tween=TweenService:Create(self.Clip,TweenInfo.new(
            0.18*self.Window.MotionScale,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
            {Size=target})
        self.Tween=tween
        tween.Completed:Once(function(state)
            if self.Tween~=tween then
                tween:Destroy()
                return
            end
            self.Tween=nil
            self._animating=false
            if state==Enum.PlaybackState.Completed and self.Clip.Parent then
                self.Clip.Size=target
                self:_measure()
            end
            tween:Destroy()
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
        Name = "Tab_" .. title, Size = UDim2.new(1,0,0,40),
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
        ScrollBarThickness = 4, ScrollBarImageColor3 = C.Faint,
        ScrollBarImageTransparency = 0.24,
        CanvasSize = UDim2.fromOffset(0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    new("UIPadding", page, {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 22), PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 12)})
    new("UIListLayout", page, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
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
    border(frame,C.Line,0.94,1)
    return frame
end

function Tab:_responsiveGrid(name,items,maxColumns,cellHeight,draw)
    local count=#items
    local gap=10
    local root=self:_surface(name,cellHeight,C.Window,1)
    local outerStroke=root:FindFirstChildWhichIsA("UIStroke")
    if outerStroke then outerStroke.Transparency=1 end
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
        border(card,C.Line,0.88,1)
        draw(card,entry,i)
    end
    self.Window:_connect(root:GetPropertyChangedSignal("AbsoluteSize"),recalc)
    task.defer(recalc)
    return root,recalc
end

function Tab:CreateHero(config)
    config=config or {}
    local frame=self:_surface("HeroSurface",150,C.Hero,0.02)
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
        Position=UDim2.fromOffset(20,38),Size=UDim2.new(1,-40,0,29),
        TextSize=20,Font=Enum.Font.GothamSemibold,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })
    label(frame,config.Description or "Your interface and tools in one place.",{
        Position=UDim2.fromOffset(20,68),Size=UDim2.new(1,-40,0,37),
        TextSize=12,TextColor3=C.Muted,TextWrapped=true,
        TextYAlignment=Enum.TextYAlignment.Top,
    })
    local primary=button(frame,config.ActionText or "Explore tools",{
        Position=UDim2.fromOffset(20,113),Size=UDim2.fromOffset(160,30),
        BackgroundColor3=C.Accent,TextColor3=C.Inverse,
        TextSize=11,
    })
    round(primary,10)
    icon(primary,config.ActionIcon or "play",14,{
        Position=UDim2.fromOffset(10,8),ImageColor3=C.Window,
    })
    new("UIPadding",primary,{PaddingLeft=UDim.new(0,31),PaddingRight=UDim.new(0,8)})
    self.Window:_connect(primary.Activated,function() safeCall(config.Callback) end)
    return {Frame=frame,Button=primary}
end

function Tab:CreateStatGrid(config)
    config=config or {}
    local items=config.Items or {}
    local out={}
    local root=self:_responsiveGrid("StatGrid",items,config.Columns or 3,88,function(card,item,index)
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
            Position=UDim2.fromOffset(13,34),Size=UDim2.new(1,-26,0,27),
            TextSize=23,Font=Enum.Font.GothamSemibold,
            TextTruncate=Enum.TextTruncate.AtEnd,
        })
        label(card,item.Footnote or "",{
            Position=UDim2.fromOffset(13,66),Size=UDim2.new(1,-26,0,16),
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
    local root=self:_responsiveGrid("ActionGrid",items,config.Columns or 2,82,function(card,item,index)
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
            Position=UDim2.fromOffset(14,43),Size=UDim2.new(1,-28,0,29),
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
    local root=self:_responsiveGrid("SelectionGrid",items,config.Columns or 3,86,function(card,item,index)
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
            Position=UDim2.fromOffset(14,59),Size=UDim2.new(1,-28,0,16),
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
    local detailHeight=math.max(48,16+#details*22)
    local headerHeight=52
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
            Position=UDim2.fromOffset(5,8+(i-1)*22),
            Size=UDim2.new(1,-12,0,20),
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
    local height=20+#items*36+10
    local frame=self:_surface("ActivityFeed",height,C.SurfaceSoft,0.08)
    label(frame,config.Title or "Recent activity",{
        Position=UDim2.fromOffset(14,9),Size=UDim2.new(1,-28,0,23),
        TextSize=12,Font=Enum.Font.GothamSemibold,
    })
    for i,item in ipairs(items) do
        local y=29+(i-1)*36
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
        Name="ControlRow",Size=UDim2.new(1,-3,0,height or 60),
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
    local row,titleLabel,descLabel=self:_row(config.Title or "Button",config.Description or "",60)
    local action=button(row,config.ButtonText or "Run",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(110,32),BackgroundColor3=C.Accent,TextColor3=C.Inverse,
    })
    round(action,14)
    self:_fitControlRow(row,titleLabel,descLabel,action,104,60,30)
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
    local row,titleLabel,descLabel=self:_row(config.Title or "Toggle",config.Description or "",60)
    local track=button(row,"",{
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-13,0.5,0),
        Size=UDim2.fromOffset(47,26),BackgroundColor3=C.Line,
    })
    round(track,13)
    self:_fitControlRow(row,titleLabel,descLabel,track,45,60,25)
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
        row.Size=UDim2.new(1,-3,0,narrow and 86 or 76)
        sliderTitle.Size=UDim2.new(1,-105,0,23)
        valueLabel.Position=UDim2.new(1,-96,0,7)
        hit.Position=UDim2.fromOffset(13,narrow and 50 or 36)
        hit.Size=UDim2.new(1,-26,0,30)
    end)
    local rail=new("Frame",hit,{Position=UDim2.new(0,0,0.5,-2),Size=UDim2.new(1,0,0,4),BackgroundColor3=C.Line,BorderSizePixel=0})
    round(rail,2)
    local fill=new("Frame",rail,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.Accent,BorderSizePixel=0})
    round(fill,2)
    local knob=new("Frame",rail,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.Inverse,BorderSizePixel=0})
    round(knob,7)
    local ctrl={Value=min,Window=self.Window,LastCallback=0,Knob=knob}
    function ctrl:SetValue(value,quiet)
        local raw=math.clamp(tonumber(value) or min,min,max)
        self.Value=math.clamp(min+math.floor((raw-min)/step+0.5)*step,min,max)
        local alpha=max==min and 0 or (self.Value-min)/(max-min)
        local dragging=self.Window and self.Window.Slider and self.Window.Slider.Control==self
        if quiet or self.Window==nil or dragging then
            fill.Size=UDim2.new(alpha,0,1,0);knob.Position=UDim2.fromScale(alpha,0.5)
        else
            self.Window:_animate(fill,{Size=UDim2.new(alpha,0,1,0)},.16,Enum.EasingStyle.Quint)
            self.Window:_animate(knob,{Position=UDim2.fromScale(alpha,0.5)},.16,Enum.EasingStyle.Quint)
            self.Window:_animate(valueLabel,{TextColor3=C.Accent},.10,Enum.EasingStyle.Quint,function()
                if valueLabel.Parent then self.Window:_animate(valueLabel,{TextColor3=C.Muted},.18,Enum.EasingStyle.Quint)end
            end)
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
        self.Window:_spring(knob,{Size=UDim2.fromOffset(18,18)},.11)
        update(input.Position.X)
    end)
    ctrl:SetValue(config.Default == nil and min or config.Default,true)
    return ctrl
end
local function extraPointer(input)
    local kind=input.UserInputType
    return kind==Enum.UserInputType.Touch or kind==Enum.UserInputType.MouseButton1
end
local function extraPress(window,object,restingColor,activeColor,shrink)
    local baseSize=object.Size
    local pressedSize=UDim2.new(baseSize.X.Scale,baseSize.X.Offset-(shrink and 2 or 0),
        baseSize.Y.Scale,baseSize.Y.Offset-(shrink and 2 or 0))
    local function resting()
        if type(restingColor)=="function" then return restingColor() end
        return restingColor
    end
    local function apply(input,down)
        if not extraPointer(input) then return end
        local props={}
        if shrink then props.Size=down and pressedSize or baseSize end
        if object.BackgroundTransparency<1 then
            local color=down and activeColor or resting()
            if color then props.BackgroundColor3=color end
        end
        if next(props) then window:_spring(object,props,down and .11 or .17) end
    end
    window:_connect(object.InputBegan,function(input)apply(input,true)end)
    window:_connect(object.InputEnded,function(input)apply(input,false)end)
end
local function extraRender(window,object,properties,animate,duration)
    if animate then
        window:_animate(object,properties,duration or .17,Enum.EasingStyle.Quint)
    else
        for key,value in pairs(properties) do object[key]=value end
    end
end
local function extraIconOpacity(window,root,visible,animate)
    root.Visible=true
    for _,segment in ipairs(root:GetChildren()) do
        if segment:IsA("Frame") then
            extraRender(window,segment,{BackgroundTransparency=visible and 0 or 1},animate,.14)
        end
    end
end

function Tab:CreateInput(config)
    config=config or {}
    local row,titleLabel,descLabel=self:_row(config.Title or "Input",config.Description or "",68)
    local input=new("TextBox",row,{
        Name="InputControl",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(156,38),BackgroundColor3=C.Panel,BorderSizePixel=0,
        Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.Text,
        PlaceholderColor3=C.Muted,PlaceholderText=tostring(config.Placeholder or "Enter value"),
        Text=tostring(config.Default or ""),ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
    })
    round(input,11);local stroke=border(input,C.Line,.58,1)
    self:_fitControlRow(row,titleLabel,descLabel,input,142,68,36)
    new("UIPadding",input,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8)})
    local ctrl={Value=input.Text}
    function ctrl:SetValue(value,quiet)
        input.Text=tostring(value or "");self.Value=input.Text
        if not quiet then safeCall(config.Callback,self.Value)end
    end
    function ctrl:GetValue()return input.Text end
    ctrl.Set=ctrl.SetValue
    self.Window:_connect(input.Focused,function()
        self.Window:_animate(stroke,{Color=C.Accent,Transparency=.16,Thickness=1.35},.15,Enum.EasingStyle.Quint)
        self.Window:_animate(input,{BackgroundColor3=C.Window},.15,Enum.EasingStyle.Quint)
    end)
    self.Window:_connect(input.FocusLost,function(enter)
        self.Window:_animate(stroke,{Color=C.Line,Transparency=.58,Thickness=1},.18,Enum.EasingStyle.Quint)
        self.Window:_animate(input,{BackgroundColor3=C.Panel},.18,Enum.EasingStyle.Quint)
        ctrl.Value=input.Text;safeCall(config.Callback,input.Text,enter)
    end)
    return ctrl
end

function Tab:CreateDropdown(c)
    c=c or {}
    local items=c.Values or c.Options or {}
    local multi=c.Multi==true
    local frame=self:_surface("Dropdown",61,C.Row,.3)
    -- Dropdown and multiselect expand inside this layout slot. Keep the slot
    -- transparent so the popup is not wrapped in a second, oversized surface.
    frame.BackgroundTransparency=1
    local surfaceStroke=frame:FindFirstChildWhichIsA("UIStroke")
    if surfaceStroke then surfaceStroke:Destroy() end
    label(frame,c.Title or "Dropdown",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,22),TextSize=12,Font=Enum.Font.GothamMedium})
    local trigger=button(frame,c.Placeholder or "Choose",{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-24,0,28),
        BackgroundColor3=C.Panel,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
    round(trigger,9);border(trigger,C.Line,.78,1)
    new("UIPadding",trigger,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,30)})
    local arrow=icon(trigger,"chevron_down",15,{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-4,0.5,0),ImageColor3=C.Muted})
    -- The popup container itself stays transparent: only individual option
    -- cards are painted, so no spare dark strip remains below the final option.
    local list=new("Frame",frame,{Position=UDim2.fromOffset(12,60),Size=UDim2.new(1,-24,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Visible=false})
    local optionHeight, optionGap, popupPad = 28, 3, 3
    local popupContentHeight = popupPad*2 + #items*optionHeight + math.max(0,#items-1)*optionGap
    round(list,9)
    local scrolling=new("ScrollingFrame",list,{Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),
        CanvasSize=UDim2.fromOffset(0,popupContentHeight),
        ScrollBarThickness=3,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarImageColor3=C.Muted})
    new("UIPadding",scrolling,{
        PaddingTop=UDim.new(0,popupPad),PaddingBottom=UDim.new(0,popupPad),
        PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2),
    })
    new("UIListLayout",scrolling,{Padding=UDim.new(0,optionGap),SortOrder=Enum.SortOrder.LayoutOrder})
    local values={};local value=nil;local expanded=false;local ctrl={Window=self.Window}
    local optionButtons={}
    local function selection()
        if not multi then return value end
        local arr={}
        for _,item in ipairs(items) do
            local v=type(item)=="table" and (item.Value or item.Title) or item
            if values[v] then arr[#arr+1]=v end
        end
        return arr
    end
    local function redraw(animate)
        if multi then
            local arr=selection();local names={}
            for _,v in ipairs(arr) do names[#names+1]=tostring(v)end
            trigger.Text=#names>0 and table.concat(names,", ") or (c.Placeholder or "Choose")
        else trigger.Text=tostring(value or c.Placeholder or "Choose")end
        for i,item in ipairs(items) do
            local v=type(item)=="table" and (item.Value or item.Title) or item
            local selected=multi and values[v]==true or (not multi and value==v)
            local entry=optionButtons[i]
            if entry then
                extraRender(self.Window,entry.Button,{BackgroundColor3=selected and C.AccentLow or C.SurfaceSoft,
                    TextColor3=selected and C.Text or C.Muted},animate,.15)
                extraRender(self.Window,entry.Stroke,{Color=selected and C.Accent or C.Line,
                    Transparency=selected and .48 or .86},animate,.15)
            end
        end
        if animate then
            self.Window:_animate(trigger,{BackgroundColor3=C.AccentLow},.10,Enum.EasingStyle.Quint,function()
                if trigger.Parent and not expanded then self.Window:_animate(trigger,{BackgroundColor3=C.Panel},.18,Enum.EasingStyle.Quint)end
            end)
        end
    end
    function ctrl:GetValue()return selection()end
    function ctrl:SetValue(v,quiet)
        if multi then
            values={}
            if type(v)=="table" then for _,x in ipairs(v)do values[x]=true end
            elseif v~=nil then values[v]=true end
        else value=v end
        redraw(not quiet)
        if not quiet then safeCall(c.Callback,selection())end
    end
    ctrl.Set=ctrl.SetValue
    local function expand(open)
        expanded=open
        local height=open and math.min(154,popupContentHeight) or 0
        list.Visible=true
        self.Window:_animate(arrow,{Rotation=open and 180 or 0},.18,Enum.EasingStyle.Quint)
        animateIconTint(self.Window,arrow,open and C.Accent or C.Muted,.18)
        self.Window:_animate(trigger,{BackgroundColor3=open and C.AccentLow or C.Panel},.16,Enum.EasingStyle.Quint)
        self.Window:_animate(frame,{Size=UDim2.new(1,-3,0,61+height)},.20,Enum.EasingStyle.Quart)
        self.Window:_animate(list,{Size=UDim2.new(1,-24,0,height)},.20,Enum.EasingStyle.Quart,function()
            if not expanded then list.Visible=false end
        end)
    end
    extraPress(self.Window,trigger,function()return expanded and C.AccentLow or C.Panel end,C.AccentLow,false)
    self.Window:_connect(trigger.Activated,function()expand(not expanded)end)
    for i,item in ipairs(items)do
        local v=type(item)=="table" and (item.Value or item.Title) or item
        local name=type(item)=="table" and (item.Title or tostring(v)) or tostring(v)
        local b=button(scrolling,name,{Size=UDim2.new(1,-4,0,optionHeight),LayoutOrder=i,
            BackgroundColor3=C.SurfaceSoft,BackgroundTransparency=0.10,TextColor3=C.Muted,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
        round(b,8);new("UIPadding",b,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,8)})
        local stroke=border(b,C.Line,.75,1)
        optionButtons[i]={Button=b,Stroke=stroke}
        extraPress(self.Window,b,function()
            local selected=multi and values[v]==true or (not multi and value==v)
            return selected and C.AccentLow or C.SurfaceSoft
        end,C.AccentLow,false)
        self.Window:_connect(b.Activated,function()
            if multi then values[v]=not values[v] else value=v end
            redraw(true);safeCall(c.Callback,selection())
            if not multi then expand(false)end
        end)
    end
    ctrl:SetValue(c.Default,true)
    return ctrl
end

function Tab:CreateCheckbox(c)
    c=c or {}
    local row=self:_surface("Checkbox",50,C.Row,.3)
    local box=button(row,"",{Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(25,25),BackgroundColor3=C.Panel})
    round(box,8);local stroke=border(box,C.Line,.58,1)
    local mark=icon(box,"check",15,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),ImageColor3=C.Inverse,ImageTransparency=1})
    mark.Visible=true
    label(row,c.Title or "Checkbox",{Position=UDim2.fromOffset(47,3),Size=UDim2.new(1,-59,0,23),TextSize=12,Font=Enum.Font.GothamMedium})
    label(row,c.Description or "",{Position=UDim2.fromOffset(47,26),Size=UDim2.new(1,-59,0,19),TextSize=10,TextColor3=C.Muted})
    local ctrl={Value=false,Window=self.Window}
    function ctrl:SetValue(v,quiet)
        self.Value=v==true
        local on=self.Value
        if quiet then
            box.BackgroundColor3=on and C.Accent or C.Panel
            stroke.Color=on and C.Accent or C.Line;stroke.Transparency=on and .22 or .58
            extraIconOpacity(self.Window,mark,on,false)
        else
            self.Window:_animate(box,{BackgroundColor3=on and C.Accent or C.Panel},.17,Enum.EasingStyle.Quint)
            self.Window:_animate(stroke,{Color=on and C.Accent or C.Line,Transparency=on and .22 or .58},.17,Enum.EasingStyle.Quint)
            extraIconOpacity(self.Window,mark,on,true)
            self.Window:_spring(box,{Size=UDim2.fromOffset(on and 27 or 25,on and 27 or 25)},.14)
        end
        if not quiet then safeCall(c.Callback,self.Value)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    extraPress(self.Window,box,function()return ctrl.Value and C.Accent or C.Panel end,C.AccentLow,false)
    self.Window:_connect(box.Activated,function()ctrl:SetValue(not ctrl.Value)end)
    ctrl:SetValue(c.Default,true)
    return ctrl
end

function Tab:CreateKeybind(c)
    c=c or {}
    local row=self:_surface("Keybind",54,C.Row,.3)
    label(row,c.Title or "Keybind",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-120,0,22),TextSize=12,Font=Enum.Font.GothamMedium})
    label(row,c.Description or "Tap to assign",{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-120,0,18),TextSize=10,TextColor3=C.Muted})
    local key=button(row,"",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(100,31),
        BackgroundColor3=C.Panel,TextSize=11})
    round(key,9);border(key,C.Line,.62,1)
    local ctrl={Value=c.Default or Enum.KeyCode.RightShift,Listening=false,Window=self.Window}
    function ctrl:SetValue(v,quiet)
        self.Value=v;self.Listening=false
        key.Text=typeof(v)=="EnumItem" and v.Name or tostring(v)
        if quiet then key.BackgroundColor3=C.Panel
        else
            self.Window:_animate(key,{BackgroundColor3=C.AccentLow,TextColor3=C.Text},.11,Enum.EasingStyle.Quint,function()
                if key.Parent then self.Window:_animate(key,{BackgroundColor3=C.Panel},.20,Enum.EasingStyle.Quint)end
            end)
            safeCall(c.Callback,v)
        end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    extraPress(self.Window,key,function()return ctrl.Listening and C.AccentLow or C.Panel end,C.AccentLow,true)
    self.Window:_connect(key.Activated,function()
        ctrl.Listening=true;key.Text="Press key"
        self.Window:_animate(key,{BackgroundColor3=C.AccentLow,TextColor3=C.Text},.14,Enum.EasingStyle.Quint)
    end)
    self.Window:_connect(game:GetService("UserInputService").InputBegan,function(input,processed)
        if ctrl.Listening and input.UserInputType==Enum.UserInputType.Keyboard then
            ctrl:SetValue(input.KeyCode)
        elseif not processed and not ctrl.Listening and input.KeyCode==ctrl.Value then safeCall(c.OnPressed)end
    end)
    ctrl:SetValue(ctrl.Value,true)
    return ctrl
end

function Tab:CreateRadioGroup(c)
    c=c or {}
    local items=c.Values or c.Options or {}
    local row=self:_surface("RadioGroup",34+#items*34,C.Row,.3)
    label(row,c.Title or "Choose one",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,22),Font=Enum.Font.GothamMedium})
    local ctrl={Value=c.Default,Window=self.Window}
    local buttons={}
    local function redraw(animate)
        for _,entry in ipairs(buttons)do
            local on=entry.Value==ctrl.Value
            extraRender(self.Window,entry.Button,{BackgroundColor3=on and C.AccentLow or C.Panel,
                TextColor3=on and C.Text or C.Muted},animate,.16)
            extraRender(self.Window,entry.Stroke,{Color=on and C.Accent or C.Line,
                Transparency=on and .24 or .68},animate,.16)
            extraIconOpacity(self.Window,entry.Mark,on,animate)
        end
    end
    function ctrl:SetValue(v,quiet)
        self.Value=v;redraw(not quiet)
        if not quiet then safeCall(c.Callback,v)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    for i,item in ipairs(items)do
        local value=type(item)=="table" and (item.Value or item.Title) or item
        local name=type(item)=="table" and (item.Title or tostring(value)) or tostring(item)
        local b=button(row,name,{Position=UDim2.fromOffset(12,30+(i-1)*34),Size=UDim2.new(1,-24,0,31),
            BackgroundColor3=C.Panel,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
        round(b,9);new("UIPadding",b,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,34)})
        local stroke=border(b,C.Line,.68,1)
        local mark=icon(b,"check",14,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),
            ImageColor3=C.Accent,ImageTransparency=1})
        buttons[#buttons+1]={Button=b,Stroke=stroke,Mark=mark,Value=value}
        extraPress(self.Window,b,function()return value==ctrl.Value and C.AccentLow or C.Panel end,C.AccentLow,false)
        self.Window:_connect(b.Activated,function()ctrl:SetValue(value)end)
    end
    ctrl:SetValue(ctrl.Value or (buttons[1] and buttons[1].Value),true)
    return ctrl
end

function Tab:CreateColorPicker(c)
 c=c or {}
 local row=self:_surface("ColorPicker",152,C.Row,0.3)
 label(row,c.Title or "Color Picker",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-82,0,23),TextSize=12})
 local preview=new("Frame",row,{Position=UDim2.new(1,-58,0,7),Size=UDim2.fromOffset(44,24),BackgroundColor3=c.Default or C.Accent,BorderSizePixel=0})
 round(preview,8);border(preview,C.Line,.48,1)
 local controls={};local value=c.Default or C.Accent;local ctrl={}
 local function setColor(color,quiet,immediate)
  value=color
  if immediate or quiet then preview.BackgroundColor3=color
  else self.Window:_animate(preview,{BackgroundColor3=color},.13,Enum.EasingStyle.Quint) end
  for index,entry in ipairs(controls) do
   local channel=index==1 and color.R or (index==2 and color.G or color.B)
   entry.Number.Text=tostring(math.floor(channel*255+0.5))
   entry.Fill.Size=UDim2.new(channel,0,1,0)
  end
  if not quiet then safeCall(c.Callback,value) end
 end
 function ctrl:SetValue(v,quiet)
  if typeof(v)=="Color3" then setColor(v,quiet,false) end
 end
 function ctrl:GetValue()return value end
 ctrl.Set=ctrl.SetValue
 for i,name in ipairs({"R","G","B"}) do
  local y=36+(i-1)*35
  label(row,name,{Position=UDim2.fromOffset(13,y),Size=UDim2.fromOffset(20,24),TextSize=11})
  local bar=button(row,"",{Position=UDim2.fromOffset(37,y+7),Size=UDim2.new(1,-98,0,11),BackgroundColor3=C.Line})
  round(bar,6)
  local fill=new("Frame",bar,{BackgroundColor3=i==1 and Color3.fromRGB(240,106,115) or (i==2 and Color3.fromRGB(120,205,155) or Color3.fromRGB(120,170,255)),Size=UDim2.fromScale(0,1),BorderSizePixel=0})
  round(fill,6)
  local amount=new("TextBox",row,{Position=UDim2.new(1,-53,0,y),Size=UDim2.fromOffset(40,24),BackgroundColor3=C.Panel,TextColor3=C.Text,TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,ClearTextOnFocus=false})
  round(amount,6)
  controls[i]={Bar=bar,Fill=fill,Number=amount}
  self.Window:_connect(bar.InputBegan,function(input)
   if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
   local function change(x)
    local f=math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1)
    local rgb={value.R,value.G,value.B};rgb[i]=f
    setColor(Color3.new(rgb[1],rgb[2],rgb[3]),false,true)
   end
   change(input.Position.X)
   local move,done
   move=game:GetService("UserInputService").InputChanged:Connect(function(update)
    if update.UserInputType==Enum.UserInputType.Touch or update.UserInputType==Enum.UserInputType.MouseMovement then change(update.Position.X) end
   end)
   done=game:GetService("UserInputService").InputEnded:Connect(function(update)
    if update.UserInputType==input.UserInputType then move:Disconnect();done:Disconnect() end
   end)
   self.Window:_connect(row.Destroying,function()if move.Connected then move:Disconnect()end;if done.Connected then done:Disconnect()end end)
  end)
  self.Window:_connect(amount.FocusLost,function()
   local channel=math.clamp(tonumber(amount.Text) or 0,0,255)/255
   local rgb={value.R,value.G,value.B};rgb[i]=channel
   setColor(Color3.new(rgb[1],rgb[2],rgb[3]),false)
  end)
 end
 setColor(value,true);return ctrl
end

-- VortexionUI Next 0.3.9 -- independent native Luau components.
-- UI components inspired by feature sets of Cascade, WindUI, Starlight.
-- Inserted into VortexionUI_Next.lua before its compatibility aliases.
local function extraOption(entry)
    if type(entry)=="table" then
        local value=entry.Value
        if value==nil then value=entry.Title or entry.Name end
        return value,tostring(entry.Title or entry.Name or value)
    end
    return entry,tostring(entry)
end
local function extraValue(initial,draw,callback)
    local ctrl={Value=initial}
    function ctrl:SetValue(v,quiet)
        self.Value=v;draw(v)
        if not quiet then safeCall(callback,v) end
    end
    function ctrl:GetValue() return self.Value end
    ctrl.Set=ctrl.SetValue
    return ctrl
end

function Tab:CreateTextArea(c)
    c=c or {}
    local height=math.clamp(tonumber(c.Height) or 140,112,310)
    local root=self:_surface("TextArea",height,C.Row,.3)
    label(root,c.Title or "Notes",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,22),Font=Enum.Font.GothamMedium})
    local input=new("TextBox",root,{
        Position=UDim2.fromOffset(12,32),Size=UDim2.new(1,-24,1,-44),
        BackgroundColor3=C.Panel,BorderSizePixel=0,Font=Enum.Font.Gotham,
        Text=tostring(c.Default or ""),PlaceholderText=tostring(c.Placeholder or "Enter text"),
        TextSize=12,TextColor3=C.Text,PlaceholderColor3=C.Muted,
        ClearTextOnFocus=false,MultiLine=true,TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
    })
    round(input,10)
    local stroke=border(input,C.Line,.62,1)
    new("UIPadding",input,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,6)})
    self.Window:_connect(input.Focused,function()
        self.Window:_animate(stroke,{Color=C.Accent,Transparency=.16,Thickness=1.35},.16,Enum.EasingStyle.Quint)
        self.Window:_animate(input,{BackgroundColor3=C.Window},.16,Enum.EasingStyle.Quint)
    end)
    self.Window:_connect(input.FocusLost,function()
        self.Window:_animate(stroke,{Color=C.Line,Transparency=.62,Thickness=1},.18,Enum.EasingStyle.Quint)
        self.Window:_animate(input,{BackgroundColor3=C.Panel},.18,Enum.EasingStyle.Quint)
    end)
    local ctrl=extraValue(input.Text,function(v)input.Text=tostring(v or "")end,c.Callback)
    function ctrl:GetValue()return input.Text end
    self.Window:_connect(input.FocusLost,function(enter)
        ctrl.Value=input.Text;safeCall(c.Callback,input.Text,enter)
    end)
    return ctrl
end

function Tab:CreateStepper(c)
    c=c or {}
    local min=tonumber(c.Min or c.Minimum) or 0
    local max=tonumber(c.Max or c.Maximum) or 100
    if max<min then min,max=max,min end
    local step=math.max(.000001,math.abs(tonumber(c.Step) or 1))
    local decimals=math.clamp(math.floor(tonumber(c.Decimals) or (step<1 and 2 or 0)),0,5)
    local row,title,desc=self:_row(c.Title or "Stepper",c.Description or "",65)
    local wrap=new("Frame",row,{BackgroundTransparency=1,BorderSizePixel=0})
    self:_fitControlRow(row,title,desc,wrap,154,65,36)
    local minus=button(wrap,"",{Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(38,36),BackgroundColor3=C.Panel})
    icon(minus,"minus",16,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),ImageColor3=C.Text})
    local amount=new("TextBox",wrap,{Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-84,0,36),
        Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=C.Text,BackgroundColor3=C.Window,
        TextXAlignment=Enum.TextXAlignment.Center,TextEditable=c.Editable==true,
        ClearTextOnFocus=false,BorderSizePixel=0})
    local plus=button(wrap,"",{Position=UDim2.new(1,-38,0,0),Size=UDim2.fromOffset(38,36),BackgroundColor3=C.Panel})
    icon(plus,"plus",16,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),ImageColor3=C.Text})
    round(minus,10);round(amount,10);round(plus,10)
    border(minus,C.Line,.65,1);local amountStroke=border(amount,C.Line,.55,1);border(plus,C.Line,.65,1)
    local function normalized(v)
        v=math.clamp(tonumber(v) or min,min,max)
        return math.clamp(tonumber(string.format("%.5f",min+math.floor((v-min)/step+.5)*step)) or min,min,max)
    end
    local ctrl={Value=normalized(c.Default or min),Window=self.Window}
    local function draw(v,animate)
        amount.Text=string.format("%."..decimals.."f",v)
        minus.TextTransparency=v<=min and .58 or 0
        plus.TextTransparency=v>=max and .58 or 0
        if animate then
            self.Window:_animate(amount,{BackgroundColor3=C.AccentLow},.09,Enum.EasingStyle.Quint,function()
                if amount.Parent then self.Window:_animate(amount,{BackgroundColor3=C.Window},.19,Enum.EasingStyle.Quint) end
            end)
            self.Window:_animate(amountStroke,{Color=C.Accent,Transparency=.18},.10,Enum.EasingStyle.Quint,function()
                if amountStroke.Parent then self.Window:_animate(amountStroke,{Color=C.Line,Transparency=.55},.20,Enum.EasingStyle.Quint) end
            end)
        else
            amount.BackgroundColor3=C.Window;amountStroke.Color=C.Line;amountStroke.Transparency=.55
        end
    end
    function ctrl:SetValue(v,quiet)
        self.Value=normalized(v);draw(self.Value,not quiet)
        if not quiet then safeCall(c.Callback,self.Value) end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    extraPress(self.Window,minus,function()return C.Panel end,C.AccentLow,true)
    extraPress(self.Window,plus,function()return C.Panel end,C.AccentLow,true)
    self.Window:_connect(minus.Activated,function()if ctrl.Value>min then ctrl:SetValue(ctrl.Value-step)end end)
    self.Window:_connect(plus.Activated,function()if ctrl.Value<max then ctrl:SetValue(ctrl.Value+step)end end)
    self.Window:_connect(amount.Focused,function()
        self.Window:_animate(amountStroke,{Color=C.Accent,Transparency=.16,Thickness=1.35},.14,Enum.EasingStyle.Quint)
    end)
    self.Window:_connect(amount.FocusLost,function()
        self.Window:_animate(amountStroke,{Color=C.Line,Transparency=.55,Thickness=1},.18,Enum.EasingStyle.Quint)
        if c.Editable then ctrl:SetValue(tonumber(amount.Text) or ctrl.Value) end
    end)
    draw(ctrl.Value,false)
    return ctrl
end

function Tab:CreateSegmentedControl(c)
    c=c or {}
    local items=c.Values or c.Options or {}
    local root=self:_surface("SegmentedControl",85,C.Row,.3)
    label(root,c.Title or "Selection",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,23),Font=Enum.Font.GothamMedium})
    local rail=new("Frame",root,{Position=UDim2.fromOffset(12,34),Size=UDim2.new(1,-24,0,38),
        BackgroundColor3=C.Panel,BorderSizePixel=0,ClipsDescendants=true})
    round(rail,11);border(rail,C.Line,.62,1)
    local count=math.max(1,#items)
    local indicator=new("Frame",rail,{Position=UDim2.new(0,4,0,4),Size=UDim2.new(1/count,-8,1,-8),
        BackgroundColor3=C.AccentLow,BorderSizePixel=0,ZIndex=1})
    round(indicator,8)
    local buttons={}
    local default=c.Default
    if default==nil and items[1]~=nil then default=extraOption(items[1])end
    local ctrl={Value=default,Window=self.Window}
    local function draw(value,animate)
        local selectedIndex=nil
        for i,item in ipairs(items) do
            local selected=extraOption(item)==value
            if selected then selectedIndex=i end
            local b=buttons[i]
            if b then extraRender(self.Window,b,{TextColor3=selected and C.Text or C.Muted},animate,.16) end
        end
        if selectedIndex then
            indicator.Visible=true
            local props={Position=UDim2.new((selectedIndex-1)/count,4,0,4),Size=UDim2.new(1/count,-8,1,-8)}
            if animate then self.Window:_spring(indicator,props,.23)
            else indicator.Position=props.Position;indicator.Size=props.Size end
        else indicator.Visible=false end
    end
    function ctrl:SetValue(value,quiet)
        self.Value=value;draw(value,not quiet)
        if not quiet then safeCall(c.Callback,value)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    for i,item in ipairs(items) do
        local value,name=extraOption(item)
        local b=button(rail,name,{Position=UDim2.new((i-1)/count,0,0,0),Size=UDim2.new(1/count,0,1,0),
            BackgroundTransparency=1,TextColor3=C.Muted,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=2})
        buttons[i]=b
        extraPress(self.Window,b,function()return C.Panel end,nil,false)
        self.Window:_connect(b.Activated,function()ctrl:SetValue(value)end)
    end
    ctrl:SetValue(default,true)
    return ctrl
end

function Tab:CreateChipGroup(c)
    c=c or {}
    local items=c.Values or c.Options or {}
    local multiple=c.Multi==true
    local root=self:_surface("ChipGroup",78,C.Row,.3)
    label(root,c.Title or "Tags",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,22),Font=Enum.Font.GothamMedium})
    local holder=new("Frame",root,{Position=UDim2.fromOffset(12,31),Size=UDim2.new(1,-24,0,40),BackgroundTransparency=1})
    local grid=new("UIGridLayout",holder,{CellPadding=UDim2.fromOffset(6,6),CellSize=UDim2.fromOffset(110,34),
        SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal})
    local chosen={}
    local chips={}
    local ctrl={Window=self.Window}
    local function current()
        local values={}
        for _,item in ipairs(items) do
            local value=extraOption(item)
            if chosen[value] then
                if not multiple then return value end
                values[#values+1]=value
            end
        end
        return multiple and values or nil
    end
    local function draw(animate)
        for _,entry in ipairs(chips) do
            local on=chosen[entry.Value]==true
            extraRender(self.Window,entry.Button,{BackgroundColor3=on and C.AccentLow or C.Panel,
                TextColor3=on and C.Text or C.Muted},animate,.17)
            extraRender(self.Window,entry.Stroke,{Color=on and C.Accent or C.Line,
                Transparency=on and .22 or .68},animate,.17)
        end
    end
    function ctrl:GetValue()return current()end
    function ctrl:SetValue(v,quiet)
        table.clear(chosen)
        if multiple and type(v)=="table" then
            for _,entry in ipairs(v) do chosen[entry]=true end
        elseif v~=nil then chosen[v]=true end
        self.Value=current();draw(not quiet)
        if not quiet then safeCall(c.Callback,self:GetValue())end
    end
    ctrl.Set=ctrl.SetValue
    for i,item in ipairs(items) do
        local value,name=extraOption(item)
        local chip=button(holder,name,{BackgroundColor3=C.Panel,TextColor3=C.Muted,TextSize=11,
            LayoutOrder=i,TextTruncate=Enum.TextTruncate.AtEnd})
        round(chip,13)
        local stroke=border(chip,C.Line,.68,1)
        chips[#chips+1]={Value=value,Button=chip,Stroke=stroke}
        self.Window:_connect(chip.Activated,function()
            if multiple then
                local nextSelected={}
                for _,other in ipairs(items) do
                    local v=extraOption(other)
                    if chosen[v] and v~=value then nextSelected[#nextSelected+1]=v end
                end
                if not chosen[value] then nextSelected[#nextSelected+1]=value end
                ctrl:SetValue(nextSelected)
            else ctrl:SetValue(value)end
        end)
    end
    local lastWidth=0
    local function resize()
        if not root.Parent then return end
        local width=root.AbsoluteSize.X-24
        if width<1 then return end
        if math.abs(width-lastWidth)>1 then
            lastWidth=width
            local columns=math.max(1,math.min(math.max(1,#items),math.floor((width+6)/116)))
            grid.FillDirectionMaxCells=columns
            grid.CellSize=UDim2.new(1/columns,-6*(columns-1)/columns,0,34)
        end
        task.defer(function()
            if not root.Parent then return end
            local contentHeight=grid.AbsoluteContentSize.Y
            holder.Size=UDim2.new(1,-24,0,contentHeight)
            local targetHeight=math.max(49,31+contentHeight+12)
            if math.abs(root.AbsoluteSize.Y-targetHeight)>1 then
                self.Window:_animate(root,{Size=UDim2.new(1,-3,0,targetHeight)},.18,Enum.EasingStyle.Quart)
            end
        end)
    end
    self.Window:_connect(root:GetPropertyChangedSignal("AbsoluteSize"),resize)
    self.Window:_connect(grid:GetPropertyChangedSignal("AbsoluteContentSize"),resize)
    task.defer(resize)
    ctrl:SetValue(c.Default,true)
    return ctrl
end

function Tab:CreateAccordion(c)
    c=c or {}
    local bodyHeight=math.clamp(tonumber(c.ContentHeight) or 90,48,300)
    local root=self:_surface("Accordion",55,C.Row,.3)
    root.ClipsDescendants=true
    local head=button(root,c.Title or "Details",{Position=UDim2.fromOffset(11,7),Size=UDim2.new(1,-22,0,39),
        BackgroundColor3=C.Panel,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
    round(head,11);border(head,C.Line,.68,1)
    new("UIPadding",head,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,38)})
    local arrow=icon(head,"chevron_down",16,{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),ImageColor3=C.Muted})
    local body=label(root,tostring(c.Content or c.Description or ""),{Position=UDim2.fromOffset(14,58),
        Size=UDim2.new(1,-28,0,bodyHeight-12),TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,
        TextColor3=C.Muted,TextSize=11,TextTransparency=1})
    local ctrl={Value=false,Window=self.Window}
    function ctrl:SetValue(value,quiet)
        self.Value=value==true
        local opened=self.Value
        self.Window:_animate(root,{Size=UDim2.new(1,-3,0,opened and (55+bodyHeight) or 55)},.22,Enum.EasingStyle.Quart)
        self.Window:_animate(arrow,{Rotation=opened and 180 or 0},.20,Enum.EasingStyle.Quint)
        animateIconTint(self.Window,arrow,opened and C.Accent or C.Muted,.20)
        self.Window:_animate(head,{BackgroundColor3=opened and C.AccentLow or C.Panel},.18,Enum.EasingStyle.Quint)
        self.Window:_animate(body,{TextTransparency=opened and 0 or 1},opened and .20 or .10,Enum.EasingStyle.Quint)
        if not quiet then safeCall(c.Callback,self.Value)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue;ctrl.SetExpanded=ctrl.SetValue
    extraPress(self.Window,head,function()return ctrl.Value and C.AccentLow or C.Panel end,C.AccentLow,false)
    self.Window:_connect(head.Activated,function()ctrl:SetValue(not ctrl.Value)end)
    ctrl:SetValue(c.DefaultOpen==true,true)
    return ctrl
end

function Tab:CreateCode(c)
    c=c or {}
    local h=math.clamp(tonumber(c.Height) or 155,100,330)
    local root=self:_surface("Code",h,C.Panel,.15)
    label(root,c.Title or "Code",{Position=UDim2.fromOffset(12,6),Size=UDim2.new(1,-110,0,24),Font=Enum.Font.GothamMedium})
    local copy=button(root,"Copy",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,5),Size=UDim2.fromOffset(74,27),
        BackgroundColor3=C.AccentLow,TextSize=11,TextColor3=C.Text})
    round(copy,9);border(copy,C.Line,.65,1)
    local code=new("TextBox",root,{Position=UDim2.fromOffset(12,38),Size=UDim2.new(1,-24,1,-50),
        BackgroundColor3=C.Window,BorderSizePixel=0,Font=Enum.Font.Code,TextSize=12,TextColor3=C.Text,
        TextWrapped=true,MultiLine=true,TextEditable=false,TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,ClearTextOnFocus=false,Text=""})
    round(code,10);border(code,C.Line,.72,1)
    new("UIPadding",code,{PaddingLeft=UDim.new(0,10),PaddingTop=UDim.new(0,8),PaddingRight=UDim.new(0,7)})
    local ctrl=extraValue(tostring(c.Code or c.Content or ""),function(v)code.Text=tostring(v or "")end,c.Callback)
    extraPress(self.Window,copy,function()return C.AccentLow end,C.Accent,true)
    self.Window:_connect(copy.Activated,function()
        local copied=false
        if type(setclipboard)=="function" then copied=pcall(setclipboard,ctrl.Value) end
        if copied then
            copy.Text="Copied"
            self.Window:_animate(copy,{BackgroundColor3=C.Green,TextColor3=C.Inverse},.12,Enum.EasingStyle.Quint)
            task.delay(1.15,function()
                if copy.Parent and not self.Window.Destroyed then
                    copy.Text="Copy"
                    self.Window:_animate(copy,{BackgroundColor3=C.AccentLow,TextColor3=C.Text},.18,Enum.EasingStyle.Quint)
                end
            end)
            self.Window:Notify({Title="Code",Content="Copied to clipboard"})
        else self.Window:Notify({Title="Code",Content="Clipboard API unavailable"})end
    end)
    ctrl:SetValue(ctrl.Value,true)
    return ctrl
end

function Tab:CreateImage(c)
    c=c or {}
    local h=math.clamp(tonumber(c.Height) or 166,100,340)
    local root=self:_surface("ImageSurface",h,C.Panel,.15)
    label(root,c.Title or "Image",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,22)})
    local img=new("ImageLabel",root,{Position=UDim2.fromOffset(12,32),Size=UDim2.new(1,-24,1,-44),
        BackgroundColor3=C.Window,BorderSizePixel=0,ScaleType=Enum.ScaleType.Fit})
    round(img,10)
    local ctrl=extraValue("",function(v)
        local value=v or ""
        if type(value)=="number" then value="rbxassetid://"..math.floor(value)end
        img.Image=tostring(value)
    end,c.Callback)
    local old=ctrl.SetValue
    function ctrl:SetValue(v,quiet)
        local value=v or ""
        if type(value)=="number" then value="rbxassetid://"..math.floor(value) end
        old(self,tostring(value),quiet)
    end
    ctrl.Set=ctrl.SetValue
    ctrl:SetValue(c.Image or c.Source or "",true)
    return ctrl
end

function Tab:CreateStatus(c)
    c=c or {}
    local row,title,desc=self:_row(c.Title or "Status",c.Description or "",64)
    local pill=label(row,"",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),
        Size=UDim2.fromOffset(102,31),TextXAlignment=Enum.TextXAlignment.Center,TextSize=11,Font=Enum.Font.GothamMedium})
    pill.BackgroundTransparency=0
    round(pill,12);local pillStroke=border(pill,C.Line,.7,1)
    self:_fitControlRow(row,title,desc,pill,102,64,31)
    local colors={Success={C.Green,C.AccentLow},Warning={Color3.fromRGB(242,191,110),C.Panel},
        Error={Color3.fromRGB(255,132,140),C.Panel},Info={C.Accent,C.AccentLow},Neutral={C.Muted,C.Panel}}
    local ctrl={Value=c.Default or "Neutral",Window=self.Window}
    local function draw(value,animate)
        pill.Text=tostring(value or "Neutral")
        local pair=colors[tostring(value)] or colors.Neutral
        extraRender(self.Window,pill,{TextColor3=pair[1],BackgroundColor3=pair[2]},animate,.18)
        extraRender(self.Window,pillStroke,{Color=pair[1],Transparency=.68},animate,.18)
    end
    function ctrl:SetValue(value,quiet)
        self.Value=tostring(value or "Neutral");draw(self.Value,not quiet)
        if not quiet then safeCall(c.Callback,self.Value)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    draw(ctrl.Value,false)
    return ctrl
end

function Tab:CreateRating(c)
    c=c or {}
    local n=math.clamp(math.floor(tonumber(c.Max) or 5),1,10)
    local root=self:_surface("Rating",82,C.Row,.3)
    label(root,c.Title or "Rating",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,23),Font=Enum.Font.GothamMedium})
    local rail=new("Frame",root,{Position=UDim2.fromOffset(12,34),Size=UDim2.new(1,-24,0,36),BackgroundTransparency=1})
    local stars={}
    local ctrl={Value=0,Window=self.Window}
    local gold=Color3.fromRGB(246,200,105)
    local function draw(value,animate)
        for i,b in ipairs(stars) do
            local active=i<=value
            local tint=active and gold or C.Muted
            local glyph=b:FindFirstChild("RatingGlyph")
            if glyph then for _,child in ipairs(glyph:GetDescendants()) do
                if child:IsA("ImageLabel") then child.ImageColor3=tint
                elseif child:IsA("Frame") and child.BackgroundTransparency<1 then child.BackgroundColor3=tint end
            end end
            extraRender(self.Window,b,{TextSize=active and 23 or 20},animate,.16)
        end
    end
    function ctrl:SetValue(v,quiet)
        self.Value=math.clamp(math.floor(tonumber(v) or 0),0,n)
        draw(self.Value,not quiet)
        if not quiet then safeCall(c.Callback,self.Value)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    for i=1,n do
        local b=button(rail,"",{Position=UDim2.new((i-1)/n,2,0,0),Size=UDim2.new(1/n,-4,1,0),
            BackgroundTransparency=1,TextColor3=C.Muted,TextSize=20,Font=Enum.Font.GothamMedium})
        icon(b,"star",18,{Name="RatingGlyph",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),ImageColor3=C.Muted})
        stars[i]=b
        self.Window:_connect(b.InputBegan,function(input)
            if extraPointer(input) then self.Window:_spring(b,{TextSize=24},.10) end
        end)
        self.Window:_connect(b.InputEnded,function(input)
            if extraPointer(input) then self.Window:_spring(b,{TextSize=i<=ctrl.Value and 23 or 20},.16) end
        end)
        self.Window:_connect(b.Activated,function()ctrl:SetValue(i)end)
    end
    ctrl:SetValue(c.Default or 0,true)
    return ctrl
end

function Tab:CreateKeyValue(c)
    c=c or {}
    local items=c.Items or {}
    local count=math.min(#items,30)
    local root=self:_surface("KeyValue",37+count*30,C.Panel,.15)
    label(root,c.Title or "Details",{Position=UDim2.fromOffset(13,7),Size=UDim2.new(1,-26,0,23)})
    local values={}
    for i=1,count do
        local item=items[i]
        label(root,tostring(item.Key or item.Title or ""),{Position=UDim2.fromOffset(13,34+(i-1)*30),
            Size=UDim2.new(.5,-18,0,24),TextSize=11,TextColor3=C.Muted,TextTruncate=Enum.TextTruncate.AtEnd})
        values[i]=label(root,tostring(item.Value or ""),{Position=UDim2.new(.5,0,0,34+(i-1)*30),
            Size=UDim2.new(.5,-14,0,24),TextXAlignment=Enum.TextXAlignment.Right,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd})
    end
    return {SetValue=function(_,index,value)if values[index] then values[index].Text=tostring(value or "")end end}
end

function Tab:CreateList(c)
    c=c or {}
    local items=c.Items or {}
    local count=math.min(#items,24)
    local root=self:_surface("ActionList",40+count*47,C.Panel,.15)
    label(root,c.Title or "Items",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,24),Font=Enum.Font.GothamMedium})
    local entries={}
    local ctrl={Value=nil,Index=nil,Window=self.Window}
    local function draw(animate)
        for _,entry in ipairs(entries) do
            local active=entry.Index==ctrl.Index
            extraRender(self.Window,entry.Button,{BackgroundColor3=active and C.AccentLow or C.Row,
                TextColor3=active and C.Text or C.Muted},animate,.16)
            extraRender(self.Window,entry.Stroke,{Color=active and C.Accent or C.Line,
                Transparency=active and .24 or .76},animate,.16)
            entry.Marker.Visible=active
            if animate then self.Window:_animate(entry.Marker,{BackgroundTransparency=active and 0 or 1},.14,Enum.EasingStyle.Quint)
            else entry.Marker.BackgroundTransparency=active and 0 or 1 end
        end
    end
    function ctrl:SetValue(value,quiet,index)
        self.Value=value
        if index then self.Index=index else
            self.Index=nil
            for _,entry in ipairs(entries) do if entry.Value==value then self.Index=entry.Index;break end end
        end
        draw(not quiet)
        if not quiet then safeCall(c.Callback,self.Value,self.Index)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    for i=1,count do
        local item=items[i]
        local value=type(item)=="table" and (item.Value or item.Title) or item
        local name=type(item)=="table" and tostring(item.Title or value) or tostring(item)
        local desc=type(item)=="table" and tostring(item.Description or "") or ""
        local b=button(root,name,{Position=UDim2.fromOffset(12,37+(i-1)*47),Size=UDim2.new(1,-24,0,42),
            BackgroundColor3=C.Row,TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=desc~="" and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd})
        round(b,10)
        local stroke=border(b,C.Line,.76,1)
        new("UIPadding",b,{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,desc~="" and 4 or 0)})
        local marker=new("Frame",b,{Position=UDim2.fromOffset(0,7),Size=UDim2.fromOffset(3,28),
            BackgroundColor3=C.Accent,BackgroundTransparency=1,BorderSizePixel=0})
        round(marker,3)
        if desc~="" then label(b,desc,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-25,0,16),
            TextSize=10,TextColor3=C.Muted,TextTruncate=Enum.TextTruncate.AtEnd})end
        entries[#entries+1]={Value=value,Index=i,Button=b,Stroke=stroke,Marker=marker}
        extraPress(self.Window,b,function()return ctrl.Index==i and C.AccentLow or C.Row end,C.AccentLow,false)
        self.Window:_connect(b.Activated,function()
            ctrl:SetValue(value,false,i)
            if type(item)=="table" then safeCall(item.Callback,value,i)end
        end)
    end
    return ctrl
end

function Tab:CreateTimeline(c)
    c=c or {}
    local items=c.Items or {}
    local count=math.min(#items,30)
    local root=self:_surface("Timeline",40+count*55,C.Panel,.15)
    label(root,c.Title or "Timeline",{Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,24)})
    if count>1 then new("Frame",root,{Position=UDim2.fromOffset(23,53),Size=UDim2.fromOffset(2,(count-1)*55),BackgroundColor3=C.Line,BorderSizePixel=0})end
    for i=1,count do
        local entry=items[i];local y=39+(i-1)*55
        local dot=new("Frame",root,{Position=UDim2.fromOffset(18,y+7),Size=UDim2.fromOffset(12,12),BackgroundColor3=entry.Color or C.Accent,BorderSizePixel=0})
        round(dot,8)
        label(root,tostring(entry.Title or "Event"),{Position=UDim2.fromOffset(40,y),Size=UDim2.new(1,-54,0,22),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
        label(root,tostring(entry.Description or entry.Time or ""),{Position=UDim2.fromOffset(40,y+23),Size=UDim2.new(1,-54,0,20),TextSize=10,TextColor3=C.Muted,TextTruncate=Enum.TextTruncate.AtEnd})
    end
    return root
end

function Tab:CreateSearch(c)
    c=c or {}
    local items=c.Items or c.Options or {}
    local maxResults=math.clamp(math.floor(tonumber(c.MaxResults) or 6),1,12)
    local root=self:_surface("Search",76,C.Row,.3)
    label(root,c.Title or "Search",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,21),Font=Enum.Font.GothamMedium})
    local input=new("TextBox",root,{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-24,0,36),
        BackgroundColor3=C.Panel,TextColor3=C.Text,PlaceholderColor3=C.Muted,
        PlaceholderText=tostring(c.Placeholder or "Search items"),Text="",TextSize=12,
        Font=Enum.Font.Gotham,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0})
    round(input,10);new("UIPadding",input,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8)})
    local inputStroke=border(input,C.Line,.62,1)
    self.Window:_connect(input.Focused,function()
        self.Window:_animate(inputStroke,{Color=C.Accent,Transparency=.16,Thickness=1.35},.15,Enum.EasingStyle.Quint)
        self.Window:_animate(input,{BackgroundColor3=C.Window},.15,Enum.EasingStyle.Quint)
    end)
    self.Window:_connect(input.FocusLost,function()
        self.Window:_animate(inputStroke,{Color=C.Line,Transparency=.62,Thickness=1},.18,Enum.EasingStyle.Quint)
        self.Window:_animate(input,{BackgroundColor3=C.Panel},.18,Enum.EasingStyle.Quint)
    end)
    local ctrl={Value=nil}
    function ctrl:SetValue(v,quiet)
        self.Value=v
        if not quiet then safeCall(c.Callback,v)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    local rows={}
    local refresh
    for i=1,maxResults do
        local b=button(root,"",{Position=UDim2.fromOffset(12,71+(i-1)*38),Size=UDim2.new(1,-24,0,34),
            BackgroundColor3=C.Panel,TextSize=11,Visible=false,TextTransparency=1,BackgroundTransparency=1,
            TextTruncate=Enum.TextTruncate.AtEnd})
        round(b,8);local stroke=border(b,C.Line,.76,1)
        rows[i]={Button=b,Stroke=stroke,Value=nil,Token=0}
        extraPress(self.Window,b,function()return C.Panel end,C.AccentLow,false)
        self.Window:_connect(b.Activated,function()
            local value=rows[i].Value
            ctrl:SetValue(value)
            if c.CloseOnSelect~=false then
                rows._dismissed=true;rows._suppress=true
                input.Text=tostring(value or "")
                rows._suppress=false
                task.defer(function()if root.Parent and refresh then refresh()end end)
            end
        end)
    end
    local noResults=label(root,"No matching results",{Position=UDim2.fromOffset(14,74),
        Size=UDim2.new(1,-28,0,28),TextSize=11,TextColor3=C.Muted,TextTransparency=1,Visible=false})
    local function showRow(entry,value,name)
        entry.Token=entry.Token+1
        entry.Value=value
        local b=entry.Button
        local wasVisible=b.Visible
        b.Text=name
        if not wasVisible then
            b.TextTransparency=1;b.BackgroundTransparency=1;b.Visible=true
            entry.Stroke.Transparency=.95
            self.Window:_animate(b,{TextTransparency=0,BackgroundTransparency=0},.16,Enum.EasingStyle.Quint)
            self.Window:_animate(entry.Stroke,{Transparency=.76},.16,Enum.EasingStyle.Quint)
        else self.Window:_animate(b,{TextColor3=C.Text},.12,Enum.EasingStyle.Quint)end
    end
    local function hideRow(entry)
        if not entry.Button.Visible then return end
        entry.Token=entry.Token+1
        local token=entry.Token
        self.Window:_animate(entry.Button,{TextTransparency=1,BackgroundTransparency=1},.10,Enum.EasingStyle.Quint,function()
            if entry.Token==token and entry.Button.Parent then entry.Button.Visible=false end
        end)
        self.Window:_animate(entry.Stroke,{Transparency=1},.10,Enum.EasingStyle.Quint)
    end
    refresh=function()
        local query=string.lower(string.gsub(input.Text,"^%s*(.-)%s*$","%1"))
        local shown=0
        if query~="" and not rows._dismissed then
            for _,entry in ipairs(items) do
                local value,name=extraOption(entry)
                if string.find(string.lower(name),query,1,true) then
                    shown=shown+1
                    if shown>maxResults then break end
                    showRow(rows[shown],value,name)
                end
            end
        end
        for i=shown+1,maxResults do hideRow(rows[i])end
        local noMatch=query~="" and not rows._dismissed and shown==0
        noResults.Visible=noMatch
        if noMatch then
            noResults.TextTransparency=1
            self.Window:_animate(noResults,{TextTransparency=0},.15,Enum.EasingStyle.Quint)
        end
        local targetHeight=76+shown*38+(noMatch and 34 or 0)
        self.Window:_animate(root,{Size=UDim2.new(1,-3,0,targetHeight)},.19,Enum.EasingStyle.Quart)
        safeCall(c.OnQueryChanged,input.Text)
    end
    self.Window:_connect(input:GetPropertyChangedSignal("Text"),function()
        if not rows._suppress then rows._dismissed=false end
        refresh()
    end)
    self.Window:_connect(input.Focused,function()rows._dismissed=false end)
    refresh()
    return ctrl
end

function Tab:CreateTooltip(c)
    c=c or {}
    local height=math.clamp(tonumber(c.Height) or 72,52,180)
    local root=self:_surface("Tooltip",54,C.Row,.3)
    root.ClipsDescendants=true
    local title=label(root,c.Title or "Help",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-77,0,34),Font=Enum.Font.GothamMedium})
    local trigger=button(root,"?",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,10),
        Size=UDim2.fromOffset(39,34),BackgroundColor3=C.AccentLow,TextSize=16})
    round(trigger,12);border(trigger,C.Line,.62,1)
    local body=label(root,c.Content or c.Text or "",{Position=UDim2.fromOffset(13,58),Size=UDim2.new(1,-26,0,height-8),
        TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,TextSize=11,TextColor3=C.Muted,TextTransparency=1})
    local ctrl={Value=false,Window=self.Window}
    function ctrl:SetValue(v,quiet)
        self.Value=v==true
        local opened=self.Value
        self.Window:_animate(root,{Size=UDim2.new(1,-3,0,opened and (54+height) or 54)},.20,Enum.EasingStyle.Quart)
        self.Window:_animate(trigger,{BackgroundColor3=opened and C.Accent or C.AccentLow},.16,Enum.EasingStyle.Quint)
        self.Window:_animate(title,{TextColor3=opened and C.Accent or C.Text},.16,Enum.EasingStyle.Quint)
        self.Window:_animate(body,{TextTransparency=opened and 0 or 1},opened and .18 or .10,Enum.EasingStyle.Quint)
        if not quiet then safeCall(c.Callback,self.Value)end
    end
    function ctrl:GetValue()return self.Value end
    ctrl.Set=ctrl.SetValue
    extraPress(self.Window,trigger,function()return ctrl.Value and C.Accent or C.AccentLow end,C.Accent,true)
    self.Window:_connect(trigger.Activated,function()ctrl:SetValue(not ctrl.Value)end)
    ctrl:SetValue(c.DefaultOpen==true,true)
    return ctrl
end

Tab.TextArea=Tab.CreateTextArea
Tab.Stepper=Tab.CreateStepper
Tab.SegmentedControl=Tab.CreateSegmentedControl
Tab.ChipGroup=Tab.CreateChipGroup
Tab.Accordion=Tab.CreateAccordion
Tab.Code=Tab.CreateCode
Tab.Image=Tab.CreateImage
Tab.Status=Tab.CreateStatus
Tab.Rating=Tab.CreateRating
Tab.KeyValue=Tab.CreateKeyValue
Tab.List=Tab.CreateList
Tab.Timeline=Tab.CreateTimeline
Tab.Search=Tab.CreateSearch
Tab.Tooltip=Tab.CreateTooltip
UI.NextComponentCatalog={"TextArea","Stepper","SegmentedControl","ChipGroup","Accordion","Code","Image","Status","Rating","KeyValue","List","Timeline","Search","Tooltip"}

-- Compatibility aliases for the first-step test. Remaining WindUI/Cascade/
-- Starlight-equivalent widgets are intentionally reserved for later steps.
Tab.Dropdown=Tab.CreateDropdown
Tab.Checkbox=Tab.CreateCheckbox
Tab.Keybind=Tab.CreateKeybind
Tab.RadioGroup=Tab.CreateRadioGroup
Tab.ColorPicker=Tab.CreateColorPicker
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
