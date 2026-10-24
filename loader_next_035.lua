-- Vortexion Surface 0.3.5 - spring motion overhaul with staggered reveal (Android / gethui)
local BASE="https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/releases/VortexionUI_Next_0_3_5.lua"
local EXPECTED="0.3.5-compact-motion"
local root=nil
local function clearOld()
    if not root then return end
    for _,name in ipairs({"Vortexion_Next_Step1","VortexionNextError"}) do
        local obj=root:FindFirstChild(name)
        while obj do
            obj:Destroy()
            obj=root:FindFirstChild(name)
        end
    end
end
local function showError(message)
    warn("[Surface 0.3.5] "..tostring(message))
    if not root then return end
    local gui=Instance.new("ScreenGui")
    gui.Name="VortexionNextError"
    gui.DisplayOrder=2000
    gui.ResetOnSpawn=false
    gui.Parent=root
    local box=Instance.new("TextLabel")
    box.Name="Error"
    box.Size=UDim2.new(0.84,0,0,86)
    box.Position=UDim2.new(0.08,0,0,80)
    box.BackgroundColor3=Color3.fromRGB(37,39,46)
    box.TextColor3=Color3.fromRGB(255,224,224)
    box.TextWrapped=true
    box.Font=Enum.Font.Gotham
    box.TextSize=14
    box.Text="Surface 0.3.5 ERROR: "..tostring(message)
    box.Parent=gui
end
local ok, result=pcall(function()
    assert(type(gethui)=="function","gethui() is unavailable")
    root=gethui()
    assert(typeof(root)=="Instance","gethui() returned invalid root")
    local env=type(getgenv)=="function" and getgenv() or _G
    if env.VortexionNextWindow then
        pcall(function()env.VortexionNextWindow:Destroy()end)
        env.VortexionNextWindow=nil
    end
    clearOld()
    local raw=game:HttpGet(BASE.."?unique=compact_035")
    assert(type(raw)=="string" and #raw>30000,"release source download incomplete")
    assert(raw:find(EXPECTED,1,true),"downloaded file is not version 0.3.5")
    local chunk,err=loadstring(raw)
    assert(chunk,"Luau syntax error: "..tostring(err))
    local UI=chunk()
    assert(type(UI)=="table" and UI.Version==EXPECTED,"wrong runtime version: "..tostring(UI and UI.Version))
    local window=UI.CreateWindow({Title="VortexionLua",Subtitle="Surface UI · 0.3.5",Width=760,Height=450,Transparency=0.10})
    env.VortexionNextWindow=window
    assert(window.Gui:GetAttribute("VortexionVersion")==EXPECTED,"runtime version stamp failed")
    local general=window:CreateTabGroup("OVERVIEW")
    local home=general:CreateTab("Overview",{Selected=true})
    home:CreateHero({
        Eyebrow="VORTEXION LUA  /  SURFACE",
        Title="Your workspace",
        Description="A responsive native interface, designed for touch and clear typography.",
        ActionText="Show notification",ActionIcon="bell",
        Callback=function() window:Notify({Title="VortexionLua",Content="The new surface layout is active."}) end,
    })
    home:CreateSection("At a glance")
    home:CreateStatGrid({Columns=3,Items={
        {Title="Components",Value="07",Footnote="New layouts",Icon="grid"},
        {Title="Motion",Value="On",Footnote="Spring enabled",Icon="activity"},
        {Title="Platform",Value="Android",Footnote="Touch adaptive",Icon="monitor"},
    }})
    home:CreateSection("Quick actions")
    home:CreateActionGrid({Columns=2,Items={
        {Title="Interface",Description="Test native controls",Icon="settings",Callback=function() window:Notify({Title="Interface",Content="Open Controls to test switches and sliders."}) end},
        {Title="Appearance",Description="Inspect selection tiles",Icon="palette",Callback=function() window:Notify({Title="Appearance",Content="Selection grid is on the Layout page."}) end},
    }})
    home:CreateActivityFeed({Title="System activity",Items={
        {Title="Layout loaded",Description="Adaptive surfaces initialized",Time="NOW"},
        {Title="Motion ready",Description="Spring and staggered reveal active",Time="READY"},
    }})
    local tools=window:CreateTabGroup("TOOLS")
    local scripts=tools:CreateTab("Scripts")
    scripts:CreateToggle({Title="Enable",Description="Switch animation check",Default=true})
    scripts:CreateSlider({Title="Value",Min=0,Max=100,Default=64,Suffix="%"})
    local forms=tools:CreateTab("Inputs")
    forms:CreateInput({Title="Name",Description="Responsive text input",Default="Vortexion"})
    local layout=window:CreateTabGroup("LAYOUT")
    local showcase=layout:CreateTab("Surfaces")
    showcase:CreateSection("Selection")
    showcase:CreateSelectionGrid({Columns=3,Default="balanced",Items={
        {Title="Balanced",Description="Recommended",Value="balanced",Icon="grid"},
        {Title="Minimal",Description="Less visual weight",Value="minimal",Icon="minus"},
        {Title="Detailed",Description="More information",Value="detailed",Icon="chart"},
    },Callback=function(value) window:Notify({Title="Layout",Content="Selected "..tostring(value)}) end})
    showcase:CreateExpandablePanel({Title="Advanced layout",Description="Tap to expand details",Icon="settings",Lines={
        "Native Roblox UI primitives",
        "Adaptive grids for narrow screens",
        "Reduced font scaling for clarity",
    }})
    showcase:CreateCompactRow({Title="Layout engine",Description="Responsive surface primitives",Icon="grid",Action="Inspect",Callback=function()
        window:Notify({Title="Layout engine",Content="V0.3.5 surface layout"})
    end})
    return window
end)
if not ok then
    clearOld()
    showError(result)
    return nil
end
return result
