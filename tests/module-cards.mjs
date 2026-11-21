import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const source = read('lib/RiftUI.luau')
const module = read('lib/core/ModuleCards.luau')
const bundle = read('public/RiftUI.luau')
const bundler = read('scripts/bundle.mjs')
const example = read('examples/showcase.luau')
const ci = read('.github/workflows/verify-subtabs-lune.yml')

assert.ok(source.includes('--@@MODULE_CARDS@@'), 'module marker missing')
assert.ok(bundler.includes("'--@@MODULE_CARDS@@', 'lib/core/ModuleCards.luau'"))
assert.ok(!bundle.includes('--@@MODULE_CARDS@@'), 'module marker not expanded')
assert.ok(bundle.includes(module.trim()), 'public Luau artifact out of sync')
for(const method of [
  'Section:ModuleCard', 'Section:InfoGrid', 'Section:InfoList',
  'card:SetExpanded', 'card:IsExpanded', 'card:SetFavorite', 'card:IsFavorite',
  'card:SetStatus', 'card:SetSummary', 'card:SetDependencyBlocked',
  'card:SetLocked', 'card:Reset',
]){
  assert.ok(module.includes('function ' + method + '('), 'missing ' + method)
}
assert.match(source, /local moduleParent = self\._isModuleCard and self or self\._moduleCard/, 'legacy control registration must preserve card ancestry')
assert.match(source, /control\._moduleCard = moduleParent/, 'controls must retain the card ancestry')
assert.match(source, /local matchedCards = \{\}/, 'search must retain parent card visibility')
assert.match(source, /control:_setSearchPeek\(query ~= "" and matched\)/, 'search must peek without saving collapse state')
assert.match(source, /group\._isGroup or group\._isModuleCard/, 'command jumps should reveal nested cards')
assert.match(source, /ModuleCard = true, OrderList = true \}/, 'module toggle and order list must be saved in config')
assert.match(module, /self:_row\(0, "ModuleCard_"/)
assert.match(module, /Motion.play\(hub, motionKey, clip/, 'cards must use shared motion')
assert.match(module, /self\._parentCard|_parentCard = parentCard/, 'nested module cards')
assert.match(module, /control.Items = \{\}/, 'info widgets must own their data')
assert.match(module, /function control:Update\(key, value, tone(?:, silent)?\)/, 'dynamic info updates')
assert.match(module, /grid:GetPropertyChangedSignal\("AbsoluteSize"\)/, 'responsive metric columns')
assert.match(module, /moduleIsExpanded\(savedFold, options.Collapsed == true\)/, 'persistent expanded/collapsed preferences')
assert.match(module, /saveMap\("ModuleCards", on and "expanded" or "collapsed"\)/, 'explicit preference values')
assert.match(module, /map\[id\] = value/, 'preserve false or string preference')
assert.match(module, /function card:OffChanged\(fn\)/, 'observer unsubscribe')
assert.match(module, /control\._dependents = control\._dependents or \{\}/, 'synchronous dependencies')
assert.match(module, /function control:UpdateMany\(values(?:, strict)?\)/, 'bulk updates')
assert.match(module, /function control:Upsert\(item\)/, 'insert and replace data')
assert.match(module, /function control:Remove\(key\)/, 'remove data by key')
assert.match(module, /function control:Clear\(\)/, 'clear without replacing public API')
assert.match(module, /moduleInfoSnapshot\(self.Items\)/, 'defensive data snapshots')
assert.match(source, /_moduleCard = self\._isModuleCard and self or self\._moduleCard/, 'nested legacy Group inherits card ancestry')
assert.match(source, /local matchedGroups = \{\}/, 'nested search tracks parent groups')
assert.match(source, /group:_setSearchPeek\(query ~= ""/, 'search peeks groups without saving state')
assert.match(source, /control.DefaultValue = type\(options.Default\)/, 'explicit defaults captured at construction')
assert.match(example, /:ModuleCard\(\{/, 'preview must demonstrate module cards')
assert.match(example, /:InfoGrid\(\{/, 'preview must demonstrate metrics')
assert.match(example, /:InfoList\(\{/, 'preview must demonstrate detailed info')
assert.match(example, /:Group\(\{/, 'the original Group demo must remain')
assert.match(example, /:RangeSlider\(\{/, 'the original controls must remain')
assert.match(example, /string\.upper\(key\) == "DEMO"/, 'demo authorization must remain')
assert.ok(ci.includes('lune run tests/module-cards-lune'), 'native module runtime regression missing')
for (const part of ['function card:OnDataEvent', 'function card:GetStatus',
    'function control:GetItem', 'function control:SetOrder',
    'infoPublish(self, "Batch")', 'hub:_dataDetachControl(control)']) {
  assert.ok(module.includes(part), 'advanced info event/reorder API missing: ' + part)
}
assert.match(module, /InheritParentState == true/, 'nested card optional inherited dependency missing')
assert.match(module, /Size = UDim2.fromOffset\(44, 44\)/, 'mobile module switch touch target missing')
assert.match(module, /function control:UpdateManyStrict\(values\)/, 'strict atomic batch update missing')
assert.match(module, /previous\[tileName\]/, 'grid must reconcile by stable key')
assert.match(module, /previous\[name\]/, 'list must reconcile by stable key')
assert.match(module, /if not listeners or #listeners == 0/, 'no-observer snapshot optimization missing')
assert.match(module, /hub:_connect\(row.Destroying, function\(\)\s*local at = table.find\(control\._dependents/, 'dependency cleanup missing')
assert.match(module, /tone == nil and self._tone/, 'status message must preserve existing tone')
assert.match(module, /local silent = type\(strict\) == "table" and strict.Silent == true/, 'strict batch must support Silent')
assert.match(module, /Name = "ModuleClip", BackgroundTransparency = 1, GroupTransparency = 1/, 'fold clipping must fade grouped content')
assert.match(module, /motionKey \+ ":opacity", clip/, 'fold opacity animation must be cancellable')
assert.match(module, /description\.Size = UDim2\.new\(1, -titleX - actionRight - 10/, 'summary must reserve space for actions')
assert.match(module, /options\.FillLastRow ~= false/, 'InfoGrid must fill orphan final row')
console.log('ModuleCard, nested old controls, search, flags, info widgets and bundle parity verified')
