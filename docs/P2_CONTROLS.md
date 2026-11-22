# Relax UI — P2 Controls

Three controls extend the existing Section, Hub, OverlayStack, Motion and Design Tokens v2. The preview requires DEMO.

## SearchSelect

Use Section:SearchSelect({ Name, Options, Multi?, Default?, MaxVisible?, Flag?, Callback? }). Options accept plain labels or { Value, Label, Disabled }. Single mode returns one value; Multi mode returns a map of selected values.

Methods: Open, Close, Get, Set(value, silent?), SetOptions(items), GetRecent, OnChanged.

The popup filters by label or value, orders recent choices first when the query is empty, shows an empty-state message, and pools at most MaxVisible + 2 result rows. It reuses the shared popup shield, scrolling viewport and Escape routing. Flags are saved by the existing configuration manager.

## ContextMenu

Section:ContextMenu({ Name, Items, Callback?, LongPressTime? }) creates a trigger. Hub:BindContextMenu(anchor, items, options) attaches right mouse click and Android long press to a GUI anchor. Hub:OpenContextMenu(anchor, items, options) opens it directly.

Menu items use Id, Text, Icon, Shortcut, Disabled, Danger, Callback and optional Children. Use { Separator = true } for separators. Nested children navigate within the same popup, so menus avoid spawning an offscreen child. Touch press takes 450–650ms (default 550ms) and cancels when moving more than 12 pixels.

Menu handles: Close, SetItems, IsOpen. Binding handles: Open, SetItems, Disconnect. Section control: Open, Close, SetItems, Get. Callbacks receive id, item and index. Popup/OverlayStack owns outside clicks and Escape.

## Accordion

Section:Accordion({ Name?, Items, Single?, Default?, Flag?, Callback? }) is a lightweight disclosure group. Items use Id, Title and Content. It contains no module switch or favorite control.

Methods: Expand(id), Collapse(id), Toggle(id), IsExpanded(id), GetExpanded, Set(map,silent?), SetItems(items). Single=true (default) permits only one expanded panel; Single=false allows multiple. Temporary _setSearchPeek does not overwrite selected state. Native clip size animations preserve clear text and use Motion. Flag values are included in named configurations.

## Acceptance

Node and native Lune tests check basic API behavior and lifecycle. Android-specific UI Scale 70/100/140%, real multi-touch/IME, large Chinese labels, long-press gesture cancellation and visual performance remain separate device checks.

## SearchSelect anchoring — 2026-11-22

The SearchSelect trigger is 150 logical px wide. Previously the popup defaulted to 260 px, right-aligned with the trigger, which pushed the menu approximately 110 px left of the control. The default popup is now **176 px**, horizontally centered against the trigger (approximately 13 px overflow on either side), with a **3 px** vertical gap. The placement engine prefers below the trigger when at least 96 px of room is available, otherwise it flips above and clamps to the available viewport. `options.Width` still allows explicit custom widths (150–340 px), and the changes do not alter placement defaults for Dropdown, ColorPicker, or ContextMenu. Both single and multi SearchSelect use this behavior. Native tests inspect both modes; Android screenshots and IME placement still need real-device acceptance.

## 2026-11-22 — P2 reliability follow-up

- `SearchSelect:SetOptions(items, silent?)` prunes selections and recent items no longer present in the new option catalog. Valid selections survive. A pruned selection emits a change unless `silent = true`. Disabled choices are rejected again in the click handler, regardless of a GUI button's Active property.
- SearchSelect's pooled list now calculates the visible row window using the actual popup viewport height. Scrolling and scale changes update the pool without assuming the default six rows always fit. Row pooling still caps the GUI count.
- ContextMenu long press has bounded, timestamped click suppression. A touch release following the long press cannot cause a duplicate open, while a future independent tap is not permanently swallowed.
- Accordion global search now matches each item's title and content. Temporary search peek expands only matching items; clearing search restores persisted expanded state. Explicit `:Destroy()` unregisters its flag, Section entry, ModuleCard nested registration, data subscriptions and rebuild recipe.
- The standalone public bundle, static checks and native Lune regression tests are updated together. Android touch/IME and 70/100/140% visual acceptance remain separate.

## 2026-11-22 — Popup visual/interaction completion pass

- The shared popup layout keeps content-anchored menus out of the visible window header. Short windows still preserve a minimum accessible viewport instead of hiding all entries.
- SearchSelect repaints selected rows in place without resetting scroll on each multi-selection click. It resizes its result popup to the number of matching rows (one empty-state row minimum), while the existing maximum visible row limit and outside/Escape dismissal remain intact.
- ContextMenu aligns the popup's left edge with the trigger, 3 logical px below it when space allows, and accepts an action only if its exact popup is the current top overlay. Navigation and dangerous actions remain behind the same owner check.
- Accordion requests a non-invasive scroll-to-reveal after the expand transition so the newly opened body is visible inside the closest vertical ScrollingFrame. Oversized answers prioritize their header instead of scrolling past it. Superseded or destroyed components cancel pending reveal requests.
- Existing background dim/opacity controls remain user-adjustable. Changing global background transparency or forcing a darker wash without a new Android screenshot is deliberately out of scope.
- Regression tests exercise adaptive result height, popup ownership/placement, and scroll-to-reveal wiring. Android IME/keyboard geometry, real long press, and frame-time acceptance still require device evidence.

## 2026-11-22 — Android popup height stability

- SearchSelect calculates the initial popup height from its actual option count (including empty lists), with the same formula used after filtering. This prevents a tall initial popup from immediately shrinking and flipping on first open.
- Filtered result height changes immediately request re-placement through the existing shared popup manager. Default centered alignment, 3px gap, bounded row pool, width and other controls remain unchanged.
- Source regression tests cover the initialization and placement wiring. Android visual, scale and IME acceptance remains pending.

## 2026-11-22 — ContextMenu availability-gate reliability

The ContextMenu binding supports an optional `CanOpen` callback. It is evaluated before every programmatic, desktop right-click and touch long-press open, preventing a locked Section control from being opened through a gesture that bypassed the normal button-click guard. Section:ContextMenu wires it to `c:IsAvailable()` and re-checks availability before dispatching an action because lock state can change while the popup is visible. Existing Hub:BindContextMenu consumers without CanOpen retain their previous behavior. Native Lune tests cover rejected and allowed binding opens and a Locked Section menu; Android gesture testing remains pending.

## 2026-11-22 — Android long-press cancellation

- ContextMenu now watches the initiating touch through temporary UserInputService InputChanged, InputEnded and InputBegan subscriptions instead of relying on the original anchor to receive movement or release outside its bounds. Movement above 12 px, ending/canceling the finger, and a second simultaneous touch all invalidate the pending long-press timer.
- Gesture subscriptions disconnect on gesture completion/cancellation and on the binding's Disconnect. No always-on RenderStepped or per-control polling is introduced. Locked-state opening and click-suppression behavior are retained.
- Source checks cover the cancellation and teardown wiring; native simulation and real Android drag/long-press testing remain distinct.

## 2026-11-22 — Video-confirmed popup anchor regression

The Android capture shows SearchSelect's multi-select popup intersecting its own trigger at the lower edge; a separate screenshot shows the legacy ModuleCard Dropdown menu displaced upward from its trigger. Both share `Hub:_placePopup`.

Root cause: the dock's top edge was applied as an unconditional popup floor, even when the current anchor was physically below that edge. The subsequent `math.clamp(y, minY, floorY - height)` forcibly teleported a popup off its selected above/below side and could place it across the trigger. The new placement checks the anchor's actual bottom before applying the dock boundary, computes height from **available space on the selected side**, and falls back to viewport bounds when the dock leaves almost no space; the final y is not globally clamped across the anchor. Long lists remain reachable via the existing `PopupViewport` scroll.

Both SearchSelect and legacy Dropdown inherit this shared fix. Source and native regression tests enforce the below-dock trigger scenario. Actual Android visual validation, including scale changes and IME, remains pending.

## 2026-11-22 — Physical video diagnosis: popup coordinate-space mismatch

The repeated Android captures still show a Dropdown aligned roughly in X but shifted substantially in Y. Earlier dock-side/viewport clamps were insufficient. A popup is rendered as a child of `Hub.Overlay`, while `Anchor.AbsolutePosition` and `Header.AbsolutePosition` are screen-space pixels. These were converted only by scale, assuming the overlay's absolute origin was (0, 0), which is not invariant across Roblox safe-area/inset and executor GUI parenting.

`Hub:_placePopup` now computes all positions relative to `self.Overlay.AbsolutePosition`, including anchor, header, dock and screen edges, before writing `Holder.Position` in overlay-local units. Position changes of Overlay itself trigger recomputation. A native test now physically offsets Overlay by 80 px and checks that the rendered popup's `AbsolutePosition` is directly below the trigger rather than checking just a source regex. Real-device validation is still required.

## 2026-11-22 — Android runtime provenance and physical-coordinate probe

Repeated user Android captures still show the same old Dropdown placement, despite static and simulated CI passing. Do not equate a merged fix with physical-device acceptance.

The opt-in diagnostic preview is available from the branch-specific `public/RelaxUI_Preview.luau` during investigation. Enable `getgenv().RELAXUI_POPUP_DEBUG = true` before running. It adds a temporary upper-right readout showing the preview build tag, downloaded library size and an `overlay-local` or `legacy` signature. On each popup open, after the animation settles it samples the **rendered** `Anchor.AbsolutePosition/AbsoluteSize` and `Holder.AbsolutePosition/AbsoluteSize`, as well as scale and overlay origin, and logs the values. The library request receives a per-run cache nonce; this is a diagnostic safeguard, not proof that the executor was caching in previous sessions.

Interpretation: if the version label is absent, the diagnostic preview itself did not load; if the runtime signature is `legacy`, the requested library is stale or unexpected; if `overlay-local` is present but the rendered gap is unexpectedly large, investigate the measured positions, effective scale and layout lifecycle before further coordinate patches. The probe is only active on opt-in, and is destroyed with its Hub. The original `DEMO` preview gate is preserved.

## 2026-11-22 — Dropdown gap: authored size versus runtime size

Android video 1000895063.mp4 confirms the opt-in preview marker `popup-probe-20261122-a`, 845820 downloaded bytes and `overlay-local` runtime signature. In that recording, the open selector is the **advanced multiselect SearchSelect**, not the original **ModuleCard / 渲染模式 legacy Dropdown**. Hence it verifies latest-code loading but does not prove the ModuleCard Dropdown gap fixed.

The shared popup placer previously used `math.max(frame.Size.Y.Offset, frame.AbsoluteSize.Y / hub._scale)`, mixing authored logical dimensions with derived runtime dimensions. When the frame's runtime AbsoluteSize is inflated relative to its intended size, the Holder grows, and above-trigger positioning can leave excess empty space between the *visible* menu content and its trigger. The placer now uses positive `Frame.Size.Offset` when the corresponding Size.Scale is zero, and falls back to layout-derived AbsoluteSize for relative dimensions. This keeps Dropdown content extent and popup clipping width/height consistent. A native Lune test injects 310px AbsoluteSize for a logically 110px popup at 1.4x UI scale and asserts that the Holder and PopupViewport still use 110px. UI Scale and above/below geometry tests remain included. Real Android confirmation of ModuleCard Dropdown is still outstanding.
