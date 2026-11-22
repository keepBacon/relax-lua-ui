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
assert.match(overlay, /local INPUT_OVERLAY_PRIORITY = \{/, 'z-index priorities must be centrally declared')
assert.match(overlay, /Priority = INPUT_OVERLAY_PRIORITY\[kind\]/)
assert.match(overlay, /if item.Priority < existing.Priority then/, 'overlay insertion must use visual priority')
assert.match(overlay, /target.Destroying:Connect/, 'owners must clean up after direct destroy')
assert.match(overlay, /overlayRelease\(item\)/, 'per-overlay destroy listeners must disconnect')
assert.match(overlay, /for _, entry in self\._overlayStack do overlayRelease\(entry\) end/, 'teardown disconnects leftover watchers')
assert.match(subtab, /Name = "SubTabPointerShield"/, 'secondary rail needs native pointer shield')
assert.match(subtab, /self\._subTabPointerShield.Visible = false/, 'shield must hide when rail closes')
assert.match(subtab, /self\._subTabPointerShield.Visible = true/, 'shield must show only when rail opens')
assert.match(source, /Name = "Overlay", BackgroundTransparency = 1, Size = UDim2.fromScale\(1, 1\), ZIndex = 98/, 'popup layer must match the priority order')

assert.match(overlay, /return true\s+end\s+\nfunction Hub:_overlayClear/)
assert.match(source, /if self:_routeOverlayPointer\(Vector2\.new\(input\.Position\.X, input\.Position\.Y\)\) then return end/)
assert.match(source, /if input\.KeyCode == Enum\.KeyCode\.Escape then/)
assert.match(source, /self:_routeOverlayKey\(input\.KeyCode\)/)
assert.doesNotMatch(source, /local top = self\._windows and self\._windows\[#self\._windows\]/)
assert.match(source, /self:_overlayRegister\("Popup", holder/)
assert.match(source, /Name = "PopupPointerShield"/, "popup must capture native outside taps")
assert.match(source, /Scroll = scroll, Shield = shield, OnClose = onClose/, "popup shield and scrolling viewport lifecycle ownership")
assert.match(source, /function Hub:_placePopup\(/, "popup position must be recalculated")

assert.match(source, /p.Anchor:IsDescendantOf\(panel\)/,
  'content popups should distinguish panel-local anchors')
assert.match(source, /header\.AbsolutePosition\.Y \+ header\.AbsoluteSize\.Y/,
  'popup placement must avoid title/header')
assert.match(source, /minY = math.min\(math.max\(minY, headerBottom\)/,
  'header avoidance must maintain reachable minimum popup height')
assert.match(source, /Name = "PopupViewport"/, "mobile popups must have accessible scrolling content")
assert.match(source, /p\.Scroll\.CanvasSize = UDim2\.fromOffset/, "tall options remain scrollable")
assert.match(source, /p\.RepositionConnections or \{\}/, "popup reposition connections must be disposed")
assert.match(source, /self:_placePopup\(p, false\)/, "popup should reposition when viewport/anchor changes")
const orb = read('lib/core/ToolbarOrb.luau')
assert.match(orb, /self:_overlayTop\(\)/, "orb must not start a drag through a modal")
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
const dialogs = read('lib/core/ControlStates.luau')
for (const method of ['SetLoading', 'SetFeedback', 'SetContent', 'Close']) {
  assert.match(dialogs, new RegExp('function handle:' + method + '\\('),
    'dialog lacks ' + method)
}
assert.match(dialogs, /if handle\.Closed or handle\.Loading or not top or top\.Owner ~= handle then return end/,
  'underlying dialog actions must not execute through a higher modal')
assert.match(dialogs, /local ok, result = pcall\(option\.Callback, handle, handle\)/,
  'legacy callback second parameter must receive dialog handle')
assert.match(dialogs, /Name = "HeadingDivider"/, 'subtle dialog heading divider absent')
assert.match(dialogs, /Name = "Error"/, 'feedback line must reuse existing error slot')
assert.match(dialogs, /Motion\.Presets\.Micro/, 'dialog buttons need shared press feedback')
assert.ok(workflow.includes('lune run tests/overlay-stack-lune'))
console.log('OverlayStack, unified global input routing, module injection and integration checks passed')
