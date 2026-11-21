import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = file => readFileSync(new URL('../' + file, import.meta.url), 'utf8')
const source = read('lib/RiftUI.luau')
const build = read('public/RiftUI.luau')
const switching = read('lib/core/BackgroundSwitch.luau')
const bundler = read('scripts/bundle.mjs')
const preview = read('examples/showcase.luau')
const zh = read('lib/core/Locales/zh.luau')
const block = (start, end) => {
  const a = source.indexOf(start)
  assert.ok(a >= 0, 'missing ' + start)
  const b = source.indexOf(end, a + start.length)
  assert.ok(b >= 0, 'missing ending ' + end)
  return source.slice(a, b)
}
const open = block('function Hub:Open(tab)', 'function Hub:Close()')
const close = block('function Hub:Close()', 'function Hub:_openPopup(')
const windowOpen = block('function Window:Open()', 'function Window:Close()')
const windowClose = block('function Window:Close()', 'function Window:Toggle()')
const background = block('function Hub:_applyBackground()', 'function Hub:_saveStudio(colors)')
const settings = block('function Hub:_buildSettings()', 'local cfg = tab:Section(')

for (const [name, code] of [
  ['Panel open', open], ['Panel close', close],
  ['Child window open', windowOpen], ['Child window close', windowClose]
]) {
  assert.ok(!/tween\(self\.PanelRise/.test(code), name + ': must not animate panel UIScale')
  assert.ok(!/tween\(self\._grow/.test(code), name + ': must not animate child window UIScale')
}
assert.doesNotMatch(open, /tween\(holder,\s*RISE/, 'text-bearing panel must not translate while opening')
assert.doesNotMatch(close, /tween\(holder,\s*FOLD/, 'text-bearing panel must not translate while closing')
assert.doesNotMatch(open, /tween\(tab\.Scroll/, 'tab content must not translate')
assert.match(open, /self\.PanelRise\.Scale = 1/)
assert.match(close, /self\.PanelRise\.Scale = 1/)
assert.match(background, /mode == "Instant"/)
assert.match(background, /mode == "Fade"/)
assert.match(background, /mode == "Crossfade"|Crossfade\//)
assert.match(background, /self\._bgGeneration ~= generation/, 'stale backdrop reveal protection missing')
assert.match(source, /source\.CacheUnique/, 'content-specific switch cache missing')

for (const api of ['GetBackgroundTransition', 'SetBackgroundTransition', 'SwitchBackground']) {
  assert.ok(switching.includes('function Hub:' + api), 'missing API ' + api)
  assert.ok(build.includes('function Hub:' + api), 'unbundled API ' + api)
}
assert.ok(source.includes('--@@BACKGROUND_SWITCH@@'), 'missing source marker')
assert.ok(bundler.includes('lib/core/BackgroundSwitch.luau'), 'missing bundle source')
assert.ok(build.includes(switching.trim()), 'built switch module must match source')
assert.ok(!build.includes('--@@BACKGROUND_SWITCH@@'), 'unexpanded marker')
for (const label of ['Name = "UI background"', 'Name = "UI background opacity"',
                   'Name = "Background switching"', 'Name = "Weather effect"',
                   'Name = "Weather density"', 'Name = "Weather speed"']) {
  assert.ok(settings.includes(label), 'missing UI label: ' + label)
}
for (const translation of ['"UI background"', '"UI background opacity"',
                           '"Background switching"', '"Weather effect"', '"Snow"', '"Rain"']) {
  assert.ok(zh.includes(translation), 'missing Chinese translation: ' + translation)
}
assert.match(preview, /Rift:CreateAuth\(/, 'preview key gate must survive')
assert.match(preview, /string\.upper\(key\) == "DEMO"/, 'DEMO key changed')
assert.match(preview, /Hub:SetWeather\(/, 'preview weather switching controls missing')
assert.match(source, /function Hub:SetBackgroundDim\(value: number\)/, 'live background readability control missing')
assert.match(source, /bg\.Dim ~= nil and bg\.Dim or 0\.70/, 'background wash should respect explicit zero and default readability')
assert.match(source, /if self\._activeThemeInfo then self\._activeThemeInfo:Set\(name\) end/, 'selected theme metadata not updated')
assert.match(settings, /Name = "Interaction feedback"/, 'feedback controls should form a separate group')
assert.match(settings, /Name = "Background appearance"/, 'background controls should form a separate group')
assert.match(settings, /Name = "Weather effects"/, 'weather controls should form a separate group')
assert.match(settings, /Name = "Background readability"/, 'readability adjustment should be available in settings')
for (const key of ['"Interaction feedback"', '"Background readability"', '"Weather effects"', '"Current theme"']) {
  assert.ok(zh.includes(key), 'missing setting localization: ' + key)
}
console.log('Stable text motion, legacy backdrop compatibility, weather switching and key gate verified')
