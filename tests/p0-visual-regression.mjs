import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const preview = read('public/RelaxUI_Preview.luau')
const main = read('lib/RiftUI.luau')
const states = read('lib/core/ControlStates.luau')
const stack = read('lib/core/OverlayStack.luau')
const orb = read('lib/core/ToolbarOrb.luau')
const bundle = read('public/RiftUI.luau')
const baseline = read('docs/P0_VISUAL_BASELINE.md')
for (const fixture of [
  'P0验收', 'p0-module-fixture', '性能优化与显示调节 · 中文长标题',
  '这里是用于验证中文描述自动换行', 'P0锁定测试',
  'P0选择器', 'P0颜色选择', 'P0输入焦点',
  '固定运行指标', '180 MB', '28 ms', '恢复本页窗口尺寸',
]) assert.ok(preview.includes(fixture), 'deterministic visual fixture missing: ' + fixture)
for (const group of [
  'ModuleCard', '二级分页', 'DataTable', 'TreeView', 'StatusList',
  '弹窗', '设置', '主题',
]) assert.ok(baseline.includes(group), 'visual matrix missing: ' + group)
for (const scale of ['70%', '100%', '140%']) {
  assert.ok(baseline.includes(scale), 'scale matrix missing ' + scale)
}
for (const width of ['4:3', '16:9', '20:9']) {
  assert.ok(baseline.includes(width), 'aspect ratio matrix missing ' + width)
}
assert.match(main, /function Hub:_placePopup\(/)
assert.match(main, /local aboveSpace =/, 'popup should check usable space above anchor')
assert.match(main, /local belowSpace =/, 'popup should check usable space below anchor')
assert.match(main, /Name = "PopupViewport"/, 'popup must expose oversize content through scrolling')
assert.match(main, /spec\[1\]:GetPropertyChangedSignal\(spec\[2\]\):Connect\(reposition\)/,
  'anchor/scale/viewport changes must trigger popup repositioning')
assert.match(main, /connection:Disconnect\(\)/, 'popup connections must be disposed')
assert.match(states, /DialogCloseFallback/, 'modal close must render even when Lucide sheets fail')
assert.match(states, /DialogIconFallback/, 'modal header must have visible fallback')
assert.match(stack, /function Hub:_routeOverlayPointer\(/, 'overlay must arbitrate global pointer input')
assert.match(orb, /self:_overlayTop\(\)/, 'orb must not capture a modal click')
assert.match(preview, /CreateAuth\(/, 'demo must stay key-gated')
assert.match(preview, /string\.upper\(key\) == "DEMO"/, 'demo key must remain intact')
assert.match(main, /Name = "Slit"/, 'keep original RiftUI notification')
assert.ok(bundle.includes(read('lib/core/ControlStates.luau').trim()), 'publish states source parity')
assert.ok(bundle.includes(read('lib/core/ToolbarOrb.luau').trim()), 'publish orb source parity')
console.log('P0 Android regression fixtures, popup routing and accessibility invariants passed')
