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


## Post-merge interaction hardening

- Popups now create a fully transparent, active `PopupPointerShield` TextButton under their popup content. This is important because returning from a global `InputBegan` handler **does not cancel native GUI button clicks**; the shield intercepts the underlying UI. It is destroyed with the popup, and its event connection is explicitly disconnected.
- The command shortcut and the palette's Up/Down/Enter selection listener honor the actual topmost overlay. An underlying palette is inert while a Prompt is on top.
- Prompt buttons and `Prompt:Close()` both remove the stack entry **at the beginning** of dismissal, not after the fade finishes.
- Opening Setup closes existing popup/secondary rail/child windows and uses a higher modal layer, preventing an older window from appearing in front of setup.
- Existing APIs and animation timings remain unchanged. Device-specific focus/IME testing is still recommended.

## Priority, lifecycle and secondary navigation shield (hardening)

**Root visual priority** (lower to higher): `SubTabs = 40`, `Window = 79`, `CommandPalette = 81`, `Setup = 95`, `Popup = 98`, `Prompt = 100`. The overlay stack now orders entries by **visible ZIndex class** with opening order as the tie-breaker, rather than treating a later low-level registration as visually dominant. The popup overlay's ScreenGui root is moved to ZIndex 98, consistent with the stack. Old modal windows cannot steal input from higher-level prompts.

The stack subscribes to each owner layer's `Destroying` event and immediately unregisters the corresponding entry even if a caller destroys it without using `Close()`. Replacing an existing entry disconnects its old subscription; `Hub:Destroy()` releases all remaining subscriptions.

**SubTabPointerShield** is a transparent full-screen `TextButton` with ZIndex 38. It sits above the ordinary panel and below the raised active dock holder (40), capturing native outside touches while a secondary icon row is open. Its visibility is tied to the rail state so dismissed tabs do not leave a permanent invisible touch blocker. This complements the existing panel-local frost.

Automated checks cover priority ordering, deduplication, direct destruction, pointer shield visibility and teardown. Android hardware keyboard, IME and multi-touch remain device-level verification tasks.
