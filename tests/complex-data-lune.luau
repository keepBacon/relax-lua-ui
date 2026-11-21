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

-- Native runtime coverage for complex data and optional viewport fallback.
host.run([[
    local R = {}
    __sink(R)
    local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = lib:CreateHub({ Name = "Complex Data", Id = "complex-data", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Advanced", Icon = "table" })
    local section = tab:Section({ Name = "Data", Side = "Left" })
    local original = section:Toggle({ Name = "Legacy", Flag = "DataLegacy", Default = true })
    local card = section:ModuleCard({ Name = "Complex module", Collapsed = false })
    local list = card:OrderList({
        Name = "Priority", Flag = "OrderTest", MaxVisible = 5,
        Items = {
            { Id = "a", Label = "A" },
            { Id = "b", Label = "B" },
            { Id = "locked", Label = "Critical", Disabled = true },
            { Id = "c", Label = "C" },
        },
    })
    R.orderStart = table.concat(list:GetOrder(), ",") == "a,b,locked,c"
    R.orderMove = list:Move("b", 1) and table.concat(list:GetOrder(), ",") == "b,a,locked,c"
    R.orderLocked = list:Move("locked", 1) == false
        and list:Move("a", 4) == false
        and table.concat(list:GetOrder(), ",") == "b,a,locked,c"
    R.orderReject = list:SetOrder({ "invalid" }) == false
        and table.concat(list:GetOrder(), ",") == "b,a,locked,c"
    R.orderSet = list:SetOrder({ "a", "b", "locked", "c" }, true)
        and table.concat(list:GetOrder(), ",") == "a,b,locked,c"
    local copy = list:GetOrder()
    copy[1] = "external"
    R.orderSnapshot = list:GetOrder()[1] == "a"
    list:SetItems({ "a", "locked", "c", "new" }, true)
    R.orderItems = table.concat(list:GetOrder(), ",") == "a,locked,c,new"
    R.orderConfig = hub:_flagValues().OrderTest ~= nil

    local grid = section:DataTable({
        Name = "Jobs", PageSize = 3,
        Columns = { { Key = "Name", Title = "Name", Width = 100 },
            { Key = "FPS", Title = "FPS", Width = 75, Align = "Right" },
            { Key = "State", Title = "State", Width = 95 } },
        Rows = { { Id = "a", Name = "Render", FPS = 100, State = "Ready" },
            { Id = "b", Name = "Input", FPS = 120, State = "Warning" },
            { Id = "c", Name = "Net", FPS = 80, State = "Ready" },
            { Id = "d", Name = "Audio", FPS = 105, State = "Idle" } },
    })
    R.gridStart = #grid:Get() == 4 and #grid:GetVisible() == 4
        and grid.Page == 1 and grid.Frame ~= nil
    R.gridCards = grid:SetLayoutMode("Cards")
        and grid:GetLayoutMode() == "Cards"
        and grid.Frame:FindFirstChild("TableShell"):FindFirstChild("CardRows").Visible
    local cards = grid.Frame:FindFirstChild("TableShell"):FindFirstChild("CardRows")
    R.gridCardPool = #cards:GetChildren() <= 3
    R.gridTableRestore = grid:SetLayoutMode("Table")
        and grid:GetLayoutMode() == "Table"
        and not cards.Visible
    R.gridBadLayout = grid:SetLayoutMode("Nope") == false
    R.gridAuto = grid:SetLayoutMode("Auto")
        and (grid:GetLayoutMode() == "Table" or grid:GetLayoutMode() == "Cards")
    R.gridSort = grid:SetSort("FPS", true)
        and grid:GetVisible()[1].Id == "b" and grid:GetVisible()[4].Id == "c"
    R.gridPage = grid:SetPage(2) and grid.Page == 2
    R.gridQuery = grid:SetQuery("Ready")
        and #grid:GetVisible() == 2 and grid:GetVisible()[1].Id == "a"
    R.gridUpsert = grid:Upsert({ Id = "e", Name = "Worker", FPS = 145, State = "Ready" }, true)
        and #grid:Get() == 5
    R.gridUpdate = grid:Update("a", { FPS = 144, State = "Warning" }, true)
        and grid:Get()[1].FPS == 144
    local operation
    local operationSub = grid:OnDataEvent("Data", function(payload)
        operation = payload.Operation
    end)
    grid:Update("a", { FPS = 143 }, false)
    R.gridUpdateEvent = operation == "Update" and grid:Get()[1].FPS == 143
    grid:Update("a", { FPS = 144 }, true)
    operationSub:Disconnect()
    R.gridRemove = grid:Remove("c", true) and #grid:Get() == 4
    R.gridSelect = grid:Select("a", true) and grid.SelectedId == "a"
    R.gridClearFilter = grid:SetQuery("") and #grid:GetVisible() == 4
    local exported = grid:Get()
    exported[1].FPS = -1
    R.gridSnapshot = grid:Get()[1].FPS == 144
    grid:SetLoading(true)
    R.gridLoading = grid.Loading == true
    grid:SetError("Offline")
    R.gridError = grid.Error == "Offline" and not grid.Loading
    grid:SetError(nil)

    local statuses = section:StatusList({
        Name = "States", MaxVisible = 3, Items = {
            { Id = "renderer", Label = "Renderer", State = "Healthy", Detail = "Stable" },
            { Id = "network", Label = "Network", State = "Warning", Detail = "High ping" },
            { Id = "storage", Label = "Storage", State = "Idle", Detail = "Ready" },
        },
    })
    R.statusStart = #statuses:Get() == 3 and statuses:Get()[1].Tone == "Success"
    R.statusUpdate = statuses:Update("network", { State = "Healthy", Detail = "Normal" })
        and statuses:Get()[2].Tone == "Success"
    R.statusUpsert = statuses:Upsert({ Id = "metrics", Label = "Metrics", State = "Ready" })
        and #statuses:Get() == 4
    statuses:SetFilter("Success")
    R.statusFilter = statuses.Filter == "Success"
    R.statusRemove = statuses:Remove("storage") and #statuses:Get() == 3
    statuses:SetLoading(true)
    R.statusLoading = statuses.Loading
    statuses:SetError("No connection")
    R.statusError = statuses.Error == "No connection" and not statuses.Loading
    statuses:SetError(nil)
    statuses:SetFilter("All")
    R.statusReset = statuses.Filter == "All"
    -- Stress the data model without rendering one GUI instance per record.
    local bulk = {}
    for i = 1, 750 do
        bulk[i] = { Id = "bulk" .. i, Name = "Work #" .. i,
            FPS = 60 + (i % 90), State = i % 9 == 0 and "Warning" or "Ready" }
    end
    grid:Set(bulk, true)
    local tableRows = grid.Frame:FindFirstChild("TableShell")
        :FindFirstChild("HorizontalScroll"):FindFirstChild("WideContent"):FindFirstChild("TableRows")
    R.largeTable = #grid:Get() == 750 and #tableRows:GetChildren() <= 3
    grid:Update("bulk401", { FPS = 143 }, true)
    R.largeTableUpdate = grid:Get()[401].FPS == 143
    local manyStates = {}
    for i = 1, 360 do
        manyStates[i] = { Id = "state" .. i, Label = "Service " .. i,
            State = i % 8 == 0 and "Warning" or "Healthy" }
    end
    statuses:Set(manyStates)
    local visibleStatus = statuses.Frame:FindFirstChild("StatusBox"):FindFirstChild("StatusRows")
    R.largeStatus = #statuses:Get() == 360 and #visibleStatus:GetChildren() <= 5
    statuses:Update("state240", { State = "Offline" })
    R.largeStatusUpdate = statuses:Get()[240].State == "Offline"
    -- EventTimeline: bounded records, filtering, pause and lifecycle.
    local events = section:EventTimeline({ Name = "Activity", MaxVisible = 3, MaxRecords = 10,
        Events = { { Id = "boot", Title = "Ready", Category = "Success", Time = "00:01" } },
    })
    R.timelineStart = #events:Get() == 1 and events:Get()[1].Id == "boot"
    R.timelineAppend = events:Append({ Id = "sync", Title = "Sync", Category = "Info" })
        and #events:Get() == 2
    events:SetPaused(true)
    events:Append({ Id = "paused", Title = "Queued", Category = "Warning" })
    R.timelinePause = events.Paused and #events:Get() == 3
    events:SetPaused(false)
    events:SetFilter("Warning")
    R.timelineFilter = events.Filter == "Warning"
    local buffer = {}
    for i = 1, 80 do
        buffer[i] = { Id = "event" .. i, Title = "Change " .. i, Category = "Debug" }
    end
    R.timelineBulk = events:Set(buffer) and #events:Get() == 10
        and events:Get()[1].Id == "event71"
    local visibleTimeline = events.Frame:FindFirstChild("TimelineShell"):FindFirstChild("TimelineScroll")
    R.timelinePool = #visibleTimeline:GetChildren() <= 5
    R.timelineRemove = events:Remove("event80") and #events:Get() == 9
    events:SetError("Offline")
    R.timelineError = events.Error == "Offline"
    events:SetError(nil)
    R.timelineClear = events:Clear() and #events:Get() == 0
    -- A false-valued cell must be found as false rather than by its numeric fallback.
    local booleans = section:DataTable({ Columns = { { Key = "Enabled", Title = "Enabled" } },
        Rows = { { Id = "disabled", Enabled = false, [1] = "fallback" } },
    })
    R.gridFalse = booleans:SetQuery("false") and #booleans:GetVisible() == 1
    booleans:Destroy()
    -- TreeView: deep hierarchy, stable selection, query and bounded GUI rows.
    local hierarchy = section:TreeView({ Name = "Hierarchy", MaxVisible = 3,
        Nodes = {
            { Id = "combat", Label = "Combat", Children = {
                { Id = "aim", Label = "Aim assist" },
                { Id = "esp", Label = "ESP", Disabled = true },
            } },
            { Id = "visual", Label = "Visual", Children = {
                { Id = "weather", Label = "Weather" },
            } },
        },
    })
    R.treeStart = #hierarchy:GetTree() == 2 and #hierarchy:GetVisible() == 5
    R.treeFold = hierarchy:SetExpanded("combat", false)
        and #hierarchy:GetVisible() == 3 and not hierarchy:GetExpanded("combat")
    R.treeSearch = hierarchy:SetQuery("aim")
        and #hierarchy:GetVisible() == 2 and hierarchy:GetVisible()[2].Id == "aim"
    hierarchy:SetQuery("")
    R.treePreserve = not hierarchy:GetExpanded("combat")
    R.treeExpand = hierarchy:ExpandAll() and #hierarchy:GetVisible() == 5
    R.treeDisabled = hierarchy:Select("esp") == false
    R.treeSelect = hierarchy:Select("aim", true) and hierarchy.SelectedId == "aim"
    R.treeUpdate = hierarchy:Update("aim", { Detail = "Active" })
        and hierarchy:GetTree()[1].Children[1].Detail == "Active"
    local snapshot = hierarchy:GetTree()
    snapshot[1].Children[1].Label = "mutated"
    R.treeSnapshot = hierarchy:GetTree()[1].Children[1].Label == "Aim assist"
    local failDup = pcall(function()
        hierarchy:SetNodes({ { Id = "dup" }, { Id = "dup" } })
    end)
    R.treeAtomic = not failDup and hierarchy:GetTree()[1].Id == "combat"
    R.treeRemove = hierarchy:Remove("weather")
        and #hierarchy:GetTree()[2].Children == 0
    local bulkTree = { { Id = "root", Label = "Root", Expanded = true, Children = {} } }
    for i = 1, 430 do
        bulkTree[1].Children[i] = { Id = "child" .. i, Label = "Child " .. i }
    end
    hierarchy:SetNodes(bulkTree)
    local treeRows = hierarchy.Frame:FindFirstChild("TreeShell"):FindFirstChild("TreeRows")
    R.treeBounded = #hierarchy:GetVisible() == 431 and #treeRows:GetChildren() <= 5
    -- Persist selection and expansion, restore named configurations and reject bad states.
    R.treeVersion = hierarchy:GetState().Version == 1
    hierarchy:SetExpanded("root", false)
    hierarchy:Select("child40", true)
    local savedTree = hierarchy:GetState()
    local storedTree = hub.SetupData.TreeStates and hub.SetupData.TreeStates[hierarchy.PersistKey]
    R.treePersist = storedTree and storedTree.Expanded.root == false
        and storedTree.SelectedId == "child40"
    R.treeNamedConfig = hub:_treeStateSnapshot()[hierarchy.PersistKey].SelectedId == "child40"
    R.treeRestore = hierarchy:SetState({ Expanded = { root = true }, SelectedId = "child1" }, true)
        and hierarchy:GetExpanded("root") and hierarchy:GetSelection() == "child1"
    hub:_restoreTreeStates({ [hierarchy.PersistKey] = savedTree })
    R.treeRestoreNamed = hierarchy:GetExpanded("root") == false
        and hierarchy:GetSelection() == "child40"
    local prior = hierarchy:GetState()
    local bad, reason = hierarchy:SetState({ Expanded = { root = "bad" } })
    R.treeStateReject = bad == false and reason ~= nil
        and hierarchy:GetState().Expanded.root == prior.Expanded.root

    -- Cross-component links: selected IDs, status filters and event feeds.
    local forward = hub:LinkData(hierarchy, grid, {
        Event = "Selection", Action = "Select",
        Map = function(id) return id and string.gsub(id, "child", "bulk") end,
    })
    local backward = hub:LinkData(grid, hierarchy, {
        Event = "Selection", Action = "Select",
        Map = function(id) return id and string.gsub(id, "bulk", "child") end,
    })
    local timelineLink = hub:LinkData(grid, events, {
        Event = "Selection", Action = "Append",
        Map = function(id) return id and { Title = "Selected " .. id, Category = "Info" } end,
    })
    local statusLink = hub:LinkData(statuses, grid, {
        Event = "Filter", Action = "SetQuery",
        Map = function(value) return value == "All" and "" or value end,
    })
    local linkedInfo = section:InfoGrid({ Items = {
        { Key = "fps", Value = "120" }, { Key = "status", Value = "Idle" },
    } })
    local linkedCard = section:ModuleCard({ Name = "Linked card", Toggle = true })
    local statusCard = section:ModuleCard({ Name = "Status card", Status = "Ready" })
    local statusLink = hub:LinkData(statusCard, linkedInfo, {
        Event = "Status", Action = "Update", Immediate = true,
        Map = function(s) return { Key = "status", Value = s.Status, Tone = s.Tone } end,
    })
    R.advancedImmediate = linkedInfo:GetItem("status").Value == "Ready"
    statusCard:SetStatus("Busy", "Warning")
    R.advancedStatus = linkedInfo:GetItem("status").Value == "Busy"
    local summaryLink = hub:LinkData(linkedInfo, linkedCard, {
        Event = "Data", Action = "SetSummary",
        Map = function(event)
            if event.Key == "fps" then return "FPS: " .. event.Item.Value end
            return nil
        end,
    })
    linkedInfo:Update("fps", 140)
    R.advancedSummary = linkedCard:GetSummary() == "FPS: 140"
    local valueLink = hub:LinkData(linkedCard, linkedInfo, {
        Event = "Value", Action = "Update",
        Map = function(value) return { Key = "fps", Value = value and 240 or 60 } end,
    })
    linkedCard:Set(true)
    R.advancedValue = linkedInfo:GetItem("fps").Value == "240"
    local batchEvents = 0
    linkedInfo:OnDataEvent("Data", function(e)
        if e.Operation == "Batch" then batchEvents += 1 end
    end)
    linkedInfo:UpdateMany({ fps = 145, status = "Healthy" })
    R.advancedBatch = batchEvents == 1
    statusLink:Disconnect()
    summaryLink:Disconnect()
    valueLink:Disconnect()
    R.advancedCleanup = not statusLink.Connected and not summaryLink.Connected and not valueLink.Connected
    -- A link across different primary and secondary tabs must keep updating
    -- its target while that page is not visible, without opening any panel.
    local dashboardTab = hub:Tab({ Name = "Dashboard remote", Icon = "layout-dashboard" })
    local remotePage = dashboardTab:SubTab({ Name = "Remote metrics", Icon = "activity" })
    local remoteSection = remotePage:Section({ Name = "Off-screen metrics" })
    local remoteInfo = remoteSection:InfoList({ Name = "Relay destination", Items = {
        { Key = "state", Value = "Unknown" },
    } })
    local remoteLink = hub:LinkData(statusCard, remoteInfo, {
        Event = "Status", Action = "Update", Immediate = true,
        Map = function(status)
            return { Key = "state", Value = status.Status, Tone = status.Tone }
        end,
    })
    R.remoteInitial = remoteInfo:GetItem("state").Value == "Busy"
        and dashboardTab ~= hub._open
    remoteLink:Pause()
    local skippedBefore = remoteLink:GetStats().Skipped
    statusCard:SetStatus("Delayed", "Warning")
    R.remotePaused = remoteInfo:GetItem("state").Value == "Busy"
        and remoteLink:GetStats().Skipped > skippedBefore
    R.remoteResume = remoteLink:Resume(true)
        and remoteInfo:GetItem("state").Value == "Delayed"
        and remoteLink:GetStats().Delivered >= 2
    local onlyWarnings = hub:LinkData(statusCard, remoteInfo, {
        Event = "Status", Action = "Update",
        Filter = function(status) return status.Tone == "Warning" end,
        Map = function(status) return { Key = "state", Value = status.Status } end,
    })
    local filteredBefore = onlyWarnings:GetStats().Skipped
    statusCard:SetStatus("Healthy", "Success")
    R.remoteFilter = remoteInfo:GetItem("state").Value == "Healthy"
        and onlyWarnings:GetStats().Skipped > filteredBefore
    -- Two links can update the same target, but a filtered link must not
    -- run its Map or modify its destination when the filter rejects it.
    local badLink = hub:LinkData(statusCard, remoteInfo, {
        Event = "Status", Action = "Update",
        Map = function() return { Key = "missing", Value = "nope" } end,
    })
    statusCard:SetStatus("Broken", "Danger")
    R.remoteError = badLink:GetStats().Errors == 1
        and type(badLink:GetStats().LastError) == "string"
    badLink:Disconnect()
    local fromListToCard = hub:LinkData(remoteInfo, linkedCard, {
        Event = "Data", Action = "SetSummary",
        Map = function(changes)
            if changes.Key == "state" and changes.Item then
                return "Remote: " .. changes.Item.Value
            end
        end,
    })
    remoteInfo:Update("state", "Running")
    R.remoteReverse = linkedCard:GetSummary() == "Remote: Running"
    fromListToCard:Disconnect()
    onlyWarnings:Disconnect()
    -- Destroying the off-screen target immediately disconnects its data link.
    remoteInfo.Frame:Destroy()
    R.remoteDisposed = not remoteLink.Connected
    R.remoteStats = remoteLink:GetStats().Connected == false
        and remoteLink:GetStats().Delivered >= 2
    -- Closed cycle must stop at the already-running link without mutating
    -- UI data indefinitely or exceeding bounded stack depth.
    local cycleA = section:ModuleCard({ Name = "Cycle A", Id = "cycle-a" })
    local cycleB = section:ModuleCard({ Name = "Cycle B", Id = "cycle-b" })
    local cycleC = section:ModuleCard({ Name = "Cycle C", Id = "cycle-c" })
    local ab = hub:LinkData(cycleA, cycleB, {
        Event = "Summary", Action = "SetSummary",
        Map = function(value) return value .. "B" end,
    })
    local bc = hub:LinkData(cycleB, cycleC, {
        Event = "Summary", Action = "SetSummary",
        Map = function(value) return value .. "C" end,
    })
    local ca = hub:LinkData(cycleC, cycleA, {
        Event = "Summary", Action = "SetSummary",
        Map = function(value) return value .. "A" end,
    })
    cycleA:SetSummary("go")
    R.linkCycle = ab:GetStats().Cycles >= 1 and ab:GetStats().Delivered == 1
        and cycleA:GetSummary() == "goBCA"
    R.linkCycleBounded = ab:GetStats().Overflow == 0
    ab:Disconnect(); bc:Disconnect(); ca:Disconnect()
    local subTarget = remoteSection:InfoList({ Name = "Subscription lifetime", Items = {
        { Key = "value", Value = "1" },
    } })
    local direct = subTarget:OnDataEvent("Data", function() end)
    subTarget.Frame:Destroy()
    R.directSubscriptionDispose = direct.Connected == false
    R.linkForward = hierarchy:Select("child71") and grid:GetSelection() == "bulk71"
    R.linkReverse = grid:Select("bulk90") and hierarchy:GetSelection() == "child90"
    R.linkTimeline = #events:Get() == 1 and events:Get()[1].Title == "Selected bulk90"
    statuses:SetFilter("Warning")
    R.linkFilter = grid.Query == "warning"
    statuses:SetFilter("All")
    R.linkUnfilter = grid.Query == ""
    local notifyCount = 0
    local sub = hierarchy:OnDataEvent("Selection", function() notifyCount += 1 end)
    hierarchy:Select("child91")
    sub:Disconnect()
    hierarchy:Select("child92")
    R.linkSubscription = notifyCount == 1
    local selectionBeforeUnlink = grid:GetSelection()
    forward:Disconnect()
    hierarchy:Select("child93")
    R.linkDisconnect = forward.Connected == false
        and grid:GetSelection() == selectionBeforeUnlink
    getgenv().__complexLinks = { Backward = backward, Timeline = timelineLink,
        Status = statusLink }
    R.touchSort = grid:SetLayoutMode("Cards")
        and grid.Frame:FindFirstChild("TableShell"):FindFirstChild("CardTools")
            :FindFirstChild("CardSort") ~= nil
    R.touchSortDirection = grid:SetSort("FPS", true)
        and grid.Frame:FindFirstChild("TableShell"):FindFirstChild("CardTools")
            :FindFirstChild("CardDirection").Text == "↓"
    grid:SetLayoutMode("Auto")
    local preview = section:ViewportPreview({
        Name = "Optional viewport", Interactive = true, Height = 160,
    })
    R.viewportSafe = preview ~= nil and preview.Type == "ViewportPreview"
        and type(preview.SetModel) == "function" and type(preview.Destroy) == "function"
        and preview:Get() == nil
    R.legacy = original:Get() and type(section.Slider) == "function"
    R.nested = list.Section == card and list._moduleCard == card
    getgenv().__complexTest = { Hub = hub, R = R, Order = list,
        Table = grid, Status = statuses, Timeline = events, Tree = hierarchy, Preview = preview }
]], "complex-data-construct")
frames(20)
host.run([[
    local M = getgenv().__complexTest
    M.Order:Destroy()
    M.Table:Destroy()
    M.Status:Destroy()
    M.Timeline:Destroy()
    M.Tree:Destroy()
    M.Preview:Destroy()
    M.R.destroyedControls = M.Order.Frame.Parent == nil and M.Table.Frame.Parent == nil
        and M.Status.Frame.Parent == nil and M.Timeline.Frame.Parent == nil and M.Tree.Frame.Parent == nil
        and M.Preview.Frame.Parent == nil
    local links = getgenv().__complexLinks
    M.R.linkDestroy = not links.Backward.Connected and not links.Timeline.Connected
        and not links.Status.Connected
    M.R.registryCleanup = M.Hub:_flagValues().OrderTest == nil
        and table.find(M.Order.Section.Controls, M.Order) == nil
        and table.find(M.Table.Section.Controls, M.Table) == nil
        and table.find(M.Status.Section.Controls, M.Status) == nil
        and table.find(M.Timeline.Section.Controls, M.Timeline) == nil
        and table.find(M.Tree.Section.Controls, M.Tree) == nil
        and table.find(M.Preview.Section.Controls, M.Preview) == nil
    M.Hub:Destroy()
    M.R.destroyedHub = M.Hub._destroyed
]], "complex-data-teardown")
-- Lifecycle stress: reinitialize reconstructs TreeView state AND data links.
host.run([[
    local R = getgenv().__complexTest.R
    local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = lib:CreateHub({ Name = "Rebuild complex", Id = "complex-rebuild", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Replay" })
    local section = tab:Section({ Name = "Replay controls", Side = "Left" })
    local tree = section:TreeView({ Id = "persistent-tree", Name = "Hierarchy", Nodes = {
        { Id = "root", Label = "Root", Children = { { Id = "item", Label = "Item" } } },
    } })
    local grid = section:DataTable({
        Name = "Rows", PageSize = 3,
        Columns = { { Key = "Name", Title = "Name" } },
        Rows = { { Id = "item", Name = "Item" } },
    })
    local link = hub:LinkData(tree, grid, { Event = "Selection", Action = "Select" })
    tree:SetExpanded("root", false)
    tree:Select("item", true)
    R.reinitBefore = tree:GetSelection() == "item"
        and not tree:GetExpanded("root") and link.Connected
    R.treeFlush = tree:FlushState() and not tree:FlushState()
        and hub.SetupData.TreeStates[tree.PersistKey].SelectedId == "item"
    hub._quietReinit = true
    hub:Reinitialize()
    R.reinitTree = tree:GetSelection() == "item"
        and not tree:GetExpanded("root") and not hub._destroyed
    tree:Select(nil, true)
    tree:Select("item")
    R.reinitLink = link.Connected and grid:GetSelection() == "item"
    -- Recreate with live metrics and card metadata; pause state and counters
    -- must survive, and original external link handle must remain functional.
    local liveInfo = section:InfoGrid({ Name = "Live metrics", Items = {
        { Key = "fps", Value = "20" },
    } })
    liveInfo:Update("fps", 144, "Success")
    local liveCard = section:ModuleCard({ Name = "Live card", Id = "live-card",
        Status = "Idle", Collapsed = true })
    liveCard:SetStatus("Healthy", "Success")
    liveCard:SetSummary("Running")
    liveCard:SetLocked(true)
    liveCard:SetFavorite(true)
    liveCard:SetExpanded(true, true)
    link:Pause()
    tree:Select(nil, true)
    tree:Select("item")
    local priorStats = link:GetStats()
    hub._quietReinit = true
    hub:Reinitialize()
    R.reinitLiveInfo = liveInfo:GetItem("fps").Value == "144"
        and liveInfo:GetItem("fps").Tone == "Success"
    R.reinitLiveCard = liveCard:GetStatus().Status == "Healthy"
        and liveCard:GetSummary() == "Running" and liveCard:IsLocked()
        and liveCard:IsFavorite() and liveCard:GetExpandedPreference()
    local afterStats = link:GetStats()
    print("REINIT LINK DEBUG before", tostring(priorStats.Connected), tostring(priorStats.Paused),
        tostring(priorStats.Skipped), tostring(priorStats.Delivered),
        "after", tostring(afterStats.Connected), tostring(afterStats.Paused),
        tostring(afterStats.Skipped), tostring(afterStats.Delivered),
        "source", tostring(tree:GetSelection()), "target", tostring(grid:GetSelection()))
    R.reinitPaused = link.Connected and link.Paused
        and link:GetStats().Skipped == priorStats.Skipped
        and link:GetStats().Delivered == priorStats.Delivered
    tree:Select(nil, true)
    local resumeOk, resumeErr = link:Resume(true)
    print("REINIT RESUME DEBUG", tostring(resumeOk), tostring(resumeErr),
        tostring(tree:GetSelection()), tostring(grid:GetSelection()))
    R.reinitResume = resumeOk and grid:GetSelection() == "item"
    tree:Select("item")
    R.reinitResumeLink = grid:GetSelection() == "item"
    link:Disconnect()
    tree:Select(nil)
    R.reinitUnlink = not link.Connected and grid:GetSelection() == "item"
    hub:Destroy()
    R.reinitCleanup = hub._destroyed
]], "complex-data-reinitialize")
frames(5)

for _, name in { "orderStart", "orderMove", "orderLocked", "orderReject",
    "orderSet", "orderSnapshot", "orderItems", "orderConfig", "gridStart",
    "gridCards", "gridCardPool", "gridTableRestore", "gridBadLayout", "gridAuto",
    "gridSort", "gridPage", "gridQuery", "gridUpsert", "gridUpdate",
    "gridUpdateEvent",
    "gridRemove", "gridSelect", "gridClearFilter", "gridSnapshot",
    "gridLoading", "gridError", "statusStart", "statusUpdate",
    "statusUpsert", "statusFilter", "statusRemove", "statusLoading",
    "statusError", "statusReset", "largeTable", "largeTableUpdate",
    "largeStatus", "largeStatusUpdate", "timelineStart", "timelineAppend",
    "timelinePause", "timelineFilter", "timelineBulk", "timelinePool",
    "timelineRemove", "timelineError", "timelineClear", "gridFalse",
    "treeStart", "treeFold", "treeSearch", "treePreserve", "treeExpand",
    "treeDisabled", "treeSelect", "treeUpdate", "treeSnapshot", "treeAtomic",
    "treeRemove", "treeBounded", "treeVersion", "treePersist",
    "treeNamedConfig", "treeRestore", "treeRestoreNamed", "treeStateReject",
    "linkForward", "linkReverse", "linkTimeline", "linkFilter", "linkUnfilter",
    "linkSubscription", "linkDisconnect", "linkDestroy",
    "advancedImmediate", "advancedStatus", "advancedSummary",
    "advancedValue", "advancedBatch", "advancedCleanup",
    "remoteInitial", "remotePaused", "remoteResume", "remoteFilter",
    "remoteError", "remoteReverse", "remoteDisposed", "remoteStats",
    "linkCycle", "linkCycleBounded", "directSubscriptionDispose",
    "touchSort", "touchSortDirection", "reinitBefore", "treeFlush",
    "reinitTree", "reinitLink", "reinitUnlink", "reinitCleanup",
    "reinitLiveInfo", "reinitLiveCard", "reinitPaused",
    "reinitResume", "reinitResumeLink",
    "viewportSafe", "legacy", "nested",
    "destroyedControls", "registryCleanup", "destroyedHub" } do
    check(sink.R[name], "complex-data: " .. name)
end
print(string.format("%d complex-data checks, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
