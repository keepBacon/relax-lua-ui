// Headless run of engine + RiftUI + example with an in-memory filesystem (no layout).
import { LuauState } from 'luau-web'
import { readFileSync } from 'node:fs'
const root = new URL('../..', import.meta.url).pathname
const engine = readFileSync(root + 'public/engine.luau', 'utf8')
const files = new Map()
let step, run, st, errors = 0
const host = {
  sync: () => '', measure: (t, s) => `${t.length * s * 0.5}\x1f${s}`,
  print: (m) => console.log('[print]', m), warn: (m) => console.log('[warn]', m),
  error: (m, t) => { errors++; console.log('[error]', m, t) },
  now: () => Date.now(),
  load: (s, n) => st.loadstring(s, n, false),
  fs: (op, p, d) => {
    if (op === 'write') { files.set(p, d); return '' }
    if (op === 'read') return files.has(p) ? files.get(p) : 'ERR\x1fno file ' + p
    if (op === 'isfile') return files.has(p) ? '1' : '0'
    if (op === 'isfolder' || op === 'mkdir') return '1'
    if (op === 'list') return [...files.keys()].filter(k => k.startsWith(p + '/')).join('\x1f')
    if (op === 'asset') return 'rbxasset://riftsim/' + p
    return ''
  },
  http: async (m, u) => {
    const i = u.indexOf('/main/public/')
    if (i < 0) return '404\x1f\x1f{}'
    const buf = readFileSync(root + 'public/' + u.slice(i + 13))
    return `200\x1f${buf.toString('base64')}\x1f{}`
  },
  clipboard: () => {}, register: (a, b) => { step = a; run = b },
}
st = await LuauState.createAsync({ __HOST: host })
await st.loadstring(engine, '=engine', true)()
await run(readFileSync(root + 'examples/hub.luau', 'utf8'), 'hub.lua')
for (let i = 0; i < 30; i++) await step(1 / 60, '')
console.log('files', [...files.keys()])
await run(`
local Rift = getgenv().__rift_probe
local gui = gethui():FindFirstChild("RiftUI")
print("gui", gui, #gui:GetDescendants(), "descendants")
local dock = gui.DockHolder.Dock
local n = 0 for _, c in dock:GetChildren() do if c:IsA("TextButton") then n += 1 end end
print("tiles", n)
`, 'probe')
for (let i = 0; i < 5; i++) await step(1 / 60, '')
await run(String.raw\`
local Rift = getgenv().__rift_probe
assert(Rift and Rift.CreateHub, "library not loaded")
local hub = Rift:CreateHub({ Name = "Nested Runtime Probe", Id = "nested-runtime-probe", Setup = false, Settings = false, Watermark = false })
local primary = hub:Tab({ Name = "主页面", Icon = "layers" })
local first = primary:SubTab({ Name = "第一页", Icon = "settings" })
local second = primary:SubTab({ Name = "第二页", Icon = "eye" })
local s1 = first:Section({ Name = "Section A" })
s1:Toggle({ Name = "Active", Flag = "NestedRuntimeActive", Default = false })
local s2 = second:Section({ Name = "Section B" })
s2:Slider({ Name = "Speed", Flag = "NestedRuntimeSpeed", Min = 0, Max = 100, Default = 20 })
hub:Open(primary)
assert(hub._open == primary, "primary tab did not open")
assert(primary.ActiveSubTab == first, "initial secondary selection wrong")
assert(first.Page.Visible, "first child not shown")
hub:_toggleSubTabs(primary)
assert(hub._subTabRailVisible and hub._subTabRail.Visible, "secondary rail did not open")
assert(hub._subTabFrost.Visible, "panel frost not visible")
hub:_setSubTab(primary, second)
assert(hub._subTabRailVisible, "switching child must not hide secondary rail")
assert(second.Page.Visible and not first.Page.Visible, "child page switch failed")
assert(hub.HeaderSub.Text == "第二页", "child header subtitle not updated")
hub:_closeSubTabs()
assert(not hub._subTabRailVisible and not hub._subTabFrost.Visible, "secondary rail did not close")
assert(hub._open == primary, "dismissing child rail must not close the primary panel")
hub:Destroy()
print("Nested navigation simulated runtime passed")
\`, 'subtabs-runtime-probe')
for (let i = 0; i < 5; i++) await step(1 / 60, '')
console.log('errors:', errors)
process.exit(errors ? 1 : 0)
