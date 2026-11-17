# VantaUI

A polished AMOLED-first Roblox UI library by **MrRos3**.

## Current version

**VantaUI 0.3.8** is the only active production version in this repository.

The public loader always uses the current `dist/main.lua` runtime. The old stable-base chaining used by earlier 0.3.x builds has been removed.

## Modern UI by default

The old plain flat-card layout is retired as the default. Both the public `main.lua` loader and direct `dist/main.lua` use the Salty Special black/red theme, floral wallpaper, translucent rounded cards, compact three-dot topbar and clean sidebar without the legacy search field. The official Vanta launcher icon is automatic. Existing window/tab/element APIs, explicit backgrounds, and alternate themes remain available.

## Loader

```lua
local cacheBuster = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local VantaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/VantaUI/main/main.lua?v=" .. cacheBuster
))()
```

## Vanta brand identity

VantaUI automatically uses the official Vanta artwork for the window icon and minimized/open badge unless custom branding is explicitly requested.

Custom branding remains supported:

```lua
Branding = {
    UseDefault = false,
    Name = "SALTY",
    Image = "https://example.com/brand.png",
}
```

Set `Branding = false` only when a script intentionally should not use Vanta branding.

## Approved VantaTest color and notification update

Production now carries the selected VantaTest refinements: the Salty Special accent and checkbox are `#A1162F`, the active tab remains a transparent burgundy fade, and OLED notifications receive a full-height themed countdown gradient, a soft icon pop and a smooth overshoot entrance. The default dark outer rim is disabled, while an explicit `ShadowTransparency` setting still works. Reloading the public loader clears previous VantaUI windows so old topbar dividers or shadows do not remain visible. **Original VantaUI buttons, toggles and sliders are unchanged**, including the production-only slider label/clearance fixes. The production owl nameplate and branding remain intact.

## Approved visual styling

The production UI includes the accepted VantaTest improvements:

- Crimson01 HD (1671×941) default wallpaper, with **50 native animated particles**: 18 crimson petals, 17 rising embers, 10 softly floating red motes, and 5 subtle twinkles (no GIF sprite jitter)
- Softly fading left-to-right active tab highlight, with extra transparency on the left and no solid outline

- Original theme-colored Lucide icons on tabs, buttons, section headings and notifications
- A ten-tab interactive showcase, without changing the VantaUI API
- OLED-black lower-right notification cards with a full-height deep-burgundy (`#251016`) timeout overlay
- A complete, original-resolution official Vanta brand image for the launcher badge and topbar
- Repaired remote-image caching and image element parenting
- Re-spaced value sliders so the decimal label stays clear of the thumb at minimum and maximum positions, with dedicated handle clearance

The window handles, drag grip, progress tracks and icons use the original theme styling; the Vanta artwork retains its original colors.

To run the older three-tab sample, load `example-basic.lua` instead of `example.lua`.

## Vanta Owl nameplate 🦉

The **Nameplate** tab in [`example.lua`](example.lua) displays your own overhead owl plate and provides visibility, size, height and distance controls. The eye button near the window's top-right controls toggles the plate on and off and stays synchronized with the Nameplate tab's toggle. This feature is local-only: other players do not receive Vanta nameplates.

The finished capsule is **44px tall**, solid `#050506` with rounded ends. Its **2px border** uses a white `UIStroke` with a dark crimson `#5A0A1C` gradient and narrow `#FF3355` highlight that rotates every **3 seconds**. A separate transparent frame holds the two 30px owls, placed 18px from each edge, and the centered **Michroma 14px** display name. The red `#FF1A3D` name has a white shine that sweeps for **1.4 seconds**, then stays fully red for **2.5 seconds**. The plate auto-sizes to the name, fades with distance, and cleans up its animations on respawn or PlayerRemoving. No extra plate decorations or glow are added.

The included [owl PNG](assets/owl/vanta_owl_96.png) is downloaded from **VantaUI's own repository** by [`nameplate.lua`](nameplate.lua), registered through `getcustomasset` or `getsynasset` when supported, with an owl emoji fallback otherwise. The identical [standalone version](nameplate_standalone.lua) is also available. In Roblox Studio without custom asset APIs, upload the owl art as a Roblox image asset and set `OWL_IMAGE` to its `rbxassetid://` ID.

This integration adds the owl feature without replacing VantaUI's existing runtime, themes, controls, Crimson01 wallpaper or particle animations inside the main window.

## Default theme

The production default is **Salty Special**.

Built-in themes:

- Salty Special
- Vanta Smoked
- Vanta Dark
- Vanta AMOLED
- Vanta Violet

Salty Special automatically uses the Crimson01 HD wallpaper with ambient particles when the window does not provide a custom background. Other backgrounds and themes remain supported.

The **Crimson01 living atmosphere** updates a fixed particle pool at up to 30 FPS using one RenderStepped listener per window. The high-resolution background itself stays perfectly sharp and stationary. The overlay is clipped to the window, never captures mouse input, and pauses whenever the window is minimized. Petals and embers hide **immediately** on Close/Minimize, even while the 0.9-second window animation finishes; reopening resumes motion without a sudden jump. Destroy disconnects the listener.

## Interface sounds

VantaUI keeps its interface sound system for buttons, tabs, toggles, dropdowns, sliders, inputs, and window state.

**Notification open and notification close sounds are disabled in production.** They cannot be accidentally re-enabled by a preset or by clearing sound overrides.

Sounds can still be adjusted per window:

```lua
Sounds = {
    Enabled = true,
    Preset = "Soft",
    Volume = 0.45,
    Pitch = 1,
}
```

Set `Sounds = false` to mute the entire window.

The runtime also exposes `SetSoundEnabled`, `SetSoundVolume`, `SetSoundPitch`, and `SetSoundForEvent` for live changes.

## 0.3.8 production notes

- Public loader points directly at the current runtime
- Executor compatibility repair is applied only when the raw dist runtime cannot compile directly
- Vanta branding and Salty Special defaults are restored by the public loader
- Notification and notification-close sounds are permanently muted
- Lucide icon loading uses the repaired production runtime path
- Startup tab selection supports both numeric index and title
- GitHub Actions regenerates `dist/main.lua` from `src/` changes

## Example

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/VantaUI/main/example.lua?v=" .. os.time()
))()
```

## Project layout

- `main.lua` - current VantaUI 0.3.8 public loader and customization layer
- `dist/main.lua` - current compiled runtime
- `src/` - editable UI source
- `build/` - build tooling
- `example.lua` - interactive showcase, including the owl Nameplate tab
- `nameplate.lua` and `nameplate_standalone.lua` - owl nameplate implementations
- `assets/owl/vanta_owl_96.png` - bundled monochrome owl art
- `tests/nameplate_mock.lua` - local-only nameplate regression test
- `.github/workflows/check-nameplate.yml` - nameplate CI checks
- `.github/workflows/build-gui.yml` - automatic source build

There are no separate legacy runtime files kept as active versions. Older releases remain only in Git history.

## License

VantaUI is released under the MIT License, Copyright (c) 2026 MrRos3. See [`LICENSE`](./LICENSE).

Required notices for inherited permissively licensed portions are preserved separately in [`THIRD_PARTY_NOTICES`](./THIRD_PARTY_NOTICES).
