# Relax UI

Roblox Luau UI library, developed from RiftUI and extended with ModuleCard, Design Tokens v2, complex data controls, Android touch input, two-state lock overlays, and native action dialogs.

## Choose an entry point

| Entry | Purpose | Key |
| --- | --- | --- |
| `public/Loader.luau` | **Integrate** the library into your own hub; returns the API table | No demo key |
| `public/RelaxUI_Preview.luau` | Android-friendly full UI preview | `DEMO` on every launch |
| `p` | Short entry for the full interactive showcase | `DEMO` on every launch |
| `public/RiftUI.luau` | Direct standalone Luau runtime, if you need explicit asset setup | No demo key |

All four entry points refer to **`keepBacon/relax-lua-ui`**. The library preserves the original `RiftUI` method names; the original upstream repository is *not* the runtime source for these examples.

### Library integration (no preview key)

```luau
local Rift = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/Loader.luau"
))()
local Hub = Rift:CreateHub({ Name = "My Hub", Id = "my-hub" })
local tab = Hub:Tab({ Name = "Main", Icon = "home" })
tab:Section({ Name = "Controls" }):Button({
    Name = "Hello", Callback = function() print("Hello") end,
})
```

### Run the preview (requires `DEMO`)

```luau
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/RelaxUI_Preview.luau"
))()
```

Alternative short entry: `loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/p"))()`.

### Pin a specific revision

For a reproducible library deployment, use the 40-digit **commit SHA** from this repository (or 7–40 hex digits accepted by GitHub). Set the pin *before* executing the Loader:

```luau
getgenv().relaxcommit = "<40-character commit SHA>"
local Rift = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/Loader.luau"
))()
```

`getgenv().riftcommit` remains an alias for old integrations. Conflicting pins are rejected. A missing pinned commit, compile error or invalid library aborts with a diagnostic including the revision; **the Loader never silently falls back to `main`, the upstream repository, or a cached version**. Library scripts and their asset paths both use the pinned revision.

For an entirely immutable entry (including the Loader itself), replace `main` in the Loader URL with the **same full commit SHA**. A short SHA is convenient but may become ambiguous later.

## Development and verification

```sh
pnpm install
node scripts/bundle.mjs
pnpm exec tsc --noEmit
node tests/release-entry.mjs
node tests/preview-entry.mjs
lune run tests/loader
```

Developer SDK, extension lifecycle and the staged architecture plan: [docs/DEVELOPER_ARCHITECTURE.md](docs/DEVELOPER_ARCHITECTURE.md).

Other API documents are under [docs/](docs). The browser simulator is optional: `pnpm dev`, then open `http://localhost:5199/simulator`.

The RiftUI notification slit/timer design, the `DEMO` preview gate, and the user-approved ModuleCard hierarchy are preserved by Relax UI. The automated tests validate source and simulation behavior; Android touch, font clarity, and GPU frame times still require physical-device checks.

[License: MPL 2.0](LICENSE). Third-party assets retain their own licenses; see [NOTICE](NOTICE).
