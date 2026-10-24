# VortexionUI Next v0.4.4 — dropdown parent surface fix

## Fix
The shared Dropdown control grows its parent layout frame when opened. That frame previously retained a row background and outer UIStroke, leaving an oversized surface behind the dropdown and multiselect options.

- Parent layout slot is now transparent.
- Removed only the parent slot's outer stroke.
- Preserved title, trigger, popup panel, option backgrounds, selection highlights, callback behavior, and expand/collapse animation.
- Single-select and `Multi=true` both use the corrected shared implementation.

## Test
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_044.lua"))()
```

Static source checks passed. Roblox runtime and Android device acceptance remain outstanding.
