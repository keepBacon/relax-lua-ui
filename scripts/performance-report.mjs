import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const path = process.argv[2] || 'perf-baseline.json'
const payload = JSON.parse(readFileSync(path, 'utf8'))
const metrics = [
  ['Create100Ms', 'Create 100 toggles'],
  ['ExpandTo300Ms', 'Add 200 toggles (300 total)'],
  ['CreateTable1000Ms', 'Create 1000-row DataTable'],
  ['UpdateTableRowMs', 'Update a row in the 1000-row DataTable'],
  ['ThemeAndPopup12Ms', '12 theme and popup cycles'],
  ['Reinitialize3Ms', '3 Hub reinitializations'],
]
assert.equal(payload.schema, 1)
assert.deepEqual(payload.control_counts, [100, 300])
assert.equal(payload.table_rows, 1000)
assert.equal(payload.theme_popup_cycles, 12)
assert.equal(payload.reinitialize_cycles, 3)
assert.equal(payload.passed, true, 'native Luau functional invariants failed')
assert.ok(payload.checks >= 20, 'too few baseline assertions')
const lines = [
  '### Relax UI R5 — simulated Luau performance baseline',
  '',
  '> Lune simulated Roblox GUI only. **Not device FPS, not a Roblox client frame-time benchmark.**',
  '',
  '| Scenario | Elapsed (ms) |',
  '|---|---:|',
]
for (const [key, label] of metrics) {
  const value = payload.metrics_ms?.[key]
  assert.ok(Number.isFinite(value) && value >= 0, 'invalid performance metric ' + key)
  lines.push('| ' + label + ' | ' + value.toFixed(3) + ' |')
}
lines.push('', 'Functional assertions: **' + payload.checks + ' passed**.', '')
console.log(lines.join('\n'))
