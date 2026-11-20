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
assert.match(source, /self\._isModuleCard then/, 'legacy control registration must track the parent card')
assert.match(source, /control\._moduleCard = self/, 'controls must retain the card ancestry')
assert.match(source, /local matchedCards = \{\}/, 'search must retain parent card visibility')
assert.match(source, /control:_setSearchPeek\(query ~= "" and matched\)/, 'search must peek without saving collapse state')
assert.match(source, /group\._isGroup or group\._isModuleCard/, 'command jumps should reveal nested cards')
assert.match(source, /ModuleCard = true \}/, 'module toggle must be saved in config')
assert.match(module, /self:_row\(0, "ModuleCard_"/)
assert.match(module, /Motion.play\(hub, motionKey, clip/, 'cards must use shared motion')
assert.match(module, /self\._parentCard|_parentCard = parentCard/, 'nested module cards')
assert.match(module, /control.Items = \{\}/, 'info widgets must own their data')
assert.match(module, /function control:Update\(key, value, tone\)/, 'dynamic info updates')
assert.match(module, /grid:GetPropertyChangedSignal\("AbsoluteSize"\)/, 'responsive metric columns')
assert.match(example, /:ModuleCard\(\{/, 'preview must demonstrate module cards')
assert.match(example, /:InfoGrid\(\{/, 'preview must demonstrate metrics')
assert.match(example, /:InfoList\(\{/, 'preview must demonstrate detailed info')
assert.match(example, /:Group\(\{/, 'the original Group demo must remain')
assert.match(example, /:RangeSlider\(\{/, 'the original controls must remain')
assert.match(example, /string\.upper\(key\) == "DEMO"/, 'demo authorization must remain')
assert.ok(ci.includes('lune run tests/module-cards-lune'), 'native module runtime regression missing')
console.log('ModuleCard, nested old controls, search, flags, info widgets and bundle parity verified')
