# RelaxUI — Animated toolbar orb

The mobile Show/Hide toolbar button is a black 44×44 circle with a theme-sensitive gradient outline and a subtle 53px halo.

- **Collapsed Dock:** green plus sign. A short tap expands the toolbar.
- **Expanded Dock:** red minus sign. A short tap hides the toolbar.
- **Press animation:** squash to 92%, spring back, fade an expanding ripple, and ease the glyph/color through a 280ms morph.
- **Drag unlock:** hold for **1 second without moving more than 11px**. A larger green ripple appears at the circle. Only then can the circle be dragged.
- **Drag feedback:** outline and halo switch to vivid green while captured; revert to the active color-theme gradient on release.
- **Position:** clamped to screen bounds with top inset, stored as normalized X/Y in `setup.json`, and restored after reload.
- **Input:** multitouch-safe pointer identity, mouse support, gesture cancellation, no accidental Dock close on orb press, and shared drag ownership.
- **Performance:** no permanent heartbeat/render loops. All active connections and pending gestures are cancelled during Hub teardown.

Files: `lib/core/ToolbarOrb.luau`, `lib/RiftUI.luau`, `public/RiftUI.luau`.
Automated source checks: `node tests/toolbar-orb.mjs`.
Animations and gestures require an additional Roblox Android/Delta device pass for final UX acceptance.
