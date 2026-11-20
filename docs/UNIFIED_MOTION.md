# RelaxUI — Unified Motion State Machine

**Scope:** P0-3 from `RelaxUI_基于八份UI源码的后续开发路线图_2026-11-20.md`. The existing property-aware `tween()` is retained; this change adds a single owner/id state lifecycle on top of it.

## API

```lua
local Motion = RiftUI.Motion

Motion.Presets.Micro     -- 140 ms, Quint Out
Motion.Presets.Control   -- 200 ms, Quad Out
Motion.Presets.Panel     -- 320 ms, Quint Out
Motion.Presets.Ripple    -- 520 ms, Quart Out
Motion.Presets.Dismiss   -- 160 ms, Quad In

Motion.play(hub, "my-control", frame, { BackgroundTransparency = 0 }, Motion.Presets.Control, function(state)
    -- Only the latest uncancelled transition can complete.
end)

Motion.transition(hub, "panel-visibility", "open", {
    { Target = panel, Goals = { GroupTransparency = 0 } },
    { Target = outline, Goals = { Transparency = 0 } },
}, Motion.Presets.Panel, function(state)
    -- All active steps finished, not a stale state.
end)

Motion.getState(hub, "panel-visibility")
Motion.cancel(hub, "panel-visibility")
Motion.cancelAll(hub)
```

## Invariants

- Each `owner + id` has at most one active transition. A newer request cancels the superseded transition's tweens and disconnects its listeners.
- Existing `tween()` still owns conflicting instance/properties, preserving theme binding semantics and preventing simultaneous writes.
- A transition may contain several target/property groups; a completion callback runs only after all steps completed and only while that transition remains current.
- Interrupted transitions continue from *currently rendered values*. Main panel reopening while its close fade is active never jumps back to full transparency.
- Section folding captures current clip height and restores automatic sizing only when the newest transition finishes.
- Secondary-tab rails preserve a 3 px tile-relative gap. Reopening a fading rail on the same parent tile reuses its present position/opacity; a prior dismissal cannot hide it.
- Popup positioning is cancelled before its holder is destroyed. Toolbar orb glyph swaps are grouped under one state without taking ownership of independently looped border gradients.
- Destroying a Hub cancels all owner transitions before releasing resources. The motion layer adds no frame polling connection.
- API compatibility retained: `Hub:Open`, `Hub:Close`, `Hub:SetToolbarVisible`, `Section:SetCollapsed`, `Hub:_openPopup` etc.

## Test coverage

- `node tests/motion-state.mjs` checks API surface, all integrations and source/bundle parity.
- `lune run tests/motion-state-lune` exercises rapid panel close/reopen, section collapse/expand, subtabs close/reopen, popup teardown, owner/id supersession, multi-step cancellation, and Hub cleanup.
- The existing native Lune and Node suites run in GitHub Actions.

**Limit:** Android touch timing/visual motion quality needs a device pass even when the native simulator and CI checks are green.
