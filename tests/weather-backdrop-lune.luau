--!nocheck
-- Headless smoke test: runs the emulated engine, RiftUI and the example hub under Lune,
-- then drives the API (flags, Set, configs, pins, unload) and checks the instance tree.
-- Run with `pnpm test` (bundles first) or `lune run tests/smoke`.

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")

local files: { [string]: string } = {}
-- Lune's fs yields; the engine resumes its own coroutines, so read everything up front
local public: { [string]: string } = {}
local function preload(dir: string)
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			preload(path)
		else
			public[string.sub(path, #"public/" + 1)] = fs.readFile(path)
		end
	end
end
preload("public")
local hubSource = fs.readFile("examples/hub.luau")
local folders: { [string]: boolean } = {}
local errors = {}
local env
local clipboardText
local authClipboard

local ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64encode(data: string): string
	local n = #data
	local src = buffer.fromstring(data)
	local out = buffer.create(math.ceil(n / 3) * 4)
	local o = 0
	for i = 0, n - 1, 3 do
		local a = buffer.readu8(src, i)
		local b = i + 1 < n and buffer.readu8(src, i + 1) or 0
		local c = i + 2 < n and buffer.readu8(src, i + 2) or 0
		local v = a * 65536 + b * 256 + c
		buffer.writeu8(out, o, string.byte(ALPHA, bit32.extract(v, 18, 6) + 1))
		buffer.writeu8(out, o + 1, string.byte(ALPHA, bit32.extract(v, 12, 6) + 1))
		buffer.writeu8(out, o + 2, i + 1 < n and string.byte(ALPHA, bit32.extract(v, 6, 6) + 1) or 61)
		buffer.writeu8(out, o + 3, i + 2 < n and string.byte(ALPHA, bit32.extract(v, 0, 6) + 1) or 61)
		o += 4
	end
	return buffer.tostring(out)
end

local host = {
	sync = function()
		return ""
	end,
	measure = function(text, size)
		return tostring(#text * size * 0.5) .. "\31" .. tostring(size)
	end,
	print = function(m)
		print("[print] " .. m)
	end,
	warn = function(m)
		print("[warn] " .. m)
	end,
	error = function(m, trace)
		table.insert(errors, m)
		print("[error] " .. m .. "\n" .. (trace or ""))
	end,
	now = function()
		return os.time() * 1000
	end,
	load = function(src, name)
		local ok, fn = pcall(luau.load, src, { debugName = name, environment = env })
		if ok then
			return fn
		end
		return tostring(fn)
	end,
	fs = function(op, path, data)
		if op == "write" then
			files[path] = data
			return ""
		elseif op == "read" then
			return files[path] or ("ERR\31no file " .. path)
		elseif op == "isfile" then
			return files[path] and "1" or "0"
		elseif op == "isfolder" then
			return folders[path] and "1" or "0"
		elseif op == "mkdir" then
			folders[path] = true
			return ""
		elseif op == "delfile" then
			files[path] = nil
			return ""
		elseif op == "list" then
			local out = {}
			for k in files do
				if string.sub(k, 1, #path + 1) == path .. "/" then
					table.insert(out, k)
				end
			end
			return table.concat(out, "\31")
		elseif op == "asset" then
			return files[path] and string.sub(files[path], 1, 11) == "iVBORw0KGgo" and ("rbxasset://riftsim/" .. path) or "ERR\31image-only executor: not a PNG " .. path
		end
		return ""
	end,
	http = function(method, url, headers)
		if url == "https://auth.test/v1/script" then
			if string.find(headers or "", "Bearer good-key", 1, true) then return "200\31" .. b64encode("return 'hub source'") .. "\31{}" end
			if string.find(headers or "", "Bearer busy-key", 1, true) then return "503\31\31{}" end
			return "401\31" .. b64encode('{"error":"Key expired"}') .. "\31{}"
		end
		if url == "https://image.test/empty.png" then return "200\31\31{}" end
		if url == "https://image.test/page.png" then return "200\31" .. b64encode("<!doctype html><html>Not an image</html>") .. "\31{}" end
		local rel = string.match(url, "/riftui/[^/]+/public/(.+)$")
		if rel and public[rel] then
			return "200\31" .. b64encode(public[rel]) .. "\31{}"
		end
		return "404\31\31{}"
	end,
	clipboard = function(value)
		clipboardText = value
		if value == "https://keys.test" then authClipboard = value end
	end,
}
host.register = function(step, run)
	host.step = step
	host.run = run
end

local sink = {}
env = setmetatable({
	__HOST = host,
	__sink = function(t)
		sink.R = t
	end,
}, { __index = _G })
local engine = luau.load(public["engine.luau"], { debugName = "engine", environment = env })
engine()
assert(host.step and host.run, "engine registered step and run")

local function frames(n)
	for _ = 1, n do
		host.step(1 / 60, "")
	end
end

local checks = 0
local function check(cond, label)
	checks += 1
	if not cond then
		table.insert(errors, "check failed: " .. label)
		print("FAIL " .. label)
	else
		print("ok   " .. label)
	end
end

-- Dedicated Lune runtime checks for two-level navigation; independent of legacy image tests.
host.run([[
    local R = {}
    __sink(R)
    local Rift = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = Rift:CreateHub({ Name = "Weather Test", Id = "weather-probe", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Demo", Icon = "sun" })
    tab:Section({ Name = "Weather" }):Button({ Name = "Test" })
    hub:Open(tab)
    R.options = #hub:ListWeather() == 7 and hub:GetWeather() == "None"
    R.ready = hub._weatherScreen == nil and hub._weatherFrameConn == nil
    R.started = hub:SetWeather("Snow")
    R.snow = hub:GetWeather() == "Snow" and #hub._weatherParticles > 0
    R.separate = hub._weatherScreen.DisplayOrder < hub.Gui.DisplayOrder
        and hub._weatherField.Parent == hub._weatherScreen
    R.modeChange = hub:SetWeatherMode("UI") and hub._weatherField.Parent == hub.Panel
    R.density = hub:SetWeatherDensity(.4) and hub:GetWeatherDensity() == .4
    R.speed = hub:SetWeatherSpeed(1.4) and hub:GetWeatherSpeed() == 1.4
    R.opacity = hub:SetWeatherOpacity(.6) and hub:GetWeatherOpacity() == .6
    R.backScreen = hub:SetWeatherMode("Screen") and hub._weatherField.Parent == hub._weatherScreen
    R.rain = hub:SetWeather("Rain") and hub:GetWeather() == "Rain" and #hub._weatherParticles > 0
    R.bad = hub:SetWeather("wrong-weather") == false
    getgenv().__weatherProbe = hub
]], "weather-setup")
frames(12)
local initial = sink.R
for _, key in {"options", "ready", "started", "snow", "separate", "modeChange",
               "density", "speed", "opacity", "backScreen", "rain", "bad"} do
    check(initial[key], "weather initial: " .. key)
end

host.run([[
    local H = getgenv().__weatherProbe
    local R = {}
    __sink(R)
    R.visible = H._weatherField.Visible
    H:Close()
    R.closed = H._open == nil
]], "weather-close")
frames(12)
local closed = sink.R
check(closed.visible, "weather field runs while main panel is open")
check(closed.closed, "closing panel updates open state")

host.run([[
    local H = getgenv().__weatherProbe
    local R = {}
    __sink(R)
    R.paused = H._weatherField.Visible == false
    H:SetWeather("None")
    R.none = H:GetWeather() == "None" and #H._weatherParticles == 0
        and H._weatherFrameConn == nil and H._weatherScreen == nil
    H:Destroy()
    R.destroyed = H._destroyed and H._weatherScreen == nil
        and H._weatherFrameConn == nil
]], "weather-teardown")
frames(4)
local final = sink.R
for _, key in {"paused", "none", "destroyed"} do
    check(final[key], "weather teardown: " .. key)
end
print(string.format("%d weather runtime assertions, %d engine errors", checks, #errors))
if #errors > 0 then process.exit(1) end
