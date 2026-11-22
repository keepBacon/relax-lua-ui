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
