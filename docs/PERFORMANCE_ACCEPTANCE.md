# Relax UI R5 — repeatable baseline and Android release acceptance

Scope: `keepBacon/relax-lua-ui`; baseline framework added on 2026-11-23.
This document is a **test specification and recording template**, not evidence
that a physical Android device has been benchmarked.

## Automatic simulation baseline

`tests/performance-lune.luau` uses the native Lune interpreter with the
repository's emulated Roblox engine (`public/engine.luau`). It executes:

| Scenario | Repetitions / workload | Invariants |
|---|---|---|
| Initial control creation | Create 100 Toggles | All 100 controls present |
| Dense control creation | Add 200 more (300 total) | 300 controls present |
| Large data creation | DataTable with 1000 rows, PageSize=10 | Full model contains 1000 rows; active row GUI pool bounded |
| Data mutation | Update row 501 in the model | Updated cell retrievable |
| Theme and popup pressure | 12 alternating theme selections and open/close dialogs | No orphaned top overlay; correct final theme |
| Developer snapshot | Explicit MaxNodes=50 tree export | At most 50 nodes; truncated when appropriate |
| Reinitialize | 3 Hub rebuild cycles with a registered extension/event | Extension, Scope and listener counts stable; each event delivered once |
| Destroy | Once, after the workload | Extension, Scope and listener counts return to zero |

**Measured values:** Create100Ms, ExpandTo300Ms, CreateTable1000Ms,
UpdateTableRowMs, ThemeAndPopup12Ms, Reinitialize3Ms.

The test writes `perf-baseline.json` and checks that measurements are finite,
non-negative numbers. `scripts/performance-report.mjs` validates the schema,
prints a Markdown comparison table for the workflow summary and rejects failed
functional assertions. The GitHub Action uploads the raw JSON as a build artifact.

A sample invocation from a clone with native Lune installed:

```bash
node scripts/bundle.mjs
lune run tests/performance-lune
node scripts/performance-report.mjs perf-baseline.json
```

**Measurement limitations:** Lune executes a simulated GUI and stubbed host
services. Wall-clock milliseconds are useful for comparing the same workload
across CI revisions with similar runners, not for absolute on-device FPS,
render timing, GPU load or battery use. Public CI hardware varies. Do not
assert a percentage speedup without repeat trials, distributions and matching
hardware; do not set an unexplained universal millisecond cut-off.

## Physical Android acceptance sheet — not yet executed

Fill in this sheet for each target Roblox Android device/build. Untested
fields remain **NOT TESTED** rather than passing by assumption.

| Field | Value |
|---|---|
| Test date / commit SHA | NOT TESTED |
| Device / SoC / RAM | NOT TESTED |
| Android version and refresh-rate mode | NOT TESTED |
| Roblox app version / game / PlaceId | NOT TESTED |
| Graphics level / render resolution / orientation | NOT TESTED |
| Executor / injection path (if applicable) | NOT TESTED |
| UI scale, theme, background weather/density | NOT TESTED |
| Baseline game FPS p50 / p95 frametime | NOT TESTED |
| UI enabled FPS p50 / p95 frametime | NOT TESTED |
| CPU, RAM, battery/thermal state | NOT TESTED |
| Known issues, reproduction steps and logs | NOT TESTED |

### Manual scenario matrix

- [ ] Portrait, landscape, device rotation while an overlay is open.
- [ ] UI scale 0.7, 1.0 and 1.4; no unreachable controls.
- [ ] Short tap, 1-second long press, drag cancellation, and cross-finger capture.
- [ ] Dropdown, ColorPicker, search and keyboard/IME: no occlusion or unwanted close.
- [ ] 100/300 controls, including ModuleCard expand and nested SubTabs.
- [ ] DataTable with 1000 rows, scrolling and single-row updates.
- [ ] Repeated palette swaps and 12 dialog open/close cycles.
- [ ] Reinitialize 3 times; release all extension resources on Destroy.
- [ ] Weather: 6 patterns × Screen/UI overlay modes; no input interception.
- [ ] Control position/scroll persistence across orientation changes.
- [ ] Record HUD/gameplay interaction with Developer Inspector closed and open.
- [ ] Compare 1% low FPS, p50/p95/p99 frame time and peak memory against
      the same game/server/scene without the test UI; sample multiple runs.
- [ ] Preserve original slim RiftUI notifications and preview DEMO requirement.

**Release condition:** Native Luau and Node CI green **plus** explicit device
review for the targeted hardware. CI alone marks only automated engineering
acceptance; Android device acceptance stays pending without recorded evidence.

## Follow-up policy

If CI work fails: keep PR open, inspect failing scenario and update the test
or implementation with source-backed reasoning. If mobile behavior fails:
record a reproduction with exact build, resize/keyboard state, gestures and
device conditions, then fix the relevant module rather than altering stable
runtime APIs. Preserve the Loader, Flag, Config and single-file bundle contract.
