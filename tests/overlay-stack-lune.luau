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

-- Overlay stack / global input routing: real hub with native simulated GUI.
host.run([[
    local R = {}
    __sink(R)
    local Rift = loadstring(game:HttpGet("https://raw.githubusercontent.com/x/riftui/main/public/RiftUI.luau"))()
    local hub = Rift:CreateHub({ Name = "Overlay Test", Id = "overlay-test",
        Setup = false, Settings = false })
    local tab = hub:Tab({ Name = "Main", Icon = "layers" })
    local sub = tab:SubTab({ Name = "Child", Icon = "star" })
    local section = sub:Section({ Name = "UI" })
    section:Dropdown({ Name = "Mode", Options = { "A", "B" }, Default = "A" })
    hub:Open(tab)
    R.empty = #hub:GetOverlayStack() == 0
    -- Test priority rather than merely last-in ordering. A later low-z
    -- Window must never capture input above a visible Prompt.
    local front = Instance.new("Frame")
    front.Parent = hub.Gui
    local back = Instance.new("Frame")
    back.Parent = hub.Gui
    hub:_overlayRegister("Prompt", front, { Content = front })
    hub:_overlayRegister("Window", back, { Content = back })
    R.priority = hub:_overlayTop().Kind == "Prompt"
        and hub:GetOverlayStack()[1].Kind == "Window"
        and hub:GetOverlayStack()[2].Kind == "Prompt"
    hub:_overlayRegister("Window", back, { Content = back })
    R.deduplicate = #hub:GetOverlayStack() == 2
    local watch = hub:_overlayTop().DestroyConnection
    R.watching = watch ~= nil
    front:Destroy()
    R.autoRemoveFront = hub:_overlayTop().Kind == "Window"
    back:Destroy()
    R.autoRemoveBack = #hub:GetOverlayStack() == 0
    R.overlayVisualPriority = hub.Overlay.ZIndex == 98
    hub:_toggleSubTabs(tab)
    R.subtabOpen = #hub:GetOverlayStack() == 1
        and hub:_overlayTop().Kind == "SubTabs"
    R.subtabNativeShield = hub._subTabPointerShield ~= nil
        and hub._subTabPointerShield.Visible
        and hub._subTabPointerShield.Active
        and hub._subTabPointerShield.ZIndex < hub.DockHolder.ZIndex
    R.subtabEscape = hub:_routeOverlayKey(Enum.KeyCode.Escape)
        and #hub:GetOverlayStack() == 0 and not hub._subTabRailVisible
        and not hub._subTabPointerShield.Visible and hub._open == tab
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(104, 70)
    hub:_openPopup(hub.Dock, frame)
    R.popup = hub:_overlayTop().Kind == "Popup"
    local shield = hub._popup.Shield
    R.shield = shield ~= nil and shield.ClassName == "TextButton"
        and shield.Active and shield.Parent == hub.Overlay
        and hub._popup.Holder.ZIndex > shield.ZIndex
    local consumed = hub:_routeOverlayPointer(Vector2.new(-400, -400))
    R.outside = consumed and not hub._popup and #hub:GetOverlayStack() == 0
        and hub._open == tab
    R.shieldDisposed = shield.Parent == nil
    local popup2 = Instance.new("Frame")
    popup2.Size = UDim2.fromOffset(104, 70)
    hub:_openPopup(hub.Dock, popup2)
    hub:_closePopup()
    R.unregister = #hub:GetOverlayStack() == 0
    local huge = Instance.new("Frame")
    huge.Size = UDim2.fromOffset(1000, 700)
    hub:_openPopup(hub.Dock, huge)
    local oversized = hub._popup
    local vp = game.Workspace.CurrentCamera.ViewportSize / hub._scale
    R.popupViewport = oversized and oversized.Scroll
        and oversized.Scroll:IsA("ScrollingFrame")
        and oversized.Holder.Size.X.Offset <= math.max(48, vp.X - 12)
        and oversized.Holder.Size.Y.Offset <= math.max(48, vp.Y)
        and oversized.Scroll.CanvasSize.Y.Offset >= 700
    local popupConnections = oversized and oversized.RepositionConnections or {}
    hub:_closePopup()
    local released = true
    for _, connection in popupConnections do
        if connection.Connected then released = false end
    end
    R.popupRelease = released and #hub:GetOverlayStack() == 0
    -- Regression: an anchor below the floating dock must not be pulled up
    -- to the dock's top edge by global popup bounds clamping.
    local oldDockPosition = hub.DockHolder.Position
    local oldDockVisible = hub.DockHolder.Visible
    hub.DockHolder.Visible = true
    hub.DockHolder.Position = UDim2.new(.5, 0, .40, 0)
    local lowAnchor = Instance.new("Frame")
    lowAnchor.Name = "PopupLowerAnchor"
    lowAnchor.Position = UDim2.fromOffset(220, 420)
    lowAnchor.Size = UDim2.fromOffset(100, 28)
    lowAnchor.Parent = hub.Gui
    local anchoredMenu = Instance.new("Frame")
    anchoredMenu.Size = UDim2.fromOffset(160, 110)
    hub:_openPopup(lowAnchor, anchoredMenu, nil, { PreferBelow = true, Gap = 4 })
    local activePopup = hub._popup
    if activePopup then hub:_placePopup(activePopup, false) end
    local scale = math.max(hub._scale or 1, .01)
    local anchorBottom = (lowAnchor.AbsolutePosition.Y + lowAnchor.AbsoluteSize.Y) / scale
    R.popupBelowDock = activePopup ~= nil
        and activePopup.Holder.Position.Y.Offset >= anchorBottom + 3
        and activePopup.Holder.Position.Y.Offset + activePopup.Holder.Size.Y.Offset
            <= game.Workspace.CurrentCamera.ViewportSize.Y / scale - 7
    hub:_closePopup()
    lowAnchor:Destroy()
    hub.DockHolder.Position = oldDockPosition
    hub.DockHolder.Visible = oldDockVisible

    local win = hub:Window({ Title = "Window", Width = 300, Height = 220 })
    win:Open()
    R.window = win.IsOpen and hub:_overlayTop().Kind == "Window"
    hub:OpenCommandPalette()
    R.palette = hub._palette ~= nil and hub:_overlayTop().Kind == "CommandPalette"
    R.stackOrder = #hub:GetOverlayStack() == 2
        and hub:GetOverlayStack()[1].Kind == "Window"
        and hub:GetOverlayStack()[2].Kind == "CommandPalette"
    R.paletteEscape = hub:_routeOverlayKey(Enum.KeyCode.Escape)
        and hub._palette == nil and win.IsOpen
        and hub:_overlayTop().Kind == "Window"
    local prompt = hub:Prompt({ Title = "Confirm", Content = "Close?" })
    R.prompt = hub:_overlayTop().Kind == "Prompt"
    R.promptBlocked = hub:_routeOverlayPointer(Vector2.new(-300, -300))
        and hub:_overlayTop().Kind == "Prompt"
    R.promptEscape = hub:_routeOverlayKey(Enum.KeyCode.Escape)
        and hub:_overlayTop().Kind == "Window"
    local direct = hub:Prompt({ Title = "Quick", Content = "Direct close" })
    direct:Close()
    R.promptDirectClose = hub:_overlayTop().Kind == "Window"
    R.windowEscape = hub:_routeOverlayKey(Enum.KeyCode.Escape)
        and not win.IsOpen and hub:_overlayTop() == nil
    win:Open()
    win:Open()
    R.dedupe = #hub:GetOverlayStack() == 1
    R.windowOutside = hub:_routeOverlayPointer(Vector2.new(-300, -300))
        and hub:_overlayTop() == nil and not win.IsOpen
    hub:OpenCommandPalette()
    R.paletteExplicit = hub:_overlayTop().Kind == "CommandPalette"
    hub:CloseCommandPalette(true)
    R.paletteClear = hub:_overlayTop() == nil
    getgenv().__overlayProbe = { Hub = hub, R = R }
]], "overlay-stack-runtime")
frames(25)
host.run([[
    local p = getgenv().__overlayProbe
    local R, hub = p.R, p.Hub
    R.closePanelEscape = hub:_routeOverlayKey(Enum.KeyCode.Escape)
        and hub._open == nil
    R.clearNoop = not hub:_routeOverlayKey(Enum.KeyCode.Escape)
    hub:Destroy()
    R.destroyed = hub._destroyed and #hub:GetOverlayStack() == 0
]], "overlay-stack-teardown")
for _, key in { "empty", "priority", "deduplicate", "watching",
    "autoRemoveFront", "autoRemoveBack", "overlayVisualPriority",
    "subtabNativeShield", "subtabOpen", "subtabEscape", "popup",
    "outside", "shield", "shieldDisposed", "unregister", "popupViewport", "popupRelease", "popupBelowDock", "window", "palette", "stackOrder",
    "paletteEscape", "prompt", "promptBlocked", "promptEscape", "promptDirectClose",
    "windowEscape", "dedupe", "windowOutside", "paletteExplicit",
    "paletteClear", "closePanelEscape", "clearNoop", "destroyed" } do
    check(sink.R[key] == true, "overlay: " .. key)
end
print(string.format("%d overlay checks, %d runtime errors", checks, #errors))
if #errors > 0 then process.exit(1) end
