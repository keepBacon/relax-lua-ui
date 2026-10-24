# VortexionUI Next v0.4.8 — action layout and architecture API

## Fix: icon/text overlap
- Replaced the Hero button's native TextButton text plus separately overlaid icon and UIPadding hack with a shared action-button primitive.
- Icon and text now have independent UI nodes. The label width is measured with TextService and recalculated when the button size changes.
- Supports left/center/right content alignment, icon on left/right, configurable padding/gap/icon size, text size/font/colors, gradient/stroke, corner radius, disabled state, and press scale.
- Refactored the standard row button to use the same primitive, so future fixes apply consistently.
- Added runtime setters for Hero action text/icon/enabled state and standard button text/icon/enabled state.

## Architecture and freedom
- Added configurable design tokens for Hero layout and action buttons via `UI.ConfigureDesignTokens(...)`.
- Added `UI.ConfigurePalette(...)` and `UI.GetPalette()` for central theme customization.
- Hero cards accept a `Layout` table and action-button overrides without editing library internals.

## Example
```lua
UI.ConfigurePalette({Accent = Color3.fromRGB(65, 150, 255)})
UI.ConfigureDesignTokens({
    ActionButton = {Width = 210, Height = 36, Radius = 12, Gap = 12, IconSize = 16},
    Hero = {ActionY = 112, AccentY = 8},
})

local hero = tab:CreateHero({
    Title = "Your workspace",
    ActionText = "Show notification",
    ActionIcon = "bell",
    ActionButton = {
        Alignment = "center",
        IconSide = "left",
        Width = 220,
        Height = 38,
        Padding = 16,
        Gap = 12,
        TextSize = 12,
        Radius = 12,
        Gradient = true,
    },
    Callback = function() print("clicked") end,
})
hero:SetActionText("Notification")
hero:SetActionIcon("bell")
hero:SetActionEnabled(true)
```

## Verification
Static source checks passed. Roblox Android runtime and touch-layout acceptance remain outstanding.
