import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8')
const source = read('lib/RiftUI.luau')
const overlay = read('lib/core/OverlayStack.luau')
const subtab = read('lib/core/SubTabs.luau')
const published = read('public/RiftUI.luau')
const bundler = read('scripts/bundle.mjs')
const workflow = read('.github/workflows/verify-subtabs-lune.yml')

assert.ok(source.includes('--@@OVERLAY_STACK@@'))
assert.ok(bundler.includes("'--@@OVERLAY_STACK@@', 'lib/core/OverlayStack.luau'"))
assert.ok(!published.includes('--@@OVERLAY_STACK@@'))
assert.ok(published.includes(overlay.trim()), 'published OverlayStack does not match module')
assert.ok(published.includes(subtab.trim()), 'published SubTabs does not match module')
for (const name of ['_overlayStackInit', '_overlayRegister', '_overlayUnregister',
  '_overlayTop', 'GetOverlayStack', '_overlayContains', '_overlayDismiss',
  '_routeOverlayKey', '_routeOverlayPointer', '_overlayClear']) {
  assert.ok(overlay.includes('function Hub:' + name + '('), name)
}
assert.match(overlay, /if top\.Outside then self:_overlayDismiss\(top, "outside"\) end/)
assert.match(overlay, /return true\s+end\s+\nfunction Hub:_overlayClear/)
assert.match(source, /if self:_routeOverlayPointer\(Vector2\.new\(input\.Position\.X, input\.Position\.Y\)\) then return end/)
assert.match(source, /if input\.KeyCode == Enum\.KeyCode\.Escape then/)
assert.match(source, /self:_routeOverlayKey\(input\.KeyCode\)/)
assert.doesNotMatch(source, /local top = self\._windows and self\._windows\[#self\._windows\]/)
assert.match(source, /self:_overlayRegister\("Popup", holder/)
assert.match(source, /Name = "PopupPointerShield"/, "popup must capture native outside taps")
assert.match(source, /Shield = shield, OnClose = onClose/, "popup shield lifecycle ownership")
assert.match(source, /p.ShieldConnection:Disconnect\(\)/, "scrim click listener cleanup")
assert.match(source, /p.Shield:Destroy\(\)/, "no stale input-blocking shield")
assert.match(source, /top and top.Kind ~= "CommandPalette" then return end/,
  "other modal layers must block the command shortcut")
assert.match(source, /top.Owner ~= palette then return end/,
  "underlying palette must not handle navigation keys")
assert.match(source, /handle.OnClosed\(\)/, "dialog button close must synchronize stack")
assert.match(source, /prompt.OnClosed = remove/, "prompt stack unregister on dismiss")
assert.match(source, /self._windows\[#self._windows\]:Close\(\)/,
  "exclusive setup must close active modal windows")
assert.match(source, /self:_overlayUnregister\("Popup", p\.Holder\)/)
assert.match(source, /hub:_overlayRegister\("Window", self/)
assert.match(source, /hub:_overlayUnregister\("Window", self\)/)
assert.match(source, /self:_overlayRegister\("CommandPalette", palette/)
assert.match(source, /self:_overlayUnregister\("CommandPalette", palette\)/)
assert.match(source, /self:_overlayRegister\("Prompt", prompt/)
assert.match(source, /self:_overlayRegister\("Setup", layer/)
assert.match(subtab, /self:_overlayRegister\("SubTabs", self\._subTabRail/)
assert.match(subtab, /self:_overlayUnregister\("SubTabs", self\._subTabRail\)/)
assert.match(source, /self:_overlayClear\(\)/, 'teardown must release all overlays')
assert.ok(workflow.includes('lune run tests/overlay-stack-lune'))
console.log('OverlayStack, unified global input routing, module injection and integration checks passed')
