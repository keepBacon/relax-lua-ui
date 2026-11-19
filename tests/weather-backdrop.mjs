import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8')
const source = read('lib/RiftUI.luau')
const weather = read('lib/core/WeatherBackdrop.luau')
const bundle = read('public/RiftUI.luau')
const example = read('examples/showcase.luau')
const zh = read('lib/core/Locales/zh.luau')
const bundler = read('scripts/bundle.mjs')
assert.match(source, /--@@WEATHER_BACKDROP@@/)
assert.ok(bundler.includes('lib/core/WeatherBackdrop.luau'))
assert.ok(bundle.includes(weather.trim()), 'bundled weather must match source')
assert.ok(!bundle.includes('--@@WEATHER_BACKDROP@@'))
for (const item of ['None','Rain','Snow','Ember','Sakura','Fireflies','Matrix']) {
  assert.ok(weather.includes('"'+item+'"'), 'missing weather '+item)
}
for (const api of ['ListWeather', 'GetWeather', 'GetWeatherMode', 'GetWeatherDensity',
  'GetWeatherSpeed', 'GetWeatherOpacity', 'SetWeather', 'SetWeatherMode',
  'SetWeatherDensity', 'SetWeatherSpeed', 'SetWeatherOpacity']) {
  assert.ok(weather.includes('function Hub:'+api+'('), 'missing weather API '+api)
}
assert.match(weather, /RenderStepped:Connect\(function\(dt\)/)
assert.match(weather, /touch and 50 or 100/, 'mobile particle limit missing')
assert.match(weather, /self\._weatherFrameClock < \(1 \/ 30\)/, 'update-rate limiter missing')
assert.match(weather, /DisplayOrder = math\.max\(0, self\.Gui\.DisplayOrder - 1\)/,
  'screen weather must be behind main UI')
assert.match(weather, /Parent = self\.Panel/, 'UI-mode weather must follow panel')
assert.match(weather, /self\._weatherFrameConn:Disconnect\(\)/, 'cleanup must disconnect frame update')
assert.match(weather, /self\._weatherScreen:Destroy\(\)/, 'cleanup must destroy weather GUI')
assert.match(source, /self:_disposeWeather\(\)/, 'hub lifecycle weather disposal missing')
assert.match(source, /if self:GetWeather\(\) ~= "None" then/, 'restore weather on startup')
for (const label of ['Weather effect','Weather area','Weather density','Weather speed','Weather opacity']) {
  assert.ok(source.includes('Name = "'+label+'"'), 'settings missing '+label)
  assert.ok(example.includes('Name = "'+label+'"'), 'showcase missing '+label)
  assert.ok(zh.includes('["'+label+'"]'), 'Chinese missing '+label)
}
assert.ok(!source.includes('Name = "Background URL or file"'), 'old background source UI must be replaced')
assert.ok(!source.includes('Name = "Transition mode"'), 'image transition must no longer be called weather switching')
assert.ok(!example.includes('Name = "Background URL or file"'), 'preview still shows old image switching')
assert.match(source, /Weather = self:GetWeather\(\)/, 'config save must include weather')
assert.match(source, /self:SetWeather\(data\.Weather\)/, 'config load must restore weather')
assert.match(example, /Rift:CreateAuth\(/, 'key gate missing')
assert.match(example, /string\.upper\(key\) == "DEMO"/, 'DEMO preview key changed')
console.log('Weather scene layering, all six particle modes, performance, config, preview and cleanup validated')
