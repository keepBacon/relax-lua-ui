# FlowUI

A UI library for Roblox: one window with a sidebar of tabs, an automatic
Home tab, sub tabs and two-column groupboxes, and a full set of controls —
toggles, dropdowns, sliders, inputs, colour pickers, keybinds, statuses,
tables, logs and more. Everything is live-themed (27 preset themes or your
own colours), supports tooltips and dependent controls, shows notifications
and dialogs, pins live values to a Dynamic Island while the window is
minimised, and saves every flagged control into named, shareable configs.

This document is the full reference. `Example.luau` in this repository is
the companion reference build: every section of it is self-contained, so
you can copy the parts you need.

## Provenance

This repository is a restored copy of the **OuroFlow** UI library,
originally published as `joustingmatch/-3` and later deleted by its author.
The restoration was possible because the author's own `Example.luau` —
downloaded before the deletion — embeds the complete library (lines
3–19583 of the example); `Source.luau` here is that library extracted into
standalone form. It is now self-hosted at `deathstrat/FlowUI` so it cannot
disappear again.

Two parts of the original repository could **not** be recovered, because
they were not part of the downloaded example: the original `README.md` and
`llms.txt`. This README is a new document written against the recovered
code and example, and replaces them.

## Load it

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deathstrat/FlowUI/refs/heads/main/Source.luau"))()
```

The returned table is referred to as `Library` throughout this document.

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deathstrat/FlowUI/refs/heads/main/Source.luau"))()

local Window = Library:CreateWindow({
    Name = "Example",
    LoadingSubtitle = "Loading",
    ToggleUIKeybind = "RightControl",
    ConfigurationSaving = { Enabled = true, FolderName = "Example" },
    Home = {
        Discord = "discord.gg/example",
        Stats = { "Players", "Execs", "Session", "FPS", "Ping" },
    },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "zap" })
local General = Main:CreateSubTab({ Name = "General" })
local Automation = General:AddLeftGroupbox({ Name = "Automation", Icon = "repeat" })

Automation:CreateToggle({
    Name = "Enabled",
    Desc = "Runs the selected tasks on a loop",
    CurrentValue = false,
    Flag = "AutomationEnabled",
    Callback = function(Value)
        print("[Example] automation", Value)
    end,
})

Window:LoadAutoload() -- loads the config marked as autoload, if any
```

The shape to remember: **tabs hold sub tabs, sub tabs hold groupboxes,
groupboxes hold elements.** Elements can also be added straight to a tab,
where each one becomes a full-width card.

## Before the window: font and default theme

Two optional `Library` calls from the example run before `CreateWindow`:

```lua
Library:LoadFont({ Name = "ValleySans" }) -- downloaded once and used everywhere
-- Library:SetDefaultTheme("Nebula") -- any preset name or a colour table; a theme the player picks wins
```

- `Library:LoadFont({ Name = "ValleySans" })` downloads the font weights
  once (it needs `writefile`, `isfile` and `getcustomasset`, and warns and
  returns `false` without them), caches them under a folder
  (`Folder = "OuroFlowFonts"` by default), and uses the font everywhere.
  Custom weights can be supplied with `Weights = { Regular = url, Medium = url, SemiBold = url }`.
- `Library:SetDefaultTheme(theme)` sets the theme new windows start with —
  a preset name or a colour table (see [Themes](#themes)). A theme the
  player picks themselves wins over the default.
- `Library:PreloadIcons()` also exists, to fetch the Lucide icon set ahead
  of time instead of on first use.

## Window options

`Library:CreateWindow(opts)` (also available as `Library.Window`) accepts:

| Option | What it does |
| --- | --- |
| `Name` | Window title; also used as the GUI name. (`Title` is the underlying field and can be given instead.) |
| `LoadingSubtitle` | Subtitle shown on the loading screen. |
| `ToggleUIKeybind` | Key that toggles the window: a KeyCode name such as `"RightControl"` or an `Enum.KeyCode`. Default `RightControl`. (`Keybind` also works.) |
| `Size` | Starting window size, a `UDim2`. Default `UDim2.fromOffset(760, 520)`; the window auto-fits the screen and can be resized by dragging. |
| `Icon` | Icon shown for the window (logo). Defaults to the library's logo asset. |
| `ConfigurationSaving` | Table, see below. |
| `Theme` / `DefaultTheme` | Starting theme: a preset name or a colour table. |
| `UIScale` | Extra scale on top of the automatic fit, `0.6` to `1.5`. Default `1`. |
| `AdaptiveSize` | Whether the window adapts its size to the screen. On unless set to `false`. |
| `Density` | `"Compact"`, `"Default"` or `"Comfortable"` — spacing density for the whole UI. |
| `CornerRadius` | Corner radius in pixels for the whole UI. |
| `SidebarWidth` | Starting sidebar width (default `188`); players can drag the divider. |
| `ToggleButton` | The floating button that reopens a hidden window, see below. `false` disables it. |
| `OpenButton` | The pill button that reopens the window. Created when set (a table `{ Title, Icon }` or `true`), and by default on touch devices when no toggle button is shown. `false` disables it. |
| `Backdrop` | The animated backdrop behind the window, see below. `false` disables it. |
| `Disclaimer` | One disclaimer prompt, or a list of them (`Disclaimers`), see below. |
| `Home` | Home tab options, see below. `false` disables the Home tab. |
| `BackgroundTransparency` | Transparency of the window's background image, `0` to `1`. Default `0.35`. |
| `IslandDraggable` | Set to `false` to lock the minimised Dynamic Island in place. |

`ConfigurationSaving = { Enabled = true, FolderName = "Example", FileName = "default" }`

- `FolderName` — the folder configs, themes and settings are written to.
  Default `"AirflowUI"`. Each config is one file: `<FolderName>/<name>.json`.
- `FileName` — the window's default config name, used by
  `Window:SaveConfig()` / `Window:LoadConfig()` when no name is passed.

`ToggleButton = { Platform = "Mobile", Icon = "layout-grid" }`

- `Platform` — `"Mobile"` (the default) or `"Both"`, which also shows it on PC.
- `Icon` — Lucide icon name. `Enabled`, `Size` and `Position` are also read.

`Backdrop = { Weather = "None", Tint = 0.45 }`

- `Weather` — `"Snow"`, `"Rain"`, `"Hell Fire"`, `"Sakura"`, `"Fireflies"`,
  `"Matrix"` or `"None"` (the library's own default is `"Snow"`).
- `Tint` — dim strength, `0` to `1`, default `0.45`.
- Also read: `Enabled`, `Dim` (default on), `Density` (`0`–`3`), `Speed`
  (`0.1`–`3`) and `Mode` (`"Screen"` or `"UI"`, as in the theme manager).

`Disclaimer = { Title = "Terms", Text = "By continuing you accept the terms.", Id = "terms-v1" }`

Disclaimers queue up before the window opens and each one must be
accepted. Also read: `Subtitle`, `Icon`, `Color`, `AcceptText`,
`DeclineText` (set to `false` for no exit button), `RememberText`,
`Callback`, and `Block = true` for one that cannot be remembered away.
A remembered disclaimer (the player ticked "Don't show again") is skipped
on later runs; `Id` identifies it.

Re-executing your script is safe: a window registers itself by config
folder and title, and creating a new one destroys the copy the previous
execution left behind first.

### The Home tab

Unless disabled, the first tab is an automatic Home tab with the player's
profile (avatar, name, welcome line, tier and expiry chips), live stats, a
game card, a links card with a searchable feature list, and an executor
line. `Home = { ... }` in the window options configures it:

| Option | What it does |
| --- | --- |
| `Name`, `Desc`, `Icon`, `Title` | Tab name (default `"Home"`), description, icon (default `"house"`) and page title. |
| `Welcome` | The greeting line above the player's name. Default `"Welcome back"`. |
| `Tier` | Tier chip text, e.g. `"Free"`. |
| `Expiry` | Expiry chip: a timestamp, a string, or a function returning either. |
| `Discord` | Community link text, shown in the links card. `DiscordTitle` / `DiscordIcon` override its title and icon. |
| `Website` | Website link text. `WebsiteTitle` / `WebsiteIcon` work the same way. |
| `Links` | Extra link entries for the links card. |
| `Stats` | Which stat readouts to show, see below. |
| `StatsFolder` | Folder for the persistent `Execs` counter. Defaults to the config folder. |
| `Features` | Custom feature list, see below. |
| `HideName` / `HideAvatar` | Start with the player's name / avatar hidden in the GUI (the same switches as `Window:SetHideName` / `Window:SetHideAvatar`). |
| `SupportedExecutors` | List of supported executor names for the executor card and its unsupported-executor warning. Can also be passed as a top-level window option. |

`Stats` is a list of names; the default is
`{ "Players", "Execs", "Session", "FPS", "Ping" }`. All recognised names:
`"Players"`, `"Friends"`, `"Execs"`, `"Session"` (alias `"Uptime"`),
`"FPS"`, `"Ping"`, `"Executor"`, `"Game"`, `"Region"`, `"Time"`,
`"ServerAge"`, `"Memory"`. FPS and Ping get large readouts with a bar
history; the others are figure readouts.

`Features = { List = { { Name = "Main", Items = { "Automation", { Name = "Targeting", Tag = "New" } } } } }`

Items are `{ Name, Desc, Tag, Icon, Callback }` tables or plain names,
grouped under entries with their own `Items`. If you do not pass
`Features`, the list is built automatically from your tabs and elements
instead — every flagged/named element becomes a searchable entry, and
picking one jumps to it. `Window:ShowFeatures()` opens the feature list
over the window.

## Navigation: tabs, sub tabs, groupboxes, tabboxes

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "zap" })

local General = Main:CreateSubTab({ Name = "General" })
local Advanced = Main:CreateSubTab({ Name = "Advanced" })
Main:CreateSubTab({ Name = "Queue" }) -- an empty sub tab shows the empty state

local Automation = General:AddLeftGroupbox({ Name = "Automation", Icon = "repeat" })
local Targeting = General:AddRightGroupbox({ Name = "Targeting", Icon = "crosshair" })
local Controls = General:AddRightGroupbox({ Name = "Controls", Icon = "sliders-horizontal", Collapsed = true })
```

- `Window:CreateTab({ Name, Icon, Desc })` adds a sidebar tab.
  (`Tab:SetBadge()` / `GetBadge()` still exist, but only as compatibility
  no-ops — tab badges were removed from this library and the calls do
  nothing.)
- `Tab:CreateSubTab({ Name, Icon, Desc })` adds a page inside a tab. A sub
  tab with no groupboxes shows an empty state.
- `SubTab:AddLeftGroupbox({ Name, Icon, Collapsed })` and
  `AddRightGroupbox(...)` add a groupbox to the left or right column.
  Groupboxes can be collapsed (`Collapsed = true` starts closed), and a
  groupbox can also be created without a side with
  `Tab:CreateGroupbox({ Name, Icon, Side = "Left" })` (`Side` accepts
  `"Left"`/`"Right"` or `1`/`2`).
- Tabs also take groupboxes directly (no sub tab needed) — that is how the
  Status and Popups tabs in the example are built:
  `Status:AddLeftGroupbox({ Name = "Session", Icon = "timer" })`.

Tabboxes are groupboxes with their own tabs in the header:

```lua
local Filters = Advanced:AddLeftTabbox({ Name = "Filters" })
local Include = Filters:AddTab({ Name = "Include", Icon = "plus" })
Include:CreateToggle({ Name = "Rare Items", CurrentValue = true, Flag = "IncludeRare" })
local Exclude = Filters:AddTab({ Name = "Exclude", Icon = "minus" })
Exclude:CreateSlider({ Name = "Below Value", Range = { 0, 1000 }, Increment = 10, CurrentValue = 100, Flag = "ExcludeBelow" })
```

`AddRightTabbox` mirrors it on the right; `Tab:CreateTabbox({ Name, Side })`
is the side-agnostic form, and a tabbox's `AddTab` is also aliased as
`CreateTab`.

Every container — tab, sub tab, groupbox and tabbox tab — shares the same
element constructors below: each public method is available both under its
plain name (`Toggle`) and as `CreateToggle`, and likewise for the rest.

## Elements

### Options every element accepts

| Option | What it does |
| --- | --- |
| `Name` | Title shown on the element. (`Title` also works.) |
| `Desc` | Smaller description line under the title. (`Description` also works.) |
| `Icon` | Lucide icon name shown with the element (where the element has an icon slot). |
| `Tooltip` | A string, or `{ Title, Text, Icon }`. Any element accepts one. |
| `Flag` | Saves the element's value into configs under this name, and registers it in `Library.Flags`. |
| `Callback` | Called when the value changes (not called when a change is applied silently, e.g. by a config load). |
| `Visible` | `false` hides the element at start; it is still saved with the config. |
| `Disabled` | `true` starts the element dimmed under a cover that swallows input. |
| `DependsOn` | Show (or enable) this element only while another flag allows it — see below. |
| `DependsMode` | `"Disable"` dims the element instead of hiding it while the rule fails. |

`DependsOn` rule forms (from the example and the library):

```lua
-- only shown in Undercut mode
DependsOn = { Flag = "PriceMode", Value = "Undercut" }
-- only shown while the Auto Bid toggle is on
DependsOn = "AutoBid"
```

A string names a flag that must be "on" (true, a non-empty pick, a
non-zero number). A table `{ Flag, Value, Not }` checks against one or
more accepted values; a list of rules must all pass; a function returning
true also works.

### The handle every element returns

Constructors return a handle. Value elements expose `.Value`, and:

```lua
handle:Get()              -- current value
handle:Set(value, silent) -- set it; silent = true skips the Callback
handle:SetVisible(bool)   -- also IsVisible()
handle:SetDisabled(bool)  -- also IsDisabled()
handle:SetDependsOn(rule, mode)
handle:SetTooltip(tip)    -- also GetTooltip()
handle:Destroy()
```

Handles are also how dependent controls are wired by hand — the example
hides a slider from a toggle's callback with `Limit:SetVisible(Value)`.

`Library.Flags["FlagName"]` gives you the handle of any flagged element
from anywhere.

### Section

A heading row that separates groups of elements on a tab. Takes a plain
string or a table:

```lua
Elements:CreateSection("Controls")
Elements:CreateSection("Media and tables")
```

### Divider

A horizontal rule, optionally with a centred caption:
`CreateDivider()`, `CreateDivider("Text")` or `CreateDivider({ Text = "..." })`.

### Label

Plain, wrapping text. Rich text is on: theme tags such as
`<Accent>...</Accent>` and `<Muted>...</Muted>` follow the current theme.
With an `Update` function the label refreshes itself:

```lua
Box:CreateLabel({ Text = "Ready" }) -- Text and Color are the fields read
```

Live labels (and statuses) accept `Update = function() ... end` and
`UpdateRate` in seconds; the returned handle has `SetUpdateRate(seconds)`.

### Paragraph

A card with a title and longer wrapped text:

```lua
Elements:CreateParagraph({
    Title = "Paragraph",
    Content = "Longer text wraps across as many lines as it needs.",
})
```

Also read: `Desc`, `Icon`, `Style`, `Callback`.

### Button

```lua
Profiles:CreateButton({
    Name = "Apply",
    Style = "Primary",
    Callback = function()
        print("[Example] applied")
    end,
})
```

- `Style = "Primary"` makes it the accent-filled button; anything else is
  the plain style.
- `Icon` and `Desc` and `Tooltip` work as usual.
- Two safety forms are built in:

```lua
Elements:CreateButton({
    Name = "Clear All Rules",
    Icon = "trash-2",
    Confirm = true, -- first click arms it, the second runs it
    Callback = function() end,
})

Elements:CreateButton({
    Name = "Spend 1,000 Gold",
    Icon = "coins",
    HoldToConfirm = 1.5, -- seconds to hold
    Callback = function() end,
})
```

With `Confirm`, the first click renames the button to "Click again to
confirm" (or your own string: `Confirm = "..."`) and disarms itself after
`ConfirmTimeout` seconds (default 3); the returned handle has `Disarm()`.
With `HoldToConfirm` (seconds, or `true` for 1 second) the button fills
while held and only fires at the end.

### Toggle

```lua
Automation:CreateToggle({
    Name = "Enabled",
    Desc = "Runs the selected tasks on a loop",
    CurrentValue = false,
    Flag = "AutomationEnabled",
    Callback = function(Value)
        print("[Example] automation", Value)
    end,
})
```

`CurrentValue` is the starting value (`Default` and `Value` are accepted
aliases — the same aliasing applies to the other value elements below).

### Slider

```lua
Automation:CreateSlider({
    Name = "Interval",
    Range = { 1, 60 },
    Increment = 1,
    Suffix = "s",
    CurrentValue = 5,
    Flag = "AutomationInterval",
    Callback = function(Value)
        print("[Example] interval", Value)
    end,
})
```

- `Range = { min, max }` (or `Min` / `Max` separately). `Increment`
  (alias `Step`) snaps values; the number of decimals shown is derived
  from the increment automatically.
- The value can also be typed into the value box.
- `OnRelease = function(Value) end` fires when a drag ends.

### Stepper

A − / value / + control for small ranges, with the same fields as Slider:

```lua
Controls:CreateStepper({
    Name = "Speed",
    Range = { 1, 10 },
    Increment = 1,
    CurrentValue = 5,
    Flag = "Speed",
    Callback = function(Value)
        print("[Example] speed", Value)
    end,
})
```

### Dropdown

Single pick, or `MultipleOptions = true` for a multi pick whose callback
receives the whole list. Picks too long for the chip scroll past in a
loop.

```lua
Targeting:CreateDropdown({
    Name = "Mode",
    Options = { "Nearest", "Lowest Health", "Highest Value" },
    CurrentOption = "Nearest",
    Flag = "TargetMode",
    Callback = function(Option)
        print("[Example] target mode", Option)
    end,
})

Automation:CreateDropdown({
    Name = "Tasks",
    Options = { "Collect", "Upgrade", "Sell", "Claim Rewards" },
    MultipleOptions = true,
    CurrentOption = { "Collect" },
    Flag = "AutomationTasks",
    Callback = function(Options)
        print("[Example] tasks", table.concat(Options, ", "))
    end,
})
```

More fields read by the dropdown: `AllowNone` (`false` forces a pick to
always exist), `NoneText`, `Searchable`, `SearchAfter` (only show the
search box above this many options), `SearchPlaceholder`, `MaxRows`,
`EmptyText`, `NoResultsText`, `PopupWidth`, `Stacked`. Its handle adds
`Refresh(newOptions, keepSelection, silent)`, `SetOptions(list, { KeepSelection, Silent })`,
`GetOptions()` and `SetOpen(bool)`. (`MultipleOptions` can also be written
`Multi`; `CurrentOption` also accepts `Default`.)

### Input

A text field. The callback fires when the box loses focus (with the Enter
key distinction handled by the box):

```lua
Profiles:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://",
    Flag = "WebhookUrl",
    Callback = function(Text)
        print("[Example] webhook", Text)
    end,
})
```

`PlaceholderText` (alias `Placeholder`), `CurrentValue`, and
`Numeric = true` for number-only entry are read.

### ColorPicker

```lua
Profiles:CreateColorPicker({
    Name = "Highlight Color",
    Color = Color3.fromRGB(128, 160, 246),
    Flag = "HighlightColor",
    Callback = function(Color)
        print("[Example] color", Color)
    end,
})
```

`Color` is the starting colour (`CurrentValue`/`Default` also work). The
handle adds `SetOpen(bool)`; `Set` / `Get` work with `Color3` values.

### Keybind

```lua
Controls:CreateKeybind({
    Name = "Stop",
    CurrentKeybind = "X",
    Flag = "StopKey",
    Callback = function()
        print("[Example] stop")
    end,
})
```

`CurrentKeybind` is a KeyCode name or an `Enum.KeyCode`. Two callbacks:
`Callback` fires **when the key is pressed** in game; `OnChanged` fires
when the player **rebinds** the key — that is how the Settings example
keeps the window keybind in sync:

```lua
Menu:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    OnChanged = function(Key)
        Window:SetKeybind(Key)
    end,
})
```

### Progress

A read-only bar. The value is a fraction, `0` to `1`:

```lua
Elements:CreateProgress({ Name = "Progress", CurrentValue = 0.65 })
```

Also read: `Format = function(value) ... end` for the readout text,
`Color` and `TextColor`. The handle adds `SetColor` / `SetTextColor`.

### OrderList

An always-open reorderable list. Drag a row (by its grip on touch) or use
the arrows; the callback receives the new order:

```lua
Priority:CreateOrderList({
    Name = "Task Order",
    Desc = "The top task runs first",
    Items = { "Collect", "Upgrade", "Sell", "Claim Rewards" },
    Flag = "TaskOrder",
    Callback = function(Order)
        print("[Example] order", table.concat(Order, " > "))
    end,
})

Priority:CreateOrderList({
    Name = "Steps",
    Items = Steps,
    MaxRows = 5, -- more rows than MaxRows scroll inside the list
    Flag = "StepOrder",
})
```

Also read: `Numbered` and `Arrows` (both on unless set to `false`),
`EmptyText`. The handle adds `Refresh(items, keepOrder, silent)`.

### Status and Statuses

Read-only key/value readouts that live in groupboxes. Styles set the
shape: `"Plain"`, `"Row"`, `"Badge"`, `"Dot"`, `"Bar"` and `"Stat"`.

```lua
Progress:CreateStatus({ Name = "Level", Value = 42, Style = "Stat" })
Progress:CreateStatus({ Name = "Experience", Value = "6200/10000", Style = "Bar" })
Progress:CreateStatus({ Name = "Balance", Value = 125000, Style = "Row", Pin = true })
```

- `Value` sets a static value; `Update = function() ... end` (with
  `UpdateRate` in seconds) recomputes it live. For `Style = "Bar"` an
  `Update` returning `value, max` sets both; for `"Dot"`/`"Badge"` an
  update returning `text, tone` sets both.
- `Tone` colours the readout: `"Success"`, `"Warning"`, `"Error"`,
  `"Accent"` (the default), `"Muted"` — any theme colour name works.
  `Color` / `ValueColor` set an exact `Color3`.
- `Pin = true` also shows the value on the minimised Dynamic Island.
- Text is rich: theme tags (`<Accent>3</Accent> active · <Muted>9 idle</Muted>`)
  follow the theme, and `Library.Colorize(text, toneOrColor)` wraps any
  colour — the example's live Ping status does exactly that:

```lua
Health:CreateStatus({ Name = "Ping", Style = "Row", Pin = true, Update = function()
    local Ms = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    local Tone = Ms < 90 and "Success" or Ms < 180 and "Warning" or "Error"
    return Library.Colorize(Ms .. " ms", Tone)
end })
```

More fields read: `Prefix`, `Suffix`, `Max` (for bars), `Placeholder`,
`Flash`, `Pulse`, `Wrap`. The status handle adds `Set(value, max)`,
`SetTone(tone)`, `SetColor(color)`, `SetName(name)`, `Text()` and
`SetUpdateRate(seconds)` alongside the common handle methods.

`CreateStatuses` builds several at once, with shared options applied to
every entry:

```lua
Session:CreateStatuses({
    { Name = "Cycles", Pin = true, Update = function()
        Cycles += 1
        return Cycles
    end },
    { Name = "Collected", Value = 0 },
    { Name = "Errors", Value = 0 },
    { Name = "Region", Value = "-" },
}, { Style = "Plain" })
```

It returns a table of handles keyed by name.

### StatusList

A read-only block of rows that grows with its rows up to `MaxRows`, then
scrolls inside itself:

```lua
Jobs:CreateStatusList({
    Name = "Queue",
    MaxRows = 5,
    EmptyText = "Nothing queued",
    UpdateRate = 0.5,
    Update = function()
        local Rows = {}
        for Index = 1, 8 do
            local Remaining = math.floor((os.clock() + Index * 3) % 15)
            Rows[Index] = {
                Text = "Job " .. Index,
                Value = Remaining == 0 and "done" or (Remaining .. "s left"),
                Tone = Remaining == 0 and "Success" or nil,
            }
        end
        return Rows
    end,
})
```

Instead of `Update`, `Rows = { ... }` sets the rows directly. The handle
adds `Set(list)`, `Clear()` and `SetName(text)`.

### Image

A media card. Images fade in once loaded:

```lua
Elements:CreateImage({
    Name = "Image",
    Image = "Deep Violet", -- an asset id, rbxassetid:// or rbxthumb:// link, a web link, a background preset or "Avatar"
    Height = 140,
    Caption = "Images fade in once loaded",
})
```

Background preset names: `"Deep Violet"`, `"Blood Red"`, `"Cyanic"`,
`"Amber Glow"`, `"Bloomings"`, `"Lavender Pink"`. Web links are
downloaded and cached by the library. The handle adds
`SetImage(source)`, `SetCaption(text)`, `SetScaleType(name)` and
`SetColor(color)`; also read: `ScaleType`, `Color`, `Desc`.

### Table

A sortable, searchable grid. Click a header to sort, again to flip, a
third time to reset:

```lua
local Board = Elements:CreateTable({
    Name = "Leaderboard",
    Rank = true, -- a # column with medals for the top three
    Columns = {
        "Player",
        { Name = "Score", Align = "Right", Width = 0.2 },
        { Name = "Balance", Align = "Right", Width = 0.25, Format = function(Value) return "$" .. Value end },
    },
    Rows = {
        { "Player One", 42, 12500 },
        { "Player Two", 57, 9800 },
        { LocalPlayer.DisplayName, 31, 15200, Highlight = true },
    },
    SortBy = "Score",
    MaxRows = 6,
    Callback = function(Row, Index)
        print("[Example] row", Row[1], Index)
    end,
})
Board:UpdateRow(3, { "Player Three", 33, 16000, Highlight = true })
Board.Rows[3] -- rows stay readable on the handle
```

Columns are plain names or tables: `{ Name, Align = "Left"/"Center"/"Right", Width (a fraction), Format = function }`.
A row can carry `Highlight = true`. Table handle methods: `SetRows(rows, silent)`,
`GetRows()`, `AddRow(row, position)`, `UpdateRow(index, row)`,
`RemoveRow(index)`, `Clear()`, `Sort(key, descending)`, `NewRow()`,
`SetColumns(list)`, `SetMaxRows(count)`, `SetSearch(text)`, `SetTitle(text)`.

Tables can be **editable** when columns are typed — with a `Flag` they
save with the config like any other element:

```lua
local Rules = Elements:CreateTable({
    Name = "Price Rules",
    Desc = "Typed columns make a table editable",
    Columns = {
        { Name = "Item", Type = "Text", Placeholder = "Item name" },
        { Name = "Sell", Type = "Number", Min = 0, Integer = true, Align = "Right", Width = 0.22 },
        { Name = "Buy", Type = "Toggle", Align = "Center", Width = 0.14 },
        { Name = "Mode", Type = "Dropdown", Options = { "Market", "Auction", "Trade" }, Searchable = true, Width = 0.24 },
    },
    Rows = {
        { Item = "Golden Egg", Sell = 500, Buy = false, Mode = "Market" },
    },
    Flag = "PriceRules", -- saved with the config like any other flag
    OnChanged = function(Rows)
        print(#Rows)
    end,
})
```

Typed columns add `Type` (`"Text"`, `"Number"`, `"Toggle"`, `"Dropdown"`),
`Placeholder`, `Min`, `Integer`, `Options`, `Searchable`. Also read on any
table: `Editable`, `AllowAdd`, `AllowRemove`, `AddText`, `NewRow`,
`Sortable`, `SortDescending`, `Search` (on unless `false`),
`SearchPlaceholder`, `NoMatchText`, `EmptyText`, `RowHeight`.

### Log

A scrolling activity feed. The oldest lines drop off past `MaxEntries`:

```lua
local Activity = Elements:CreateLog({
    Name = "Activity",
    MaxEntries = 50, -- the oldest lines drop off past this
    MaxRows = 5,
})

Activity:Push("Bought <Accent>Golden Egg</Accent> for 480", "Success")
Activity:Push("Listed Silver Egg for 1,200")
Activity:Push("Trade declined", "Warning")
```

`Push(text, toneOrColor)` (aliases `Add`, `Log`) appends a line — entries
are timestamped unless `Timestamps = false` (`TimeFormat` formats the
stamp). The handle adds `Clear()`, `Get()` (copies of the entries, oldest
first: `{ Text, Color, Time }`) and `SetMaxEntries(count)`. `CreateFeed`
is an alias of `CreateLog`.

## Popups: notifications, confirms and dialogs

All three are `Library` calls that forward to the most recent window
(each `Window` has the same methods):

```lua
Library:Notify({
    Title = "Success",
    Content = "This is a success notification.",
    Type = "Success",
    Duration = 3,
})
```

- `Notify({ Title, Content, Type, Duration, Icon })` — `Type` colours the
  title: `"Success"`, `"Warning"` or `"Error"` (anything else uses the
  normal text colour). `Duration` defaults to 4 seconds. `Text` /
  `Message` are accepted instead of `Content`. While the window is
  minimised, notifications also surface on the Dynamic Island.

```lua
Library:Confirm({
    Title = "Reset progress?",
    Content = "This cannot be undone.",
    ConfirmText = "Reset",
    CancelText = "Cancel",
    Callback = function()
        print("[Example] confirmed")
    end,
})
```

- `Confirm({ Title, Content, ConfirmText, CancelText, Icon, Callback, OnCancel })`
  is the two-button form; the defaults are `"Are you sure?"`, `"Confirm"`
  and `"Cancel"`.

```lua
Library:Dialog({
    Title = "Choose a mode",
    Content = "You can change this later in Settings.",
    Buttons = {
        { Title = "Basic", Callback = function() print("[Example] basic") end },
        { Title = "Balanced", Callback = function() print("[Example] balanced") end },
        { Title = "Full", Variant = "Primary", Callback = function() print("[Example] full") end },
    },
})
```

- `Dialog({ Title, Content, Icon, Buttons, OnCancel })` is the general
  form `Confirm` is built on: any number of `{ Title, Variant, Callback }`
  buttons (`Variant = "Primary"` for the accent button). Opening a new
  dialog closes the previous one.

## Settings

The example's Settings tab shows the standard "menu" wiring — every
control drives a real window method:

```lua
local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })
local Menu = Settings:AddLeftGroupbox({ Name = "Menu", Icon = "monitor" })

Menu:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    OnChanged = function(Key)
        Window:SetKeybind(Key)
    end,
})

Menu:CreateMinimizeOnStart()

Menu:CreateDropdown({
    Name = "Toggle Button",
    Options = { "Mobile only", "Mobile & PC" },
    CurrentOption = "Mobile only",
    AllowNone = false,
    Flag = "ToggleButtonPlatform",
    Callback = function(Option)
        Window:SetToggleButtonPlatform(Option == "Mobile & PC" and "Both" or "Mobile")
    end,
})

Menu:CreateToggle({
    Name = "Backdrop",
    CurrentValue = true,
    Flag = "Backdrop",
    Callback = function(Value)
        Window:SetBackdrop(Value)
    end,
})

Menu:CreateSlider({
    Name = "Backdrop Tint",
    Range = { 0, 90 },
    Increment = 5,
    Suffix = "%",
    CurrentValue = 45,
    Flag = "BackdropTint",
    Callback = function(Value)
        Window:SetBackdropTint(Value / 100)
    end,
})

Menu:CreateButton({
    Name = "Unload",
    Icon = "power",
    Callback = function()
        Library:Confirm({
            Title = "Unload Example?",
            ConfirmText = "Unload",
            Callback = function()
                Window:Destroy()
            end,
        })
    end,
})
```

`CreateMinimizeOnStart({ Name })` builds the "Minimize UI on Start"
toggle for you — it reads and writes `Window:GetMinimizeOnStart()` /
`Window:SetMinimizeOnStart(bool)`, and is stored with the window's own
settings rather than a config flag.

Below the menu, two one-line managers build their own groupboxes:

```lua
Settings:CreateConfigManager({ Name = "Configs", Side = "Left" }) -- builds its own groupbox
Settings:CreateThemeManager({ Name = "Themes", Side = "Right" })
```

Both are called on a tab (or sub tab); called inside a groupbox they
build into it instead. Both accept `{ Name, Icon, Side, Placeholder, Rows }`.

### Config manager

The config manager is a complete config UI: a list of saved configs (with
"loaded" / "auto" tags and a status line), a name input, and buttons for
**Save**, **Load**, **Delete**, **Refresh**, **Rename**, **Reset**,
**Copy code** and **Import code**, an **Auto Load Config** toggle for the
picked config, and an **Autoload mode** dropdown (`"All accounts"` /
`"This account"`). Copy code exports a config as a shareable code;
importing a code from another config folder asks before overwriting.

It returns a manager handle with `Create(name)`, `Save(name)`,
`Load(name)`, `Delete(name)`, `Rename(name, newName)`, `Reset()`,
`Refresh()`, `SetAutoload(name)`, `ClearAutoload()`,
`ToggleAutoload(name)`, `SetAutoloadMode(mode)`, `Export(name)` and
`Import(code)`.

### Configs in code

Everything the manager does is also on the `Window`:

```lua
Window:SaveConfig("main")        -- writes <FolderName>/main.json
Window:LoadConfig("main")        -- applies every saved flag (silently)
Window:LoadConfig()              -- the FileName config / last loaded one
Window:DeleteConfig("main")
Window:RenameConfig("main", "backup")
Window:ConfigExists("main")      --> boolean
Window:ListConfigs()             --> { "main", ... }
Window:ResetConfig()             -- back to the elements' starting values
Window:ExportConfig("main")      --> shareable code string
Window:ImportConfig(code, "imported")
Window:ClearWorkspace()          -- deletes the whole config folder
Window:OnConfigChanged(function() end) --> returns a disconnect function
```

Autoload marks one config to be loaded by `Window:LoadAutoload()`:

```lua
Window:SetAutoload("main")            -- scope "Global" (all accounts)
Window:SetAutoload("main", "Account") -- this account only
Window:GetAutoload()                  -- the marked name, if any
Window:SetAutoloadMode("Account")     -- or "Global"; GetAutoloadMode() reads it
Window:LoadAutoload()                 -- loads the marked config once, and notifies
```

How values are stored: every element with a `Flag` is registered in
`Library.Flags` and serialised by flag name. When a config loads, values
are applied silently (callbacks do not fire), in a fixed element order
(dropdowns, sliders, steppers, inputs, colour pickers, keybinds, then
toggles — `Window:SetLoadingOrder(order)` changes it, and
`Window:SetIgnoreFlags({ ... })` excludes flags). A flagged element
created *after* a load still picks up its saved value when its
constructor returns.

### Theme manager

The theme manager is the themes equivalent: a preset dropdown, a list of
saved themes, a name input with **Save** / **Load** / **Delete** /
**Set Default**, a status line, and a per-colour customiser (a colour
picker for each theme colour). Its handle has `Create(name)`,
`Save(name)`, `Load(name)`, `Delete(name)`, `Refresh()` and
`ToggleDefault(name)`.

Unless you opt pieces out with `opts.X = false`, it also builds a
companion **Menu** groupbox of interface options: Weather, Weather Mode,
Dim, Transparent, Drag Style, Dynamic Island style, Adaptive Size,
UI Scale, Density, Corner Radius, and a Background picker with a
Background Opacity slider. (`Menu = false` skips the groupbox;
`MenuName` / `MenuIcon` / `MenuSide` rename it.)

### Themes

The library ships 27 preset themes:
Midnight (the default), Ocean, Rose, Emerald, Amber, Mono, Nebula,
Synthwave, Sakura, Velvet, Crimson, Sunset, Gold, Cyber, Toxic, Matcha,
Aurora, Frost, Abyss, Halloween, Haunted, Christmas, Valentine, Lunar,
Tropical, Dracula and Coffee.

```lua
Library:SetTheme("Nebula")          -- by preset name, live
Library:SetTheme({ Accent = Color3.fromRGB(201, 162, 39) }) -- or a colour table
Library:GetTheme()                  --> current theme table
Library:SetDefaultTheme("Nebula")   -- what new windows start with
Window:SaveTheme("mine")            -- per-window theme files, like configs
Window:LoadTheme("mine")
Window:ListThemes()
Window:DeleteTheme("mine")
Window:SetDefaultTheme("mine")      -- this window's saved default
```

A custom theme is a table of `Color3` values keyed by the theme colours:
`Accent`, `AccentDark`, `Background`, `Surface`, `Surface2`, `Surface3`,
`Stroke`, `StrokeHover`, `Text`, `Muted`, `Warning`, `Success`, `Error`.
`Library:SetCornerRadius(pixels)` rescales every corner in the UI, and
`Library:SetDensity("Compact" | "Default" | "Comfortable")` respaces it.

## Window methods

Beyond the config and theme methods above, these `Window` methods are
verified in the library (the Settings example uses the first group):

```lua
Window:SetKeybind(keyCode)              -- the toggle-UI key
Window:SetToggleButton(enabled)         -- show/hide the floating toggle button
Window:SetToggleButtonPlatform("Mobile" | "Both")
Window:SetToggleButtonIcon(icon)
Window:SetBackdrop(enabled)
Window:SetBackdropTint(amount)          -- 0 to 1
Window:SetWeather(name)                 -- backdrop weather, as in Backdrop above
Window:SetWeatherMode(mode)             -- "Screen" or "UI"
Window:SetWeatherDensity(density)
Window:SetWeatherSpeed(speed)
Window:SetDim(enabled)
Window:Toggle(open)                     -- show/hide; no argument flips it (.Open reads the state)
Window:Minimize() / Window:Restore() / Window:SetMinimized(bool)
Window:SelectTab(tab)                   -- switch to a tab handle
Window:SetHideName(hidden)              -- hide the player's name inside the GUI
Window:SetHideAvatar(hidden)            -- hide the player's avatar inside the GUI
Window:SetUIScale(value)                -- also GetUIScale()
Window:SetDensity(mode)                 -- also GetDensity()
Window:SetSize(size, instant)           -- also GetSize()
Window:SetDragStyle(style)              -- "Outline", "Brackets", "Ghost", "Frame" or "Off"
Window:SetIslandStyle(style)            -- "Show on Hover" or "Always Show"
Window:SetIslandDraggable(enabled)
Window:ResetIslandPosition()
Window:SetTransparent(enabled)
Window:SetAdaptiveSize(enabled)
Window:SetKeepOnScreen(enabled)
Window:SetBackground(source)            -- preset name, asset id, rbxthumb:// or web link
Window:SetBackgroundTransparency(value) -- also GetBackground() / ListBackgrounds()
Window:CopyToClipboard(text, what)      -- copies, with a notification
Window:Rejoin()
Window:ServerHop()
Window:JoinLowestServer()
Window:ShowFeatures()                   -- the Home feature list, over the window
Window:Destroy()                        -- unload this window completely
```

`Window.Gui` is the window's `ScreenGui`, and `Window.LoadedConfig` the
name of the config currently loaded, if any.

## Library methods

```lua
Library:CreateWindow(opts)   -- also Library.Window
Library:Notify(opts)         -- forwards to the most recent window
Library:Confirm(opts)
Library:Dialog(opts)
Library:LoadFont(opts)       -- { Name, Weights, Folder }
Library:PreloadIcons()
Library.Colorize(text, toneOrColor)  -- wrap text in a theme tone or a Color3
Library:SetTheme(theme, instant) / Library:GetTheme()
Library:SetDefaultTheme(theme) / Library:GetDefaultTheme()
Library:SetDensity(mode) / Library:SetCornerRadius(pixels) / Library:GetCornerRadius()
Library:Destroy()            -- destroys every window; Library.Unload is the same call
Library.Flags                -- { [flag] = element handle }
Library.Windows              -- all live windows
Library.ThemePresets         -- the preset table
```

## Runtime assets

Exactly as in the original library, two assets are fetched at runtime:

- **Lucide icons** — every `Icon` name in this document is a Lucide icon,
  loaded from `Footagesus/Icons`
  (`raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua`).
  If the fetch fails the library warns (`[OuroFlow] lucide icons unavailable`)
  and continues without icons.
- **Valley Sans font** — the Regular, Medium and SemiBold weights from
  `HelsinkiTypeStudio/valley-sans`, downloaded by `Library:LoadFont` and
  cached as files (see above). Without it, the library's built-in font
  faces are used.

Window chrome assets (shadow, glow, logo) are ordinary `rbxassetid://`
images and need no fetching.

## Files in this repo

- `Source.luau` — the library itself: the recovered OuroFlow code as a
  standalone `return (function() ... end)()` module, ready for the
  loadstring above.
- `Example.luau` — the author's original example, untouched. It embeds
  its own copy of the library, so it runs on its own and doubles as the
  reference build for this README.
- `README.md` — this document.
