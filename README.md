# VortexionUI

**Final source:** `1.0.0-final` · Native Roblox Luau · No WindUI dependency.

## Run the Android showcase
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader.lua"))()
```
The loader verifies the final source version, replaces an existing VortexionUI window, and opens a multi-page component showcase. It includes a size assertion for the Hero action button to catch the oversized blue-button regression.

## Load the library
```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/VortexionUI.lua"))()
local window = UI.CreateWindow({Title="VortexionLua", Width=760, Height=450, Transparency=0.24, BlurEnabled=false})
local group = window:CreateTabGroup("OVERVIEW")
local home = group:CreateTab("Home", {Selected=true})
home:CreateHero({
    Eyebrow="VORTEXION LUA",
    Title="Your workspace",
    Description="A responsive native interface.",
    ActionText="Show notification",
    ActionIcon="bell",
    Callback=function() window:Notify({Title="VortexionUI", Content="Action callback works."}) end,
})
local controls = window:CreateTabGroup("CONTROLS")
local settings = controls:CreateTab("Settings")
settings:CreateToggle({Title="Enabled", Default=true})
settings:CreateSlider({Title="Power", Min=0, Max=100, Step=5, Default=45})
settings:CreateDropdown({Title="Preset", Options={"Comfort","Balanced","Realistic"}, Default="Balanced"})
```

The library uses `gethui()` by default. In Roblox Studio, copy the source into a ModuleScript and pass `GuiParent=Players.LocalPlayer:WaitForChild("PlayerGui")` to `CreateWindow`. Ordinary LocalScripts do not support arbitrary remote `loadstring(game:HttpGet(...))` by default.

## Component catalog
- Layout: `CreateHero`, `CreateStatGrid`, `CreateActionGrid`, `CreateCompactRow`, `CreateSelectionGrid`, `CreateExpandablePanel`, `CreateActivityFeed`
- Basic: `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateInput`, `CreateDropdown`, `CreateCheckbox`, `CreateRadioGroup`, `CreateKeybind`, `CreateColorPicker`
- Extended: `CreateTextArea`, `CreateStepper`, `CreateSegmentedControl`, `CreateChipGroup`, `CreateRating`, `CreateSearch`
- Content: `CreateSection`, `CreateParagraph`, `CreateBadge`, `CreateDivider`, `CreateProgress`, `CreateAccordion`, `CreateCode`, `CreateImage`, `CreateStatus`, `CreateKeyValue`, `CreateList`, `CreateTimeline`, `CreateTooltip`
- Window: `CreateTabGroup`, `CreateTab`, `CreateGroup`, `Minimize`, `Restore`, `Maximize`, `Destroy`, `Notify`, `SetBlurEnabled`, `SetBackgroundVideo`, `SetAnimationsEnabled`

## Design and runtime
Call `UI.ConfigurePalette({...})` and `UI.ConfigureDesignTokens({...})` before creating windows. The library uses native Roblox GUI objects, not HTML/CSS. `BlurEffect` blurs the 3D scene, not other ScreenGui layers; disable it for lower mobile GPU cost. Video backgrounds require a video uploaded to Roblox and a valid asset ID. Static checks do not replace live Android/Roblox interaction tests.
