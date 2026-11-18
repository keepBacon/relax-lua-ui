# RelaxUI second-level tabs

Second-level tabs are optional. Existing `Hub:Tab()` and `Tab:Section()` calls continue to work.

```luau
local Hub = Rift:CreateHub({ Name = "RelaxUI" })
local Combat = Hub:Tab({ Name = "战斗", Icon = "crosshair" })
local Aim = Combat:SubTab({ Name = "自瞄", Icon = "target" })
local Weapon = Combat:SubTab({ Name = "武器", Icon = "swords" })

Aim:Section({ Name = "目标设置" }):Toggle({ Name = "开启", Flag = "AimEnabled", Default = false })
Weapon:Section({ Name = "武器设置" }):Slider({ Name = "射速", Flag = "Rate", Min = 1, Max = 10, Default = 5 })
```

Interaction contract:

- Open the first-level tab by tapping its Dock icon.
- Tap its **already selected** Dock icon again to show a smaller row of second-level icons immediately above it.
- Tap a child icon to switch content without dismissing the child row.
- Tap outside the child row to dismiss **only** the row; the main panel stays open.
- The primary tab name remains the header title, while the currently selected child name becomes the small grey subtitle.
- If a primary tab has its own `Section` content as well as child tabs, the child row includes an **All** item for that original content.
- `Hub:Open(childTab)` selects a child programmatically.
- Tabs without child tabs retain the original first-level behavior.
- This feature does **not** introduce open/close or page-switch animations.

Visual compatibility note: Roblox has not exposed a stable, generally functioning way to blur the pixels of live ScreenGui content behind another ScreenGui. The current implementation uses a **static translucent frosted veil** confined to the UI panel—not a global `Lighting.BlurEffect`—to avoid blurring the game world. This is an approximation rather than true Gaussian blur.

Child tabs participate in control flags, command-palette search, resource teardown, pin restoration and hub reinitialization.
