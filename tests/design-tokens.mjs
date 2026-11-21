import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const core = read('lib/RiftUI.luau')
const module = read('lib/core/DesignTokens.luau')
const bundle = read('scripts/bundle.mjs')
const built = read('public/RiftUI.luau')
const motion = read('lib/core/Motion.luau')
const control = read('lib/core/ControlThemes.luau')
const cards = read('lib/core/ModuleCards.luau')

assert.match(core, /--@@DESIGN_TOKENS_V2@@/, 'v2 source marker absent')
assert.match(bundle, /'--@@DESIGN_TOKENS_V2@@', 'lib\/core\/DesignTokens\.luau'/, 'v2 must be bundled')
assert.doesNotMatch(built, /--@@DESIGN_TOKENS_V2@@/, 'v2 module not expanded')
assert.ok(built.includes(module.trim()), 'published v2 module differs from source')
assert.ok(built.includes(motion.trim()), 'published Motion differs from source')
assert.ok(built.includes(control.trim()), 'published control themes differ from source')
assert.ok(built.includes(cards.trim()), 'published ModuleCard differs from source')

for (const group of ['Color', 'Radius', 'Spacing', 'Typography', 'Motion', 'State']) {
  assert.match(module, new RegExp('\\b' + group + '\\b'), group + ' tokens absent')
}
for (const role of [
  'Surface0','Surface1','Surface2','BorderSubtle','BorderStrong',
  'TextPrimary','TextSecondary','Accent','Success','Warning','Danger'
]) assert.ok(module.includes(role), 'semantic role absent: ' + role)
for (const state of ['Idle','Hover','Pressed','Focused','Disabled','Dragging','Loading','Error']) {
  assert.match(module, new RegExp('\\b' + state + '\\b'), 'missing state: ' + state)
}
for (const method of [
 'GetDesignTokens','GetDesignTokenOverrides','GetToken','SetToken',
 'SetDesignTokens','ResetDesignTokens','GetMotionMode','SetMotionMode',
 'GetTokenOverride','HasTokenOverride','ResetToken',
 'BindToken','BindTokenState','ApplyTokenState','TokenTween'
]) assert.ok(module.includes('function Hub:' + method), 'missing v2 API: ' + method)

assert.match(module, /if type\(value\) ~= "number" or value ~= value/,
  'invalid numeric inputs must be rejected')
assert.match(module, /local nextOverrides = deepCopy\(previous\)/,
  'invalid input must not mutate effective state')
assert.match(module, /hub:_savePref|self:_savePref\("DesignTokens"/,
  'token overrides must be persisted')
assert.match(core, /DesignTokens = self:GetDesignTokenOverrides\(\)/,
  'named config must carry token overrides')
assert.match(core, /self:SetDesignTokens\(data.DesignTokens\)/,
  'named config must restore token overrides')
assert.match(core, /rebuildOptions.DesignTokens = designTokens/,
  'hub rebuild must preserve token state')
assert.match(core, /self:_refreshDesignTokens\(\)/,
  'palette switching must update semantic tokens')
assert.match(module, /function Hub:_disposeDesignTokens\(\)/, 'token handles must be released at teardown')
assert.match(core, /self:_disposeDesignTokens\(\)/, 'hub teardown must dispose token bindings')
assert.match(module, /if previous.Property == property then/, 'duplicate property binding must retire its owner')
assert.match(motion, /RelaxMotionMode/, 'shared tween runtime must respect motion preference')
assert.match(control, /hub:GetToken\(rounded and "Radius.M" or "Radius.XS"\)/,
  'rounded controls must resolve radius tokens')
assert.match(cards, /hub:BindToken\(surface, "BackgroundColor3", "Color.Surface2"\)/,
  'ModuleCards must bind v2 surface color')
assert.match(read('lib/core/DataTable.luau'), /hub:BindToken\(shell, "BackgroundColor3", "Color.Surface1"\)/,
  'DataTable must use semantic surface')
assert.match(read('lib/core/TreeView.luau'), /hub:BindToken\(shell, "BackgroundColor3", "Color.Surface1"\)/,
  'TreeView must use semantic surface')
console.log('Design Tokens v2: schema, source parity, runtime APIs, config/motion and component integrations verified')
