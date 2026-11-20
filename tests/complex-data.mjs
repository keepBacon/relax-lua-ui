import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = file => readFileSync(new URL('../' + file, import.meta.url), 'utf8')
const src = read('lib/RiftUI.luau')
const published = read('public/RiftUI.luau')
const bundle = read('scripts/bundle.mjs')
const modules = [
  ['--@@COMPLEX_ORDER_LIST@@', 'lib/core/OrderList.luau', ['Section:OrderList', 'c:GetOrder', 'c:SetOrder', 'c:Move', 'c:SetItems', 'c:Reset', 'c:Destroy']],
  ['--@@COMPLEX_DATA_TABLE@@', 'lib/core/DataTable.luau', ['Section:DataTable', 'c:Set', 'c:Upsert', 'c:Update', 'c:Remove', 'c:SetSort', 'c:SetQuery', 'c:SetPage', 'c:Select', 'c:Destroy']],
  ['--@@COMPLEX_STATUS_LIST@@', 'lib/core/StatusList.luau', ['Section:StatusList', 'c:Set', 'c:Upsert', 'c:Update', 'c:Remove', 'c:SetFilter', 'c:SetLoading', 'c:SetError', 'c:Destroy']],
  ['--@@COMPLEX_VIEWPORT@@', 'lib/core/ViewportPreview.luau', ['Section:ViewportPreview', 'c:SetModel', 'c:SetInteractive', 'c:ResetView', 'c:Destroy']],
]
for (const [marker, file, methods] of modules) {
  const content = read(file).trim()
  assert.ok(src.includes(marker), 'source marker missing: ' + marker)
  assert.ok(bundle.includes(marker) && bundle.includes(file), 'bundle map missing: ' + file)
  assert.ok(published.includes(content), 'published code differs: ' + file)
  assert.ok(!published.includes(marker), 'unexpanded marker in published code: ' + file)
  for(const method of methods) {
    assert.ok(content.includes('function ' + method + '('), file + ' missing ' + method)
  }
}
assert.match(src, /ModuleCard = true, OrderList = true/, 'OrderList should participate in config saves')
assert.match(src, /DataTable = true, StatusList = true, ViewportPreview = true/, 'read-only widgets should respect requirements without an overlay')
assert.match(read('lib/core/OrderList.luau'), /bindPointerDrag\(hub, drag,/, 'touch-drag reorder absent')
assert.match(read('lib/core/OrderList.luau'), /local function complexForgetControl\(control\)/, 'destroy registry cleanup helper missing')
for (const file of ['OrderList','DataTable','StatusList','ViewportPreview']) {
  assert.match(read('lib/core/' + file + '.luau'), /complexForgetControl\(self\)/, file + ' must unregister on Destroy')
}
assert.match(read('lib/core/OrderList.luau'), /Disabled/, 'fixed row boundaries absent')
assert.match(read('lib/core/DataTable.luau'), /local pageSize = math\.clamp/, 'bounded table pagination absent')
assert.match(read('lib/core/DataTable.luau'), /node\.Frame\.Visible = false/, 'table row pooling absent')
assert.match(read('lib/core/DataTable.luau'), /CanvasSize = UDim2\.fromOffset\(minWidth/, 'horizontal scroll for narrow screens absent')
assert.match(read('lib/core/StatusList.luau'), /local slotCount = math\.min\(count, maxVisible \+ 2\)/, 'status viewport pooling absent')
assert.match(read('lib/core/ViewportPreview.luau'), /pcall\(function\(\)\s*return create\("ViewportFrame"/, 'native-preview fallback absent')
assert.match(read('lib/core/ViewportPreview.luau'), /source:Clone\(\)/, 'preview must clone caller source')
assert.match(read('lib/core/ViewportPreview.luau'), /node:IsA\("LuaSourceContainer"\)/, 'preview must discard cloned scripts')
assert.match(read('lib/core/ViewportPreview.luau'), /bindPointerDrag\(hub, viewport,/, 'preview input must reuse per-hub capture')
assert.match(read('examples/showcase.luau'), /:OrderList\(/)
assert.match(read('examples/showcase.luau'), /:DataTable\(/)
assert.match(read('examples/showcase.luau'), /:StatusList\(/)
assert.match(read('examples/showcase.luau'), /:ViewportPreview\(/)
assert.match(read('.github/workflows/verify-subtabs-lune.yml'), /lune run tests\/complex-data-lune/)
assert.match(read('.github/workflows/rift-verify.yml'), /node tests\/complex-data\.mjs/)
console.log('Complex data: four modules, bundle parity, legacy APIs, bounded rendering and CI coverage verified')
