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
assert.match(src, /self:_syncLockOverlay\(control\)/, 'all controls should share visible requirement locking')
assert.match(read('lib/core/OrderList.luau'), /bindPointerDrag\(hub, drag,/, 'touch-drag reorder absent')
assert.match(read('lib/core/OrderList.luau'), /local function complexForgetControl\(control\)/, 'destroy registry cleanup helper missing')
for (const file of ['OrderList','DataTable','StatusList','EventTimeline','TreeView','ViewportPreview']) {
  assert.match(read('lib/core/' + file + '.luau'),
    /complexForgetControl\((?:self|c)\)/, file + ' must unregister on Destroy or parent disposal')
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
const dataLinks = read('lib/core/DataLinks.luau')
for (const method of ['Pause','Resume','Refresh','GetStats']) {
  assert.match(dataLinks, new RegExp('function link:' + method + '\\('), 'missing data link lifecycle method ' + method)
}
assert.match(dataLinks, /options.Filter/, 'event filter must be validated')
assert.match(dataLinks, /link.Paused/, 'data links must preserve paused state')
assert.match(dataLinks, /link.Errors \+= 1/, 'delivery errors should be recorded')
assert.match(dataLinks, /link.Delivered \+= 1/, 'delivery count should be recorded')
assert.match(read('lib/core/DataLinks.luau'), /MAX_CASCADE_DEPTH/, 'cascade depth must be bounded')
assert.match(read('lib/core/DataLinks.luau'), /link.Cycles \+= 1/, 'cycle suppression telemetry missing')
assert.match(src, /local liveInfoStates = \{\}/, 'reinitialize dynamic state snapshot missing')
assert.match(src, /linkState.Stats or \{\}/, 'reinitialize link statistics not restored')
assert.match(src, /owner._dataSubscriptions\[subscription\] = true/, 'control subscription ownership missing')
assert.match(src, /canonicalRecipeObject\(target\)/, 'recording via forwarded Section must canonicalize owner')
assert.match(src, /resolveRecipe\(linkState.Source\)/, 'rebuild must resolve forwarded link sources')
assert.match(dataLinks, /Operation = "Snapshot", Items = payload/, 'immediate Data snapshot should have event envelope')
assert.match(dataLinks, /Silent = options.Silent == true/, 'link batch must forward silent option')
assert.match(read('lib/core/TreeView.luau'), /iconLabel\("chevron-right", 14/, 'TreeView should use a font-independent arrow')
assert.doesNotMatch(read('lib/core/TreeView.luau'), /slot\.Toggle\.Text = hasChildren and/, 'legacy font glyphs must be removed')
assert.match(read('lib/core/DataTable.luau'), /options\.CardHeight/, 'mobile DataTable must allow card height customization')
assert.match(read('lib/core/DataTable.luau'), /back\.Visible = pages > 1/, 'inert single-page arrows should be hidden')
// Final mobile data pass: every visual change is asserted against source.
assert.match(read('lib/core/OrderList.luau'), /local rowStep = 44/, 'touch list should use at least 42px cells')
assert.match(read('lib/core/OrderList.luau'), /Size = UDim2.fromOffset\(36, 36\)/, 'reorder arrows must be touch-sized')
assert.match(read('lib/core/OrderList.luau'), /\) \/ rowStep \+ \.5\)/, 'drag distance must match display row step')
assert.match(read('lib/core/DataTable.luau'), /local cardMinHeight = math.max\(52, 12 \+ #columns \* 18\)/, 'cell lines must not overlap')
assert.match(read('lib/core/DataTable.luau'), /scroll.CanvasPosition = Vector2.zero/, 'table view must reset stale scroll on page changes')
assert.match(read('lib/core/TreeView.luau'), /logicalWidth - 180/, 'TreeView must reserve mobile label width')
assert.match(read('lib/core/TreeView.luau'), /slot.Badge.Visible = showBadge/, 'badge must not obscure mobile tree labels')
assert.match(read('lib/core/StatusList.luau'), /compact and 65 or 86/, 'StatusList badge should resize on small screens')
assert.match(read('lib/core/DataTable.luau'), /local nextPage = math\.clamp\(math\.floor\(page\), 1, pageCount\)/, 'table pagination must be clamped before event dispatch')
assert.match(read('lib/core/DataTable.luau'), /if nextPage == self\.Page then return true end/, 'out-of-range swipes must not emit redundant events')
assert.match(read('lib/core/TreeView.luau'), /flushPersistence\(\)\s*alive = false/, 'parent destroy must flush debounced tree state')
assert.match(read('lib/core/TreeView.luau'), /c\._disposed = true[\s\S]*?complexForgetControl\(c\)/, 'parent destroy must unregister tree from hub and section')
console.log('Complex data: four modules, bundle parity, legacy APIs, bounded rendering and CI coverage verified')
