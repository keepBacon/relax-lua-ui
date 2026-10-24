# VortexionUI Next v0.4.1 — atlas icons and surface refinement

## Fixed
- Added a 25-glyph, 5×5 transparent PNG atlas and corrected the atlas source path and 5-column tile offsets.
- Atlas-backed icons switch in after the supported executor's local-asset loader resolves the PNG. Existing native Frame-vector strokes remain visible as a fallback when local asset APIs are unavailable.
- Replaced text glyph arrows in Dropdown and Accordion, plus/minus symbols in Stepper, and star glyphs in Rating with icon-rendered glyphs.
- Reduced the visual weight of group/container outlines and removed the outer grid outline that created a double-frame appearance.
- Reworked the content toolbar hierarchy: current page title has a leading accent icon, clearer title/subtitle spacing, and no strong bottom divider.
- Preserved control values, callbacks, and existing tab-navigation behavior.

## Load
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_041.lua"))()
```

Source: `VortexionUI_Next.lua`
Pinned release: `releases/VortexionUI_Next_0_4_1.lua`
Atlas: `assets/next-icons-atlas-v2.png`

## Verification
Static checks cover the atlas index layout, fallback path, removal of Unicode pseudo-icons, and loader version consistency. Runtime rendering and Android touch behavior still require device acceptance.
