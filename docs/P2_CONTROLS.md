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
