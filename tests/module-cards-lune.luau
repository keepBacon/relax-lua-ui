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

-- Native Luau runtime tests for additive module/card information APIs.
host.run([[
    local R = {}
    __sink(R)
    local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = lib:CreateHub({ Name = "Module Test", Id = "modules-test", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Modules", Icon = "layers" })
    local sec = tab:Section({ Name = "Controls", Side = "Left" })
    local old = sec:Toggle({ Name = "Legacy toggle", Flag = "TestLegacy", Default = true })
    local card = sec:ModuleCard({ Name = "Performance", Flag = "ModulePerformance",
        Default = false, Status = "Ready", Tone = "Success", Collapsed = true })
    local slider = card:Slider({ Name = "Render distance", Flag = "ModuleDistance",
        Min = 0, Max = 100, Default = 35 })
    local subgroup = card:Group({ Name = "Fine tuning", Open = false })
    local groupedSlider = subgroup:Slider({ Name = "Group slider", Flag = "ModuleGroupDistance",
        Min = 0, Max = 100, Default = 22 })
    local dependent = card:ModuleCard({ Name = "Dependent", Id = "dependent",
        DependsOn = { Control = card, Equals = true, Behavior = "Disable" } })
    local child = card:ModuleCard({ Name = "Details", Id = "more", Collapsed = true })
    local inner = child:Toggle({ Name = "Show details", Flag = "ModuleDetailsEnabled", Default = true })
    local grid = sec:InfoGrid({ Name = "Metrics", Items = {
        { Key = "fps", Label = "FPS", Value = 120 },
        { Key = "ping", Label = "Ping", Value = "25ms" },
    } })
    local details = sec:InfoList({ Name = "System", Items = {
        { Key = "theme", Label = "Theme", Value = "Graphite" },
    } })
    hub:Open(tab)
    R.cards = card.Type == "ModuleCard" and card._isModuleCard
        and child._parentCard == card and child._isModuleCard
    local legacyGroup = sec:Group({ Name = "Legacy group" })
    R.old = old:Get() == true and old.Type == "Toggle"
        and type(sec.Slider) == "function" and type(legacyGroup.Slider) == "function"
    R.nested = slider.Section == card and inner.Section == child
        and #card._moduleControls >= 2 and #child._moduleControls >= 1
    R.config = hub:_flagValues().ModulePerformance ~= nil
        and hub:_flagValues().ModuleDistance ~= nil
        and hub:_flagValues().ModuleGroupDistance ~= nil
    R.groupParent = groupedSlider._moduleCard == card
        and groupedSlider.Section == subgroup
    R.dependencyInitial = dependent:IsLocked() == true
    R.startFolded = not card:IsExpanded()
    card:SetExpanded(true, true)
    child:SetExpanded(true, true)
    R.expand = card:IsExpanded() and child:IsExpanded()
    R.prefsExplicit = hub.SetupData.ModuleCards[card.Id] == "expanded"
    card:SetExpanded(false, true)
    R.prefsCollapsed = hub.SetupData.ModuleCards[card.Id] == "collapsed"
    card:_setSearchPeek(true)
    R.searchDoesNotPersist = card:IsExpanded() and not card:GetExpandedPreference()
        and hub.SetupData.ModuleCards[card.Id] == "collapsed"
    card:_setSearchPeek(false)
    card:SetExpanded(true, true)
    R.set = card:Set(true, true) and card:Get() == true
    R.dependencyRestored = not dependent:IsLocked()
    card:SetStatus("Busy", "Warning")
    card:SetSummary("CPU load")
    card:SetFavorite(true)
    R.favorite = card:IsFavorite() == true
    card:SetFavorite(false)
    R.favoriteCleared = card:IsFavorite() == false
    R.info = #grid:Get() == 2 and #details:Get() == 1
        and grid:Update("fps", 144, "Success") and details:Update("theme", "Ink")
    R.infoValue = grid:Get()[1].Value == "144" and details:Get()[1].Value == "Ink"
    local oldTile = grid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_fps")
    grid:Set({ { Key = "fps", Label = "FPS", Value = 146 },
        { Key = "ping", Label = "Ping", Value = "29ms" } })
    R.gridReused = oldTile == grid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_fps")
    grid:UpdateMany({ fps = 150, ping = { Value = "22ms", Tone = "Success" } })
    details:UpdateMany({ theme = { Value = "Slate", Tone = "Accent" } })
    R.batch = grid:Get()[1].Value == "150" and grid:Get()[2].Value == "22ms"
        and details:Get()[1].Value == "Slate"
    local copy = grid:Get()
    copy[1].Value = "modified outside"
    R.copyIsolated = grid:Get()[1].Value == "150"
    grid:Upsert({ Key = "memory", Label = "Memory", Value = "196 MB" })
    details:Upsert({ Key = "runtime", Label = "Runtime", Value = "Ready" })
    R.upsert = #grid:Get() == 3 and #details:Get() == 2
    grid:Remove("memory")
    details:Remove("runtime")
    R.remove = #grid:Get() == 2 and #details:Get() == 1
    hub:_applySearch("Render distance")
    R.search = card.Frame.Visible and slider.Frame.Visible and not child.Frame.Visible
        and card:IsExpanded()
    hub:_applySearch("")
    R.searchRestored = child.Frame.Visible and not card._searchPeek
    hub:_applySearch("Group slider")
    R.groupSearch = card.Frame.Visible and groupedSlider.Frame.Visible
        and not slider.Frame.Visible
    hub:_applySearch("")
    R.groupSearchRestored = card:GetExpandedPreference() == true
        and groupedSlider.Frame.Visible
    hub.SetupData.ModuleCards[sec.Id .. "/module/preferred"] = "expanded"
    local override = sec:ModuleCard({ Name = "Preferred", Id = "preferred", Collapsed = true })
    R.prefsLoad = override:IsExpanded()
    getgenv().__moduleTest = { hub = hub, tab = tab, card = card, slider = slider,
        groupedSlider = groupedSlider, subgroup = subgroup,
        old = old, child = child, inner = inner, R = R }
]], "module-card-test")
frames(18)
host.run([[
    local M = getgenv().__moduleTest
    local R = M.R
    M.slider:Set(93, true)
    M.groupedSlider:Set(99, true)
    M.card:Reset()
    R.reset = M.card:Get() == false and M.slider:Get() == 35
        and M.groupedSlider:Get() == 22
    R.oldPreserved = M.old:Get() == true
    M.hub:Destroy()
    R.destroyed = M.hub._destroyed
]], "module-card-teardown")
for _, label in { "cards", "old", "nested", "config", "groupParent", "dependencyInitial",
    "dependencyRestored", "startFolded", "expand", "prefsExplicit", "prefsCollapsed",
    "searchDoesNotPersist", "prefsLoad", "set", "favorite", "favoriteCleared",
    "info", "infoValue", "gridReused", "batch", "copyIsolated", "upsert", "remove",
    "search", "searchRestored", "groupSearch", "groupSearchRestored",
    "reset", "oldPreserved", "destroyed" } do
    check(sink.R[label], "modules: " .. label)
end
print(string.format("%d module-card runtime checks, %d engine errors", checks, #errors))
if #errors > 0 then process.exit(1) end
