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
    local hub = Rift:CreateHub({ Name = "P2 Controls", Id = "p2-controls", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Advanced", Icon = "layers" })
    local sec = tab:Section({ Name = "Controls" })
    local entries = {}
    for i = 1, 300 do entries[i] = "Entry " .. tostring(i) end
    local selectOne = sec:SearchSelect({
        Name = "Search", Flag = "P2Search", Options = entries, Default = "Entry 3",
    })
    R.searchInitial = selectOne:Get() == "Entry 3"
    selectOne:Set("Entry 200")
    R.searchSet = selectOne:Get() == "Entry 200"
    selectOne:SetOptions({ "Alpha", "Beta", "Gamma" })
    selectOne:Set("Beta")
    R.searchReplace = selectOne:Get() == "Beta"
    selectOne:SetOptions({ "Gamma", "Delta" })
    R.searchPruneSingle = selectOne:Get() == nil
    selectOne:Set("Gamma", true)
    selectOne:SetOptions({ "Gamma", "Epsilon" })
    R.searchKeepSingle = selectOne:Get() == "Gamma"
    local multi = sec:SearchSelect({ Name = "Multi", Flag = "P2Multi",
        Multi = true, Options = { "A", "B", "C" }, Default = { "A" } })
    multi:Set({ "A", "C" })
    local saved = multi:Get()
    R.searchMulti = saved.A and saved.C and not saved.B
    saved.C = nil
    R.searchIsolated = multi:Get().C == true
    multi:SetOptions({ "A", "D" })
    R.searchPruneMulti = multi:Get().A == true and multi:Get().C == nil
    multi:Set({ "D" }, true)
    multi:SetOptions({ "D", "E" })
    R.searchKeepMulti = multi:Get().D == true
    R.searchConfig = hub:_flagValues().P2Search ~= nil
        and hub:_flagValues().P2Multi ~= nil
    -- Popup alignment must remain close to both selection modes, rather
    -- than opening a 260px menu far to the left of a 150px field.
    local singlePane = selectOne:Open()
    local singlePopup = hub._popup
    R.searchPopupSingle = singlePane ~= nil and singlePopup ~= nil
        and singlePopup.Placement ~= nil
        and singlePopup.Placement.Align == "Center"
        and singlePopup.Placement.Gap == 3
        and singlePopup.Frame.Size.X.Offset == 176
    selectOne:_filter("Gamma")
    R.searchFilterFit = singlePane.Size.Y.Offset == 88
        and singlePopup.Placement.Align == "Center"
    selectOne:_filter("unmatched-search")
    R.searchEmptyFit = singlePane.Size.Y.Offset == 88
    selectOne:Close()
    local multiPane = multi:Open()
    local multiPopup = hub._popup
    R.searchPopupMulti = multiPane ~= nil and multiPopup ~= nil
        and multiPopup.Placement ~= nil
        and multiPopup.Placement.PreferBelow == true
        and multiPopup.Frame.Size.X.Offset == 176
    multi:Close()
    local menu = sec:ContextMenu({ Name = "More", Items = {
        { Id = "copy", Text = "Copy" },
        { Id = "nested", Text = "Nested", Children = {
            { Id = "child", Text = "Child" },
        } },
    } })
    local handle = menu:Open()
    R.menuOpen = handle and handle:IsOpen() and hub:_overlayTop().Kind == "Popup"
    R.menuPlacement = hub._popup and hub._popup.Placement
        and hub._popup.Placement.Align == "Left"
        and hub._popup.Placement.Gap == 3
    handle:SetItems({ { Id = "new", Text = "New" } })
    R.menuUpdate = handle.Items[1].Id == "new"
    handle:Close()
    R.menuClose = not handle:IsOpen() and hub:_overlayTop() == nil
    -- Bound gestures and direct binding APIs must share one availability
    -- gate; a denied attempt must never create a popup or overlay.
    local canOpen = false
    local gated = hub:BindContextMenu(menu.Trigger,
        { { Id = "gated", Text = "Gated" } }, {
        CanOpen = function() return canOpen end,
    })
    R.menuDenied = gated:Open() == nil and hub._popup == nil
        and hub:_overlayTop() == nil
    canOpen = true
    local gateOpen = gated:Open()
    R.menuAllowed = gateOpen and gateOpen:IsOpen()
    if gateOpen then gateOpen:Close() end
    gated:Disconnect()
    local lockedMenu = sec:ContextMenu({ Name = "Locked More", Locked = true,
        Items = { { Id = "never", Text = "Never run" } },
    })
    R.menuLocked = lockedMenu:IsLocked() and lockedMenu:Open() == nil
    local accordion = sec:Accordion({ Name = "FAQ", Single = false,
        Flag = "P2Accordion",
        Items = { { Id = "one", Title = "One", Content = "A" },
            { Id = "two", Title = "Two", Content = "Longer answer" } },
        Default = { one = true },
    })
    R.accordionDefault = accordion:IsExpanded("one") and not accordion:IsExpanded("two")
    R.accordionToggle = accordion:Expand("two") and accordion:IsExpanded("two")
        and accordion:IsExpanded("one")
    R.accordionCollapse = accordion:Collapse("one") and not accordion:IsExpanded("one")
    local snapshot = accordion:GetExpanded()
    snapshot.two = nil
    R.accordionIsolated = accordion:IsExpanded("two")
    R.accordionSet = accordion:Set({ one = true }) and accordion:IsExpanded("one")
        and not accordion:IsExpanded("two")
    R.accordionReplace = accordion:SetItems({ { Id = "new", Title = "New", Content = "Answer" } })
        and not accordion:IsExpanded("one")
    R.accordionConfig = hub:_flagValues().P2Accordion ~= nil
    R.accordionSearch = accordion:MatchesSearch("Answer")
        or accordion:MatchesSearch("New")
    accordion:SetItems({
        { Id = "a", Title = "Alpha", Content = "Some text" },
        { Id = "b", Title = "Beta", Content = "Unique needle" },
    })
    R.accordionMatch = accordion:MatchesSearch("needle")
        and accordion:MatchesSearch("Alpha")
        and not accordion:MatchesSearch("unmatched")
    accordion:Expand("a", true)
    accordion:_setSearchPeek(true, "needle")
    local rows = accordion.Frame:FindFirstChild("AccordionShell")
    local alphaClip = rows:FindFirstChild("Item_a"):FindFirstChild("AccordionClip")
    local betaClip = rows:FindFirstChild("Item_b"):FindFirstChild("AccordionClip")
    R.accordionSelective = not alphaClip.Visible and betaClip.Visible
    accordion:_setSearchPeek(false)
    R.accordionSearchRestore = alphaClip.Visible and not betaClip.Visible
        and accordion:GetExpanded().a == true and accordion:GetExpanded().b == nil
    accordion:Destroy()
    R.accordionDisposed = accordion._disposed
        and hub:_flagValues().P2Accordion == nil
        and table.find(sec.Controls, accordion) == nil
        and not accordion.Frame.Parent
    local inRecipe = false
    for _, step in hub._recipe do if step.Result == accordion then inRecipe = true end end
    R.accordionRecipeRemoved = not inRecipe
    local single = sec:Accordion({ Name = "Only one", Items = {
        { Id = "a", Title = "A", Content = "A" },
        { Id = "b", Title = "B", Content = "B" },
    } })
    single:Expand("a")
    single:Expand("b")
    R.accordionSingle = single:IsExpanded("b") and not single:IsExpanded("a")
    -- P2 expansion: actions, states, forms and Accordion API on native Luau.
    local actionsSeen = 0
    local action = sec:InlineAction({ Name = "Document", Actions = {
        { Id = "open", Text = "Open", Callback = function() actionsSeen += 1 end },
        { Id = "copy", Text = "Copy" },
        { Id = "delete", Text = "Delete", Locked = true, Reason = "Not allowed" },
    } })
    local acted = action:Trigger("open")
    R.inlineTrigger = acted == true and actionsSeen == 1 and action:Get() == "open"
    R.inlineLocked = action:Trigger("delete") == false
        and action:SetActionLocked("delete", false)
        and action:Trigger("delete") == true
    action:SetActions({ { Id = "refresh", Text = "Refresh" } })
    R.inlineUpdate = #action:GetActions() == 1 and action:Trigger("refresh") == true
    R.inlineOverflow = action.Frame:FindFirstChild("InlineRail") ~= nil
    local state = sec:EmptyState({ Name = "Network", Title = "Empty",
        Description = "No data", Action = { Text = "Retry", Callback = function() end } })
    R.emptyInitial = state:Get() == "Empty"
    state:SetLoading(true)
    R.emptyLoading = state:Get() == "Loading"
        and state.Frame:FindFirstChild("DataState")
            :FindFirstChild("SkeletonRows").Visible
    state:SetError("Offline")
    R.emptyError = state:Get() == "Error"
    local sk = sec:Skeleton({ Name = "Skeleton", Rows = 4 })
    R.skeleton = sk:Get() == "Loading"
    sk:SetLoading(false)
    R.skeletonStopped = sk:Get() == "Empty"
    local formSubmit, submittedValue = 0, nil
    local form = sec:Form({ Name = "Config", Flag = "P2Form",
        Fields = {
            { Id = "name", Name = "Name", Required = true,
                MinLength = 3, Default = "" },
            { Id = "count", Name = "Count", Type = "Number",
                Min = 1, Max = 10, Default = 2 },
            { Id = "enabled", Name = "Enabled", Type = "Toggle",
                Default = true },
            { Id = "mode", Name = "Mode", Type = "Select",
                Options = { "Basic", "Advanced" }, Default = "Basic" },
        },
        OnSubmit = function(values)
            formSubmit += 1
            submittedValue = values.name
            return true
        end,
    })
    local valid, fieldErrors = form:Validate()
    R.formRequired = valid == false and fieldErrors.name ~= nil
    form:Set({ name = "AB", count = "12" }, true)
    valid, fieldErrors = form:Validate()
    R.formRange = valid == false and fieldErrors.name ~= nil
        and fieldErrors.count ~= nil
    form:Set({ name = "Alice", count = "3" }, true)
    valid = form:Validate()
    R.formValid = valid == true
    R.formIsolated = form:GetValues().name == "Alice"
    local snapshot = form:GetValues()
    snapshot.name = "mutated"
    R.formIsolated = R.formIsolated and form:GetValues().name == "Alice"
    local submitted = form:Submit()
    R.formSubmit = submitted and submittedValue == "Alice" and formSubmit == 1
        and not form:IsDirty()
    form:Set({ name = "Later" }, true)
    R.formDirty = form:IsDirty()
    form:Reset(true)
    R.formReset = form:GetValues().name == "Alice" and not form:IsDirty()
    R.formConfig = hub:_flagValues().P2Form ~= nil
    form:Destroy()
    R.formDestroy = form._disposed and hub:_flagValues().P2Form == nil
    local extended = sec:Accordion({ Name = "Extended", Items = {
        { Id = "alpha", Title = "Alpha", Content = "Old" },
        { Id = "beta", Title = "Beta", Content = "Old" },
    }, Single = false })
    extended:ExpandAll(true)
    R.accordionExpandAll = extended:IsExpanded("alpha") and extended:IsExpanded("beta")
    extended:SetContent("alpha", "New")
    R.accordionContent = extended:MatchesSearch("New")
    extended:CollapseAll(true)
    R.accordionCollapseAll = not extended:IsExpanded("alpha")
        and not extended:IsExpanded("beta")
    state:Destroy()
    action:Destroy()
    R.newControlsDisposed = state._disposed and action._disposed

    -- Advanced control regression: actual component instances and public methods.
    local commandCalls = 0
    local commandBar = sec:AdaptiveCommandBar({
        Name = "Tools", FallbackWidth = 300,
        Commands = {
            { Id = "run", Text = "Run", Callback = function()
                commandCalls += 1
            end },
            { Id = "reset", Text = "Reset", Disabled = true },
            { Id = "inspect", Text = "Inspect" },
            { Id = "copy", Text = "Copy" },
        },
    })
    R.commandBuilt = commandBar.Frame:FindFirstChild("CommandSurface") ~= nil
        and #commandBar:GetCommands() == 4
    R.commandRun = commandBar:Run("run") and commandCalls == 1
        and commandBar:Get() == "run"
    R.commandDisabled = commandBar:Run("reset") == false
    commandBar:SetQuery("ins")
    R.commandSearch = commandBar:GetQuery() == "ins"
        and commandBar:Run("inspect") == true
    commandBar:SetCommands({ { Id = "only", Text = "One" } })
    R.commandReplace = #commandBar:GetCommands() == 1
        and commandBar:Run("only") == true
    local chart = sec:MiniChart({ Name = "FPS", Type = "Sparkline",
        Data = { 20, 40, 30 }, Capacity = 4, Min = 0, Max = 100 })
    R.chartStart = chart:GetType() == "Sparkline" and #chart:Get() == 3
        and chart.Frame:FindFirstChild("ChartSurface") ~= nil
    local snapshot = chart:Get()
    snapshot[1] = -42
    R.chartCopy = chart:Get()[1] == 20
    chart:Append(50)
    chart:Append(60)
    R.chartAppend = #chart:Get() == 4 and chart:Get()[1] == 40
        and chart:Get()[4] == 60
    local typesOk = true
    for _, kind in { "Bars", "Progress", "Ring", "Heatmap", "Sparkline" } do
        typesOk = typesOk and chart:SetType(kind) and chart:GetType() == kind
    end
    R.chartTypes = typesOk and chart:SetRange(0, 120)
    chart:SetData({})
    R.chartEmpty = #chart:GetData() == 0
    local registered = hub:RegisterWidgetPreset("Metrics", {
        Title = "Metrics", Widgets = {
            { Id = "signal", Type = "MiniChart", Options = {
                Name = "Signal", Type = "Bars", Data = { 10, 20 } } },
            { Id = "enable", Type = "Toggle", Options = {
                Name = "Enabled", Default = false } },
        },
    })
    R.presetRegistered = registered and hub:GetWidgetPreset("Metrics") ~= nil
        and #hub:ListWidgetPresets() >= 4
        and hub:RegisterWidgetPreset("Metrics", { Widgets = {} }) == false
    local preset = sec:UseWidgetPreset("Metrics", { FlagPrefix = "UnitMetrics" })
    R.presetBuilt = preset ~= nil and preset:GetWidget("signal") ~= nil
        and preset:GetWidget("enable") ~= nil
    R.presetUpdate = preset:SetValues({ signal = { 50, 35 }, enable = true }, true)
        and preset:Get().enable == true and preset:Get().signal[1] == 50
    R.presetUnknown = sec:UseWidgetPreset("NoSuchPreset") == nil
    preset:Destroy()
    R.presetDisposed = preset.Destroyed and preset:GetWidget("signal") == nil
        and hub:UnregisterWidgetPreset("Metrics") == true
    local inspector = hub:OpenVisualInspector()
    R.inspectorBuilt = inspector ~= nil and inspector.Window.IsOpen
        and #inspector.Targets > 0
    R.inspectorSelect = inspector:SelectTarget(chart.Frame) == true
    local visual = inspector:GetSnapshot()
    R.inspectorSnapshot = visual ~= nil and visual.Name == chart.Frame.Name
        and visual.Class == chart.Frame.ClassName
    if visual then visual.Name = "mutated" end
    R.inspectorIsolated = inspector:GetSnapshot().Name == chart.Frame.Name
    inspector:Close()
    R.inspectorClose = not inspector.Window.IsOpen
    inspector:Destroy()
    R.inspectorDispose = inspector.Destroyed and hub._visualInspector == nil
    commandBar:Destroy()
    chart:Destroy()
    R.advancedDisposed = commandBar._disposed and chart._disposed
    getgenv().__p2Probe = { Hub = hub, R = R }
]], "p2-controls-runtime")
frames(15)
host.run([[
    local probe = getgenv().__p2Probe
    local hub, R = probe.Hub, probe.R
    hub:Destroy()
    R.destroyed = hub._destroyed and hub:_overlayTop() == nil
]], "p2-controls-dispose")
for _, key in {
    "searchInitial", "searchSet", "searchReplace", "searchMulti",
    "searchIsolated", "searchConfig", "searchPopupSingle", "searchPopupMulti",
    "searchFilterFit", "searchEmptyFit", "menuPlacement",
    "searchPruneSingle", "searchKeepSingle", "searchPruneMulti", "searchKeepMulti",
    "menuOpen", "menuUpdate", "menuClose",
    "menuDenied", "menuAllowed", "menuLocked",
    "accordionDefault", "accordionToggle", "accordionCollapse",
    "accordionIsolated", "accordionSet", "accordionReplace",
    "accordionConfig", "accordionSingle", "accordionMatch", "accordionSelective",
    "accordionSearchRestore", "accordionDisposed", "accordionRecipeRemoved", "destroyed",
    "inlineTrigger", "inlineLocked", "inlineUpdate", "inlineOverflow",
    "emptyInitial", "emptyLoading", "emptyError", "skeleton", "skeletonStopped",
    "formRequired", "formRange", "formValid", "formIsolated", "formSubmit",
    "formDirty", "formReset", "formConfig", "formDestroy", "accordionExpandAll",
    "accordionContent", "accordionCollapseAll", "newControlsDisposed",
    "commandBuilt", "commandRun", "commandDisabled", "commandSearch", "commandReplace",
    "chartStart", "chartCopy", "chartAppend", "chartTypes", "chartEmpty",
    "presetRegistered", "presetBuilt", "presetUpdate", "presetUnknown", "presetDisposed",
    "inspectorBuilt", "inspectorSelect", "inspectorSnapshot", "inspectorIsolated",
    "inspectorClose", "inspectorDispose", "advancedDisposed",
} do
    check(sink.R and sink.R[key] == true, "p2: " .. key)
end
print(string.format("%d P2 checks, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
