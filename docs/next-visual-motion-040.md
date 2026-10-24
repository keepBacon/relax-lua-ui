# VortexionUI Next v0.4.0 — visual and motion refinement

This release addresses visual issues identified in the Android recording of the v0.3.9 component gallery.

## What changed
- Added a moving selection indicator to SegmentedControl.
- ChipGroup uses grid content height and viewport width to size itself; selected chips animate background, text and outline.
- Search starts compact when empty, reveals matches with fade transitions, expands to fit results, and displays a no-results state.
- Accordion and Tooltip animate container height, title/trigger state, arrow rotation and content opacity.
- Stepper gains clearer numeric hierarchy, focused outline, animated value feedback and tactile button response.
- Rating uses gold star glyphs without rectangular button tiles, with touch feedback.
- Code copy has a temporary copied state and explicit clipboard-unavailable feedback.
- Text input and TextArea gain animated focus outlines.
- Checkbox and RadioGroup animate selection marks using native vector Frame segments.
- Dropdown adds selected-option highlighting, a rotating chevron and animated expansion.
- Slider animates programmatic changes and knob press/release while keeping finger-drag updates immediate.
- ColorPicker preview and legacy button/keybind/status/list states use more consistent motion and contrast.
- List has a clear active row and left-side selection marker.

## Load the Android gallery

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_040.lua"))()
```

Pinned release: `releases/VortexionUI_Next_0_4_0.lua`
Core source: `VortexionUI_Next.lua`

## Motion design
- Short transitions generally use 0.14–0.22 seconds with Quint/Quart easing.
- Direct touch tracking for sliders and RGB channels is not tweened per frame, to avoid input lag.
- Every animation is scheduled through the window motion manager, so interrupted transitions are replaced rather than accumulated.
- Existing SetValue/GetValue/Set aliases and callbacks remain available.

## Verification
Static source checks verify method uniqueness, version markers, helper declaration order, and release-loader consistency. Roblox Luau runtime and Android touch behavior still require on-device acceptance; this commit does not claim a completed live-device test.
