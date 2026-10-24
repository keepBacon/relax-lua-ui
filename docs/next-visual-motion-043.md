# VortexionUI Next v0.4.3 — video-driven visual fixes

## Changes
- Removed the optional raster icon atlas path and made semantic icons consistently use native vector strokes. This prevents the raster atlas from hiding vector glyphs when an asset loads, fails to load, or has a mismatched tile layout.
- Set explicit ZIndex on vector glyph strokes so close, resize, next, and other icons remain visible over their parent controls.
- Added a native `next` arrow path and normalized aliases for dropdown, chevron, and rating icons.
- Rebuilt the active page title icon from the selected navigation icon so the toolbar stays synchronized with the selected page.
- Increased the Overview hero action button width, improved text contrast, and added non-overlapping icon/text padding.
- Fixed the Status control to display its current status value inside the pill.
- Softened Dropdown trigger/list outlines and selected-option strokes to reduce the nested/double-border appearance.

## Validation
Static checks passed for vector-only rendering, close glyph availability, explicit glyph layering, status text, hero button spacing, dropdown border weights, and page-title icon updates. Roblox runtime and Android acceptance are still required.

## Test loader
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_043.lua"))()
```
