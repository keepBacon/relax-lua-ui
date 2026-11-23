import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const types = read('types/DeveloperSDK.luau')
const sdk = read('lib/core/DeveloperKit.luau')
const components = read('lib/core/CustomComponents.luau')
const inspector = read('lib/core/VisualInspector.luau')
const example = read('examples/developer-sdk.luau')
const manual = read('docs/SDK_QUICKSTART.md')
const simulator = read('src/main.ts')
const docs = read('src/docs/content.ts')
const origin = 'https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/Loader.luau'

assert.match(types, /--!strict/, 'SDK types must be strict Luau source')
assert.match(types, /export type DeveloperHub\s*=/, 'public SDK Hub interface missing')
for (const name of ['ResourceScope','ExtensionDescriptor','ComponentDescriptor',
  'ComponentContext','ComponentView','ComponentInfo','DeveloperStats',
  'VisualNode','VisualTree','DeveloperReport','SnapshotOptions']) {
  assert.ok(types.includes('export type ' + name + ' ='),
    name + ' must have an editor-visible exported contract')
}
for (const method of [
  'RegisterExtension','UnregisterExtension','GetExtension','ListExtensions',
  'CreateDeveloperScope','OnDeveloperEvent','EmitDeveloperEvent',
  'ReportDeveloperDiagnostic','GetDeveloperDiagnostics','ClearDeveloperDiagnostics',
  'GetDeveloperStats','RegisterComponent','UnregisterComponent','GetComponent',
  'ListComponents','GetVisualTreeSnapshot','CaptureDeveloperReport',
  'OpenVisualInspector','CloseVisualInspector'
]) {
  assert.ok(types.includes(method + ':'), method + ' absent from Luau type contract')
  const source = ['RegisterComponent','UnregisterComponent','GetComponent','ListComponents'].includes(method)
    ? components
    : ['GetVisualTreeSnapshot','CaptureDeveloperReport','OpenVisualInspector',
      'CloseVisualInspector'].includes(method) ? inspector : sdk
  assert.ok(source.includes('function Hub:' + method + '('),
    method + ' must correspond to a real public Hub method')
}
assert.match(types, /return \{\}\s*$/, 'type aliases must be safe to require as a module')
assert.ok(example.includes(origin), 'example must load the maintained fork')
for (const line of ['hub:RegisterExtension(', 'owner:RegisterComponent(',
  'section:Component(', 'context:BindToken(', 'context:Connect(',
  'scope:Defer(', 'hub:CaptureDeveloperReport(', 'hub:OpenVisualInspector(']) {
  assert.ok(example.includes(line), 'runnable SDK example must show ' + line)
}
assert.match(example, /scope:Own\(owner:OnDeveloperEvent/,
  'event subscription should be owned by the extension scope')
assert.match(example, /scope:Own\(counter\)/,
  'extension-owned custom components must clean up with the extension scope')
assert.ok(example.indexOf('section:Component(') < example.indexOf('scope:Defer('),
  'component instance must be created inside Start before Start returns')
assert.match(manual, /Reinitialize replays ordinary Tab\/Section recipes first/,
  'migration guide must reflect actual extension Start ordering')
assert.doesNotMatch(example, /CreateAuth\(|DEMO.*return true/,
  'developer example must not bypass or replace the preview DEMO gate')
assert.ok(manual.includes('## API reference') && manual.includes('## Migration examples'),
  'SDK manual requires lifecycle reference and migration table')
assert.ok(manual.includes('Reinitialize') && manual.includes('Android'),
  'SDK manual needs replay and mobile verification caveats')
assert.ok(simulator.includes(origin), 'simulator Minimal Hub must load fork')
assert.ok(docs.includes(origin), 'website quickstart must load fork')
assert.doesNotMatch(simulator + docs, /Naymmmm\/riftui/,
  'developer-facing website must not link to the upstream codebase')
console.log('R4 SDK type contracts, runnable example, migration guide and fork URLs verified')
