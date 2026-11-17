import { readFileSync } from 'node:fs'
import assert from 'node:assert/strict'
const read = (file) => readFileSync(new URL('../' + file, import.meta.url), 'utf8')
const pointer = read('lib/core/PointerDrag.luau')
const scheduler = read('lib/core/CallbackScheduler.luau')
const source = read('lib/RiftUI.luau')
const build = read('public/RiftUI.luau')
const bundler = read('scripts/bundle.mjs')
for (const marker of ['--@@ICONS@@', '--@@MOTION@@', '--@@POINTER_DRAG@@', '--@@CALLBACK_SCHEDULER@@']) {
  assert(!build.includes(marker), 'Unexpanded marker: ' + marker)
}
for (const [name, content] of [
  ['Pointer capture', pointer],
  ['Callback scheduler', scheduler],
]) {
  assert(build.includes(content.trim()), name + ' is not synchronized into the public bundle')
}
assert.match(pointer, /UserInputState\.Cancel/, 'touch cancellation must be handled')
assert.match(pointer, /ended\.UserInputType == Enum\.UserInputType\.MouseButton1/, 'mouse release must be handled')
assert.match(pointer, /ScrollingEnabled = previous/, 'scroll ownership must be returned')
assert.match(pointer, /hub\._capturedDrag == binding/, 'capture must be released')
assert.match(pointer, /handle\.Destroying:Connect/, 'drag handlers must be destroyed with their owners')
assert.match(scheduler, /queuedControlCallbacks\[control\] = nil/, 'coalesced callbacks must clear pending state')
assert.match(scheduler, /if not hub\._destroyed/, 'no callback may run after hub teardown')
assert.match(source, /cancelHubCallbacks\(self\)/, 'teardown must cancel pending callbacks')
assert.match(source, /function control:OffChanged/, 'observers must be detachable')
assert.match(bundler, /CallbackScheduler\.luau/, 'bundler must include the scheduler')
assert.equal((build.match(/local function bindPointerDrag/g) || []).length, 1)
assert.equal((build.match(/local function scheduleControlCallback/g) || []).length, 1)
console.log('RiftUI first-round runtime invariants passed')
