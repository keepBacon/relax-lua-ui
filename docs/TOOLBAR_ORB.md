# RelaxUI — Animated toolbar orb

The mobile Show/Hide toolbar button is a black 36×36 face inside a 44×44 touch area, with a continuously revolving theme-sensitive gradient outline and a 46px halo.

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

## Continuous gradient

The border and halo run independent native TweenService repeat loops (6.8s and 10.6s) using the active color theme's Accent and companion colors. Neutral themes gain subtle cyan/violet highlights. Holding the ball pauses the flow and turns its rim green; releasing resumes the flowing gradient. The loop is suspended while the control is hidden or the Hub is destroyed, without a Lua per-frame listener.
