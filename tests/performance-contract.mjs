import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const source = read('tests/performance-lune.luau')
const report = read('scripts/performance-report.mjs')
const workflow = read('.github/workflows/verify-subtabs-lune.yml')
const docs = read('docs/PERFORMANCE_ACCEPTANCE.md')
for (const pattern of [
  /addControls\(1, 100\)/, /addControls\(101, 300\)/,
  /for i = 1, 1000 do/, /for i = 1, 12 do/,
  /for i = 1, 3 do/, /grid:Update\("row501"/,
  /hub:Reinitialize\(\)/, /hub:GetDeveloperStats\(\)/,
  /hub:GetDeveloperResourceSnapshot\(\)/,
  /hub:CaptureDeveloperReport|hub:GetVisualTreeSnapshot/,
  /metrics\.Snapshot50Ms = elapsed\(start\)/,
  /fs\.writeFile\("perf-baseline\.json"/,
]) assert.match(source, pattern, 'performance workload is incomplete')
assert.match(report, /Lune simulated Roblox GUI/)
assert.match(workflow, /lune run tests\/performance-lune/)
assert.match(workflow, /scripts\/performance-report\.mjs/)
assert.match(workflow, /actions\/upload-artifact@v4/)
assert.match(docs, /Android/)
assert.match(docs, /FPS/)
assert.doesNotMatch(source, /RenderStepped:Connect|Heartbeat:Connect/,
  'test must not introduce a background polling loop')
console.log('R5 benchmark scenarios, CI artifact and physical-device boundaries verified')
