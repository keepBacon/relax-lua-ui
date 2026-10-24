# VortexionUI Next v0.4.5 — glass blur, header redesign, dropdown cleanup

## Changes
- Added a configurable Lighting BlurEffect for the 3D scene behind the translucent UI. Default blur size is 8; use `BlurEnabled=false` or `Blur=false` to disable it, and `BlurSize=0..24` to tune intensity.
- Added `window:SetBlurEnabled(enabled, size)` for runtime control. Blur fades down while minimized and is removed when the window is destroyed.
- Rebuilt the page header with a blue gradient icon tile, separated title and breadcrumb rows, and larger outlined minimize/maximize/close controls.
- Increased the header to 68px and moved the page content down to preserve spacing.
- Reworked compact/mobile header positioning so the menu no longer overlaps the page icon/title.
- Removed the dropdown popup's own painted background and outline. Each option keeps its own rounded surface and selected state.
- Calculated dropdown list canvas height from option height, gaps, and exact top/bottom padding to eliminate the surplus strip below the last option.

## API
```lua
local window = UI.CreateWindow({
    Title = "VortexionLua",
    BlurEnabled = true,
    BlurSize = 8,
})
-- Later:
window:SetBlurEnabled(true, 10)
window:SetBlurEnabled(false)
```

## Technical limitation
Roblox Lighting BlurEffect blurs the 3D scene, not other ScreenGui layers. UI panels use translucency and gradients for glass styling while foreground text stays sharp. This does not provide true blur of arbitrary 2D content behind the ScreenGui.

## Test loader
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_045.lua"))()
```

Static source checks passed. Roblox runtime and Android device acceptance remain outstanding.
