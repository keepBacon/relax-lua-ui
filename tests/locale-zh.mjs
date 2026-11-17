import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = (name) => readFileSync(new URL('../' + name, import.meta.url), 'utf8')
const lang = read('lib/core/Locales/zh.luau')
const source = read('lib/RiftUI.luau')
const bundled = read('public/RiftUI.luau')
const bundler = read('scripts/bundle.mjs')
const docs = read('src/docs/content.ts')

assert.match(lang, /RiftUI\.LanguageNames\.zh = "简体中文"/)
assert.match(lang, /RiftUI\.Translations\.zh\s*=\s*\{/)
const keys = [...lang.matchAll(/\["([^"]+)"\]\s*=/g)].map(match => match[1])
assert.ok(keys.length >= 120, 'Chinese localization must include the common UI strings')
assert.equal(new Set(keys).size, keys.length, 'Duplicate Chinese localization key')
for (const key of ['Settings', 'Language', 'Config', 'Toolbar key', 'Save', 'Load', 'No results',
                   '{n} results', 'Save, load and share setups for {hub}', 'UI sounds',
                   'UI sound preset', 'Background preset', 'Open theme studio']) {
  assert.ok(keys.includes(key), 'Missing translation: ' + key)
}
assert.ok(source.includes('--@@LOCALE_ZH@@'), 'Source should have locale marker')
assert.ok(bundler.includes('lib/core/Locales/zh.luau'), 'Bundler must load Chinese locale')
assert.ok(!bundled.includes('--@@LOCALE_ZH@@'), 'Unexpanded locale marker')
assert.ok(bundled.includes(lang.trim()), 'Chinese locale must be bundled verbatim')
assert.match(source, /canonical:match\("\^zh%-"\)/, 'zh-CN region normalization missing')
assert.ok(docs.includes('Simplified Chinese'), 'Docs language support must be updated')
assert.ok(docs.includes('zh-CN'), 'Docs should show Chinese language code')
console.log('Simplified Chinese: ' + keys.length + ' translations, bundled and documented')
