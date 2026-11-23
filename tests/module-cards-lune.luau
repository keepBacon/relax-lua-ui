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
    local lockedControl = sec:Button({
        Name = "Locked sample", Locked = true,
        LockReason = "Demo permission required",
        LockActions = { { Text = "Explain", KeepOpen = true }, { Text = "OK", Primary = true } },
    })
    R.lockedNative = lockedControl:IsLocked() and lockedControl:GetAvailability() == "Locked"
        and lockedControl._lockOverlay and lockedControl._lockOverlay.Visible
        and lockedControl._lockOverlay:FindFirstChild("LockPlate") ~= nil
    local lockPrompt = lockedControl:ShowLockReason()
    R.lockModal = lockPrompt and hub:_overlayTop().Kind == "Prompt"
        and lockPrompt.Body:FindFirstChild("Reason") ~= nil
    if lockPrompt then lockPrompt:Close() end
    lockedControl:SetAvailability("Available")
    R.unlockedNative = lockedControl:IsAvailable()
        and not lockedControl._lockOverlay.Visible
    lockedControl:SetLocked(true, "Changed reason")
    R.relockedNative = lockedControl:IsLocked()
        and select(2, lockedControl:IsAvailable()) == "Changed reason"
    local modalBounded = true
    for i = 1, 100 do
        lockedControl:SetLocked(true, "Reason " .. i)
        local dialog = lockedControl:ShowLockReason()
        local same = lockedControl:ShowLockReason()
        if dialog ~= same or #hub:GetOverlayStack() ~= 1 then
            modalBounded = false
        end
        if dialog then dialog:Close() end
        if #hub:GetOverlayStack() ~= 0 then modalBounded = false end
        lockedControl:SetLocked(false)
    end
    lockedControl:SetLocked(true, "Final reason")
    R.lockStress = modalBounded and lockedControl:IsLocked()
        and select(2, lockedControl:IsAvailable()) == "Final reason"
    local lastDialog = lockedControl:ShowLockReason()
    lockedControl:SetLocked(false)
    R.lockAutoDismiss = lastDialog and lastDialog.Closed
        and hub:_overlayTop() == nil and not lockedControl._lockOverlay.Visible
    lockedControl:SetLocked(true, "Reason after restore")

    local card = sec:ModuleCard({ Name = "Performance", Flag = "ModulePerformance",
        Default = false, Status = "Ready", Tone = "Success", Collapsed = true })
    local slider = card:Slider({ Name = "Render distance", Flag = "ModuleDistance",
        Min = 0, Max = 100, Default = 35 })
    local subgroup = card:Group({ Name = "Fine tuning", Open = false })
    local groupedSlider = subgroup:Slider({ Name = "Group slider", Flag = "ModuleGroupDistance",
        Min = 0, Max = 100, Default = 22 })
    -- Native regression: folded ∨ and opened ∧, consistent across sections
    -- and nested groups; use the actual published Instance tree.
    local function isArrow(arrow, opened)
        if not arrow then return false end
        if arrow:IsA("TextLabel") then
            if arrow.Name == "CollapseGlyph" then
                -- Primary Section keeps the same glyph and animates its angle.
                return arrow.Text == "∨"
                    and math.abs(arrow.Rotation - (opened and 180 or 0)) < 0.1
            end
            -- Nested Group retains its existing textual disclosure fallback.
            return arrow.Text == (opened and "∧" or "∨")
        end
        return math.abs(arrow.Rotation - (opened and 180 or 0)) < 0.1
    end
    sec:SetCollapsed(true, true)
    R.sectionDisclosure = isArrow(sec._chevron, false)
    sec:SetCollapsed(false, true)
    R.sectionDisclosure = R.sectionDisclosure and isArrow(sec._chevron, true)
    local groupHead = subgroup.Rows.Parent.Parent:FindFirstChild("GroupHead")
    local groupArrow = groupHead and (groupHead:FindFirstChild("Icon")
        or groupHead:FindFirstChild("GroupArrow"))
    subgroup:SetOpen(true, true)
    R.groupDisclosure = isArrow(groupArrow, true)
    subgroup:SetOpen(false, true)
    R.groupDisclosure = R.groupDisclosure and isArrow(groupArrow, false)
    local sectionLayout = sec.Rows:FindFirstChildOfClass("UIListLayout")
    local groupLayout = subgroup.Rows:FindFirstChildOfClass("UIListLayout")
    local cardLayout = card.Rows:FindFirstChildOfClass("UIListLayout")
    R.controlSpacing = sectionLayout and groupLayout and cardLayout
        and sectionLayout.Padding.Offset == 7 and groupLayout.Padding.Offset == 7
        and cardLayout.Padding.Offset == 7

    local dependent = card:ModuleCard({ Name = "Dependent", Id = "dependent",
        DependsOn = { Control = card, Equals = true, Behavior = "Disable" } })
    local child = card:ModuleCard({ Name = "Details", Id = "more", Collapsed = true,
        InheritParentState = true })
    local inner = child:Toggle({ Name = "Show details", Flag = "ModuleDetailsEnabled", Default = true })
    local grid = sec:InfoGrid({ Name = "Metrics", Items = {
        { Key = "fps", Label = "FPS", Value = 120 },
        { Key = "ping", Label = "Ping", Value = "25ms" },
    } })
    local details = sec:InfoList({ Name = "System", Items = {
        { Key = "theme", Label = "Theme", Value = "Graphite" },
    } })
    local eventStatus, eventFavorite = 0, 0
    local subStatus = card:OnDataEvent("Status", function(payload)
        if payload.Status == "Busy" then eventStatus += 1 end
    end)
    local subFavorite = card:OnDataEvent("Favorite", function() eventFavorite += 1 end)
    local infoEvents = 0
    local latestOp
    grid:OnDataEvent("Data", function(payload)
        infoEvents += 1
        latestOp = payload.Operation
    end)
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
    R.inheritedInitially = child:IsLocked() == true
    local visualSwitch = card.Head:FindFirstChild("ModuleSwitch")
    R.touchTarget = visualSwitch and visualSwitch.Size.X.Offset == 44
        and visualSwitch.Size.Y.Offset == 44
        and visualSwitch:FindFirstChild("ModuleSwitchTrack").Size.X.Offset == 34
    local favoriteHit = card.Head:FindFirstChild("Favorite")
    local expandHit = card.Head:FindFirstChild("ExpandAction")
    -- Chevron + favorite share the top row; switch is on the second row.
    -- Check actual touch rectangles rather than requiring a left-to-right sequence.
    local function bounds(node)
        local x = node.Position.X.Scale * card.Head.Size.X.Offset + node.Position.X.Offset
        local y = node.Position.Y.Scale * card.Head.Size.Y.Offset + node.Position.Y.Offset
        return x - node.Size.X.Offset, x, y - node.Size.Y.Offset / 2, y + node.Size.Y.Offset / 2
    end
    local function separated(a, b)
        local ax0, ax1, ay0, ay1 = bounds(a)
        local bx0, bx1, by0, by1 = bounds(b)
        return ax1 <= bx0 or bx1 <= ax0 or ay1 <= by0 or by1 <= ay0
    end
    R.touchNonoverlap = visualSwitch and favoriteHit and expandHit
        and favoriteHit.Size.X.Offset >= 40 and expandHit.Size.X.Offset >= 40
        and separated(visualSwitch, favoriteHit)
        and separated(visualSwitch, expandHit)
        and separated(favoriteHit, expandHit)
        and select(4, bounds(visualSwitch)) <= card.Head.Size.Y.Offset
    local statusPill = card.Head:FindFirstChild("ModuleStatusPill")
    local title = card.Head:FindFirstChild("ModuleTitle")
    local summary = card.Head:FindFirstChild("ModuleSummary")
    R.headerHierarchy = statusPill == nil and title and summary
        and title.Position.Y.Offset < summary.Position.Y.Offset
        and expandHit.Position.Y.Scale == .5 and expandHit.Position.Y.Offset < 0
        and visualSwitch.Position.Y.Scale == .5 and visualSwitch.Position.Y.Offset > 0
    local leadingIcon = card.Head:FindFirstChild("ModuleIcon")
    R.leadingGeometry = leadingIcon == nil or (
        leadingIcon.AnchorPoint.Y == .5 and leadingIcon.Position.Y.Scale == .5)
    R.leadingText = title.TextSize >= 16 and summary.TextSize >= 13
        and title.Position.X.Offset == summary.Position.X.Offset
    R.summaryWrapped = summary and summary.TextWrapped
        and summary.AutomaticSize == Enum.AutomaticSize.Y
        and summary.Position.X.Offset == title.Position.X.Offset
        and summary.Size.X.Offset == -summary.Position.X.Offset - 46
        and title.Size.X.Offset <= -96
    R.summaryClearOfActions = summary.Position.Y.Offset
        >= math.ceil(card.Head.Size.Y.Offset / 2 - 21 + 22)
    card:SetSummary("Long text that must wrap across multiple lines on mobile without overlapping the action row, title, or status.")
    R.summaryResized = card.Head.Size.Y.Offset >= 84
    R.summaryLongClearance = summary.Position.Y.Offset
        >= math.ceil(card.Head.Size.Y.Offset / 2 - 21 + 22)
    card:SetSummary("Module test")

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
    R.inheritedEnabled = not child:IsLocked()
    card:SetLocked(true)
    R.moduleLockVisual = card._lockOverlay and card._lockOverlay.Visible
        and card._lockOverlay.Parent == card.Frame
    R.inheritedLocked = child:IsLocked()
    card:SetLocked(false)
    R.inheritedUnlocked = not child:IsLocked()
    card:SetDependencyBlocked(true)
    R.inheritedDependency = child:IsLocked()
    card:SetDependencyBlocked(false)
    R.inheritedDependencyClear = not child:IsLocked()
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
    R.cardStatusEvent = eventStatus == 1 and card:GetStatus().Status == "Busy"
        and card:GetSummary() == "CPU load"
    R.cardFavoriteEvent = eventFavorite == 2
    card:SetStatus("Rechecking")
    R.statusTonePreserved = card:GetStatus().Status == "Rechecking"
        and card:GetStatus().Tone == "Warning"
    subFavorite:Disconnect()
    subStatus:Disconnect()
    local gridEventBefore = infoEvents
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
    R.infoBatchEvent = infoEvents == gridEventBefore + 2 and latestOp == "Batch"
    local fpsTile = grid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_fps")
    R.infoGetItem = grid:GetItem("fps").Value == "150" and grid:GetItem("absent") == nil
    R.infoBadOrder = grid:SetOrder({ "fps", "fps" }) == false
        and grid:Get()[1].Key == "fps"
    R.infoOrder = grid:SetOrder({ "ping", "fps" })
        and grid:Get()[1].Key == "ping"
        and grid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_fps") == fpsTile
    R.infoListOrder = details:SetOrder({ "theme" })
        and details:GetItem("theme").Value == "Slate"
    local beforeDuplicate = grid:Get()[1].Key
    R.infoDuplicate = not pcall(function()
        grid:Set({ { Key = "same", Value = 1 }, { Key = "same", Value = 2 } })
    end) and grid:Get()[1].Key == beforeDuplicate
    local stableGrid = grid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_fps")
    local stableList = details.Frame:FindFirstChild("InfoListPanel"):FindFirstChild("Detail_theme")
    R.strictAtomic = grid:UpdateMany({ fps = 180, bad = 2 }, true) == false
        and grid:GetItem("fps").Value == "150"
    R.strictValid = grid:UpdateManyStrict({ fps = 151, ping = "20ms" }) == 2
        and grid:GetItem("fps").Value == "151"
    R.listStrict = details:UpdateManyStrict({ theme = "Ink" }) == 1
        and details:GetItem("theme").Value == "Ink"
    grid:Upsert({ Key = "memory", Label = "Memory", Value = "196 MB" })
    details:Upsert({ Key = "runtime", Label = "Runtime", Value = "Ready" })
    R.keyedGrid = grid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_fps") == stableGrid
    R.keyedList = details.Frame:FindFirstChild("InfoListPanel"):FindFirstChild("Detail_theme") == stableList
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
    -- High-frequency live telemetry: 36 stable GUI rows, 90 full batches
    -- each for InfoGrid and InfoList (6,480 individual values).
    local sample = {}
    for i = 1, 36 do sample[i] = { Key = "metric" .. i, Value = i } end
    local loadGrid = sec:InfoGrid({ Name = "Load metrics", Columns = 3, Items = sample })
    local loadList = sec:InfoList({ Name = "Load details", Items = sample })
    local firstTile = loadGrid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_metric1")
    local firstLine = loadList.Frame:FindFirstChild("InfoListPanel"):FindFirstChild("Detail_metric1")
    local readsGrid, readsList = 0, 0
    local gridGet, listGet = loadGrid.Get, loadList.Get
    function loadGrid:Get()
        readsGrid += 1
        return gridGet(self)
    end
    function loadList:Get()
        readsList += 1
        return listGet(self)
    end
    local sampleBatch = {}
    for i = 1, 36 do sampleBatch["metric" .. i] = i end
    local applied = 0
    for i = 1, 90 do
        sampleBatch.metric1 = i
        applied += loadGrid:UpdateManyStrict(sampleBatch)
        applied += loadList:UpdateManyStrict(sampleBatch)
    end
    R.highFrequency = applied == 6480
        and loadGrid:GetItem("metric1").Value == "90"
        and loadList:GetItem("metric1").Value == "90"
    R.noUnobservedSnapshots = readsGrid == 0 and readsList == 0
    local observedGrid, observedList, observedSize = 0, 0, 0
    loadGrid:OnDataEvent("Data", function(event)
        if event.Operation == "Batch" then
            observedGrid += 1
            observedSize = #event.Items
        end
    end)
    loadList:OnDataEvent("Data", function(event)
        if event.Operation == "Batch" then observedList += 1 end
    end)
    loadGrid:UpdateManyStrict(sampleBatch)
    loadList:UpdateManyStrict(sampleBatch)
    R.perfBatchEvent = observedGrid == 1 and observedList == 1
        and observedSize == 36 and readsGrid == 1 and readsList == 1
    R.perfPoolStable = loadGrid.Frame:FindFirstChild("MetricGrid"):FindFirstChild("Metric_metric1") == firstTile
        and loadList.Frame:FindFirstChild("InfoListPanel"):FindFirstChild("Detail_metric1") == firstLine
        and #loadGrid.Frame:FindFirstChild("MetricGrid"):GetChildren() == 36
    local depChild = card:ModuleCard({ Name = "Temporary dependency", Id = "dep-temp",
        DependsOn = { Control = card, Equals = true } })
    local depsBefore = #(card._dependents or {})
    depChild.Frame:Destroy()
    R.dependencyCleanup = #(card._dependents or {}) == depsBefore - 1
    hub.SetupData.ModuleCards[sec.Id .. "/module/preferred"] = "expanded"
    local override = sec:ModuleCard({ Name = "Preferred", Id = "preferred", Collapsed = true })
    R.prefsLoad = override:IsExpanded()
    getgenv().__moduleTest = { hub = hub, tab = tab, card = card, slider = slider,
        groupedSlider = groupedSlider, subgroup = subgroup,
        old = old, child = child, inner = inner, R = R }
]], "module-card-test")
-- Stress interruptible fold motion and verify only the final state wins.
host.run([[
    local M = getgenv().__moduleTest
    local card = M.card
    for i = 1, 30 do
        card:SetExpanded(i % 2 == 0)
    end
    M.R.motionLastExpanded = card:IsExpanded()
    M.R.motionClipDuringClosing = true
    card:SetExpanded(false)
    local clip = card.Surface:FindFirstChild("ModuleClip")
    M.R.motionClipDuringClosing = clip ~= nil and clip.Visible
    card:SetExpanded(true)
]], "module-card-motion-stress")
frames(24)
host.run([[
    local M = getgenv().__moduleTest
    local clip = M.card.Surface:FindFirstChild("ModuleClip")
    M.R.motionSettled = clip and clip.Visible and M.card:IsExpanded()
        and clip.Size.Y.Offset >= 0
]], "module-card-motion-stress-verify")
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
    "reset", "oldPreserved", "destroyed", "cardStatusEvent",
    "cardFavoriteEvent", "statusTonePreserved", "infoBatchEvent", "infoGetItem", "infoBadOrder",
    "infoOrder", "infoListOrder", "infoDuplicate",
    "strictAtomic", "strictValid", "listStrict", "keyedGrid", "keyedList",
    "inheritedInitially", "inheritedEnabled", "inheritedLocked",
    "inheritedUnlocked", "inheritedDependency", "inheritedDependencyClear", "touchTarget",
    "touchNonoverlap", "headerHierarchy", "summaryWrapped", "summaryResized",
    "summaryClearOfActions", "summaryLongClearance",
    "leadingGeometry", "leadingText",
    "lockedNative", "lockModal", "unlockedNative", "relockedNative", "lockStress", "lockAutoDismiss", "moduleLockVisual", "highFrequency", "noUnobservedSnapshots",
    "perfBatchEvent", "perfPoolStable", "dependencyCleanup",
    "motionLastExpanded", "motionClipDuringClosing", "motionSettled",
    "sectionDisclosure", "groupDisclosure", "controlSpacing" } do
    check(sink.R[label], "modules: " .. label)
end
print(string.format("%d module-card runtime checks, %d engine errors", checks, #errors))
if #errors > 0 then process.exit(1) end
