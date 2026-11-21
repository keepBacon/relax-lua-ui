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

-- End-to-end interruptions use the native Luau simulator and real Hub instances.
host.run([[
    local R = {}
    __sink(R)
    local loader, compileError = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))
    assert(loader, "Luau build failed: " .. tostring(compileError))
    local Rift = loader()
    local hub = Rift:CreateHub({ Name = "Motion Test", Id = "motion-test", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Main", Icon = "layers" })
    local sub = tab:SubTab({ Name = "Child", Icon = "star" })
    local section = sub:Section({ Name = "Foldable", Collapsible = true })
    section:Button({ Name = "Action" })
    hub:Open(tab)
    hub:Close()
    hub:Open(tab)
    R.panelState = Rift.Motion.getState(hub, "panel-visibility") == "open"
    R.panelReopened = hub._open == tab and hub.PanelHolder.Visible
    section:SetCollapsed(true)
    section:SetCollapsed(false)
    R.sectionState = Rift.Motion.getState(hub, "section-collapse:" .. section.Id) ~= nil
    local other = hub:Tab({ Name = "Other", Icon = "settings" })
    other:Section({ Name = "Second", Side = "Left" }):Button({ Name = "Action" })
    hub:Open(other)
    hub:Open(tab)
    hub:_setSubTab(tab, sub)
    hub:_setSubTab(tab, nil)
    hub:_setSubTab(tab, sub)
    R.fastNavigation = hub._open == tab and sub.Page.Visible
        and not other.Page.Visible and not tab.Page.Visible
    hub:_toggleSubTabs(tab)
    hub:_closeSubTabs()
    hub:_toggleSubTabs(tab)
    R.railState = Rift.Motion.getState(hub, "subtab-rail") == "open"
    R.railVisible = hub._subTabRailVisible and hub._subTabRail.Visible

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.Parent = hub.Gui
    local nextBox = Instance.new("Frame")
    nextBox.BackgroundTransparency = 1
    nextBox.Parent = hub.Gui
    local stale, completed = 0, 0
    Rift.Motion.play(hub, "test-opacity", box,
        { BackgroundTransparency = 0 }, Rift.Motion.Presets.Control, function() stale += 1 end)
    Rift.Motion.play(hub, "test-opacity", box,
        { BackgroundTransparency = .42 }, Rift.Motion.Presets.Control, function() completed += 1 end)
    R.latestState = Rift.Motion.getState(hub, "test-opacity") == "test-opacity"
    local discarded = 0
    local groupBox = Instance.new("Frame")
    groupBox.BackgroundTransparency = 1
    groupBox.Parent = hub.Gui
    Rift.Motion.transition(hub, "test-group", "appear", {
        { Target = groupBox, Goals = { BackgroundTransparency = .2 } },
        { Target = nextBox, Goals = { BackgroundTransparency = .2 } },
    }, Rift.Motion.Presets.Control, function() discarded += 1 end)
    Rift.Motion.transition(hub, "test-group", "vanish", {
        { Target = groupBox, Goals = { BackgroundTransparency = .75 } },
        { Target = nextBox, Goals = { BackgroundTransparency = .85 } },
    }, Rift.Motion.Presets.Control)
    R.groupState = Rift.Motion.getState(hub, "test-group") == "vanish"
    Rift.Motion.cancel(hub, "test-group")
    R.groupCancelled = Rift.Motion.getState(hub, "test-group") == nil
    local popupFrame = Instance.new("Frame")
    popupFrame.Size = UDim2.fromOffset(100, 70)
    hub:_openPopup(hub.Dock, popupFrame)
    hub:_closePopup()
    R.popupCancelled = Rift.Motion.getState(hub, "popup-position") == nil
    getgenv().__motionProbe = { Hub = hub, Tab = tab, Section = section,
        Box = box, R = R, Stale = function() return stale end,
        Completed = function() return completed end,
        Discarded = function() return discarded end }
]], "motion-interrupt")
frames(32)

host.run([[
    local p = getgenv().__motionProbe
    local R = p.R
    local hub = p.Hub
    R.panelRetained = hub._open == p.Tab and hub.PanelHolder.Visible
        and hub.Panel:IsA("Frame") and not hub.Panel:IsA("CanvasGroup")
    R.railSettled = hub._subTabRailVisible and hub._subTabRail.Visible
        and not hub._subTabAnimating and math.abs(hub._subTabRail.GroupTransparency) < .02
    R.sectionSettled = p.Section._rowsClip.AutomaticSize == Enum.AutomaticSize.Y
    R.sectionOpacitySettled = math.abs(p.Section._rowsClip.GroupTransparency) < .02
    R.layoutScheduledCompleted = hub._panelFitPending == false
    R.staleSkipped = p.Stale() == 0 and p.Discarded() == 0
    R.newCallback = p.Completed() == 1
    R.opacitySettled = math.abs(p.Box.BackgroundTransparency - .42) < .04
    hub:Close()
]], "motion-settled")
frames(32)
host.run([[
    local p = getgenv().__motionProbe
    local R = p.R
    local hub = p.Hub
    R.panelHidden = hub._open == nil and not hub.PanelHolder.Visible
    hub:Destroy()
]], "motion-final")
local R = sink.R
for _, key in { "panelState", "panelReopened", "sectionState",
    "railState", "railVisible", "latestState", "groupState",
    "groupCancelled", "popupCancelled", "panelRetained",
    "railSettled", "sectionSettled", "sectionOpacitySettled",
    "fastNavigation", "layoutScheduledCompleted", "staleSkipped",
    "newCallback", "opacitySettled", "panelHidden" } do
    check(R[key] == true, "unified motion: " .. key)
end
print(string.format("%d motion-state checks, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
