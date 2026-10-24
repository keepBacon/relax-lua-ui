-- Relax UI MD3 rounds 1-2 audited Android entrypoint; uses versioned source path.
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader.lua"))()
local SOURCE = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/releases/RelaxUI_0_6_0_md3_r4.lua?v=android_r4_20261024"
local ENV = (type(getgenv) == "function" and getgenv()) or _G

local function mountDiagnostic()
    assert(type(gethui) == "function", "[RelaxUI] gethui() required")
    local parent = gethui()
    assert(typeof(parent) == "Instance", "[RelaxUI] gethui() did not return an Instance")
    local gui = Instance.new("ScreenGui")
    gui.Name = "RelaxUI_Diagnostic"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100000
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Name = "Status"
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0, 55)
    label.Size = UDim2.new(0.9, 0, 0, 46)
    label.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
    label.TextColor3 = Color3.fromRGB(245, 245, 250)
    label.TextSize = 13
    label.TextWrapped = true
    label.Font = Enum.Font.Gotham
    label.Text = "RelaxUI: starting"
    label.Parent = gui
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 12)
    return gui, label
end

if type(ENV.RelaxUI_AutoStart) == "table" and ENV.RelaxUI_AutoStart.Window then
    pcall(function() ENV.RelaxUI_AutoStart.Window:Destroy() end)
end
if type(ENV.RelaxUI_AutoStart) == "table" and ENV.RelaxUI_AutoStart.Diagnostic then
    pcall(function() ENV.RelaxUI_AutoStart.Diagnostic:Destroy() end)
end

local state = {Status = "starting", Window = nil, Diagnostic = nil, Error = nil}
ENV.RelaxUI_AutoStart = state
local panel, label = mountDiagnostic()
state.Diagnostic = panel
local function status(stage, message)
    state.Status = stage
    label.Text = "RelaxUI · " .. stage .. (message and ("\n" .. tostring(message)) or "")
    print("[RelaxUI] " .. stage .. " " .. tostring(message or ""))
end
local function main()
    status("download", "Fetching Luau UI library")
    local raw = game:HttpGet(SOURCE)
    assert(type(raw) == "string" and #raw > 5000, "Downloaded source empty")
    assert(not raw:find("control:Set = control.SetValue", 1, true), "Stale Luau library received (invalid colon assignment)")
    status("compile", "Downloaded " .. tostring(#raw) .. " bytes")
    local chunk, compileError = loadstring(raw)
    assert(type(chunk) == "function", tostring(compileError))
    local library = chunk()
    assert(type(library) == "table" and type(library.CreateWindow) == "function", "Library module invalid")
    state.Library = library
    status("window")
    local window = library.CreateWindow({
        Title = "VortexionLua",
        Subtitle = "Relax UI · Android",
        Theme = "Dark",
        Transparency = 0.1,
        Animations = false,
        Size = UDim2.fromOffset(610, 390),
        GuiParent = panel.Parent,
        GuiParentMode = "gethui",
    })
    state.Window = window
    local general = window:CreateTabGroup("Main")
    local home = general:CreateTab("Home", {Selected = true})
    home:CreateParagraph({Title = "Relax UI", Content = "Library loaded. This interface was created by loader.lua."})
    home:CreateToggle({Title = "Enable", Default = false, Callback = function(value) print("RelaxUI Toggle", value) end})
    home:CreateSlider({Title = "Value", Min = 0, Max = 100, Default = 50})
    local controls = window:CreateTabGroup("Components", {Collapsed = false})
    local inputs = controls:CreateTab("Inputs")
    inputs:CreateSection("Form controls")
    inputs:CreateInput({Title = "Text input", Placeholder = "Enter text", Default = "Relax UI"})
    inputs:CreateDropdown({Title = "Style", Options = {"Comfort", "Balanced", "Compact"}, Default = "Comfort"})
    inputs:CreateCheckbox({Title = "Enable option", Default = true})
    inputs:CreateRadioGroup({Title = "Mode", Options = {"One", "Two", "Three"}, Default = "Two"})
    local display = controls:CreateTab("Display")
    display:CreateStatusCard({Title = "UI runtime", Status = "Ready"})
    display:CreateProgressBar({Title = "Load progress", Default = 76})
    display:CreateAccordion({Title = "Details", Content = "MD3 rounds 1 and 2 audit build."})
    home:CreateButton({Title = "Notification", ButtonText = "Show", Callback = function()
        window:Notify({Title = "Relax UI", Content = "The callback works."})
    end})
    state.Status = "ready"
    status("ready", "Parent: " .. tostring(window.GuiParentMode))
    -- Keep a small diagnostic until the user verifies it is visible.
    task.delay(5, function()
        if state.Status == "ready" and state.Diagnostic == panel and panel.Parent then
            panel:Destroy()
            state.Diagnostic = nil
        end
    end)
    return window
end

local ok, result = xpcall(main, function(err)
    local text = tostring(err)
    if debug and type(debug.traceback) == "function" then
        local success, traceback = pcall(debug.traceback, text, 2)
        if success then return traceback end
    end
    return text
end)
if not ok then
    state.Status = "error"
    state.Error = tostring(result)
    warn("[RelaxUI] " .. state.Error)
    label.Text = "RelaxUI ERROR\n" .. state.Error:sub(1, 350)
    return nil
end
return result
