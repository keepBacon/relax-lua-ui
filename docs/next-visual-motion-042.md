# VortexionUI Next v0.4.2 — icon tween compatibility fix

## Root cause
v0.4.1 changed Dropdown and Accordion arrows to Frame-backed icon containers, but their open/close tweens still included `TextColor3`. Roblox Frame objects do not support that property, causing TweenService initialization errors.

## Fixed
- Removed `TextColor3` from the arrow-container tweens; arrow rotation remains animated.
- Added `animateIconTint`, which animates `ImageColor3` on image glyphs and `BackgroundColor3` on visible vector strokes.
- Applied the helper to both Dropdown and Accordion so the atlas and native vector fallback share the same behavior.
- Preserved public control APIs and callback behavior.

## Android test loader
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_042.lua"))()
```

Static source checks passed. Roblox runtime and Android device acceptance are still required.
