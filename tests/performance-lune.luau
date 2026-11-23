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

-- R5 stress benchmark: numbers are Lune emulation durations, never phone FPS.
host.run([[
    local R = {}
    __sink(R)
    local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = lib:CreateHub({ Name = "Perf Baseline", Id = "perf-baseline",
        Setup = false, Settings = false, Watermark = false })
    local page = hub:Tab({ Name = "Benchmark", Icon = "activity" })
    local section = page:Section({ Name = "Controls", Side = "Left" })
    local metrics = {}
    local function elapsed(t0)
        return math.floor(math.max(0, (os.clock() - t0) * 1000) * 100 + .5) / 100
    end
    local function addControls(from, to)
        for i = from, to do
            section:Toggle({ Name = "Benchmark Toggle " .. i,
                Default = i % 2 == 0 })
        end
    end

    local start = os.clock()
    addControls(1, 100)
    metrics.Create100Ms = elapsed(start)
    R.controls100 = #section.Controls == 100

    start = os.clock()
    addControls(101, 300)
    metrics.ExpandTo300Ms = elapsed(start)
    R.controls300 = #section.Controls == 300

    local rows = {}
    for i = 1, 1000 do
        rows[i] = { Id = "row" .. i, Name = "Job " .. i,
            Value = i, State = i % 11 == 0 and "Warning" or "Ready" }
    end
    local data = page:Section({ Name = "Large data", Side = "Right" })
    start = os.clock()
    local grid = data:DataTable({
        Name = "1000-row baseline", PageSize = 10,
        Columns = { { Key = "Name", Title = "Name", Width = 120 },
            { Key = "Value", Title = "Value", Width = 90 },
            { Key = "State", Title = "State", Width = 100 } },
        Rows = rows,
    })
    metrics.CreateTable1000Ms = elapsed(start)
    local tableRows = grid.Frame:FindFirstChild("TableShell")
        :FindFirstChild("HorizontalScroll"):FindFirstChild("WideContent")
        :FindFirstChild("TableRows")
    R.table1000 = #grid:Get() == 1000
    R.tableBounded = #tableRows:GetChildren() <= 14
    start = os.clock()
    local updated = grid:Update("row501", { Value = 9001 }, true)
    metrics.UpdateTableRowMs = elapsed(start)
    R.tableUpdate = updated and grid:Get()[501].Value == 9001

    start = os.clock()
    local tree = hub:GetVisualTreeSnapshot({ MaxNodes = 50, IncludeHidden = true })
    metrics.Snapshot50Ms = elapsed(start)
    R.inspectorBounded = tree ~= nil and #tree.Nodes == 50
        and tree.Truncated and tree.MaxNodes == 50

    start = os.clock()
    local stressOK = true
    for i = 1, 12 do
        hub:SetColorTheme(i % 2 == 0 and "Slate" or "Graphite")
        local dialog = hub:OpenActionDialog({
            Title = "Stress " .. i, Content = "Popup and theme lifecycle",
            Buttons = { { Text = "Close" }, { Text = "Apply", Primary = true } },
        })
        if not dialog then stressOK = false
        else dialog:Close() end
    end
    metrics.ThemeAndPopup12Ms = elapsed(start)
    R.popupStress = stressOK and hub:_overlayTop() == nil
    R.themeStable = hub:GetColorTheme() == "Slate"

    local events = 0
    local registered = hub:RegisterExtension("perf.lifecycle", {
        Version = "1.0.0",
        Start = function(owner, scope)
            scope:Own(owner:OnDeveloperEvent("perf.pulse", function(data)
                events += data.Value
            end))
        end,
    })
    R.registered = registered == true
    local initial = hub:GetDeveloperStats()
    R.initialOwners = initial.Extensions == 1
        and initial.Scopes == 1 and initial.Listeners == 1
    local initialHandles = hub:GetDeveloperResourceSnapshot()
    R.initialResources = initialHandles.ScopeCount == 1
        and initialHandles.ScopedHandles == 1
    R.Metrics = metrics -- preserve first five metrics if a later async rebuild yields
    R.ReinitStage = 0
    start = os.clock()
    local stable = true
    for i = 1, 3 do
        hub._quietReinit = true
        R.ReinitStage = i
        hub:Reinitialize()
        R.ReinitStage = -i
        local stats = hub:GetDeveloperStats()
        local retained = hub:GetDeveloperResourceSnapshot()
        if stats.Extensions ~= initial.Extensions
            or stats.Scopes ~= initial.Scopes or stats.Listeners ~= initial.Listeners
            or retained.ScopeCount ~= initialHandles.ScopeCount
            or retained.ScopedHandles ~= initialHandles.ScopedHandles then
            stable = false
        end
        hub:EmitDeveloperEvent("perf.pulse", { Value = 1 })
    end
    metrics.Reinitialize3Ms = elapsed(start)
    R.reinitializeStable = stable and events == 3
        and hub:GetDeveloperStats().Faults == 0
    -- Reinitialize restores the declared table model; dynamic row updates
    -- are not required to persist unless the consumer saves them explicitly.
    R.tablePreserved = #grid:Get() == 1000
    local activeControls = 0
    for _, activeTab in hub.Tabs do
        for _, activeSection in activeTab.Sections do
            if activeSection.Name == "Controls" then
                activeControls = #activeSection.Controls
            end
        end
    end
    R.controlsPreserved = activeControls == 300

    R.Metrics = metrics
    hub:Destroy()
    local final = hub:GetDeveloperStats()
    R.disposed = hub._destroyed and final.Extensions == 0
        and final.Scopes == 0 and final.Listeners == 0
    local released = hub:GetDeveloperResourceSnapshot()
    R.resourcesReleased = released.ScopeCount == 0
        and released.ScopedHandles == 0 and released.HubHandles == 0
]], "r5-performance-baseline")
frames(180) -- Reinitialize can yield on panel restore; finish all 3 cycles.
print("R5 reinitialize stage: " .. tostring(sink.R and sink.R.ReinitStage))

for _, name in { "controls100", "controls300", "table1000", "tableBounded",
    "tableUpdate", "inspectorBounded", "popupStress", "themeStable",
    "registered", "initialOwners", "initialResources", "reinitializeStable",
    "tablePreserved", "controlsPreserved", "disposed", "resourcesReleased" } do
    check(sink.R and sink.R[name], "r5-performance: " .. name)
end

local metrics = sink.R and sink.R.Metrics or {}
local metricRows = {}
for _, name in { "Create100Ms", "ExpandTo300Ms", "CreateTable1000Ms",
    "UpdateTableRowMs", "Snapshot50Ms", "ThemeAndPopup12Ms", "Reinitialize3Ms" } do
    local value = metrics[name]
    check(type(value) == "number" and value >= 0 and value < math.huge,
        "r5-metric: " .. name)
    metricRows[#metricRows + 1] = string.format('"%s":%.3f', name,
        type(value) == "number" and value or 0)
end
local report = '{\n'
    .. '  "schema": 1,\n'
    .. '  "environment": "Lune simulated Roblox GUI; NOT an Android FPS measurement",\n'
    .. '  "control_counts": [100, 300],\n'
    .. '  "table_rows": 1000,\n'
    .. '  "theme_popup_cycles": 12,\n'
    .. '  "reinitialize_cycles": 3,\n'
    .. '  "checks": ' .. tostring(checks) .. ',\n'
    .. '  "passed": ' .. tostring(#errors == 0) .. ',\n'
    .. '  "metrics_ms": {' .. table.concat(metricRows, ', ') .. '}\n'
    .. '}\n'
fs.writeFile("perf-baseline.json", report)
print(report)
print(string.format("%d R5 baseline assertions, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
