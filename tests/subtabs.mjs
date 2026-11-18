import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const source = read('lib/RiftUI.luau')
const runtime = read('lib/core/SubTabs.luau')
const bundle = read('public/RiftUI.luau')
const preview = read('examples/showcase.luau')
const bundler = read('scripts/bundle.mjs')
const block = (start, end) => {
 const a=source.indexOf(start), b=source.indexOf(end,a+start.length)
 assert.ok(a>=0&&b>a,start+' missing')
 return source.slice(a,b)
}
assert.ok(source.includes('--@@SUBTABS_RUNTIME@@'), 'subtab module marker missing')
assert.ok(bundler.includes('lib/core/SubTabs.luau'), 'subtab module missing from bundler')
assert.ok(!bundle.includes('--@@SUBTABS_RUNTIME@@'), 'subtab marker was not expanded')
assert.ok(bundle.includes(runtime.trim()), 'bundled subtab implementation out of sync')
for (const name of ['Tab:SubTab', 'Hub:_setSubTab', 'Hub:_toggleSubTabs', 'Hub:_closeSubTabs',
                    'Hub:_updateTabHeader', 'Hub:_positionSubTabs']) {
 assert.ok(runtime.includes('function '+name+'('), 'missing '+name)
}
assert.match(runtime, /self\.HeaderSub\.Text = caption/, 'grey subtitle must show selected child name')
assert.match(runtime, /self\._subTabRailVisible = true/, 'rail must persist after selection')
const setSub = block('function Hub:Open(tab)', 'function Hub:Close()')
assert.match(setSub, /if tab\.IsSubTab then/, 'Hub:Open should support child tab')
assert.match(setSub, /self:_updateTabHeader\(tab\)/, 'header must reflect child')
const click=block('function Hub:Tab(options)','--@@SUBTABS_RUNTIME@@')
assert.match(click, /if tab\.SubTabs and #tab\.SubTabs > 0 then/, 'selected primary must open child row')
const input=block('function Hub:_bindInput()', 'function Hub:_dockBottom')
assert.match(input, /if self\._subTabRailVisible then/, 'outside click must check secondary rail first')
assert.match(input, /self:_closeSubTabs\(\)\s*return/, 'outside click must stop before closing panel')
assert.match(runtime, /within\(self\._subTabRail, pos\)|self\._subTabRail\.Visible = true/, 'rail must be distinct')
assert.doesNotMatch(runtime, /TweenInfo|TweenService|tween\(/, 'secondary navigation must have no animations')
assert.match(runtime, /SubTabPanelFrost/, 'static UI-only veil missing')
assert.doesNotMatch(runtime, /Lighting|BlurEffect/, 'must not blur the game world')
assert.match(source, /if self\.IsSubTab then return end/, 'child toggle counts must not access primary badge')
assert.match(source, /for _, sub in tab\.SubTabs or \{\} do/, 'lifecycle must include child pages')
for (const name of ['通用', '战斗', '视觉']) {
 assert.ok(preview.includes('Nested:SubTab({ Name = "'+name+'"'), 'preview missing '+name)
}
assert.match(preview, /string\.upper\(key\) == "DEMO"/, 'preview key gate must remain')
console.log('Two-level tabs: API, hierarchy, title, outside-click, lifecycle, preview and no-animation checks passed')
