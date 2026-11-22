import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = p => readFileSync(new URL('../'+p, import.meta.url), 'utf8')
const runtime = read('lib/RiftUI.luau')
const bundle = read('public/RiftUI.luau')
const build = read('scripts/bundle.mjs')
const preview = read('public/RelaxUI_Preview.luau')
const modules = [
  ['ContextMenu', 'CONTEXT_MENU', ['Hub:OpenContextMenu', 'Hub:BindContextMenu', 'Section:ContextMenu']],
  ['SearchSelect', 'SEARCH_SELECT', ['Section:SearchSelect']],
  ['Accordion', 'ACCORDION', ['Section:Accordion']],
]
for(const [file, marker, methods] of modules){
  const source = read('lib/core/'+file+'.luau')
  assert.ok(runtime.includes('--@@'+marker+'@@'), 'missing marker for '+file)
  assert.ok(build.includes('lib/core/'+file+'.luau'), 'missing build map for '+file)
  assert.ok(bundle.includes(source.trim()), 'published bundle stale for '+file)
  assert.ok(!bundle.includes('--@@'+marker+'@@'), 'unexpanded public marker for '+file)
  for(const method of methods) assert.ok(source.includes('function '+method+'('), 'missing API '+method)
  assert.ok(preview.includes(':'+file+'('), 'instant preview missing '+file)
}
assert.match(read('lib/core/ContextMenu.luau'), /InputBegan/, 'mobile right click/long press absent')
assert.match(read('lib/core/ContextMenu.luau'), /task\.delay\(math\.clamp/, 'long press should be bounded')
assert.match(read('lib/core/ContextMenu.luau'), /Children/, 'nested submenu support missing')
assert.match(read('lib/core/SearchSelect.luau'), /local maxVisible = math\.clamp/, 'bounded selection viewport absent')
assert.match(read('lib/core/SearchSelect.luau'), /function c:SetOptions\(/, 'dynamic options absent')
assert.match(read('lib/core/SearchSelect.luau'), /function c:GetRecent\(/, 'recent selection history absent')
assert.match(read('lib/core/Accordion.luau'), /function c:_setSearchPeek\(/, 'search peeking absent')
assert.match(read('lib/core/Accordion.luau'), /function c:SetItems\(/, 'dynamic item update absent')
assert.match(runtime, /SearchSelect = true, Accordion = true/, 'named configs should retain new controls')
assert.ok(preview.includes('string.upper(key) == "DEMO"'), 'do not bypass demo auth')
assert.match(read('.github/workflows/verify-subtabs-lune.yml'), /lune run tests\/p2-controls-lune/)
console.log('P2 control wiring, release parity, preview, config and lifetime checks passed')
