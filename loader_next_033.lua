-- Vortexion Surface 0.3.3 - spring motion overhaul with staggered reveal (Android / gethui)
local BASE="https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/releases/VortexionUI_Next_0_3_3.lua"
local EXPECTED="0.3.3-motion-overhaul"
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
    warn("[Surface 0.3.3] "..tostring(message))
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
    box.Text="Surface 0.3.3 ERROR: "..tostring(message)
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
    local raw=game:HttpGet(BASE.."?unique=surface_033")
    assert(type(raw)=="string" and #raw>30000,"release source download incomplete")
    assert(raw:find(EXPECTED,1,true),"downloaded file is not version 0.3.3")
    local chunk,err=loadstring(raw)
    assert(chunk,"Luau syntax error: "..tostring(err))
    local UI=chunk()
    assert(type(UI)=="table" and UI.Version==EXPECTED,"wrong runtime version: "..tostring(UI and UI.Version))
    local window=UI.CreateWindow({Title="VortexionLua",Subtitle="Surface UI · 0.3.3",Width=850,Height=520,Transparency=0.10})
    env.VortexionNextWindow=window
    assert(window.Gui:GetAttribute("VortexionVersion")==EXPECTED,"runtime version stamp failed")
    local general=window:CreateTabGroup("OVERVIEW")
    local home=general:CreateTab("Overview",{Selected=true})
    home:CreateSection("Surface 0.3.3")
    home:CreateParagraph({Title="Visual validation",Content="Spring motion overhaul is active: spring entrance, staggered crisp reveal, directional page transitions, animated drawer, collapsible groups, tactile controls and minimize/restore."})
    home:CreateBadge({Text="VERSION VERIFIED",Icon="check",Variant="Success"})
    home:CreateDivider({Label="Component showcase"})
    home:CreateProgress({Title="Initialization complete",Value=100})
    home:CreateButton({Title="Notification",ButtonText="Show",Callback=function()
        window:Notify({Title="Surface 0.3.3",Content="Runtime verified."})
    end})
    local tools=window:CreateTabGroup("TOOLS")
    local scripts=tools:CreateTab("Scripts")
    scripts:CreateToggle({Title="Enable",Description="Switch animation check",Default=true})
    scripts:CreateSlider({Title="Value",Min=0,Max=100,Default=64,Suffix="%"})
    local forms=tools:CreateTab("Inputs")
    forms:CreateInput({Title="Name",Default="Vortexion"})
    return window
end)
if not ok then
    clearOld()
    showError(result)
    return nil
end
return result
