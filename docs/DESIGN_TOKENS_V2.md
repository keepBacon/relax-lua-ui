# RelaxUI Design Tokens v2

Implemented in `lib/core/DesignTokens.luau` (P1-1). The runtime retains the existing `Graphite / Ink / Slate / Ember` color themes, `Default / Rounded` control themes and `Hub:SetTheme()` API. There is no separate layout engine or dependency.

## Token catalog

| Group | Tokens | Initial values |
|---|---|---|
| `Color` | `Surface0/1/2`, `SurfaceActive`, `BorderSubtle/Strong`, `TextPrimary/Secondary/Muted`, `Accent/AccentText`, `Success/Warning/Danger`, `Focus/Track/Knob` | Derived from the active legacy palette |
| `Radius` | `XS/S/M/L/Pill` | 6 / 8 / 12 / 16 / 999 |
| `Spacing` | `XS/S/M/L/XL` | 4 / 8 / 12 / 16 / 24 |
| `Typography` | `Head/Body/Meta` | 15 / 13 / 11 px, with weight and line height |
| `Motion` | `Fast/Control/Panel/Dismiss/Ripple`, `Mode` | 0.14 / 0.20 / 0.32 / 0.16 / 0.52 s; Full |
| `State` | `Idle/Hover/Pressed/Focused/Disabled/Dragging/Loading/Error` | Semantic surface, text role and opacity |

Each hub maintains its own **deep-copied, validated token overrides**. Token changes cannot modify other hubs or the static defaults.

## Usage

```luau
local hub = Rift:CreateHub({
    Name = "VTX",
    ColorTheme = "Graphite",
    ControlTheme = "Rounded",
    DesignTokens = {
        Radius = { M = 14, L = 18 },
        Spacing = { M = 14 },
        Typography = { Body = { Size = 13 } },
        Motion = { Mode = "Reduced" },
        Color = { Accent = "#8CBAFF" },
    },
})

hub:GetToken("Radius.M")          -- 14
hub:GetDesignTokens()             -- isolated complete snapshot
hub:GetDesignTokenOverrides()     -- JSON-compatible Version=2 override object
hub:SetToken("Radius.M", 16)
hub:SetDesignTokens({ Color = { Accent = "#7CA6FF" } })
hub:SetMotionMode("Off")
hub:ResetDesignTokens()
```

`SetToken` and `SetDesignTokens` return `true` or `false, reason`. Invalid paths, unsupported groups, nonfinite values, malformed colors and unrecognized state labels reject the entire patch before application. Colors accept `Color3` or 6-digit hex strings. Changes persist to the hub's `setup.json` by default; pass `false` as the final argument for temporary changes. Named configs and `Reinitialize()` preserve overrides; absent v2 data in legacy configs is supported.

## Binding live components

```luau
local panel = Instance.new("Frame")
panel.Parent = hub.Gui
local background = hub:BindToken(panel, "BackgroundColor3", "Color.Surface2")
local shape = hub:BindToken(panel:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.M")
local caption = hub:BindToken(textLabel, "TextSize", "Typography.Body.Size")
hub:ApplyTokenState(panel, "Disabled")
background:Disconnect() -- explicitly stop future color updates
```

`BindToken(instance, property, path, transform?)` registers a weak-instance-backed binding and returns a disconnectable handle. `CornerRadius` and padding values automatically adapt numeric pixels to `UDim`. Theme switches recompute semantic roles without replacing controls or their flags, callbacks, or values. The current integrations include main panel/Dock, header labels, search, ModuleCard, DataTable, TreeView, StatusList and EventTimeline. Unbound external custom controls retain their own styling.

## Motion accessibility

`Motion.Mode` supports **Full**, **Reduced** and **Off**. It is stored on the hub `ScreenGui` and read by the shared tween path, including the existing panel, popup and control animations. Reduced mode caps transitions at approximately 80 ms; Off mode uses a near-zero-time completion to preserve existing completion callbacks instead of abruptly suppressing them. The explicit `hub:TokenTween(instance, preset, goals)` applies changes immediately in Off mode.

Changing motion settings does not stop weather effects or suppress audio automatically. The Android Roblox runtime's actual timing/gesture response, text legibility and 44px hit-target accessibility need device testing; native Lune tests do not prove mobile conformance.

## Compatibility and design

Color and shape themes remain independent. The classic palette keys (`Panel`, `Field`, `Accent`, etc.) remain supported, and token roles derive from the current palette unless explicitly overridden. Existing scripts do not need to adopt Design Tokens v2; the v2 semantic API is additive. Avoid adding a glow/shadow to each control: the graphite look relies on restrained borders, readable typography and spacing rather than layered cards.

## Incremental editing and live semantic state bindings (v2 hardening)

Token editors no longer need to replace the complete overrides object to remove one setting:

```luau
hub:SetToken("Radius.M", 18)
print(hub:HasTokenOverride("Radius.M"))  -- true
print(hub:GetTokenOverride("Radius.M"))  -- 18
hub:ResetToken("Radius.M")                -- restore the active theme's default
hub:ResetToken("Typography.Body")         -- also supports a nested group
```

`ResetToken(path, persist?)` validates the path, only removes the indicated override, prunes empty groups, refreshes bindings and persists unless `persist == false`. Absent but valid paths are an idempotent success. The existing `ResetDesignTokens()` still resets everything. `GetTokenOverride` returns a detached value (or `nil` when not customized), and `HasTokenOverride` returns a boolean. Colors are returned as typed Color3 from `GetTokenOverride`; use `GetDesignTokenOverrides()` for serializable hex strings.

For custom components that need **live** semantic states rather than a one-off `ApplyTokenState` call:

```luau
local action = Instance.new("TextButton")
action.Parent = hub.Gui
local state = hub:BindTokenState(action, "Idle")
state:SetState("Pressed")
state:SetState("Disabled")
print(state:GetState()) -- Disabled
state:Disconnect()
```

The state binding re-applies semantic surface, text and opacity on palette/token changes. It is opt-in, accepts only Instances belonging to the Hub, does not install per-control input listeners and never changes the user's toggle/flag values. If both `BindToken` and `BindTokenState` own a surface on the same Instance, the state wins after each refresh. Rebinding the same `instance + property` through `BindToken` invalidates the previous binding handle. Hub destruction/Reinitialize invalidates both binding-handle types, so old handles should not be reused after rebuilding.

Native regression tests cover per-path reset, preserved unrelated overrides, duplicate property ownership, live color/state refresh, malformed paths, and teardown. Android touch sizing, high-contrast legibility and native frame pacing remain manual verification items.

## Deep component unification — 2026-11-22

The v2 schema now includes **component-specific typography and layout**, while continuing to derive color roles from Graphite / Ink / Slate / Ember. The base v2 `Version = 2` is unchanged; existing saved overrides remain valid.

### Component catalog

| Token group | Adjustable values | Initial reference |
|---|---|---|
| `Components.Dialog` | width/min/max width, max viewport height, edge insets, card padding/gap, heading, icon plate/glyph, close target, body padding/gap/height/transparency, scrim alpha, button min/max width/height/gap/radius/row behavior, lock plate/icon/alpha/radius | width 382, title 15px, action height 36, body radius 10 |
| `Components.Button` | height, rounded extension, corner radius, horizontal padding and icon size | height 28, radius 6 |
| `Components.Popup` | width, corner radius, edge inset, gap, item height and icon size | width 190, item height 28 |
| `Components.Input` | input/chip height and corner radii | 26/24 height |
| `Components.ModuleCard` | reference compact geometry for icon, switch and hit targets | icon 44, switch 34×20, hit 44 |

Text style roles: `Typography.DialogTitle`, `DialogBody`, `DialogDetail`, `DialogButton`, `DialogError`, `ButtonLabel`, `ControlLabel`, `ControlDescription`, `PopupItem`, `ModuleTitle`, `ModuleSummary`. Each role includes `Size`, `Weight`, `LineHeight`.

Color roles now include `DialogSurface`, `DialogBodySurface`, `DialogIconSurface`, `DialogScrim`, `DialogBorder`, `DialogTitle`, `DialogBodyText`, `DialogDetailText`, `DialogIcon`, `DialogCloseIcon`, `DialogButtonSurface`, `DialogButtonText`, `DialogPrimarySurface`, `DialogPrimaryText`, `DialogButtonBorder`, `DialogDangerText`, `DialogErrorText`, `LockShade`, `LockIcon` and standard `Button`/`Input`/`Popup` roles.

### Customize a dialog without modifying its Lua implementation

```luau
hub:SetDesignTokens({
    Color = {
        DialogSurface = "#131720",
        DialogBodySurface = "#0D111B",
        DialogTitle = "#F5F7FB",
        DialogButtonSurface = "#242C3B",
        DialogButtonText = "#E7EBF4",
        DialogPrimarySurface = "#76A5FF",
    },
    Typography = {
        DialogTitle = { Size = 17, Weight = "SemiBold" },
        DialogBody = { Size = 13 },
        DialogButton = { Size = 13 },
    },
    Components = {
        Dialog = {
            Width = 408, MaxWidth = 470,
            Radius = 18, PaddingX = 20, PaddingY = 18,
            IconPlateSize = 36, IconSize = 20,
            ButtonHeight = 42, ButtonMinWidth = 94,
            ButtonRadius = 12, BodyMaxHeight = 190,
        },
    },
})
local modal = hub:OpenActionDialog({
    Title = "确认设置",
    Content = "字号、间距、背景、图标和按钮尺寸均来自 Tokens v2。",
    ButtonLayout = "HorizontalRight",
    Buttons = {
        { Text = "取消" },
        { Text = "确认", Primary = true },
    },
})
hub:SetToken("Typography.DialogTitle.Size", 19) -- updates already-open modal
hub:SetToken("Color.DialogSurface", "#222631")
hub:ResetToken("Components.Dialog.ButtonHeight")
```

`hub:GetComponentTokens("Dialog")` returns a detached snapshot; `hub:WatchDesignTokens(callback)` lets additional composite widgets respond to token changes, returning a `:Disconnect()` handle. `hub:BindComponentTokens(instance, { PropertyName = "Color.DialogSurface" })` is a convenience wrapper around multiple `BindToken` calls with deterministic cleanup.

**Important:** semantic bindings automatically reapply existing dialog colors, font sizes, borders and radii. A single watcher reflows its coupled geometry (button direction, widths, height, icon/text alignment and body scroll budget). No polling loops or CanvasGroup glyph downsampling are introduced. Existing per-dialog `Width` options still take precedence over default width; token min/max bounds remain enforced.

The user-approved ModuleCard layout and default RiftUI notification slit are preserved. The extended catalog is a single source of style values; some legacy widgets may still have specialized positioning logic, so a universal visual parity claim requires continued component audit. Automated Luau tests verify token isolation, validation, persistence and live modal updates; device-specific font rendering and tap targets still need physical Android validation.

## v2 extensibility: custom component catalog and scoped updates (2026-11-22)

Existing themes, pre-defined component tokens and the `Version = 2` storage format are unchanged. Third-party components can now register additional **hub-local** groups under `Components` with deterministic defaults and strict validation. Supported leaf types: finite numbers, booleans, strings and `Color3` (or `#RRGGBB` when setting a color-valued field). Defaults are one-level scalar fields, at most 64 fields per component, with identifier-only names of at most 48 characters. Existing component names cannot be replaced.

```luau
local hub = Rift:CreateHub({
    Name = "Dashboard",
    TokenComponents = {
        Badge = { Size = 18, Filled = false, Caption = "READY",
            Tint = Color3.fromHex("#7399CC") },
    },
    DesignTokens = { Components = { Badge = { Size = 22 } } },
})

hub:GetToken("Components.Badge.Size") -- 22
hub:GetComponentTokens("Badge")       -- detached copy
hub:GetRegisteredComponentTokens()    -- detached custom catalog
hub:SetToken("Components.Badge.Size", 26)
hub:SetDesignTokens({ Components = { Badge = { Tint = "#BBAAFF", Filled = true } } })
hub:ResetToken("Components.Badge.Size") -- returns to component default 18

local watcher = hub:WatchToken("Components.Badge.Size", function(value, path)
    print(path, value) -- called only when the observed value actually changes
end, true) -- optional immediate callback
watcher:Disconnect()

-- Late registration works too:
hub:RegisterComponentTokens("Indicator", { Width = 12, Active = false })
```

`RegisterComponentTokens(name, defaults)` returns `true` or `false, reason`. It does not overwrite existing built-in or custom component schemas. `GetRegisteredComponentTokens()` returns a detached snapshot. Each Hub retains its own registry; registration is preserved through `Reinitialize()` without modifying the caller's shared options.

Set and reset use the existing atomic validation. A rejected update leaves all current overrides and live UI untouched. `GetDesignTokenOverrides()`, named configs and setup persistence serialize component `Color3` values as hex strings. When a saved config contains custom-component overrides before the component has been registered, those values remain pending and are validated/applied on registration. Invalid pending data is discarded for that component without blocking component creation. `ResetDesignTokens()` also clears pending overrides.

`WatchToken(path, callback, immediate?)` observes any existing leaf or subtree and calls back only when its value changes (including theme-derived changes). It uses the existing hub-owned change-dispatch mechanism—no polling loop or additional RenderStepped listener. Disconnect before destroying component-owned GUI objects; Hub teardown also invalidates handles.

**Scope:** This adds extension registration and scoped observation, not new control skins or an automatic layout engine. Custom components remain responsible for applying returned token values to their own instances, using `BindToken`, `BindComponentTokens` or `WatchToken`.
