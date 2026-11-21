import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const get = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const entry = get('p')
const preview = get('examples/showcase.luau')
const built = get('public/RiftUI.luau')

assert.match(entry, /examples\/showcase\.luau/, 'short entry must load the full showcase')
assert.match(preview, /Rift:CreateAuth\(\{/, 'preview key gate must be retained')
assert.match(preview, /Remember\s*=\s*false/, 'preview must not silently bypass the key gate on another launch')
assert.match(preview, /string\.upper\(key\)\s*==\s*"DEMO"/, 'DEMO should be the preview key')
assert.match(preview, /if not accepted then return end/, 'non-accepted keys must stop the preview')
assert.match(preview, /keepBacon\/relax-lua-ui\/main\//, 'use owner fork instead of upstream code')
assert.match(preview, /Language\s*=\s*"zh"/, 'Chinese preview default missing')
for (const api of ['SetUISounds', 'PlayUISound', 'ListBackgrounds', 'SetBackgroundPreset', 'SetBackgroundTransparency']) {
  assert.ok(preview.includes(api), 'preview API not demonstrated: ' + api)
  assert.ok(built.includes('function Hub:' + api + '('), 'missing bundled API: ' + api)
}
assert.ok(!preview.includes('https://discord.gg/your-invite'), 'invalid Discord link should not be displayed')
const instant = get('public/RelaxUI_Preview.luau')
assert.match(instant, /local activeTheme = themeSection:_info\("当前主题"/, 'instant preview must display active theme')
assert.match(instant, /refreshThemeChoices\(\)/, 'instant preview must refresh theme selection')
assert.match(instant, /Name = "控件形状"/, 'shape group must remain separate')
assert.match(instant, /Name = "动画偏好"/, 'motion controls must not appear under shape')
assert.match(instant, /Hub:SetMotionMode\(mode\)/, 'preview motion choices must remain functional')
console.log('Preview entry /p, DEMO key and current UI feature examples verified')
