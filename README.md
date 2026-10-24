## Android one-line loader

Run directly in an executor that supports loadstring and game:HttpGet:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader.lua"))()
```

Unlike the library module, loader.lua creates a visible window, tabs and controls. A PlayerGui status label displays each initialization stage or an error. The UI library prefers gethui() for the actual window. The loader and main window are both mounted to `gethui()`; missing hidden UI APIs cause an explicit error rather than a PlayerGui fallback. Live Android compatibility is not guaranteed.

# Relax Lua UI / VortexionUI

## MD3 rebuild — round 2 of 5

This release changes the native controls to share MD3 tonal cards, softer outlines and standardized primary-control sizing. Button, Toggle, Slider and Input geometry have been refined for touch, including focus strokes. A dedicated Android entry point `loader_md3_r2.lua` loads the new versioned `releases/RelaxUI_0_4_md3_r2.lua` instead of the older cached `loader_android_021.lua`. Navigation and animation parity remain for rounds 3–5. This code has passed static source checks, not Android device visual regression.


## MD3 visual rebuild — round 1 of 5

Reference: `VortexionLua_UI_MD3_Glass_V05_Complete.html` from the design prototype.
This first round introduces semantic MD3 tone tokens, window geometry (24px radius),
a three-part header/sidebar/content shell, a contextual breadcrumb strip, and
responsive navigation-panel wiring. Controls, animations, and Android refinements
are scheduled for subsequent rounds. Roblox native GUI does not reproduce CSS
backdrop-filter blur. Static checks only; Android on-device comparison is pending.


Standalone **Roblox Luau** UI library, independent of WindUI, using a minimal Material Design 3-inspired surface system.

## Runtime mounting and downloaded logo

- In supported executor environments, the library calls `gethui()` first and parents its `ScreenGui` to that hidden UI container, matching common executor UI-library mounting patterns. If unavailable or failing, window creation now reports an error instead of silently falling back to `PlayerGui`; Studio users may explicitly supply `config.GuiParent`.
- The default Vortexion mark is downloaded from `assets/vortexion-mark.png`, cached as `RelaxUI/vortexion-mark.png`, then resolved with `getcustomasset` or `getsynasset` for use by `ImageLabel`. Custom HTTP(S) image URLs can also be supplied via `Icon` and follow the same local-download path.
- Downloaded local image assets require executor support for `game:HttpGet`, `writefile`, and either `getcustomasset` or `getsynasset`; `makefolder`/`isfile` are optional helpers. If those APIs are unavailable or the download fails, the library uses its code-drawn logo fallback. Existing `rbxassetid://...` icon values are used directly.

## Round 2

This release expands the component set, adds nested navigation, loading feedback, state flags and JSON configuration import/export. It remains a native Roblox ScreenGui implementation, not an HTML wrapper.

### Load from an executor

```lua
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/VortexionUI.lua"
))()
```

The loader above uses executor-specific APIs. **Ordinary Roblox LocalScripts do not support arbitrary remote loadstring(game:HttpGet()).** For Roblox Studio, copy VortexionUI.lua into a ModuleScript under ReplicatedStorage, then require it from a LocalScript.

### Basic example

See [examples/quickstart.lua](examples/quickstart.lua) for a broader smoke-test script covering controls, nested groups, loading overlay, notifications, confirmation dialogs and config flags.

```lua
local window = UI.CreateWindow({
    Title = "VortexionLua",
    Theme = "Dark",
    Transparency = 0.1,
})
local group = window:CreateTabGroup("Main")
local tab = group:CreateTab("Settings", {Selected = true})
tab:CreateToggle({Title = "Enabled", Flag = "enabled", Default = false})
tab:CreateSlider({Title = "Amount", Flag = "amount", Min = 0, Max = 100, Default = 50})
```

## Component API

| Component | Methods |
|---|---|
| Basic | CreateButton, CreateToggle, CreateSlider, CreateInput, CreateTextArea, CreateDropdown, CreateMultiDropdown, CreateKeybind |
| Selection | CreateCheckbox, CreateCheckboxGroup, CreateRadioGroup, CreateSegmentedControl, CreateStepper, CreateColorPicker |
| Content | CreateSection, CreateDivider, CreateLabel, CreateParagraph, CreateBadge, CreateSpacer, CreateProgressBar, CreateCode, CreateImage, CreateVideo, CreateViewport |
| Extended | CreateAccordion, CreateStatusCard, CreateStatCard, CreateTimeline, CreateChipGroup, CreateMarkdown (plain-text fallback) |
| Window | CreateWindow, CreateTabGroup, CreateSubGroup, CreateTab, SetTheme, SetTransparency, SetSize, Minimize, Restore, Toggle, Destroy |
| Feedback | Notify, Confirm, PlayLoadingAnimation |
| Configuration | RegisterFlag, GetFlag, SetFlag, ExportConfig, ImportConfig, SaveConfig, LoadConfig |

CreateTabGroup supports group:CreateSubGroup("Advanced"). Value controls support Flag = "stable.key"; state can be exported as JSON and restored once matching controls have been created.

## Configuration persistence

```lua
local json = window:ExportConfig()
window:ImportConfig(json)

-- Executor file APIs only; SaveConfig/LoadConfig return false when unsupported.
local ok, result = window:SaveConfig("my-settings")
local loaded, detail = window:LoadConfig("my-settings")
```

Import/export works without file-system APIs. SaveConfig/LoadConfig additionally require executor-specific writefile/readfile; the library does not silently pretend persistence succeeded.

## Runtime limitations

- Uses Roblox native GUI instances. The frosted-glass look is simulated using translucent surfaces; Roblox ScreenGui has no browser-style backdrop-filter blur.
- Exact silver logo art requires an uploaded Roblox asset ID supplied through Icon = "rbxassetid://..."; the code-drawn fallback is an approximation.
- Video playback, ViewportFrame model rendering and clipboard copy depend on valid Roblox assets or executor capabilities.
- WindUI-like aliases ease migration, but argument signatures and behavior are not guaranteed to be drop-in compatible with WindUI.
- This repository has not been validated in a live Roblox Studio/Android session. Please test in your target runtime before relying on it in production.
