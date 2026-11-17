local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local CreateToggle = require("../components/ui/Toggle").New
local CreateCheckbox = require("../components/ui/Checkbox").New

local Element = {}

function Element:New(Config)
	local Toggle = {
		__type = "Toggle",
		Title = Config.Title or "Toggle",
		Desc = Config.Desc or nil,
		Locked = Config.Locked or false,
		LockedTitle = Config.LockedTitle,
		Value = Config.Value,
		Icon = Config.Icon or nil,
		IconSize = Config.IconSize or 23,
		Type = Config.Type or "Toggle",
		Callback = Config.Callback or function() end,
		UIElements = {},
	}
	Toggle.ToggleFrame = require("../components/window/Element")({
		Title = Toggle.Title,
		Desc = Toggle.Desc,
		Window = Config.Window,
		Parent = Config.Parent,
		-- Compact state label + 44px capsule group.
		TextOffset = Config.Window.NewElements and 74 or 70,
		Hover = false,
		Tab = Config.Tab,
		Index = Config.Index,
		ElementTable = Toggle,
		ParentConfig = Config,
		Tags = Config.Tags,
	})

	local CanCallback = true

	if Toggle.Value == nil then
		Toggle.Value = false
	end

	function Toggle:Lock()
		Toggle.Locked = true
		CanCallback = false
		return Toggle.ToggleFrame:Lock(Toggle.LockedTitle)
	end
	function Toggle:Unlock()
		Toggle.Locked = false
		CanCallback = true
		return Toggle.ToggleFrame:Unlock()
	end

	if Toggle.Locked then
		Toggle:Lock()
	end

	local Toggled = Toggle.Value

	local ToggleFrame, ToggleFunc
	if Toggle.Type == "Toggle" then
		ToggleFrame, ToggleFunc = CreateToggle(
			Toggled,
			Toggle.Icon,
			Toggle.IconSize,
			Toggle.ToggleFrame.UIElements.Main,
			Toggle.Callback,
			Config.Window.NewElements,
			Config
		)
	elseif Toggle.Type == "Checkbox" then
		ToggleFrame, ToggleFunc = CreateCheckbox(
			Toggled,
			Toggle.Icon,
			Toggle.IconSize,
			Toggle.ToggleFrame.UIElements.Main,
			Toggle.Callback,
			Config
		)
	else
		error("Unknown Toggle Type: " .. tostring(Toggle.Type))
	end

	ToggleFrame.AnchorPoint = Vector2.new(1, Config.Window.NewElements and 0 or 0.5)
	ToggleFrame.Position = UDim2.new(1, 0, Config.Window.NewElements and 0 or 0.5, 0)

	function Toggle:Set(v, isCallback, isAnim)
		if CanCallback then
			local changed = Toggle.Value ~= v
			ToggleFunc:Set(v, isCallback, isAnim or false)
			Toggled = v
			Toggle.Value = v
			if changed and isCallback ~= false then
				Creator.PlaySound(v and "ToggleOn" or "ToggleOff")
			end
		end
	end

	Toggle:Set(Toggled, false, Config.Window.NewElements)

	local CurInput = Config.WindUI.GenerateGUID()

	if Config.Window.NewElements and ToggleFunc.Animate then
		if Toggle.Type == "Toggle" then
			Creator.AddSignal(ToggleFrame.ToggleFrame.Hitbox.InputBegan, function(Input)
				if
					not Config.Window.IsToggleDragging
					and (
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					)
				then
					if Config.WindUI.CurrentInput and Config.WindUI.CurrentInput ~= CurInput then
						return
					end

					Config.WindUI.CurrentInput = CurInput
					ToggleFunc:Animate(Input, Toggle)
				end
			end)
		end
	else
		if Toggle.Type == "Toggle" then
			Creator.AddSignal(ToggleFrame.ToggleFrame.Hitbox.MouseButton1Click, function()
				Toggle:Set(not Toggle.Value, nil, Config.Window.NewElements)
			end)
		elseif Toggle.Type == "Checkbox" then
			Creator.AddSignal(ToggleFrame.MouseButton1Click, function()
				Toggle:Set(not Toggle.Value, nil, Config.Window.NewElements)
			end)
		end
	end

	return Toggle.__type, Toggle
end

return Element
