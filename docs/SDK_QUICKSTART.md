# Relax UI Developer SDK — R4 quickstart, contracts and migration

**Target:** `keepBacon/relax-lua-ui`, main; Roblox Luau executor runtime.
**Runtime:** `lib/RiftUI.luau` + `lib/core/{DeveloperKit,CustomComponents,VisualInspector,DesignTokens}.luau`,
assembled as `public/RiftUI.luau` by `scripts/bundle.mjs`. Do not require the
individual core files in an executor. **Types:** `types/DeveloperSDK.luau` is
editor/documentation only and is not bundled into the runtime.

## Run the developer example

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/examples/developer-sdk.luau"))()
```

The example creates a new Hub with a named extension, a scoped counter component
whose value survives normal config/replay, a local event and an opt-in Inspector.
It is **not** the `DEMO`-gated showcase; the existing `public/RelaxUI_Preview.luau`
and short loader `p` keep their respective preview gate unchanged.

For revision-pinned evaluation, first set `getgenv().relaxcommit` to an existing
7–40-character hexadecimal commit SHA, then run the standard Loader. Pinning only
accepts the specified revision and does not fall back silently.

## Architecture boundaries

- `Hub` owns SDK registries, subscriptions, custom components and Inspector.
- `Section:Component(name, opts)` owns the resulting control; use regular
  `Flag`, `Get/Set`, Callback, availability and config paths.
- `scope` owns connections, UI objects, functions and other disposable resources.
- `DesignTokens` is the **single** theme and component schema registry.
- `OverlayStack`, `InputFocus` and `Motion` remain the only corresponding
  infrastructure: extensions must not install perpetual frame-level polling.
- Reinitialize replays ordinary Tab/Section recipes first, then invokes
  registered extension Start hooks on the rebuilt Hub. An extension-owned
  control must be instantiated from Start (not from a detached ordinary recipe);
  this ensures its definition exists before the control instance is built.
  The old Hub/Section/Control Lua references may be forwarders; do not cache raw
  GUI Instances across reinitialization.

## API reference

### Hub extension lifecycle (R1)

| Method | Inputs | Result | Notes |
|---|---|---|---|
| `RegisterExtension` | `name: string, descriptor: {Version?, Start, Stop?}` | `true, metadata` or `false, reason` | Valid names: letters/digits/`_-.`, 1–72 chars; duplicate rejected; failed Start rolls back Scope. |
| `UnregisterExtension` | `name` | `true` or `false, reason` | Stop then scoped cleanup; idempotence is not implied. |
| `GetExtension` | `name` | Metadata copy or `nil` | State = Active or Starting. |
| `ListExtensions` | none | Array of names | Registration order. |
| `CreateDeveloperScope` | optional `name` | Scope or `nil, reason` | Scope supports Own/Connect/Defer/Close. |
| `OnDeveloperEvent` | `event, callback, scope?` | Disconnectable subscription or `nil, reason` | Callback gets `(payload,event,hub)`. Exceptions isolated. |
| `EmitDeveloperEvent` | `event, payload?` | `true, deliveredCount` or `false, reason` | Synchronous fanout; callbacks run under xpcall. |
| `ReportDeveloperDiagnostic` | `severity, code, message, context?` | Diagnostic copy or `nil, reason` | Info, Warning, Error; history retains last 80. |
| `GetDeveloperDiagnostics` | optional severity | Detached diagnostic array | Do not log credentials. |
| `ClearDeveloperDiagnostics` | none | none | Does not reset total Faults counter. |
| `GetDeveloperStats` | none | Detached summary | Extensions/Scopes/Listeners/Diagnostics/Events/Faults. |

```luau
local scope = hub:CreateDeveloperScope("custom-panel")
scope:Connect(button.MouseButton1Click, function() print("clicked") end)
scope:Defer(function() print("disposed") end)
scope:Close() -- safe to call twice
```

### Custom Section components (R2)

```luau
local ok, infoOrError = hub:RegisterComponent("example.badge", {
    Version = "1.0.0", Height = 44, Default = 0, Persist = true,
    Validate = function(value) return type(value) == "number" end,
    Render = function(context, options)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.Parent = context.Frame
        context:BindToken(label, "TextColor3", "Color.TextPrimary")
        return { Set = function(_, value) label.Text = tostring(value) end }
    end,
}, optionalScope)
local control = section:Component("example.badge", {
    Flag = "BadgeCount", Default = 1, Callback = function(value) print(value) end,
})
if control then
    control:Set(3)           -- returns true or false, reason
    print(control:Get())     -- detached simple value
    control:Destroy()
end
```

- `RegisterComponent` returns `true, {Name,Version}`; `GetComponent` returns
  `{Name,Version,Instances}` or nil; `ListComponents` lists registered names.
  `UnregisterComponent` destroys live instances of the registered type.
- Definition options: Render is required; Validate is optional;
  Height 28–320 (default 44); Default optional; Persist=false disables config.
- Rendering context: `Hub`, `Section`, `Frame`, `Control`, `Scope` and helper methods
  `BindToken(instance,property,path,transform?)`,
  `Connect(signal,callback)`, `OnDestroy(fn)`, `Emit(value,silent?)`.
- Render can return nil or a view table with optional `Set/Get/Destroy` methods.
  Invalid initial value or Render failure cleans up the row, resources and Flag.
- `Component` is inherited by Group/ModuleCard. It never overwrites built-in
  `Section` methods. A control definition is scoped to one Hub, not global.
- Do not put Roblox Instances/Color3 into JSON persisted custom values;
  use primitive-compatible values and your own explicit serialization.

### Inspector and report export (R3)

```luau
local report = hub:CaptureDeveloperReport({
    MaxNodes = 200, Filter = "Button", IncludeHidden = false,
})
if report then
    for _, node in report.Tree.Nodes do
        print(node.Path, node.Hitbox.Width, node.EffectiveHitbox.Width)
        for _, binding in node.TokenBindings do
            print(binding.Property, binding.Path, binding.Overridden)
        end
    end
end
local inspector = hub:OpenVisualInspector({ Limit = 80 })
if inspector then inspector:Close() end
```

- `GetVisualTreeSnapshot` and `CaptureDeveloperReport` are **on-demand**,
  default MaxNodes 250, allowed 1–1000. Report includes bounded tree, diagnostics,
  stats, component and extension name lists. No automatic file/network export.
- `Hitbox` is the screen-rect from AbsolutePosition/AbsoluteSize;
  `EffectiveHitbox` intersects ancestor `ClipsDescendants` rectangles.
  This does not account for rounded corners, foreground overlays, ZIndex occlusion,
  or Roblox's final touch dispatch.
- `TokenBindings` reflect actual active Hub:BindToken connections (not color guesses).
  `TokenState` reflects BindTokenState; not every control has such a binding.
- When the Inspector is open, use its `SelectTarget/GetSnapshot/Refresh`
  and `ExportTree/ExportReport/Close/Destroy` methods. Only explicit calls perform scans.
- Error responses use `nil, reason` for failed reports; no GUI references
  are exposed in the serialized tree/report tables.

## Migration examples

| Before | After | Why |
|---|---|---|
| Copy a bespoke control directly into `lib/RiftUI.luau` | Register it via `RegisterComponent` and create through `Section:Component` | Keep core upgradable and preserve native config/Flags. |
| Attach permanent global input handlers to a custom button | Use `context:Connect` or `scope:Connect` | Parent/Hub destruction releases them. |
| Rebuild a GUI row every time value changes | Return view `Set` and call `context:Emit` | Reuse native control state and callbacks. |
| Hard-code arbitrary theme colors | `context:BindToken`; optionally `RegisterComponentTokens` | Theme changes propagate without manual listeners. |
| Read/write internal `hub._recipe` or `hub._customComponents` | Use public component/extension queries and APIs | Avoid structural coupling. |
| Use `RenderStepped` to inspect every GUI node | Manually call `GetVisualTreeSnapshot` | Debugging stays off the hot path. |
| Create a scoped custom control outside extension Start while its type exists only inside Start | Instantiate and `scope:Own(control)` inside Start, using a replayed Section forwarder or fresh Hub | Extension Start executes after ordinary recipe replay; scoped types and controls must be rebuilt together. |
| Move whole sections out of R1 extension Start into a cached UI Instance | Recreate from the fresh Hub, or put ordinary controls in Section recipes | Prevent stale references on Reinitialize. |

## Compatibility and verification

1. **Build:** `node scripts/bundle.mjs`. Source and generated
   `public/RiftUI.luau` must agree for every inlined module.
2. **Node:** `node tests/sdk-tooling.mjs`, `node tests/design-tokens.mjs`,
   `node tests/release-entry.mjs`. Source mapping, examples, loader origin,
   and API contracts should pass.
3. **Native Lune:** `lune run tests/design-tokens-lune` exercises the R1/R2/R3
   runtime behavior and Reinitialize. Running Lune is not physical Android testing.
4. **Browser:** simulator Minimal and quickstart snippets must point to
   `keepBacon/relax-lua-ui`. Keep preview `DEMO` key gate intact.
5. **Android release:** record device model, UI scale (0.7/1/1.4),
   portrait/landscape, keyboard/IME interactions, multi-touch, popup clipping,
   repeated Hub reinitialization and FPS/frame-time distribution.
   **No Android verification is claimed here**.

## SDK versioning policy

This document describes the available contracts in R1–R4 of the Relax UI fork,
**not** the published npm package.json version. Changes to existing method
names, error result shapes, or config persistence require a migration note.
Extension authors should pin a known commit when reproduction is important.
