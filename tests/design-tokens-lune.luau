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
    local hub = Rift:CreateHub({ Name = "Token Tests", Id = "token-tests", Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Design" })
    local section = tab:Section({ Name = "Tokens" })
    local toggle = section:Toggle({ Name = "Legacy", Flag = "TokenLegacy", Default = true })
    local button = section:Button({ Name = "Inspect" })
    local tree = section:TreeView({ Name = "Feature tree", Id = "tree", Nodes = {
        { Id = "root", Label = "Root", Children = { { Id = "leaf", Label = "Leaf" } } },
    } })
    R.version = hub:GetToken("Version") == 2 and Rift.DesignTokensV2.Version == 2
    R.colors = hub:GetToken("Color.Surface0") == hub.Theme.Panel
        and hub:GetToken("Color.TextPrimary") == hub.Theme.Text
    R.geometry = hub:GetToken("Radius.XS") == 6
        and hub:GetToken("Radius.L") == 16 and hub:GetToken("Spacing.M") == 12
    R.typography = hub:GetToken("Typography.Head.Size") == 15
        and hub:GetToken("Typography.Body.Size") == 13
    R.states = hub:GetToken("State.Disabled.Opacity") == .55
        and hub:GetToken("State.Dragging.Text") == "Accent"
    R.motion = hub:GetToken("Motion.Panel.Duration") == .32
        and hub:GetMotionMode() == "Full"
    R.invalidPath = hub:GetToken("Foo.Bar") == nil
    local snap = hub:GetDesignTokens()
    snap.Radius.M = 900
    R.snapshot = hub:GetToken("Radius.M") == 12
    R.badColor = hub:SetToken("Color.Surface0", "not-a-color") == false
        and hub:GetToken("Color.Surface0") == hub.Theme.Panel
    R.badRadius = hub:SetToken("Radius.M", 9999) == false
        and hub:GetToken("Radius.M") == 12
    R.badField = hub:SetToken("Spacing.Unknown", 2) == false
    R.badMotion = hub:SetMotionMode("Wrong") == false
    R.badVersion = hub:SetDesignTokens({ Version = 3 }) == false
    R.atomic = hub:SetDesignTokens({ Spacing = { M = 18, Unknown = 4 } }) == false
        and hub:GetToken("Spacing.M") == 12
    local ok = hub:SetDesignTokens({
        Spacing = { M = 18 },
        Radius = { L = 20, M = 14 },
        Typography = { Body = { Size = 14 } },
        State = { Disabled = { Opacity = .65 } },
        Motion = { Mode = "Reduced", Control = { Duration = .13 } },
    })
    R.configure = ok and hub:GetToken("Spacing.M") == 18
        and hub:GetToken("Typography.Body.Size") == 14
        and hub:GetToken("Motion.Control.Duration") == .13
    R.shell = hub.Panel:FindFirstChildOfClass("UICorner").CornerRadius.Offset == 20
        and hub.Gui:GetAttribute("RelaxMotionMode") == "Reduced"
    R.independent = hub:GetControlTheme() == "Default" and toggle.Value == true
    hub:SetControlTheme("Rounded")
    R.rounded = hub:GetControlTheme() == "Rounded"
    hub:SetColorTheme("Slate")
    R.palette = hub:GetToken("Color.Surface0") == hub.Theme.Panel
        and hub:GetColorTheme() == "Slate"
        and hub:GetToken("Radius.L") == 20
    hub:SetToken("Color.Surface0", "#223344")
    R.override = hub.Panel.BackgroundColor3 == Color3.fromHex("#223344")
    hub:SetColorTheme("Ember")
    R.colorSurvives = hub:GetToken("Color.Surface0") == Color3.fromHex("#223344")
        and hub:GetToken("Color.Surface1") == hub.Theme.Field
    local custom = Instance.new("Frame")
    custom.Parent = hub.Gui
    local binding = hub:BindToken(custom, "BackgroundColor3", "Color.Surface2")
    hub:SetToken("Color.Surface2", "#334455")
    R.binding = binding and custom.BackgroundColor3 == Color3.fromHex("#334455")
    binding:Disconnect()
    hub:SetToken("Color.Surface2", "#445566")
    R.unbind = not binding.Connected
        and custom.BackgroundColor3 == Color3.fromHex("#334455")
    -- Rebinding the same property is deterministic and retires old handles.
    local oldOwner = hub:BindToken(custom, "BackgroundColor3", "Color.Surface1")
    local newOwner = hub:BindToken(custom, "BackgroundColor3", "Color.Surface2")
    hub:SetToken("Color.Surface2", "#556677")
    R.replaceBinding = oldOwner and newOwner and not oldOwner.Connected and newOwner.Connected
        and custom.BackgroundColor3 == Color3.fromHex("#556677")
    newOwner:Disconnect()
    local retainedBinding = hub:BindToken(custom, "BackgroundColor3", "Color.Surface0")
    R.invalidState = hub:ApplyTokenState(custom, "Unknown") == false
    R.state = hub:ApplyTokenState(custom, "Disabled")
        and custom.BackgroundTransparency > .3
    R.offSet = hub:SetMotionMode("Off")
        and hub.Gui:GetAttribute("RelaxMotionMode") == "Off"
    hub:TokenTween(custom, "Fast", { BackgroundTransparency = .2 })
    R.offMotion = custom.BackgroundTransparency == .2
    hub:SetMotionMode("Reduced")
    R.reduced = hub.Gui:GetAttribute("RelaxMotionMode") == "Reduced"
    local stateTarget = Instance.new("TextButton")
    stateTarget.Parent = hub.Gui
    local liveState = hub:BindTokenState(stateTarget, "Disabled")
    R.liveState = liveState and liveState.Connected and liveState:GetState() == "Disabled"
    hub:SetToken("Color.Surface1", "#324356")
    R.liveColor = stateTarget.BackgroundColor3 == Color3.fromHex("#324356")
    hub:SetToken("State.Disabled.Opacity", .7)
    R.liveOpacity = math.abs(stateTarget.BackgroundTransparency - .3) < .001
    R.badStateSwitch = liveState:SetState("Unknown") == false and liveState:GetState() == "Disabled"
    R.stateSwitch = liveState:SetState("Pressed")
        and liveState:GetState() == "Pressed"
        and stateTarget.BackgroundColor3 == hub:GetToken("Color.SurfaceActive")
    hub:SetColorTheme("Graphite")
    R.stateTheme = stateTarget.BackgroundColor3 == hub:GetToken("Color.SurfaceActive")
    hub:SetColorTheme("Ember")
    R.overrideInspection = hub:HasTokenOverride("Typography.Body.Size")
        and hub:GetTokenOverride("Typography.Body.Size") == 14
        and not hub:HasTokenOverride("Typography.Head.Size")
    R.resetNested = hub:ResetToken("State.Disabled.Opacity")
        and hub:GetToken("State.Disabled.Opacity") == .55
        and not hub:HasTokenOverride("State.Disabled.Opacity")
    R.resetSingle = hub:ResetToken("Color.Surface1")
        and hub:GetToken("Color.Surface1") == hub.Theme.Field
        and hub:GetToken("Color.Surface0") == Color3.fromHex("#223344")
        and not hub:HasTokenOverride("Color.Surface1")
    R.invalidReset = hub:ResetToken("Color.Bad") == false
        and hub:ResetToken("Color..Surface0") == false
    R.resetIdempotent = hub:ResetToken("Color.Surface1") == true
    -- Component tokens are nested, validated and live even with a dialog open.
    local catalog = hub:GetComponentTokens("Dialog")
    catalog.ButtonHeight = 999
    R.componentSnapshot = hub:GetComponentTokens("Dialog").ButtonHeight == 36
    R.componentAtomic = hub:SetDesignTokens({
        Components = { Dialog = { ButtonHeight = 42, Unsupported = 1 } },
    }) == false and hub:GetToken("Components.Dialog.ButtonHeight") == 36
    R.componentPatch = hub:SetToken("Components.Dialog.ButtonHeight", 42)
        and hub:GetToken("Components.Dialog.Width") == 382
        and hub:GetToken("Components.Dialog.ButtonHeight") == 42
    R.componentBad = hub:SetToken("Components.Dialog.BodyTransparency", 2) == false
    local dialog = hub:OpenActionDialog({
        Title = "Token fixture", Content = "Live styles",
        Buttons = { { Text = "Cancel" }, { Text = "Confirm", Primary = true } },
        ButtonLayout = "HorizontalRight",
    })
    local title = dialog.Card:FindFirstChild("Heading"):FindFirstChild("DialogTitle")
    local actions = dialog.Card:FindFirstChild("Actions")
    local firstAction = actions:FindFirstChild("Action_1")
    R.componentDialog = firstAction and firstAction.Size.Y.Offset == 42
        and title.TextSize == 15
    local divider = dialog.Card:FindFirstChild("Heading"):FindFirstChild("HeadingDivider")
    R.dialogVisual = divider ~= nil and divider.BackgroundTransparency > .5
    R.dialogLoading = dialog:SetLoading(true)
        and dialog.Loading and not firstAction.Active
        and firstAction.TextTransparency > 0
    R.dialogReady = dialog:SetLoading(false)
        and not dialog.Loading and firstAction.Active and firstAction.Text == "Cancel"
    local feedbackLabel = dialog.Card:FindFirstChild("Error")
    R.dialogSuccess = dialog:SetFeedback(true, "Saved")
        and feedbackLabel.Visible and feedbackLabel.Text == "Saved"
        and feedbackLabel.TextColor3 == hub:GetToken("Color.Success")
    R.dialogFailure = dialog:SetError("Retry")
        and feedbackLabel.Text == "Retry"
        and feedbackLabel.TextColor3 == hub:GetToken("Color.DialogErrorText")
    R.dialogContent = dialog:SetContent("Updated content") == nil
        and dialog.Body:FindFirstChild("Reason").Text == "Updated content"
    local updates = 0
    local watcher = hub:WatchDesignTokens(function() updates += 1 end)
    hub:SetDesignTokens({
        Typography = { DialogTitle = { Size = 19 } },
        Color = { DialogSurface = "#123456", DialogButtonText = "#BBDDEE" },
        Components = { Dialog = { ButtonHeight = 46, ButtonRadius = 13 } },
    })
    R.liveDialog = title.TextSize == 19
        and dialog.Card.BackgroundColor3 == Color3.fromHex("#123456")
        and firstAction.Size.Y.Offset == 46
        and firstAction.TextColor3 == Color3.fromHex("#BBDDEE")
        and firstAction:FindFirstChildOfClass("UICorner").CornerRadius.Offset == 13
        and updates > 0
    watcher:Disconnect()
    local captured = updates
    hub:SetToken("Typography.DialogTitle.Size", 18)
    R.watcherDisconnect = not watcher.Connected and updates == captured
    dialog:Close()
    R.dialogClosed = dialog.Closed and hub:_overlayTop() == nil
    hub:ResetToken("Components.Dialog.ButtonHeight")
    R.componentReset = hub:GetToken("Components.Dialog.ButtonHeight") == 36
        and hub:GetToken("Components.Dialog.Width") == 382


    -- Plugin-style custom components use the same atomically validated,
    -- persistent token system without affecting built-in component catalogs.
    local customDefaults = { Size = 18, Filled = false, Caption = "Badge",
        Tint = Color3.fromHex("#7399CC") }
    R.customRegister = hub:RegisterComponentTokens("Badge", customDefaults)
        and hub:GetToken("Components.Badge.Size") == 18
        and hub:GetToken("Components.Badge.Tint") == customDefaults.Tint
    local registered = hub:GetRegisteredComponentTokens()
    registered.Badge.Size = 999
    R.customIsolation = hub:GetToken("Components.Badge.Size") == 18
        and hub:GetComponentTokens("Dialog").Width == 382
        and hub:RegisterComponentTokens("Badge", customDefaults) == false
        and hub:RegisterComponentTokens("Dialog", customDefaults) == false
    R.customInvalidSchema = hub:RegisterComponentTokens("Invalid", {
        Nested = { Size = 5 }
    }) == false
    local changes = 0
    local seenValue
    local customWatch = hub:WatchToken("Components.Badge.Size", function(value)
        changes += 1
        seenValue = value
    end)
    local okCustom = hub:SetDesignTokens({ Components = { Badge = {
        Size = 24, Filled = true, Caption = "Live", Tint = "#BBAAFF",
    } } })
    R.customPatch = okCustom and hub:GetToken("Components.Badge.Filled") == true
        and hub:GetToken("Components.Badge.Caption") == "Live"
        and hub:GetToken("Components.Badge.Tint") == Color3.fromHex("#BBAAFF")
        and changes == 1 and seenValue == 24
    local beforeUnrelated = changes
    hub:SetToken("Spacing.S", 9)
    R.customScoped = changes == beforeUnrelated
    R.customAtomic = hub:SetDesignTokens({ Components = { Badge = {
        Size = 30, Unknown = 2,
    } } }) == false and hub:GetToken("Components.Badge.Size") == 24
    R.customOverride = hub:HasTokenOverride("Components.Badge.Size")
        and hub:GetTokenOverride("Components.Badge.Size") == 24
    R.customReset = hub:ResetToken("Components.Badge.Size")
        and hub:GetToken("Components.Badge.Size") == 18
        and changes == beforeUnrelated + 1
    customWatch:Disconnect()
    hub:SetToken("Components.Badge.Size", 27)
    R.customDisconnect = not customWatch.Connected and changes == beforeUnrelated + 1
    local customStored = hub:GetDesignTokenOverrides()
    R.customStorage = customStored.Components.Badge.Size == 27
        and customStored.Components.Badge.Tint == "#BBAAFF"
        and hub.Options.TokenComponents.Badge.Size == 18


    -- Developer SDK: owned cleanup order, fault-isolated local events and
    -- extension registration surviving a Reinitialize without double recipes.
    local cleanup = {}
    local manual = hub:CreateDeveloperScope("manual-check")
    manual:Defer(function() cleanup[#cleanup + 1] = "first" end)
    manual:Defer(function() cleanup[#cleanup + 1] = "second" end)
    local seen = 0
    local eventSub = hub:OnDeveloperEvent("sdk.tick", function(value)
        seen += value.Count
    end, manual)
    local emitted, delivered = hub:EmitDeveloperEvent("sdk.tick", { Count = 3 })
    R.sdkEvents = emitted and delivered == 1 and seen == 3
    R.sdkScopeReverse = manual:Close() and cleanup[1] == "second"
        and cleanup[2] == "first" and manual:Close() == false
    hub:EmitDeveloperEvent("sdk.tick", { Count = 5 })
    R.sdkScopeListeners = not eventSub.Connected and seen == 3
    local badListener = hub:OnDeveloperEvent("sdk.fault", function()
        error("expected isolated event failure")
    end)
    local faultOK, faultDelivered = hub:EmitDeveloperEvent("sdk.fault", {})
    badListener:Disconnect()
    R.sdkFaultIsolation = faultOK and faultDelivered == 0
        and #hub:GetDeveloperDiagnostics("Error") >= 1
    for i = 1, 86 do
        hub:ReportDeveloperDiagnostic("Info", "sdk.history", tostring(i))
    end
    local diagnostics = hub:GetDeveloperDiagnostics()
    R.sdkDiagnosticsBound = #diagnostics == 80 and diagnostics[1].Code == "sdk.history"
    diagnostics[1].Message = "changed"
    R.sdkDiagnosticsCopy = hub:GetDeveloperDiagnostics()[1].Message ~= "changed"
    hub:ClearDeveloperDiagnostics()
    R.sdkDiagnosticsClear = #hub:GetDeveloperDiagnostics() == 0
    local shared = { Starts = 0, Stops = 0, Disposals = 0, Received = 0 }
    local descriptor = {
        Version = "1.4.0",
        Start = function(targetHub, scope)
            shared.Starts += 1
            scope:Defer(function() shared.Disposals += 1 end)
            scope:Own(targetHub:OnDeveloperEvent("sdk.metric", function(payload)
                shared.Received += payload.Value
            end))
        end,
        Stop = function()
            shared.Stops += 1
        end,
    }
    local registered, detail = hub:RegisterExtension("demo.metric", descriptor)
    R.sdkRegister = registered and detail.State == "Active"
        and detail.Version == "1.4.0" and #hub:ListExtensions() == 1
    R.sdkDuplicate = hub:RegisterExtension("demo.metric", descriptor) == false
    local starting = hub:RegisterExtension("demo.broken", {
        Start = function() error("expected extension startup failure") end,
    })
    R.sdkRollback = starting == false and hub:GetExtension("demo.broken") == nil
        and hub:GetDeveloperStats().Extensions == 1
        and #hub:GetDeveloperDiagnostics("Error") >= 1
    hub:EmitDeveloperEvent("sdk.metric", { Value = 2 })
    R.sdkDelivery = shared.Received == 2
        and hub:GetDeveloperStats().Listeners == 1
        and hub:GetDeveloperStats().Scopes == 1
    getgenv().__sdkLifetime = shared
    getgenv().__tokenLifetime = { State = liveState, Property = retainedBinding }
    R.storage = hub.SetupData and hub.SetupData.DesignTokens
        and hub.SetupData.DesignTokens.Color.Surface0 == "#223344"
    local configSaved = hub:SaveConfig("tokens-v2")
    hub:SetToken("Spacing.M", 31)
    hub:LoadConfig("tokens-v2")
    R.config = configSaved and hub:GetToken("Spacing.M") == 18
        and hub:GetToken("Color.Surface0") == Color3.fromHex("#223344")
    R.tree = tree:GetState().Version == 1
    R.legacy = toggle.Value == true
    getgenv().__tokenTest = { R = R, Hub = hub }
]], "design-token-v2")
frames(12)

host.run([[
    local M = getgenv().__tokenTest
    local R, hub = M.R, M.Hub
    hub._quietReinit = true
    hub:Reinitialize()
    local held = getgenv().__tokenLifetime
    R.cleanupOnReinit = not held.State.Connected and not held.Property.Connected
    R.reinitialize = hub:GetToken("Radius.L") == 20
        and hub:GetToken("Spacing.M") == 18
        and hub:GetMotionMode() == "Reduced"
        and hub:GetControlTheme() == "Rounded"
        and hub:GetColorTheme() == "Ember"
    R.customReinitialize = hub:GetToken("Components.Badge.Size") == 27
        and hub:GetToken("Components.Badge.Tint") == Color3.fromHex("#BBAAFF")
        and hub:GetRegisteredComponentTokens().Badge.Size == 18

    local shared = getgenv().__sdkLifetime
    R.sdkReinitialize = shared.Starts == 2 and shared.Stops == 1
        and shared.Disposals == 1
        and hub:GetExtension("demo.metric") ~= nil
        and #hub:ListExtensions() == 1
    hub:EmitDeveloperEvent("sdk.metric", { Value = 4 })
    R.sdkReinitDelivery = shared.Received == 6
        and hub:GetDeveloperStats().Listeners == 1
    R.sdkRemove = hub:UnregisterExtension("demo.metric")
        and hub:GetExtension("demo.metric") == nil
        and shared.Stops == 2 and shared.Disposals == 2
        and hub:GetDeveloperStats().Extensions == 0
    local finalScope = hub:CreateDeveloperScope("shutdown-test")
    finalScope:Defer(function() shared.DestroyedScope = true end)
    R.reset = hub:ResetDesignTokens()
        and hub:GetToken("Radius.L") == 16
        and hub:GetToken("Color.Surface0") == hub.Theme.Panel
        and hub:GetMotionMode() == "Full"
    R.resetPersist = hub.SetupData.DesignTokens.Version == 2
        and hub.SetupData.DesignTokens.Color == nil
    hub:Destroy()
    R.destroyed = hub._destroyed
    R.sdkDestroy = shared.DestroyedScope and finalScope.Closed
]], "design-token-lifecycle")
frames(7)
for _, name in {
    "version", "colors", "geometry", "typography", "states", "motion",
    "invalidPath", "snapshot", "badColor", "badRadius", "badField",
    "badMotion", "badVersion", "atomic", "configure", "shell", "independent",
    "rounded", "palette", "override", "colorSurvives", "binding",
    "unbind", "invalidState", "state", "offSet", "offMotion", "reduced",
    "storage", "config", "tree", "legacy", "reinitialize", "reset",
    "resetPersist", "destroyed", "replaceBinding", "liveState",
    "liveColor", "liveOpacity", "badStateSwitch", "stateSwitch", "stateTheme",
    "overrideInspection", "resetNested", "resetSingle", "invalidReset",
    "resetIdempotent", "cleanupOnReinit", "componentSnapshot",
    "componentAtomic", "componentPatch", "componentBad", "componentDialog",
    "liveDialog", "watcherDisconnect", "dialogClosed", "componentReset",
    "dialogVisual", "dialogLoading", "dialogReady", "dialogSuccess",
    "dialogFailure", "dialogContent",
    "customRegister", "customIsolation", "customInvalidSchema", "customPatch",
    "customScoped", "customAtomic", "customOverride", "customReset",
    "customDisconnect", "customStorage", "customReinitialize",
    "sdkEvents", "sdkScopeReverse", "sdkScopeListeners", "sdkFaultIsolation",
    "sdkDiagnosticsBound", "sdkDiagnosticsCopy", "sdkDiagnosticsClear",
    "sdkRegister", "sdkDuplicate", "sdkRollback", "sdkDelivery",
    "sdkReinitialize", "sdkReinitDelivery", "sdkRemove", "sdkDestroy",
} do
    check(sink.R[name], "tokens-v2: " .. name)
end
print(string.format("%d Design Tokens v2 assertions, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
