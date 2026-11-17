local url = "https://raw.githubusercontent.com/Snipez-Dev/Vantix/refs/heads/main/VantixUI6"

local VantixUI = loadstring(game:HttpGet(url))()

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local LP         = Players.LocalPlayer

local Window = VantixUI:CreateWindow({
	Title       = "Showcase",
	Theme       = "Vantix",
	AccentColor = Color3.fromRGB(255, 255, 255),
	LogoID      = 110034487018208,
	Size        = {820, 480},
})

Window:CreateTag("Beta",    Color3.fromRGB(240, 100, 100), nil, "flask-conical")
Window:CreateTag("Premium", Color3.fromRGB(255, 180, 50),  nil, "crown")
Window:CreateTag("v2.0",    Color3.fromRGB(60, 120, 210),  nil, "git-branch")
Window:CreateTag("discord.gg/GUXhJuaqsF", Color3.fromRGB(88, 101, 242), nil, nil, true)

Window:Notify({
	Title    = "Welcome",
	Text     = "Library loaded",
	Icon     = "check",
	Duration = 4,
})

local Flags = {}
local Panel, QuickBar, accentRow, minRow, keyRow, qFpsRow, qPingRow, zoomConn
local lastPing = "n/a"

local function toHex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
end

local MainTab = Window:AddTab("Main", "house")

-- created at the bottom of the tab, the callbacks below only use them later
local status, console

local godmode = MainTab:AddToggle({
	Title    = "God Mode",
	Subtitle = "Become invincible",
	Icon     = "shield",
	Default  = false,
	Risky    = "Changing MaxHealth gets picked up by a lot of anti-cheats. Use it on servers you trust.",
	Tooltip  = "Some anti-cheats flag this",
	Callback = function(state)
		Flags.GodMode = state
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.MaxHealth = state and math.huge or 100
			hum.Health = hum.MaxHealth
		end
		status:Set("Status: God Mode " .. (state and "on" or "off"))
		console:Write("God Mode " .. (state and "enabled" or "disabled"))
		Window:Notify({
			Title    = "God Mode",
			Text     = state and "Enabled" or "Disabled",
			Icon     = state and "shield-check" or "shield-off",
			Duration = 2,
		})
	end,
})

local autoFarm = MainTab:AddToggle({
	Title    = "Auto Farm",
	Subtitle = "Collects nearby items",
	Icon     = "flask-conical",
	Default  = false,
	Beta     = "Can miss items on some maps, still working on it.",
	Tooltip  = "Still in testing",
	Callback = function(state)
		Flags.AutoFarm = state
		console:Write("Auto Farm " .. (state and "enabled" or "disabled"))
		Window:Notify({
			Title    = "Auto Farm",
			Text     = state and "Enabled" or "Disabled",
			Icon     = state and "flask-conical" or "flask",
			Duration = 2,
		})
	end,
})

local walkspeed = MainTab:AddSlider({
	Title    = "Walk Speed",
	Icon     = "activity",
	Min      = 16,
	Max      = 200,
	Default  = 16,
	Tooltip  = "Applies instantly",
	Callback = function(value)
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = value end
	end,
})

-- every element also has a .Changed signal
walkspeed.Changed:Connect(function(value)
	if status then status:Set("Status: walk speed " .. value) end
end)

MainTab:AddButton({
	Title    = "Custom Button Label",
	Subtitle = "The button on the right says Press Me",
	Icon     = "mouse-pointer",
	Text     = "Press Me",
	Callback = function()
		console:Write("Custom button pressed")
		Window:Notify({Title="Pressed", Text="You pressed the button"})
	end,
})

MainTab:AddButton({
	Title    = "Rebuild Item Cache",
	Subtitle = "Rescans the map for items",
	Icon     = "refresh-cw",
	Text     = "Rebuild",
	Beta     = true,
	Tooltip  = "New scan, not tested on every map",
	Callback = function()
		console:Write("Item cache rebuilt")
		Window:Notify({Title="Item Cache", Text="Rebuilt", Duration=2})
	end,
})

MainTab:AddSeparator()

MainTab:AddToggleKey({
	Title    = "UI Toggle Key",
	Subtitle = "Key that hides / shows the window",
	Icon     = "keyboard",
})

MainTab:AddButton({
	Title    = "Reset Toggle Key",
	Subtitle = "Back to RightShift",
	Icon     = "rotate-ccw",
	Text     = "Reset",
	Callback = function()
		Window:SetToggleKey(Enum.KeyCode.RightShift)
		Window:Notify({Title="Toggle Key", Text="Reset to " .. Window:GetToggleKey().Name, Duration=2})
	end,
})

MainTab:AddSeparator()

status = MainTab:AddLabel("Status: idle", "activity")
console = MainTab:AddConsole({ Title = "Activity Log", Height = 110 })
console:Write("Showcase loaded")

local LocksTab = Window:AddTab("Locked Controls", "lock")
local lockState = LocksTab:AddLabel("Demo toggle: locked / off", "lock")
local lockedToggle
local function updateLockState()
	lockState:Set("Demo toggle: " .. (lockedToggle:IsLocked() and "locked" or "unlocked")
		.. " / " .. (lockedToggle:Get() and "on" or "off"))
end

-- Locked accepts true for the default message, or a string for a custom reason.
-- A locked toggle stays off even when Default is true or Set(true) is called.
lockedToggle = LocksTab:AddToggle({
	Title = "Locked Toggle",
	Subtitle = "Click to see the reason, or unlock it with the button below",
	Icon = "lock",
	Default = true,
	Locked = "This toggle is locked for the showcase. Click Unlock Demo Toggle to enable it.",
	Callback = function(state)
		Flags.LockedDemo = state
		console:Write("Demo toggle " .. (state and "enabled" or "disabled"))
		updateLockState()
	end,
})

LocksTab:AddButton({
	Title = "Locked Button",
	Subtitle = "Locked = true shows the default reason and blocks the callback",
	Icon = "lock",
	Text = "Try It",
	Locked = true,
	Callback = function()
		console:Write("This callback cannot run while the button is locked")
	end,
})

LocksTab:AddSeparator()
LocksTab:AddButton({
	Title = "Unlock Demo Toggle",
	Subtitle = "Unlock() makes the toggle available without turning it on",
	Icon = "lock-open",
	Text = "Unlock",
	Callback = function()
		lockedToggle:Unlock()
		updateLockState()
	end,
})
LocksTab:AddButton({
	Title = "Lock Demo Toggle",
	Subtitle = "Lock(reason) switches it off and restores the locked state",
	Icon = "lock",
	Text = "Lock",
	Callback = function()
		lockedToggle:Lock("The demo toggle was locked again. Use Unlock Demo Toggle to enable it.")
		updateLockState()
	end,
})

local VisualsTab = Window:AddTab("Visuals", "eye")

local espColor = VisualsTab:AddColorPicker({
	Title    = "ESP Color",
	Subtitle = "Color for player ESP",
	Icon     = "palette",
	Default  = Color3.fromRGB(255, 0, 0),
	Callback = function(color)
		Flags.ESPColor = color
	end,
})

VisualsTab:AddSeparator()

local materialDropdown = VisualsTab:AddDropdown({
	Title   = "Chams Material",
	Icon    = "box",
	Options = {
		"ForceField", "Neon", "Plastic", "Glass",
		"Wood", "Metal", "Ice", "Slate",
		"Marble", "Granite", "Sand", "Fabric",
		"Grass", "Cobblestone", "Brick", "Foil"
	},
	Default  = 1,
	Callback = function(selected)
		Flags.ChamsMaterial = selected
	end,
})

VisualsTab:AddSeparator()

local espElements = VisualsTab:AddMultiDropdown({
	Title    = "ESP Elements",
	Subtitle = "Pick what the ESP draws",
	Icon     = "layers",
	Options  = {"Names", "Boxes", "Bones", "Chams", "Tools", "Snaplines"},
	Default  = {"Names", "Boxes"},
	Callback = function(selected)
		Flags.ESPElements = selected
	end,
})

VisualsTab:AddSeparator()

VisualsTab:AddKeybind({
	Title    = "Toggle ESP",
	Subtitle = "Press to turn ESP on / off",
	Icon     = "crosshair",
	Default  = Enum.KeyCode.RightAlt,
	Callback = function()
		Flags.ESPEnabled = not Flags.ESPEnabled
	end,
})

-- keybinds take keyboard keys or middle mouse; without a Callback you read the key yourself with :Get()
local zoomKey = VisualsTab:AddKeybind({
	Title    = "Hold to Zoom",
	Subtitle = "Middle mouse by default",
	Icon     = "zoom-in",
	Default  = Enum.UserInputType.MouseButton3,
})

local function isHeld(key)
	if typeof(key) ~= "EnumItem" or key == Enum.KeyCode.Unknown then return false end
	if key.EnumType == Enum.UserInputType then return UIS:IsMouseButtonPressed(key) end
	return UIS:IsKeyDown(key)
end

local normalFov
zoomConn = RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if not cam then return end
	if isHeld(zoomKey:Get()) and not UIS:GetFocusedTextBox() then
		normalFov = normalFov or cam.FieldOfView
		cam.FieldOfView = 30
	elseif normalFov then
		cam.FieldOfView = normalFov
		normalFov = nil
	end
end)

local SettingsTab = Window:AddTab("Settings", "settings")

local themeNames = {}
for name in pairs(VantixUI.Themes) do
	table.insert(themeNames, name)
end
table.sort(themeNames)

SettingsTab:AddDropdown({
	Title    = "Theme",
	Icon     = "swatch-book",
	Options  = themeNames,
	Default  = Window:GetTheme(),
	Callback = function(selected)
		Window:SetTheme(selected)
	end,
})

SettingsTab:AddDropdown({
	Title    = "Accent Color",
	Icon     = "droplet",
	Options  = {"White", "Blue", "Red", "Green", "Purple"},
	Default  = "White",
	Callback = function(selected)
		local colors = {
			White  = Color3.fromRGB(255, 255, 255),
			Blue   = Color3.fromRGB(64, 156, 255),
			Red    = Color3.fromRGB(230, 70, 70),
			Green  = Color3.fromRGB(80, 210, 120),
			Purple = Color3.fromRGB(170, 110, 240),
		}
		VantixUI:SetAccentColor(colors[selected])
		Panel:SetTitle("Live Stats (" .. selected .. ")")
		accentRow:Set(toHex(VantixUI:GetAccentColor()))
	end,
})

SettingsTab:AddToggle({
	Title    = "Show Stats Panel",
	Icon     = "gauge",
	Default  = true,
	Callback = function(state)
		Panel:SetVisible(state)
	end,
})

SettingsTab:AddSeparator()

local configName = SettingsTab:AddTextBox({
	Title       = "Configuration Name",
	Icon        = "file-text",
	Placeholder = "Enter config name...",
	Default     = "ShowcaseConfig",
	Callback    = function(text, enterPressed)
		if enterPressed then
			Flags.ConfigName = text
		end
	end,
})

local uiKeybind = SettingsTab:AddKeybind({
	Title    = "Hide UI Keybind",
	Subtitle = "Insert hides the window (separate from the toggle key)",
	Icon     = "keyboard",
	Default  = Enum.KeyCode.Insert,
	Callback = function()
		-- the gui name is random, use the reference
		local sg = Window.Gui
		if sg then sg.Enabled = not sg.Enabled end
	end,
})

SettingsTab:AddSeparator()
SettingsTab:AddLabel("Config System", "save")

Window.ConfigManager:SetFolder("VantixUI_Examples")

local function buildConfig(name)
	local cfg = Window.ConfigManager:CreateConfig(name)
	cfg:RegisterElement("GodMode",       godmode)
	cfg:RegisterElement("WalkSpeed",     walkspeed)
	cfg:RegisterElement("ESPColor",      espColor)
	cfg:RegisterElement("ChamsMaterial", materialDropdown)
	cfg:RegisterElement("ESPElements",   espElements)
	cfg:RegisterElement("ConfigName",    configName)
	cfg:RegisterElement("UIKeybind",     uiKeybind)
	cfg:RegisterElement("ZoomKey",       zoomKey)
	return cfg
end

local savedConfigs = SettingsTab:AddDropdown({
	Title    = "Saved Configs",
	Icon     = "folder",
	Options  = Window.ConfigManager:GetConfigs(),
})

SettingsTab:AddButton({
	Title    = "Save Config",
	Icon     = "save",
	Text     = "Save",
	Callback = function()
		buildConfig(configName:Get()):Save()
		savedConfigs:SetOptions(Window.ConfigManager:GetConfigs())
		Window:Notify({Title="Config", Text="Saved as " .. configName:Get(), Duration=2})
	end,
})

SettingsTab:AddButton({
	Title    = "Load Selected",
	Icon     = "download",
	Text     = "Load",
	Callback = function()
		local name = savedConfigs:Get()
		if name and name ~= "" then
			configName:Set(name)
			buildConfig(name):Load()
			Window:Notify({Title="Config", Text="Loaded " .. name, Duration=2})
		end
	end,
})

SettingsTab:AddButton({
	Title    = "Delete Selected",
	Icon     = "trash-2",
	Text     = "Delete",
	Risky    = true,
	Tooltip  = "Deletes the config file",
	Callback = function()
		local name = savedConfigs:Get()
		if name and name ~= "" then
			Window.ConfigManager:DeleteConfig(name)
			savedConfigs:SetOptions(Window.ConfigManager:GetConfigs())
			Window:Notify({Title="Config", Text="Deleted " .. name, Duration=2})
		end
	end,
})

SettingsTab:AddSeparator()

SettingsTab:AddButton({
	Title    = "Minimize",
	Icon     = "minus",
	Text     = "Minimize",
	Callback = function() Window:Minimize() end,
})

SettingsTab:AddButton({
	Title    = "Restore",
	Icon     = "square",
	Text     = "Restore",
	Callback = function() Window:Restore() end,
})

SettingsTab:AddButton({
	Title    = "Toggle Window",
	Icon     = "repeat",
	Text     = "Toggle",
	Callback = function() Window:Toggle() end,
})

SettingsTab:AddButton({
	Title    = "Restore Stats Panel",
	Subtitle = "Show the stats panel and expand its body",
	Icon     = "panel-top",
	Text     = "Restore",
	Callback = function() Panel:Restore() end,
})

SettingsTab:AddButton({
	Title    = "Unload",
	Icon     = "log-out",
	Text     = "Unload",
	Callback = function()
		if zoomConn then zoomConn:Disconnect() end
		Panel:Destroy()
		QuickBar:Destroy()
		Window:Destroy()
	end,
})

Panel = VantixUI:CreateNewWindow({
	Title   = "Live Stats (White)",
	Name    = "ShowcaseStats",
	Size    = {240},
	Minimizable = true, -- opt in to the minus / plus button in the title bar
	OnClose = function() console:Write("Stats panel closed") end,
})
Panel:AddHeader("Session")
local fpsRow  = Panel:AddRow("FPS")
local pingRow = Panel:AddRow("Ping")
minRow = Panel:AddRow("Main Window Minimized")
keyRow = Panel:AddRow("Toggle Key")
Panel:AddSeparator()
Panel:AddHeader("Window")
accentRow = Panel:AddRow("Accent")
accentRow:Set(toHex(VantixUI:GetAccentColor()))
Panel:AddSeparator()
Panel:AddHeader("Player")
local posRow = Panel:AddRow("Position")
Panel:AddRow("Character", {
	Style         = "Vertical",
	AccentKey     = "white",
	ValueColorKey = "text",
}):Set(LP.Name)
Panel:AddSeparator()
Panel:AddHeader("Actions")
Panel:AddToggle("Show Quick Bar", true, function(on)
	QuickBar:SetVisible(on)
end)
Panel:AddButton("Clear activity log", function()
	console:Clear()
end)
Panel:AddButton("Minimize this panel", function()
	Panel:Minimize()
end)

-- Omit Minimizable (or set it to false) for the original close-only header.
QuickBar = VantixUI:CreateNewWindow({
	Title    = "Quick Bar",
	Layout   = "Horizontal",
	Position = UDim2.new(0, 20, 0, 88),
})
qFpsRow  = QuickBar:AddRow("FPS")
QuickBar:AddSeparator()
qPingRow = QuickBar:AddRow("Ping")
QuickBar:AddSeparator()
QuickBar:AddButton({ Text = "Log ping", Callback = function()
	console:Write("Ping: " .. lastPing)
end })

task.spawn(function()
	local Stats = game:GetService("Stats")
	local frames, last = 0, os.clock()
	while Panel.Card and Panel.Card.Parent do
		frames += 1
		local now = os.clock()
		if now - last >= 1 then
			fpsRow:Set(frames)
			qFpsRow:Set(frames)
			frames, last = 0, now
		end
		local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local p = root.Position
			posRow:Set(string.format("%d, %d, %d", p.X, p.Y, p.Z))
		end
		local ok, ping = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok then
			lastPing = string.format("%dms", ping)
			pingRow:Set(lastPing)
			qPingRow:Set(lastPing)
		end
		minRow:Set(Window:IsMinimized() and "Yes" or "No")
		local key = Window:GetToggleKey()
		keyRow:Set(key and key.Name or "None")
		RunService.Heartbeat:Wait()
	end
end)
