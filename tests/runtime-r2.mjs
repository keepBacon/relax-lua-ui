import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { createHash } from 'node:crypto'

const read = (file) => readFileSync(new URL('../' + file, import.meta.url), 'utf8')
const buffer = (file) => readFileSync(new URL('../' + file, import.meta.url))
const main = read('lib/RiftUI.luau')
const output = read('public/RiftUI.luau')
const bundler = read('scripts/bundle.mjs')

const modules = [
  ['Sound', 'lib/core/UISound.luau', '--@@UI_SOUND@@'],
  ['Backdrop', 'lib/core/BackdropPresets.luau', '--@@BACKGROUND_PRESETS@@'],
  ['Ownership', 'lib/core/ResourceScope.luau', '--@@RESOURCE_SCOPE@@'],
  ['Motion', 'lib/core/Motion.luau', '--@@MOTION@@'],
]
for (const [name, path, marker] of modules) {
  const source = read(path)
  assert.ok(bundler.includes(path), name + ' missing from bundler')
  assert.ok(main.includes(marker), name + ' marker absent from source')
  assert.ok(!output.includes(marker), name + ' marker not expanded')
  assert.ok(output.includes(source.trim()), name + ' module is out of sync with published bundle')
}
for (const api of [
  'function Hub:PlayUISound(', 'function Hub:SetUISounds(', 'function Hub:GetUISounds(',
  'function Hub:SetBackgroundPreset(', 'function Hub:ListBackgrounds(',
  'function Hub:GetBackground(', 'function Hub:SetBackgroundTransparency(',
  'function Hub:_releaseOwned(', 'function Hub:_requestPanelFit(',
]) {
  assert.ok(output.includes(api), 'Missing public API: ' + api)
}
assert.match(output, /function Hub:_applyBackground\(\)[\s\S]*?GroupTransparency = 1/, 'Crossfade backdrop missing')
assert.match(main, /notifications: a slit that opens/, 'original RiftUI slit notification must be restored')
assert.match(main, /Name = "Slit"/, 'slit timer must be visible')
assert.match(main, /timer:Pause\(\)/, 'hover and dismiss must pause notification timer')
assert.match(main, /Name = "Clip"/, 'notification card must reveal from the slit')
assert.match(main, /ZIndex = 42,[\s\S]*?Parent = gui/, 'notifications must draw over the toolbar orb')
assert.match(output, /notifications: a slit that opens/, 'published bundle must include RiftUI toast style')
assert.doesNotMatch(main, /notifications: restored rounded slide-in cards/, 'temporary rounded notification override must be gone')
assert.match(output, /self\._backgroundRequest ~= requestId/, 'Stale background request protection missing')
assert.match(output, /self\._themeScanned\[inst\] = true/, 'Theme token scan cache missing')
assert.match(output, /self:_releaseOwned\(\)/, 'Hub teardown must release owned resources')
assert.match(output, /motionTargets\[inst\]/, 'Tween target reuse index missing')

const wavs = {
  'soft-pop.wav': 'fc0b3d362a48d9dcb3102701cae000dca60c7697232812809b854fadacd47afb',
  'soft-tick.wav': 'b88bf3e5a45467e903d512562510664ddf29876726cb12a13c2c3f44ae2944da',
  'minimal-tick.wav': 'bca1ea367f73f486119ba7a67d7958f0527d401d9dc6f619ee4d5dba563188bd',
  'minimal-confirm.wav': '269e87fb4c7a6d6ec79d203e96b823b7ab2b1042cd48a8be083b482e206e357f',
  'error-buzz.wav': '36f2620f6bf3fa1ea17935be0608dffb47a3a6787424c930154df4a70712563d',
}
for (const [file, checksum] of Object.entries(wavs)) {
  const data = buffer('assets/sounds/' + file)
  assert.equal(data.subarray(0, 4).toString(), 'RIFF', file + ' is not a RIFF sound')
  assert.equal(data.subarray(8, 12).toString(), 'WAVE', file + ' is not WAV')
  assert.equal(createHash('sha256').update(data).digest('hex'), checksum, file + ' differs from VantaUI reference')
}
assert.match(read('assets/sounds/LICENSE-VantaUI.txt'), /MIT License/)
console.log('RiftUI R2 sound assets, background presets, module bundle and lifecycle checks passed')
