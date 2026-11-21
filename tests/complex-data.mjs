import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = file => readFileSync(new URL('../' + file, import.meta.url), 'utf8')
const src = read('lib/RiftUI.luau')
const published = read('public/RiftUI.luau')
const bundle = read('scripts/bundle.mjs')
const modules = [
  ['--@@DATA_LINKS@@', 'lib/core/DataLinks.luau', ['Hub:LinkData', 'Hub:_dataDetachControl', 'Hub:_clearDataLinks']],
  ['--@@COMPLEX_ORDER_LIST@@', 'lib/core/OrderList.luau', ['Section:OrderList', 'c:GetOrder', 'c:SetOrder', 'c:Move', 'c:SetItems', 'c:Reset', 'c:Destroy']],
  ['--@@COMPLEX_DATA_TABLE@@', 'lib/core/DataTable.luau', ['Section:DataTable', 'c:Set', 'c:Upsert', 'c:Update', 'c:Remove', 'c:SetSort', 'c:SetQuery', 'c:SetPage', 'c:Select', 'c:Destroy']],
  ['--@@COMPLEX_STATUS_LIST@@', 'lib/core/StatusList.luau', ['Section:StatusList', 'c:Set', 'c:Upsert', 'c:Update', 'c:Remove', 'c:SetFilter', 'c:SetLoading', 'c:SetError', 'c:Destroy']],
  ['--@@COMPLEX_EVENT_TIMELINE@@', 'lib/core/EventTimeline.luau', ['Section:EventTimeline', 'c:Append', 'c:Set', 'c:Get', 'c:Remove', 'c:SetFilter', 'c:SetPaused', 'c:SetLoading', 'c:SetError', 'c:Clear', 'c:Destroy']],
  ['--@@COMPLEX_TREE_VIEW@@', 'lib/core/TreeView.luau', ['Section:TreeView', 'c:SetNodes', 'c:GetTree', 'c:Get', 'c:GetVisible', 'c:SetExpanded', 'c:GetExpanded', 'c:ExpandAll', 'c:CollapseAll', 'c:SetQuery', 'c:Select', 'c:Update', 'c:Remove', 'c:Destroy']],
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
assert.match(src, /function control:OnDataEvent\(event, fn\)/, 'data event subscription missing')
assert.match(src, /function Hub:_treeStateSnapshot\(\)/, 'tree state snapshot missing')
assert.match(src, /TreeStates = self:_treeStateSnapshot\(\)/, 'tree state absent from named config')
assert.match(read('lib/core/DataLinks.luau'), /function Hub:LinkData\(source, target, options\)/, 'link API missing')
assert.match(src, /ModuleCard = true, OrderList = true/, 'OrderList should participate in config saves')
assert.match(src, /DataTable = true, StatusList = true, EventTimeline = true, TreeView = true, ViewportPreview = true/, 'read-only widgets should respect requirements without an overlay')
assert.match(read('lib/core/OrderList.luau'), /bindPointerDrag\(hub, drag,/, 'touch-drag reorder absent')
assert.match(read('lib/core/OrderList.luau'), /local function complexForgetControl\(control\)/, 'destroy registry cleanup helper missing')
for (const file of ['OrderList','DataTable','StatusList','EventTimeline','TreeView','ViewportPreview']) {
  assert.match(read('lib/core/' + file + '.luau'), /complexForgetControl\(self\)/, file + ' must unregister on Destroy')
}
assert.match(read('lib/core/OrderList.luau'), /Disabled/, 'fixed row boundaries absent')
assert.match(read('lib/core/DataTable.luau'), /function c:SetLayoutMode\(mode\)/, 'responsive layout switch absent')
assert.match(read('lib/core/DataTable.luau'), /local cardNodes = \{\}/, 'card row pooling absent')
assert.match(read('lib/core/DataTable.luau'), /local pageSize = math\.clamp/, 'bounded table pagination absent')
assert.match(read('lib/core/DataTable.luau'), /node\.Frame\.Visible = false/, 'table row pooling absent')
assert.match(read('lib/core/DataTable.luau'), /CanvasSize = UDim2\.fromOffset\(minWidth/, 'horizontal scroll for narrow screens absent')
assert.match(read('lib/core/EventTimeline.luau'), /local maxRecords = math\.clamp/, 'timeline max-record budget absent')
assert.match(read('lib/core/EventTimeline.luau'), /local total = math\.min\(count, maxVisible \+ 2\)/, 'timeline bounded row pooling absent')
assert.match(read('lib/core/DataTable.luau'), /if value == nil then value = row\[col.Index\] end/, 'false cell value must not be discarded')
assert.match(read('lib/core/TreeView.luau'), /function c:FlushState\(\)/, 'persistence flush missing')
assert.match(read('lib/core/TreeView.luau'), /task\.delay\(\.35/, 'persistence write coalescing absent')
assert.match(read('lib/core/DataTable.luau'), /node\.TouchConnection:Disconnect\(\)/, 'card touch listeners must be disposed')
assert.match(read('lib/core/DataLinks.luau'), /links\[link\] = nil/, 'forwarded link cleanup must use live link')
assert.match(read('lib/core/TreeView.luau'), /function c:SetState\(state, silent\)/, 'TreeView state API missing')
assert.match(read('lib/core/TreeView.luau'), /hub:_savePref\("TreeStates", hub\.SetupData\.TreeStates\)/, 'TreeView setup persistence flush absent')
assert.match(read('lib/core/DataTable.luau'), /Name = "CardSort"/, 'card sort toolbar absent')
assert.match(read('lib/core/DataTable.luau'), /math\.abs\(delta.X\) > 65/, 'swipe paging absent')
assert.match(read('lib/core/TreeView.luau'), /math\.min\(count, maxVisible \+ 2\)/, 'TreeView must pool visible rows')
assert.match(read('lib/core/TreeView.luau'), /local newRoots, newIndex, defaults = normalize\(nodes\)/, 'TreeView must validate before changing state')
assert.match(read('lib/core/StatusList.luau'), /local slotCount = math\.min\(count, maxVisible \+ 2\)/, 'status viewport pooling absent')
assert.match(read('lib/core/ViewportPreview.luau'), /pcall\(function\(\)\s*return create\("ViewportFrame"/, 'native-preview fallback absent')
assert.match(read('lib/core/ViewportPreview.luau'), /source:Clone\(\)/, 'preview must clone caller source')
assert.match(read('lib/core/ViewportPreview.luau'), /node:IsA\("LuaSourceContainer"\)/, 'preview must discard cloned scripts')
assert.match(read('lib/core/ViewportPreview.luau'), /bindPointerDrag\(hub, viewport,/, 'preview input must reuse per-hub capture')
assert.match(read('examples/showcase.luau'), /:OrderList\(/)
assert.match(read('examples/showcase.luau'), /:DataTable\(/)
assert.match(read('examples/showcase.luau'), /:StatusList\(/)
assert.match(read('examples/showcase.luau'), /:ViewportPreview\(/)
assert.match(read('examples/showcase.luau'), /:EventTimeline\(/)
assert.match(read('examples/showcase.luau'), /:TreeView\(/)
assert.match(read('.github/workflows/verify-subtabs-lune.yml'), /lune run tests\/complex-data-lune/)
assert.match(read('.github/workflows/rift-verify.yml'), /node tests\/complex-data\.mjs/)
console.log('Complex data: four modules, bundle parity, legacy APIs, bounded rendering and CI coverage verified')
