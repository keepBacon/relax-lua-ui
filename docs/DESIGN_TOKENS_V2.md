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
