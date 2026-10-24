-- Relax UI Next: clean-room stage-one visual acceptance
local BASE="https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/VortexionUI_Next.lua?rev=video_visual_013"
local function showError(message)
    warn("[Relax Next] "..tostring(message))
    if type(gethui)~="function" then return end
    local ok,root=pcall(gethui)
    if not ok or typeof(root)~="Instance" then return end
    local gui=Instance.new("ScreenGui");gui.Name="VortexionNextError";gui.DisplayOrder=2000;gui.Parent=root
    local text=Instance.new("TextLabel");text.Size=UDim2.new(0.9,0,0,70);text.Position=UDim2.new(0.05,0,0,75);text.BackgroundColor3=Color3.fromRGB(35,35,42);text.TextColor3=Color3.new(1,1,1);text.TextWrapped=true;text.Text=tostring(message);text.Parent=gui
end
local ok,result=pcall(function()
    local raw=game:HttpGet(BASE)
    assert(type(raw)=="string" and #raw>3000,"source download failed")
    local chunk,why=loadstring(raw)
    assert(chunk,why)
    local UI=chunk()
    assert(type(UI)=="table" and type(UI.CreateWindow)=="function","library return invalid")
    local state=type(getgenv)=="function" and getgenv() or _G
    if state.VortexionNextWindow then pcall(function()state.VortexionNextWindow:Destroy()end)end
    local window=UI.CreateWindow({Title="Overview",Subtitle="Interface preview · Step 1",Width=790,Height=492,Transparency=0.12})
    state.VortexionNextWindow=window
    local main=window:CreateTabGroup("GENERAL")
    local home=main:CreateTab("Overview",{Selected=true})
    home:CreateSection("Dashboard")
    home:CreateParagraph({Title="Clean-room UI — first-step preview",Content="Desktop-inspired shell, clear navigation hierarchy, low-noise surfaces, native controls, and gethui() mounting."})
    home:CreateButton({Title="Notification",Description="Check action feedback",ButtonText="Show",Callback=function()window:Notify({Title="Relax UI Next",Content="Button callback is working."})end})
    home:CreateToggle({Title="Minimal motion",Description="Preview a boolean setting",Default=true})
    home:CreateSlider({Title="Interface scaling",Min=0,Max=100,Default=64,Suffix="%"})
    local forms=main:CreateTab("Inputs")
    forms:CreateSection("Basic form elements")
    forms:CreateInput({Title="Profile name",Default="Vortexion"})
    forms:CreateToggle({Title="Enable notifications",Default=true})
    local groups=window:CreateTabGroup("LIBRARY")
    local example=groups:CreateTab("Components")
    example:CreateParagraph({Title="Component catalog",Content="Next stages will extend this clean shell with advanced controls, dialogs, themes and motion."})
    local nested=groups:CreateGroup("Examples")
    nested:CreateTab("Navigation"):CreateParagraph({Title="Nested page",Content="Two-level sidebar navigation is active."})
    return window
end)
if not ok then showError(result);return nil end
return result
