local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local DialogModule = {
	Holder = nil,
	Parent = nil,
}

function DialogModule.Create(Key, Type, Window, WindUI, Parent)
	local Dialog = {
		UICorner = 22,
		UIPadding = 14,

		Window = Window,
		WindUI = WindUI,

		UIElements = {},
	}

	if Key then
		Dialog.UIPadding = 0
		Dialog.UICorner = 20
	end

	Type = Type or "Dialog"

	if not Key then
		Dialog.UIElements.FullScreen = New("Frame", {
			ZIndex = 999,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromHex("#000000"),
			Size = UDim2.new(1, 0, 1, 0),
			Active = false,
			Visible = false,
			Parent = DialogModule.Parent
				or (Window and Window.UIElements and Window.UIElements.Main and Window.UIElements.Main.Main),
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, Window.UICorner),
			}),
		})
	end

	local Blur = New("ImageLabel", {
		Image = "rbxassetid://8992230677",
		ThemeTag = {
			ImageColor3 = "WindowShadow",
		},
		ImageTransparency = 1,
		Size = UDim2.new(1, 90, 1, 90),
		Position = UDim2.new(0, -45, 0, -45),
		ScaleType = "Slice",
		SliceCenter = Rect.new(99, 99, 99, 99),
		BackgroundTransparency = 1,
		ZIndex = -999999999999999,
		Name = "Blur",
	})

	Dialog.UIElements.Main = New("Frame", {
		Size = UDim2.new(0, 300, 0, 0),
		ThemeTag = {
			BackgroundColor3 = Type .. "Background",
		},
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 99999,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, Dialog.UIPadding),
			PaddingLeft = UDim.new(0, Dialog.UIPadding),
			PaddingRight = UDim.new(0, Dialog.UIPadding),
			PaddingBottom = UDim.new(0, Dialog.UIPadding),
		}),
	})

	Dialog.UIElements.MainContainer = Creator.NewRoundFrame(Dialog.UICorner, "Squircle", {
		Visible = false,
		ImageTransparency = Key and 0.15 or 0,
		Parent = Parent or Dialog.UIElements.FullScreen,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = "XY",
		ThemeTag = {
			ImageColor3 = Type .. "Background",
			ImageTransparency = Type .. "BackgroundTransparency",
		},
		ZIndex = 9999,
	}, {
		Dialog.UIElements.Main,
	})

	function Dialog:Open()
		if not Key then
			Dialog.UIElements.FullScreen.Visible = true
			Dialog.UIElements.FullScreen.Active = true
		end

		task.spawn(function()
			Dialog.UIElements.MainContainer.Visible = true

			if not Key then
				Tween(Dialog.UIElements.FullScreen, 0.16, { BackgroundTransparency = 0.55 }):Play()
			end
			Tween(Dialog.UIElements.MainContainer, 0.16, { ImageTransparency = 0 }):Play()
			task.spawn(function()
				task.wait(0.06)
				Dialog.UIElements.Main.Visible = true
			end)
		end)
	end
	function Dialog:Close()
		if not Key then
			Tween(Dialog.UIElements.FullScreen, 0.14, { BackgroundTransparency = 1 }):Play()
			Dialog.UIElements.FullScreen.Active = false
			task.spawn(function()
				task.wait(0.14)
				Dialog.UIElements.FullScreen.Visible = false
			end)
		end
		Dialog.UIElements.Main.Visible = false

		Tween(Dialog.UIElements.MainContainer, 0.14, { ImageTransparency = 1 }):Play()

		task.spawn(function()
			task.wait(0.14)
			if not Key then
				Dialog.UIElements.FullScreen:Destroy()
			else
				Dialog.UIElements.MainContainer:Destroy()
			end
		end)

		return function() end
	end

	return Dialog
end

return DialogModule
