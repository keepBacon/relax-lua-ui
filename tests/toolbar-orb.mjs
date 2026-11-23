import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8')
const src = read('lib/RiftUI.luau')
const core = read('lib/core/ToolbarOrb.luau')
const bundle = read('public/RiftUI.luau')
const builder = read('scripts/bundle.mjs')
assert.ok(src.includes('--@@TOOLBAR_ORB@@'))
assert.ok(builder.includes("'--@@TOOLBAR_ORB@@', 'lib/core/ToolbarOrb.luau'"))
assert.ok(!bundle.includes('--@@TOOLBAR_ORB@@'))
assert.ok(bundle.includes(core.trim()), 'bundled runtime must match modular source')
for (const name of ['_setupToolbarOrb','_syncToolbarOrbState','_refreshToolbarOrbTheme',
  '_toolbarOrbRipple','_setToolbarOrbPosition']) {
  assert.ok(core.includes('function Hub:' + name + '('), 'missing ' + name)
}
assert.match(src, /Size = UDim2.fromOffset\(44, 44\)/)
assert.match(src, /BackgroundTransparency = 1/, 'transparent 44px touch area')
// Graphite reference: charcoal 36px rounded square, subtle border/shadow,
// crisp white minus. The 44px transparent touch target is unchanged.
assert.match(core, /Name = "OrbFace", BackgroundColor3 = ORB_BG/)
assert.match(core, /Size = UDim2.fromOffset\(36, 36\)/, '36px Graphite face')
assert.match(core, /\}, \{ corner\(9\) \}\)/, 'round square, not a circular disk')
assert.match(core, /ORB_BG = Color3.fromRGB\(17, 19, 22\)/)
assert.match(core, /ORB_GLYPH = Color3.fromRGB\(240, 241, 243\)/)
assert.match(core, /Name = "GraphiteBorder"/)
assert.match(core, /Name = "GraphiteShadow"/)
assert.match(core, /Name = "GlyphHorizontal", BackgroundColor3 = ORB_GLYPH/)
assert.match(core, /Size = UDim2.fromOffset\(14, 2\)/, 'small white minus')
assert.match(core, /function Hub:_setToolbarOrbSpin\(_enabled\)/, 'legacy Hub call remains safe')
assert.doesNotMatch(core, /_orbGradient|_orbHalo|OrbHalo|ThemeGradientBorder|_orbSpinTween/,
  'Graphite must not retain neon gradients, circular halo or idle spins')
assert.doesNotMatch(core, /TweenService:Create|RenderStepped:Connect|while true do/,
  'Graphite should have no continuous idle work')
assert.doesNotMatch(src, /self\.Restore\.Text = visible and/)
assert.match(core, /ORB_HOLD_SECONDS = 1/)
assert.match(core, /task.delay\(ORB_HOLD_SECONDS/)
assert.match(core, /p\.unlocked = true/)
assert.match(core, /p\.invalid = true/)
assert.match(core, /not p\.unlocked and not p\.invalid/, 'hold must not toggle')
assert.match(core, /Color = ORB_GREEN, Thickness = 1\.8/,
  'existing green drag-unlock feedback remains but is limited to the border')
assert.match(core, /self\._orbScale, ORB_SETTLE/, 'press and settle feedback retained')
assert.match(core, /Motion.transition\(self, "toolbar-orb-glyph"/, 'window glyph morph retained')
assert.match(core, /BackgroundTransparency = open and 1 or 0/,
  'window-open minus and hidden-window plus stay legible')
assert.match(core, /self:_savePref\("ToolbarOrbPosition"/)
assert.match(core, /self._capturedDrag = dragBinding/)
assert.match(core, /self:Own\(\{ Disconnect/)
assert.match(src, /self:_routeOverlayPointer\(Vector2\.new\(input\.Position\.X, input\.Position\.Y\)\) then return end/, 'central route protects orb and top overlay without closing the panel')
assert.match(src, /self:_refreshToolbarOrbTheme\(\)/)
assert.doesNotMatch(core, /RunService\.RenderStepped:Connect|while true do/)
console.log('RelaxUI Graphite launcher: geometry, bundle, hold, drag, state and cleanup checks passed')
