local WindUI = {
	Name = "VantaUI",
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	SoundManager = require("./modules/SoundManager"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.12,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,

	CreateWindow = nil,

	CurrentInput = nil,
}

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

WindUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

function WindUI.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

local CurInput = WindUI.GenerateGUID()

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	--[[if GameProcessed then
		return
	end]]

	task.defer(function()
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			if WindUI.CurrentInput and WindUI.CurrentInput ~= CurInput then
				return
			end

			WindUI.CurrentInput = CurInput
			--print(CurInput)
			--WindUI.InputStartedOnUI = false
		end
	end)
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessed)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		if WindUI.CurrentInput and WindUI.CurrentInput ~= CurInput then
			return
		end

		WindUI.CurrentInput = nil
	end
end)

local LocalPlayer = Players.LocalPlayer or nil

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	WindUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = WindUI.Creator

local New = Creator.New

--local Tween = Creator.Tween
--local ServicesModule = WindUI.Services

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = gethui and gethui() or (CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local TOP_DISPLAY_ORDER = 1000000
local SetHiddenProperty = sethiddenproperty or sethiddenprop

local function KeepScreenGuiOnTop(ScreenGui, DisplayOrder)
	ScreenGui.DisplayOrder = DisplayOrder

	if SetHiddenProperty then
		pcall(SetHiddenProperty, ScreenGui, "OnTopOfCoreBlur", true)
	end
end

local UIScaleObj = New("UIScale", {
	Scale = WindUI.UIScale,
})

WindUI.UIScaleObj = UIScaleObj

WindUI.ScreenGui = New("ScreenGui", {
	Name = "VantaUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = TOP_DISPLAY_ORDER,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

WindUI.NotificationGui = New("ScreenGui", {
	Name = "VantaUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	DisplayOrder = TOP_DISPLAY_ORDER + 3,
})
WindUI.DropdownGui = New("ScreenGui", {
	Name = "VantaUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	DisplayOrder = TOP_DISPLAY_ORDER + 2,
})
WindUI.TooltipGui = New("ScreenGui", {
	Name = "VantaUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	DisplayOrder = TOP_DISPLAY_ORDER + 1,
})
ProtectGui(WindUI.ScreenGui)
ProtectGui(WindUI.NotificationGui)
ProtectGui(WindUI.DropdownGui)
ProtectGui(WindUI.TooltipGui)

KeepScreenGuiOnTop(WindUI.ScreenGui, TOP_DISPLAY_ORDER)
KeepScreenGuiOnTop(WindUI.NotificationGui, TOP_DISPLAY_ORDER + 3)
KeepScreenGuiOnTop(WindUI.DropdownGui, TOP_DISPLAY_ORDER + 2)
KeepScreenGuiOnTop(WindUI.TooltipGui, TOP_DISPLAY_ORDER + 1)

WindUI.SoundManager:Init(WindUI)
Creator.Init(WindUI)

function WindUI:SetParent(parent)
	if WindUI.ScreenGui then
		WindUI.ScreenGui.Parent = parent
	end
	if WindUI.NotificationGui then
		WindUI.NotificationGui.Parent = parent
	end
	if WindUI.DropdownGui then
		WindUI.DropdownGui.Parent = parent
	end
	if WindUI.TooltipGui then
		WindUI.TooltipGui.Parent = parent
	end
end
math.clamp(WindUI.TransparencyValue, 0, 1)

local Holder = WindUI.NotificationModule.Init(WindUI.NotificationGui)

function WindUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Window = WindUI.Window
	--Config.WindUI = WindUI
	return WindUI.NotificationModule.New(Config)
end

function WindUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function WindUI:ConfigureSounds(Config)
	return WindUI.SoundManager:Configure(Config)
end

function WindUI:SetSoundEnabled(Value)
	return WindUI.SoundManager:SetEnabled(Value)
end

function WindUI:SetSoundPreset(Name)
	return WindUI.SoundManager:SetPreset(Name)
end

function WindUI:SetSoundVolume(Value)
	return WindUI.SoundManager:SetVolume(Value)
end

function WindUI:SetSoundPitch(Value)
	return WindUI.SoundManager:SetPitch(Value)
end

function WindUI:SetSoundForEvent(EventName, Sound, Options)
	return WindUI.SoundManager:SetSoundForEvent(EventName, Sound, Options)
end

function WindUI:ClearSoundOverride(EventName)
	return WindUI.SoundManager:ClearSoundOverride(EventName)
end

function WindUI:ClearSoundOverrides()
	return WindUI.SoundManager:ClearSoundOverrides()
end

function WindUI:PlaySound(EventName, Options)
	return WindUI.SoundManager:Play(EventName, Options)
end

function WindUI:PreviewSound(SoundName, Options)
	return WindUI.SoundManager:Preview(SoundName, Options)
end

function WindUI:GetSoundConfig()
	return WindUI.SoundManager:GetConfig()
end

function WindUI:GetSoundEvents()
	return WindUI.SoundManager:GetEvents()
end

function WindUI:GetSoundPresets()
	return WindUI.SoundManager:GetPresetNames()
end

function WindUI:GetSoundNames()
	return WindUI.SoundManager:GetSoundNames()
end

function WindUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function WindUI:OnThemeChange(func)
	WindUI.OnThemeChangeFunction = func
end

function WindUI:AddTheme(LTheme)
	WindUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function WindUI:SetTheme(Value)
	if WindUI.Themes[Value] then
		WindUI.Theme = WindUI.Themes[Value]
		Creator.SetTheme(WindUI.Themes[Value])

		if WindUI.OnThemeChangeFunction then
			WindUI.OnThemeChangeFunction(Value)
		end

		return WindUI.Themes[Value]
	end
	return nil
end

function WindUI:GetThemes()
	return WindUI.Themes
end
function WindUI:GetCurrentTheme()
	return WindUI.Theme.Name
end
function WindUI:GetTransparency()
	return WindUI.Transparent or false
end
function WindUI:GetWindowSize()
	return WindUI.Window.UIElements.Main.Size
end
function WindUI:Localization(LocalizationConfig)
	return WindUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function WindUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function WindUI:ToggleAcrylic(Value)
	if WindUI.Window and WindUI.Window.AcrylicPaint and WindUI.Window.AcrylicPaint.Model then
		WindUI.Window.Acrylic = Value
		WindUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function WindUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function WindUI:Popup(PopupConfig)
	PopupConfig.WindUI = WindUI
	return require("./components/popup/Init").new(PopupConfig, WindUI.ScreenGui.Popups)
end

WindUI.Themes = require("./themes/Init")(WindUI, Creator)

WindUI.Themes["Salty Special"] = {
	Name = "Salty Special",
	Accent = Color3.fromHex("#A1162F"),
	Dialog = Color3.fromHex("#0A0709"),
	Outline = Color3.fromHex("#5A1824"),
	Text = Color3.fromHex("#FFFFFF"),
	Placeholder = Color3.fromHex("#9A9AA3"),
	Background = Color3.fromHex("#000000"),
	Button = Color3.fromHex("#251016"),
	Icon = Color3.fromHex("#E2DDE0"),
	Toggle = Color3.fromHex("#A1162F"),
	Slider = Color3.fromHex("#A1162F"),
	Checkbox = Color3.fromHex("#A1162F"),
	Primary = Color3.fromHex("#A1162F"),
	SliderIcon = Color3.fromHex("#F1E3E7"),
	PanelBackground = Color3.fromHex("#050406"),
	PanelBackgroundTransparency = 0.42,
	LabelBackground = Color3.fromHex("#0A080A"),
	LabelBackgroundTransparency = 0.08,
	ElementBackground = Color3.fromHex("#151116"),
	ElementBackgroundTransparency = 0.16,
	-- Let the Crimson01 artwork show through; selection fades away to the right.
	TabBackgroundActive = Color3.fromHex("#0B0A0C"),
	TabBackgroundActiveTransparency = 1,
	TabBackgroundHover = Color3.fromHex("#151013"),
	TabBackgroundHoverTransparency = 0.82,
	TabSelectionFade = Color3.fromHex("#4A1C2B"),
}


WindUI.Themes["Gui Dark"] = {
	Name = "Gui Dark",
	Accent = Color3.fromHex("#151923"),
	Dialog = Color3.fromHex("#11141C"),
	Outline = Color3.fromHex("#FFFFFF"),
	Text = Color3.fromHex("#F7F9FF"),
	Placeholder = Color3.fromHex("#98A1B3"),
	Background = Color3.fromHex("#0B0E14"),
	Button = Color3.fromHex("#242B3A"),
	Icon = Color3.fromHex("#AEB7C8"),
	Toggle = Color3.fromHex("#5DE7FF"),
	Slider = Color3.fromHex("#7C8CFF"),
	Checkbox = Color3.fromHex("#7C8CFF"),
	Primary = Color3.fromHex("#7C8CFF"),
	SliderIcon = Color3.fromHex("#A9B2C4"),
	PanelBackground = Color3.fromHex("#FFFFFF"),
	PanelBackgroundTransparency = 0.96,
	LabelBackground = Color3.fromHex("#000000"),
	LabelBackgroundTransparency = 0.82,
	ElementBackground = Color3.fromHex("#171C27"),
	ElementBackgroundTransparency = 0,
}

WindUI.Themes["Gui AMOLED"] = {
	Name = "Gui AMOLED",
	Accent = Color3.fromHex("#0A0A0D"),
	Dialog = Color3.fromHex("#08090C"),
	Outline = Color3.fromHex("#FFFFFF"),
	Text = Color3.fromHex("#FFFFFF"),
	Placeholder = Color3.fromHex("#858B98"),
	Background = Color3.fromHex("#000000"),
	Button = Color3.fromHex("#17191F"),
	Icon = Color3.fromHex("#A8AFBC"),
	Toggle = Color3.fromHex("#55F1D6"),
	Slider = Color3.fromHex("#5DE7FF"),
	Checkbox = Color3.fromHex("#5DE7FF"),
	Primary = Color3.fromHex("#5DE7FF"),
	SliderIcon = Color3.fromHex("#C4CAD4"),
	PanelBackground = Color3.fromHex("#FFFFFF"),
	PanelBackgroundTransparency = 0.975,
	LabelBackground = Color3.fromHex("#090A0C"),
	LabelBackgroundTransparency = 0.12,
	ElementBackground = Color3.fromHex("#0D0F14"),
	ElementBackgroundTransparency = 0,
}

WindUI.Themes["Gui Violet"] = {
	Name = "Gui Violet",
	Accent = Color3.fromHex("#211B35"),
	Dialog = Color3.fromHex("#171323"),
	Outline = Color3.fromHex("#FFFFFF"),
	Text = Color3.fromHex("#FCF9FF"),
	Placeholder = Color3.fromHex("#A49AB5"),
	Background = Color3.fromHex("#0D0A13"),
	Button = Color3.fromHex("#2C2440"),
	Icon = Color3.fromHex("#C5B8D8"),
	Toggle = Color3.fromHex("#A98BFF"),
	Slider = Color3.fromHex("#A98BFF"),
	Checkbox = Color3.fromHex("#D47CFF"),
	Primary = Color3.fromHex("#A98BFF"),
	SliderIcon = Color3.fromHex("#D7CCEA"),
	PanelBackground = Color3.fromHex("#FFFFFF"),
	PanelBackgroundTransparency = 0.965,
	LabelBackground = Color3.fromHex("#120E1B"),
	LabelBackgroundTransparency = 0.12,
	ElementBackground = Color3.fromHex("#1B1628"),
	ElementBackgroundTransparency = 0,
}

Creator.Themes = WindUI.Themes

WindUI:SetTheme("Salty Special")
WindUI:SetLanguage(Creator.Language)

function WindUI:CreateWindow(Config)
	Config = Config or {}
	local CreateWindow = require("./components/window/Init")
	if Config.Branding == nil then
		local brand = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/vanta-brand-v2-original.jpeg?v=original-valid-20261015"
		Config.Branding = { Name = "VANTA", Image = brand, WindowIcon = brand, OpenButtonIcon = brand,
			IconSize = 24, IconRadius = 7, OpenButtonIconRadius = 8 }
	end

	if not RunService:IsStudio() and writefile then
		if not isfolder("Gui") then
			makefolder("Gui")
		end
		if Config.Folder then
			makefolder(Config.Folder)
		else
			makefolder(Config.Title)
		end
	end

	Config.WindUI = WindUI
	Config.Window = WindUI.Window
	Config.Parent = WindUI.ScreenGui.Window

	if WindUI.Window then
		warn("[Gui] You cannot create more than one window")
		return
	end

	local SoundConfig = Config.Sounds
	if SoundConfig == nil then
		SoundConfig = {}
	end
	if typeof(SoundConfig) == "table" and SoundConfig.Folder == nil then
		SoundConfig.Folder = Config.Folder or Config.Title or "VantaUI"
	end
	WindUI:ConfigureSounds(SoundConfig)

	local CanLoadWindow = true

	local Theme = WindUI.Themes[Config.Theme or "Salty Special"] or WindUI.Theme

	--WindUI.Theme = Theme
	Creator.SetTheme(Theme)

	local hwid = gethwid or function()
		return Players.LocalPlayer.UserId
	end

	local Filename = hwid()

	if Config.KeySystem then
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table") and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = WindUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	WindUI.Transparent = Config.Transparent
	WindUI.Window = Window

	if Config.Acrylic then
		Acrylic.init()
	end

	-- function Window:ToggleTransparency(Value)
	--     WindUI.Transparent = Value
	--     WindUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and WindUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and WindUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1),
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return WindUI