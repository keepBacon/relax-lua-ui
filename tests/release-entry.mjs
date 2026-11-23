import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = file => readFileSync(new URL('../' + file, import.meta.url), 'utf8')
const origin = 'https://raw.githubusercontent.com/keepBacon/relax-lua-ui/'
const forbidden = /raw\.githubusercontent\.com\/Naymmmm\/riftui\//
const paths = [
  'lib/Loader.luau', 'public/Loader.luau', 'README.md',
  'examples/hub.luau', 'examples/showcase.luau',
  'examples/developer-sdk.luau', 'src/main.ts', 'src/docs/content.ts',
  'public/RelaxUI_Preview.luau', 'p',
]
for (const path of paths) {
  const content = read(path)
  assert.doesNotMatch(content, forbidden, path + ' must never silently route to upstream')
  assert.ok(content.includes(origin), path + ' must use the Relax UI origin')
}
const librarySource = read('lib/RiftUI.luau')
const releaseAssetBase = 'AssetBase = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/"'
assert.ok(librarySource.includes(releaseAssetBase), 'standalone Luau library must use fork assets')
assert.doesNotMatch(librarySource, /Naymmmm\/riftui/, 'standalone library must not refer users to original fork')
assert.ok(read('public/RiftUI.luau').includes(releaseAssetBase),
  'generated standalone release must use fork assets')
assert.doesNotMatch(read('public/RiftUI.luau'), /Naymmmm\/riftui/,
  'generated release must not contain upstream links')
const sourceLoader = read('lib/Loader.luau')
const bundledLoader = read('public/Loader.luau')
const bundle = read('public/RiftUI.luau')
const build = read('scripts/bundle.mjs')
const readme = read('README.md')
const short = read('p')
const preview = read('public/RelaxUI_Preview.luau')
const showcase = read('examples/showcase.luau')
assert.equal(bundledLoader, sourceLoader, 'published loader must equal the canonical loader')
assert.match(build, /writeFileSync\(join\(root, 'public\/Loader\.luau'\), readFileSync\(join\(root, 'lib\/Loader\.luau'/,
  'build must generate public Loader from lib Loader')
assert.ok(sourceLoader.includes(origin))
assert.match(sourceLoader, /local commit = env\.relaxcommit[\s\S]*?if commit == nil then commit = env\.riftcommit end/, 'both pin options must work')
assert.match(sourceLoader, /if env\.relaxcommit ~= nil and env\.riftcommit ~= nil and env\.relaxcommit ~= env\.riftcommit/,
  'conflicting SHA pins must fail rather than silently choosing one')
assert.match(sourceLoader, /REPOSITORY \.\. commit \.\. "\/public\//, 'commit must apply to library and assets')
assert.doesNotMatch(sourceLoader, /Naymmmm|fallback\(|["']fallback["']/)
assert.match(sourceLoader, /local ok, source = pcall/, 'network failure must be caught')
assert.match(sourceLoader, /if not ok then\s+error/, 'download failure must be fatal')
for (const module of ['ModuleCards', 'ControlStates', 'PanelResize', 'OverlayStack', 'Motion']) {
  assert.match(bundle, new RegExp('function Hub:|function Section:'), module)
  assert.ok(bundle.includes('Name = "ModuleHead"') || bundle.includes('Name = "ModuleSurface"'),
    'runtime must contain the Relax UI components')
}
assert.match(readme, /public\/Loader\.luau/, 'README must document standard loader')
assert.match(readme, /public\/RelaxUI_Preview\.luau/, 'README must document key-gated preview')
assert.match(readme, /relaxcommit/, 'README must explain revision pins')
assert.match(readme, /DEMO/, 'README must explain preview key')
assert.match(short, /examples\/showcase\.luau/, 'short entry must load versioned showcase')
assert.match(preview, /CreateAuth\(/, 'instant preview remains gated')
assert.match(showcase, /CreateAuth\(/, 'showcase remains gated')
assert.match(bundle, /function Hub:OpenActionDialog\(/, 'release artifact must retain lock dialogs')
assert.match(bundle, /Name = "Slit"/, 'original RiftUI notification design must survive')
console.log('RelaxUI P0 release origin, pinned loading and artifact parity passed')
