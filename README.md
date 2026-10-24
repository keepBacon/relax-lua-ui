# Relax Lua UI / VortexionUI

Standalone **Roblox Luau** UI library, independent of WindUI, built around a minimal Material Design 3-inspired surface/controls style.

> **Round 1 core release:** functional window, nested tab groups, drag & resize, minimize-to-icon, themes, notifications, confirmation dialogs, and basic controls. This is not yet the complete WindUI component catalog. No Roblox Android/device integration test is claimed.

## Load from an executor

```lua
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/VortexionUI.lua"
))()
```

The loader above uses executor-specific APIs; **ordinary Roblox LocalScripts do not support arbitrary remote `loadstring(game:HttpGet())`**. For Roblox Studio, copy `VortexionUI.lua` into a **ModuleScript** under ReplicatedStorage and `require` it from a LocalScript:

```lua
local UI = require(game:GetService("ReplicatedStorage"):WaitForChild("VortexionUI"))
```

## Basic usage

```lua
local window = UI.CreateWindow({
    Title = "VortexionLua",
    Subtitle = "My server",
    Theme = "Dark",
    Transparency = 0.1,
    -- Icon = "rbxassetid://YOUR_UPLOADED_ICON_ID"
})
local group = window:CreateTabGroup("Main")
local tab = group:CreateTab("Settings", {Selected = true})
tab:CreateToggle({Title = "Enabled", Default = false, Callback = function(v) print(v) end})
tab:CreateSlider({Title = "Amount", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end})
tab:CreateButton({Title = "Show notification", Callback = function()
    window:Notify({Title = "Hello", Content = "It works"})
end})
```

See [examples/quickstart.lua](examples/quickstart.lua).

## Core API

| Object | API |
|---|---|
| UI | `CreateWindow(config)`, `GetThemes()` |
| Window | `CreateTabGroup(name, options)`, `CreateTab(name, options)`, `Minimize()`, `Restore()`, `Toggle()`, `Destroy()` |
| Window | `SetTheme(nameOrTokens)`, `SetTitle(text)`, `SetSubtitle(text)`, `SetTransparency(0..0.45)`, `SetSize(width,height)`, `SetAnimationsEnabled(bool)` |
| Window | `Notify(config)`, `Confirm(config)` |
| TabGroup | `CreateTab(title, options)`, `SetCollapsed(bool)` |
| Tab | `Select()`, `CreateSection(title)`, `CreateDivider()`, `CreateLabel(text)`, `CreateParagraph(config)` |
| Tab | `CreateButton(config)`, `CreateToggle(config)`, `CreateSlider(config)`, `CreateInput(config)`, `CreateDropdown(config)`, `CreateKeybind(config)` |
| Control | `SetValue(value)`, `GetValue()` for value-based controls |

## Notes and limitations

- Uses Roblox `Instance.new` native GUI. The frosted-glass appearance is a translucent surface approximation; `ScreenGui` does not offer webpage-style `backdrop-filter` scene blur.
- The exact metallic brand mark requires an uploaded Roblox `rbxassetid://` supplied in `Icon`; the built-in fallback is an approximate code-drawn mark.
- All GUI creation happens on the client in `PlayerGui`. `Destroy()` disconnects tracked listeners.
- The current API is intentionally separate from WindUI. Full control parity, configuration persistence, polished motion and deeper device testing belong to round 2.
- Please test with your own Roblox client/device before production use.
