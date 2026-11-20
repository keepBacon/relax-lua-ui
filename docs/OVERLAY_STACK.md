# RelaxUI — Overlay Stack / Unified Input Router

## Architecture

`lib/core/OverlayStack.luau` is a Hub-owned overlay coordinator. It replaces independent global outside-click and Escape priority logic with a deterministic **last-opened, first-dismissed** stack, without reworking the original widget APIs.

Managed layers: `Popup` (dropdowns / color picker), `SubTabs` (second-level dock rail), `Window`, `CommandPalette`, `Prompt`, and `Setup`. Setup is a blocking, non-dismissible overlay until its existing completion workflow finishes; a prompt consumes outside touches and permits Escape. Toasts, pinned panels, floating toolbar orb, drags, and keybind capture are not modal layers.

## Routing rules

- `Hub:_bindInput()` owns the shared global `UserInputService.InputBegan` route.
- **Escape** closes only the top overlay. With no overlay, Escape closes the open main panel (except while editing a text box or capturing a keybind).
- **Outside pointer-down** is consumed by the top overlay. Dismissing a dropdown can never dismiss the parent panel with the *same* gesture, nor can it reach a lower window/subtab.
- **Inside pointer-down** is consumed by the overlay boundary router but local widget controls continue receiving their native Roblox GUI mouse/touch signals.
- **Command palette keyboard** Up/Down/Enter remain in its local selection controller; Escape and the command shortcut are removed from that local listener to avoid double dispatch.
- Shortcut toggles are inhibited when a blocking overlay is open; keyboard focus and gameProcessed are respected for non-Escape shortcuts.
- **Touch orb long-press/drag** remains under its existing gesture handler, and is not affected by overlay state.
- **Window open** dismisses an older popup, palette, and subtabs before elevating its own stack entry.
- A newly opened popup can stack above an active Window. ScreenGui's existing `Overlay` layer is kept; no extra global blur is introduced.

## Public/read-only API

```lua
-- Top-to-bottom snapshot of managed overlay kinds. No mutable internal references returned.
for _, entry in hub:GetOverlayStack() do
    print(entry.Kind, entry.Serial)
end
```

Internal integration points: `_overlayRegister`, `_overlayUnregister`, `_overlayTop`, `_overlayDismiss`, `_routeOverlayKey`, `_routeOverlayPointer`, `_overlayClear`. Calling `Close`, `Toggle`, `Open`, `Prompt`, `OpenCommandPalette`, `_openPopup` and `_toggleSubTabs` remains source-compatible.

Duplicate opens of the same owner/kind cannot produce repeated entries. Closing a modal unregisters exactly its own entry. Dismissing the top entry does not propagate to the next one. On Hub destruction, the stack is cleared and existing resource ownership disconnects the global input listeners.

## Tests

```sh
node scripts/bundle.mjs
node tests/overlay-stack.mjs
lune run tests/overlay-stack-lune
```

The native runtime checks overlay push/pop, nested Window + CommandPalette + Prompt, Escape priority, outside-touch consumption, duplicate opens, and teardown. Automated tests are not a substitute for Android touch/IME/gamepad hands-on verification.
