-- Relax Lua UI / VortexionUI round 2 smoke-test example
-- Executor example. For Roblox Studio, require a ModuleScript copy instead.

local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/VortexionUI.lua"
))()

-- The default Vortexion logo is downloaded and cached automatically when executor
-- APIs game:HttpGet, writefile and getcustomasset/getsynasset are available.
-- ScreenGui mounts to gethui() when available, otherwise PlayerGui.
local Window = UI.CreateWindow({
    Title = "VortexionLua", Subtitle = "Relax UI · Round 2",
    Theme = "Dark", Transparency = 0.1, Animations = true,
})

local boot = Window:PlayLoadingAnimation({Title = "VortexionLua", Status = "Loading components", Progress = 0.15})
task.wait(0.25)
boot:SetProgress(0.55, "Preparing interface")
task.wait(0.25)
boot:SetProgress(1, "Ready")
task.wait(0.2)
boot:Close()

local main = Window:CreateTabGroup("Main")
local home = main:CreateTab("Overview", {Selected = true})
home:CreateParagraph({Title = "Round 2", Content = "Standalone Luau UI; no WindUI dependency."})
home:CreateStatusCard({Title = "Runtime", Status = "Ready"})
home:CreateStatCard({Title = "Controls", Value = "Expanded"})
home:CreateProgressBar({Title = "Progress", Default = 68})
home:CreateButton({Title = "Notification", ButtonText = "Show", Callback = function()
    Window:Notify({Title = "Relax UI", Content = "Notification callback works."})
end})

local settingsGroup = Window:CreateTabGroup("Settings")
local settings = settingsGroup:CreateTab("Controls")
settings:CreateToggle({Title = "Enable feature", Flag = "feature.enabled", Default = true, Callback = function(v) print(v) end})
settings:CreateSlider({Title = "Amount", Flag = "amount", Min = 0, Max = 100, Step = 5, Default = 40})
settings:CreateInput({Title = "Name", Flag = "player.note", Default = "", Placeholder = "Enter a note"})
settings:CreateTextArea({Title = "Notes", Flag = "notes", Height = 110})
settings:CreateDropdown({Title = "Mode", Flag = "mode", Options = {"Balanced", "Fast", "Quiet"}, Default = "Balanced"})
settings:CreateCheckbox({Title = "Accept option", Flag = "accepted", Default = false})
settings:CreateRadioGroup({Title = "Quality", Flag = "quality", Options = {"Low", "Medium", "High"}, Default = "Medium"})
settings:CreateCheckboxGroup({Title = "Features", Flag = "features", Options = {"A", "B", "C"}, Default = {"A"}})
settings:CreateSegmentedControl({Title = "Layout", Flag = "layout", Options = {"Comfort", "Compact"}, Default = "Comfort"})
settings:CreateStepper({Title = "Count", Flag = "count", Min = 0, Max = 10, Step = 1, Default = 3})
settings:CreateColorPicker({Title = "Accent", Flag = "accent", Default = Color3.fromRGB(110, 130, 200)})
settings:CreateKeybind({Title = "Toggle UI", Default = Enum.KeyCode.RightShift, Callback = function() Window:Toggle() end})

local display = settingsGroup:CreateTab("Display")
display:CreateCode({Title = "Code sample", Content = 'print("Hello, Relax UI")', Height = 100})
display:CreateImage({Title = "Image", Image = "rbxassetid://0", Height = 90})
display:CreateAccordion({Title = "Details", Content = "Accordion content"})
display:CreateTimeline({Title = "Recent events", Events = {"Created window", "Loaded controls"}})
display:CreateBadge({Text = "Ready"})
display:CreateDivider()
display:CreateSpacer(8)

local nested = settingsGroup:CreateSubGroup("Advanced")
local advanced = nested:CreateTab("Advanced options")
advanced:CreateMultiDropdown({Title = "Modules", Options = {"Movement", "Interface", "Audio"}, Default = {"Interface"}})

local about = Window:CreateTab("About")
about:CreateButton({Title = "Confirm dialog", ButtonText = "Open", Callback = function()
    Window:Confirm({Title = "Continue?", Content = "This is a test dialog.", Callback = function(accepted) print(accepted) end})
end})

local json = Window:ExportConfig()
print("Config JSON length:", #json)
-- Executor persistence requires writefile/readfile:
-- local saved, payload = Window:SaveConfig("my-settings")
-- local loaded, detail = Window:LoadConfig("my-settings")
-- Window:Destroy() when finished.
