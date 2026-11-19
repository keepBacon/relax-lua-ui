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

host.run([[
    local R = {}
    __sink(R)
    local Rift = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = Rift:CreateHub({ Name = "Skin Test", Id = "skin-test", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Controls", Icon = "settings" })
    local section = tab:Section({ Name = "Control gallery" })
    local toggle = section:Toggle({ Name = "Enabled", Flag = "SkinToggle", Default = false })
    local slider = section:Slider({ Name = "Power", Flag = "SkinSlider", Min = 0, Max = 100, Default = 40 })
    local button = section:Button({ Name = "Press" })
    local segmented = section:Segmented({ Name = "Mode", Options = { "A", "B" }, Default = "A" })
    local dropdown = section:Dropdown({ Name = "Quality", Options = { "High", "Low" }, Default = "High" })
    local input = section:Input({ Name = "Text", Default = "Hello" })
    hub:Open(tab)
    getgenv().__skinHub = hub
    getgenv().__skinControls = { Toggle = toggle, Slider = slider, Button = button, Segmented = segmented, Dropdown = dropdown, Input = input }
]], "skins-setup")
frames(12)

host.run([[
    local H, C = getgenv().__skinHub, getgenv().__skinControls
    local R = {}
    __sink(R)
    R.initial = H:GetControlTheme() == "Default" and C.Toggle.Frame:FindFirstChild("Check").Size.X.Offset == 16
    R.changed = H:SetControlTheme("Rounded")
    R.nowRounded = H:GetControlTheme() == "Rounded"
    C.Toggle:Set(true)
    C.Slider:Set(72)
    R.values = C.Toggle.Value == true and C.Slider.Value == 72
    R.colorAPI = H:GetColorTheme() == "Graphite"
]], "skins-switch-rounded")
frames(30)

host.run([[
    local H, C = getgenv().__skinHub, getgenv().__skinControls
    local R = {}
    __sink(R)
    local box = C.Toggle.Frame:FindFirstChild("Check")
    R.roundedToggle = box.Size.X.Offset == 30 and box:FindFirstChild("RoundedThumb") ~= nil
    R.roundedTrack = C.Slider.Frame:FindFirstChild("Track").Size.Y.Offset == 5
    R.roundedButton = C.Button.Frame:FindFirstChild("Button").Size.Y.Offset == 30
    R.roundedSegment = C.Segmented.Frame:FindFirstChild("Track").Size.Y.Offset == 36
    R.roundedInput = C.Input.Frame:FindFirstChild("Box").Size.Y.Offset >= 32
    R.roundedDropdown = C.Dropdown.Frame:FindFirstChild("Chip").Size.Y.Offset == 30
    local bubble = C.Slider.Frame:FindFirstChild("RoundedValueBubble")
    R.bubbleStartsHidden = bubble and not bubble.Visible
    C.Slider._skinDrag(true)
    R.bubbleOnDrag = bubble.Visible and bubble:FindFirstChild("BubbleValue").Text == "72"
    C.Slider._skinDrag(false)
]], "skins-inspect-rounded")
frames(20)
host.run([[
    local H, C = getgenv().__skinHub, getgenv().__skinControls
    local R = {}
    __sink(R)
    R.bubbleGoneAfterRelease = not C.Slider.Frame:FindFirstChild("RoundedValueBubble").Visible
    H:SetControlTheme("Default")
]], "skins-verify-bubble-dismissal")
local bubbleResult = sink.R
frames(30)
local rounded = sink.R
for _, key in {"roundedToggle", "roundedTrack", "roundedButton", "roundedSegment", "roundedInput", "roundedDropdown", "bubbleStartsHidden", "bubbleOnDrag"} do
    check(rounded[key], key)
end
check(bubbleResult.bubbleGoneAfterRelease, "slider bubble must disappear after drag release")

host.run([[
    local H, C = getgenv().__skinHub, getgenv().__skinControls
    local R = {}
    __sink(R)
    R.restored = H:GetControlTheme() == "Default" and C.Toggle.Frame:FindFirstChild("Check").Size.X.Offset == 16
    R.originalTrack = C.Slider.Frame:FindFirstChild("Track").Size.Y.Offset == 2
    R.originalButton = C.Button.Frame:FindFirstChild("Button").Size.Y.Offset == 28
    R.originalSegment = C.Segmented.Frame:FindFirstChild("Track").Size.Y.Offset == 28
    R.defaultValues = C.Toggle.Value and C.Slider.Value == 72
    H:Destroy()
    R.destroyed = H._destroyed
]], "skins-default-restoration")
frames(8)
local restored = sink.R
for _, key in {"restored", "originalTrack", "originalButton", "originalSegment", "defaultValues", "destroyed"} do
    check(restored[key], key)
end
print(string.format("%d control theme runtime assertions, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
