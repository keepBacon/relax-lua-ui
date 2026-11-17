-- RelaxUI / RiftUI interactive showcase. Demo data only; no gameplay changes.
-- The DEMO key gate is intentionally retained for every launch.
-- Short loader: loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/p"))()
local SOURCE_BASE = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/"
local Rift = loadstring(game:HttpGet(SOURCE_BASE .. "public/RiftUI.luau"))()
Rift.AssetBase = SOURCE_BASE .. "public/"

local HUB_ID = "relaxui-preview"
local HUB_ICON = "sparkles"

---------------------------------------------------------------- key gate
-- A real gate sends the key to your server, which answers with the hub script:
--
--     local source = Rift:CreateAuth({ Name = "My Hub", Url = "https://auth.example.com/v1/script" })
--     if not source then return end
--     loadstring(source)()
--
-- This tour has no server, so Request stands in for one and the hub is built below.
local accepted = Rift:CreateAuth({
	Name = "RelaxUI Preview",
	Id = HUB_ID,
	HubIcon = HUB_ICON,
	Subtitle = "输入预览密钥继续 / Enter preview key",
	Note = "预览密钥 / Demo key: DEMO",
	Remember = false, -- keep the key page visible each time
	Request = function(key)
		task.wait(0.5) -- a server round trip
		if string.upper(key) == "DEMO" then return true, "-- your server would send the hub here" end
		return false, "Invalid key. The demo key is DEMO."
	end,
})
if not accepted then return end

-- Build inside xpcall so a mistake shows RiftUI's failure card instead of dying silently.
xpcall(function()

local Hub = Rift:CreateHub({
	Name = "RelaxUI Preview",
	Id = HUB_ID,
	Subtitle = "Latest feature tour",
	HubIcon = HUB_ICON,
	Language = "zh",
	ToggleKey = Enum.KeyCode.RightShift,
	CommandKey = Enum.KeyCode.F2,
	Watermark = true,
	KeybindList = true,
	-- the card stays up while the tabs below are built, then hands over to the toolbar
	Loading = { Manual = true, Subtitle = "Building the tour" },
	Requirements = {
		Roster = { Name = "Player list", Test = function()
			local ok, list = pcall(function() return game:GetService("Players"):GetPlayers() end)
			return ok and type(list) == "table", "This executor can't read the player list"
		end },
	},
	Translations = {
		zh = {
			["Controls"] = "控件", ["Text & data"] = "文本与数据", ["Live"] = "实时数据", ["People"] = "玩家", ["Hub"] = "功能",
			["Every input control"] = "交互控件总览", ["Multiline input, lists and logs"] = "多行输入、列表与日志",
			["Readouts fed by demo data"] = "演示数据驱动的实时组件", ["Player picker and requirements"] = "玩家选择与运行条件",
			["Windows, themes, configs and more"] = "窗口、主题、配置及其他功能",
			["Basics"] = "基础控件", ["More inputs"] = "更多输入", ["Click me"] = "点击测试",
			["Feature enabled"] = "启用功能", ["Strength"] = "强度", ["Smoothing"] = "平滑度",
			["Quality"] = "质量", ["Copies"] = "份数", ["Time window"] = "时间范围",
			["Look & feel"] = "外观和交互", ["Configs & pins"] = "配置与悬浮面板",
			["Test UI sound"] = "播放测试音效", ["UI sounds"] = "界面音效",
			["UI sound preset"] = "音效预设", ["UI sound volume"] = "音效音量",
			["Background preset"] = "背景预设", ["UI background"] = "UI背景", ["UI background opacity"] = "UI背景不透明度",
			["Background switching"] = "背景切换", ["Transition mode"] = "切换动画",
			["Background URL or file"] = "背景链接或文件", ["Apply background"] = "应用背景", ["Background opacity"] = "背景不透明度",
			["About the tour"] = "关于预览", ["Welcome to the tour"] = "欢迎体验 RelaxUI",
		},
		es = { ["Controls"] = "Controles", ["Text & data"] = "Texto y datos", ["Live"] = "En vivo", ["People"] = "Personas", ["Hub"] = "Hub" },
	},
	Setup = {
		Title = "Tune the tour",
		Description = "Shown once on first launch. Change these later in Settings.",
		Options = {
			{ Type = "Dropdown", Name = "Starting mode", Flag = "SetupMode", Options = { "Explore", "Build", "Practice" }, Default = "Explore" },
			{ Type = "Toggle", Name = "Start with demo data running", Flag = "SetupLive", Default = true },
		},
	},
})
local Flags = Rift.Flags

---------------------------------------------------------------- Controls
Hub:SetLoading("Adding controls", 0.15)
local Controls = Hub:Tab({ Name = "Controls", Icon = "sliders-horizontal", Description = "Every input control" })

local Basics = Controls:Section({ Name = "Basics", Side = "Left" })
local Status = Basics:Label("Nothing clicked yet.")
local clicks = 0
Basics:Button({ Name = "Click me", Description = "Updates the label above", Callback = function()
	clicks += 1
	Status:Set("Clicked " .. clicks .. (clicks == 1 and " time." or " times."))
end })
local Enabled = Basics:Toggle({ Name = "Feature enabled", Flag = "Enabled", Default = true, Description = "Turns the group below on and off" })
-- folds away while the toggle is off; its header still opens it by hand
local Tuning = Basics:Group({ Name = "Tuning", DependsOn = Enabled })
Tuning:Slider({ Name = "Strength", Flag = "Strength", Min = 0, Max = 100, Default = 40, Suffix = "%" })
Tuning:Slider({ Name = "Smoothing", Flag = "Smoothing", Min = 0, Max = 1, Step = 0.05, Default = 0.3, Description = "Hover any control with a description for help" })
Basics:Dropdown({ Name = "Mode", Flag = "Mode", Options = { "Explore", "Build", "Practice" }, Default = "Explore" })
Basics:Dropdown({ Name = "Layers", Flag = "Layers", Multi = true, Options = { "Grid", "Labels", "Outlines", "Shadows" }, Default = { "Grid", "Labels" } })

local More = Controls:Section({ Name = "More inputs", Side = "Right" })
More:Segmented({ Name = "Quality", Flag = "Quality", Options = { "Low", "Medium", "High" }, Default = "Medium" })
More:Stepper({ Name = "Copies", Flag = "Copies", Min = 1, Max = 8, Default = 2 })
More:RangeSlider({ Name = "Time window", Flag = "Window", Min = 0, Max = 60, Default = { 10, 30 }, Suffix = " s" })
More:Keybind({ Name = "Quick action", Flag = "QuickKey", Default = Enum.KeyCode.G, Mode = "Toggle", Callback = function(on)
	Hub:Notify({ Title = "Quick action", Content = on and "On" or "Off", Duration = 2 })
end })
More:Keybind({ Name = "Hold to preview", Flag = "PreviewKey", Default = Enum.KeyCode.H, Mode = "Hold" })
More:ColorPicker({ Name = "Highlight colour", Flag = "Highlight", Default = Color3.fromRGB(127, 178, 255) })

-- starts folded; click its header to open it, and the choice is remembered
local Extra = Controls:Section({ Name = "Folded by default", Side = "Right", Collapsed = true })
Extra:Input({ Name = "Profile name", Flag = "ProfileName", Placeholder = "Enter a name", Default = "Tour profile", MaxLength = 24 })
Extra:Input({ Name = "Seed", Flag = "Seed", Numeric = true, Default = "1234" })

---------------------------------------------------------------- Text & data
Hub:SetLoading("Adding text and lists", 0.35)
local Data = Hub:Tab({ Name = "Text & data", Icon = "database", Description = "Multiline input, lists and logs" })

local Notes = Data:Section({ Name = "Notes", Side = "Left" })
Notes:Input({
	Name = "Snippet",
	Flag = "Snippet",
	MultiLine = true,
	Lines = 6,
	Code = true,
	Default = 'print("Hello from the tour")\nfor i = 1, 3 do\n    print(i)\nend',
	Callback = function(text) print("Snippet is now " .. #string.split(text, "\n") .. " lines") end,
})
Notes:Paragraph({ Title = "Plain text", Content = "Paragraphs wrap to the column and grow with their content." })

local Bookmarks = Data:Section({ Name = "Bookmarks", Side = "Right" })
local Marks = Bookmarks:List({
	Name = "Saved spots",
	Columns = { "Name", "Note" },
	Widths = { 2, 3 },
	Items = { { "Lobby", "Where everyone spawns" }, { "Lookout", "Best view of the map" }, { "Garden", "Quiet corner" } },
	Removable = true,
	Placeholder = "No bookmarks yet",
	Callback = function(item) Hub:Notify({ Title = item[1], Content = item[2], Icon = "bookmark", Duration = 3 }) end,
	OnRemove = function(item) print("Removed bookmark", item[1]) end,
})
Bookmarks:Button({ Name = "Add bookmark", Callback = function()
	Marks:Add({ "Spot " .. (#Marks.Items + 1), "Added at " .. os.date("%H:%M:%S") })
end })
local Log = Bookmarks:Console({ Name = "Activity", Height = 110, MaxLines = 50 })
Log:Log("Tour started")

---------------------------------------------------------------- Live
Hub:SetLoading("Adding live widgets", 0.55)
local Live = Hub:Tab({ Name = "Live", Icon = "activity", Description = "Readouts fed by demo data" })
local Numbers = Live:Section({ Name = "Numbers", Side = "Left" })
local Coins = Numbers:Stat({ Name = "Coins", Default = 1200, Delta = true })
local Visitors = Numbers:Stat({ Name = "Visitors", Default = 0, Delta = true })
local Energy = Numbers:Progress({ Name = "Energy", Max = 100, Default = 70 })
local Steps = Numbers:Progress({ Name = "Steps", Max = 10, Default = 3, Segments = 5, Format = function(v, _, max) return v .. " / " .. max end })
local Running = Numbers:Toggle({ Name = "Run demo data", Flag = "LiveData", Default = true })
local Graphs = Live:Section({ Name = "Graphs", Side = "Right" })
local Fps = Graphs:Sparkline({ Name = "Frame rate", Suffix = " fps", Points = 40 })
local Rate = Graphs:Sparkline({ Name = "Coins per tick", Min = -50, Max = 150 })

---------------------------------------------------------------- People
Hub:SetLoading("Adding the player list", 0.7)
local People = Hub:Tab({ Name = "People", Icon = "users", Description = "Player picker and requirements" })
local Players = game:GetService("Players")
local function countPlayers()
	if not Hub._destroyed then People:SetBadge(#Players:GetPlayers()) end
end
Hub:Own(Players.PlayerAdded:Connect(countPlayers))
Hub:Own(Players.PlayerRemoving:Connect(function() task.defer(countPlayers) end))
countPlayers()
-- locked behind the Roster requirement until its test passes
local Pick = People:Section({ Name = "Pick someone", Requires = "Roster" })
Pick:PlayerPicker({ Name = "Player", Flag = "Player", Callback = function(p)
	Log:Log("Picked " .. (p and p.DisplayName or "nobody"))
end })
Pick:Button({ Name = "Say hello", Callback = function()
	local p = Flags.Player.Value
	Hub:Notify({ Title = p and ("Hello, " .. p.DisplayName) or "Pick a player first", Icon = "hand", Duration = 3 })
end })

---------------------------------------------------------------- Hub
Hub:SetLoading("Adding hub tools", 0.85)
local Tools = Hub:Tab({ Name = "Hub", Icon = "layout-grid", Description = "Windows, themes, configs and more" })

-- a child window with its own tabs, opened from a button, with a Discord button in its header
local About = Hub:Window({ Title = "About the tour", Description = "Community and credits", Icon = "info", Width = 520, Height = 360 })
local Credits = About:Tab({ Name = "Credits", Icon = "heart" })
Credits:Section({ Name = "Made with RiftUI" }):Paragraph({ Title = "Open source", Content = "RelaxUI is based on RiftUI (MPL-2.0). This preview only demonstrates UI controls." })
local Shortcuts = About:Tab({ Name = "Shortcuts", Icon = "keyboard" })
local Keys = Shortcuts:Section({ Name = "Keys" })
Keys:List({ Columns = { "Key", "Action" }, Selectable = false, Height = 110, Items = {
	{ "Right Shift", "Show or hide the toolbar" },
	{ "F2", "Search everything" },
	{ "G", "Quick action" },
	{ "H (hold)", "Preview" },
} })

local Windows = Tools:Section({ Name = "Windows & messages", Side = "Left" })
Windows:Button({ Name = "About the tour", Window = About })
Windows:Button({ Name = "Show a notification", Callback = function()
	Hub:Notify({ Title = "Saved", Content = "Hover to pause the timer, click to dismiss.", Icon = "check", Tone = Hub.Theme.Success })
end })
Windows:Button({ Name = "Reset values", Danger = true, Callback = function()
	Hub:Prompt({
		Title = "Reset the tour values?",
		Content = "Toggles, sliders and the mode go back to their defaults.",
		Buttons = {
			{ Text = "Cancel" },
			{ Text = "Reset", Primary = true, Callback = function()
				Flags.Enabled:Set(true)
				Flags.Strength:Set(40)
				Flags.Smoothing:Set(0.3)
				Flags.Mode:Set("Explore")
				Hub:Notify({ Title = "Values reset", Icon = "rotate-ccw", Duration = 3 })
			end },
		},
	})
end })
Windows:Button({ Name = "Search everything", Description = "Same as pressing F2", Callback = function() Hub:OpenCommandPalette() end })

local Look = Tools:Section({ Name = "Look & feel", Side = "Right" })
Look:Segmented({ Options = { "Graphite", "Ink", "Slate", "Ember" }, Default = Hub.ThemeName, Callback = function(name) Hub:SetTheme(name) end })
Look:Button({ Name = "Theme studio", Callback = function() Hub:OpenThemeStudio() end })
Look:Stepper({ Name = "Interface scale", Min = 0.8, Max = 1.2, Step = 0.1, Default = 1, Callback = function(v) Hub:SetScale(v) end })
local languageCodes = { ["简体中文"] = "zh", ["English"] = "en", ["Español"] = "es" }
Look:Dropdown({
	Name = "Language", Options = { "简体中文", "English", "Español" },
	Default = Hub.Language == "zh" and "简体中文" or Hub.Language == "es" and "Español" or "English",
	Callback = function(label) Hub:SetLanguage(languageCodes[label] or "en") end,
})
local audio = Hub:GetUISounds()
Look:Toggle({
	Name = "UI sounds", Default = audio.Enabled,
	Callback = function(on) Hub:SetUISounds({ Enabled = on }) end,
})
Look:Dropdown({
	Name = "UI sound preset", Options = { "Soft", "Minimal" }, Default = audio.Preset,
	Callback = function(preset)
		Hub:SetUISounds({ Preset = preset })
		Hub:PlayUISound("Select")
	end,
})
Look:Slider({
	Name = "UI sound volume", Min = 0, Max = 100, Step = 5,
	Default = math.floor(audio.Volume * 100 + 0.5), Suffix = "%",
	Callback = function(percent) Hub:SetUISounds({ Volume = percent / 100 }) end,
})
Look:Button({ Name = "Test UI sound", Callback = function() Hub:PlayUISound("Success") end })
local currentBackground = Hub:GetBackground()
Look:Dropdown({
	Name = "UI background", Options = Hub:ListBackgrounds(),
	Default = currentBackground and currentBackground.BackgroundPreset or "None",
	Callback = function(preset)
		local ok, reason = Hub:SetBackgroundPreset(preset)
		if not ok then Hub:Notify({ Title = "Background unavailable", Content = tostring(reason), Duration = 4 }) end
	end,
})
Look:Slider({
	Name = "UI background opacity", Min = 0, Max = 100, Step = 5,
	Default = math.floor((currentBackground and currentBackground.Opacity or 0.6) * 100 + 0.5),
	Suffix = "%",
	Callback = function(percent) Hub:SetBackgroundTransparency(1 - percent / 100) end,
})
-- AsterUI / FlowUI background-source switching, independent from the UI preset picker.
Look:Dropdown({
	Name = "Transition mode", Options = { "Crossfade", "Fade", "Instant" },
	Default = Hub:GetBackgroundTransition(),
	Callback = function(value) Hub:SetBackgroundTransition(value) end,
})
local switchSource = Look:Input({
	Name = "Background URL or file",
	Placeholder = "https://example.com/image.png or local/image.png",
	Default = "",
})
Look:Button({
	Name = "Apply background",
	Callback = function()
		local ok, reason = Hub:SwitchBackground(switchSource.Value)
		if not ok then Hub:Notify({ Title = "Background unavailable", Content = tostring(reason), Duration = 4 }) end
	end,
})
Look:Button({ Name = "Clear background", Callback = function() Hub:SwitchBackground(nil) end })
Look:Toggle({ Name = "Watermark", Default = true, Callback = function(on) Hub:SetWatermark(on) end })
Look:Toggle({ Name = "Keybind list", Default = true, Callback = function(on) Hub:SetKeybindList(on) end })

local Profiles = Tools:Section({ Name = "Configs & pins", Side = "Left" })
Profiles:Button({ Name = "Save config", Callback = function()
	local ok, err = Hub:SaveConfig("tour")
	Hub:Notify({ Title = ok and "Config saved" or "Couldn't save", Content = ok and "Saved as \"tour\"." or err, Duration = 3 })
end })
Profiles:Button({ Name = "Load config", Callback = function()
	local ok, err = Hub:LoadConfig("tour")
	Hub:Notify({ Title = ok and "Config loaded" or "Couldn't load", Content = ok and "Values restored." or err, Duration = 3 })
end })
Profiles:Button({ Name = "Copy share code", Callback = function()
	local code, err = Hub:ExportConfig("tour")
	if code and typeof(setclipboard) == "function" then setclipboard(code) end
	Hub:Notify({ Title = code and "Share code copied" or "Save a config first", Content = code and nil or err, Duration = 3 })
end })
local pinned = false
Profiles:Button({ Name = "Pin the numbers", Description = "Floats the Numbers section; drag its header", Callback = function()
	pinned = not pinned
	if pinned then Numbers:Pin(Vector2.new(24, 120)) else Numbers:Unpin() end
end })

---------------------------------------------------------------- demo data
task.spawn(function()
	local RunService = game:GetService("RunService")
	local frames, last, coins = 0, os.clock(), 1200
	Hub:Own(RunService.RenderStepped:Connect(function() frames += 1 end))
	while not Hub._destroyed do
		task.wait(1)
		if Hub._destroyed then break end
		local now = os.clock()
		Fps:Push(math.floor(frames / (now - last) + 0.5))
		frames, last = 0, now
		if Running.Value then
			local earned = math.random(-30, 120)
			coins += earned
			Coins:Update(coins)
			Rate:Push(earned)
			Energy:Set(math.clamp(Energy.Value + math.random(-10, 8), 5, 100))
			Steps:Set((Steps.Value + 1) % 11)
			if math.random() < 0.25 then
				Visitors:Update(Visitors.Value + 1)
				Log:Log("A visitor arrived")
			elseif earned < 0 then
				Log:Log("Spent " .. -earned .. " coins", "warn")
			end
		end
	end
end)

Hub:SetLoading("Ready", 1)
Hub:FinishLoading()
Hub:Notify({ Title = "Welcome to the tour", Content = "Open Look & feel for Chinese, Vanta sounds and animated backgrounds. F2 searches everything.", Icon = "sparkles", Duration = 6 })

end, Rift.HandleError)
