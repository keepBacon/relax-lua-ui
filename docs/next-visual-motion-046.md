# VortexionUI Next v0.4.6 — launcher position and hero spacing

## Fixes
- Remember the minimized launcher position in the live window object while it is dragged and again when the pointer is released.
- Reuse the saved launcher position on subsequent minimize operations instead of resetting it to the center of the main window.
- Clamp the restored launcher position to the current viewport when screen dimensions change.
- Move the Hero card's blue accent bar up from y=20 to y=12.
- Shift the action icon left, left-align the button label, and widen the button to prevent icon/text overlap.

## Test loader
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_046.lua"))()
```

The launcher position is retained for the lifetime of the current UI instance. Persistence across destroying/recreating the UI or restarting the game is not included because portable client-side persistent storage is not available to every executor/runtime. Static source checks passed; Roblox Android runtime acceptance remains outstanding.
