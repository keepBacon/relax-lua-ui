local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local NotificationModule = {
	-- Lower-right notification stack with a 29px bottom/right safe margin.
	Size = UDim2.new(0, 300, 1, -96),
	SizeLower = UDim2.new(0, 300, 1, -84),
	UICorner = 18,
	UIPadding = 14,
	--ButtonPadding = 9,
	Holder = nil,
	NotificationIndex = 0,
	Notifications = {},
}

function NotificationModule.Init(Parent)
	local NotModule = {
		Lower = false,
	}

	function NotModule.SetLower(val)
		NotModule.Lower = val
		NotModule.Frame.Size = val and NotificationModule.SizeLower or NotificationModule.Size
	end

	NotModule.Frame = New("Frame", {
		Position = UDim2.new(1, -116 / 4, 0, 96),
		AnchorPoint = Vector2.new(1, 0),
		Size = NotificationModule.Size,
		Parent = Parent,
		BackgroundTransparency = 1,
		--[[ScrollingDirection = "Y",
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",--]]
	}, {
		New("UIListLayout", {
			HorizontalAlignment = "Center",
			SortOrder = "LayoutOrder",
			VerticalAlignment = "Bottom",
			Padding = UDim.new(0, 8),
		}),
		New("UIPadding", {
			PaddingBottom = UDim.new(0, 116 / 4),
		}),
	})
	return NotModule
end

function NotificationModule.New(Config)
	Creator.PlaySound("Notification")
	local Notification = {
		Title = Config.Title or "Notification",
		Content = Config.Content or nil,
		Icon = Config.Icon or nil,
		IconColor = Config.IconColor,
		IconThemed = Config.IconThemed,
		Background = Config.Background,
		BackgroundImageTransparency = Config.BackgroundImageTransparency,
		Duration = Config.Duration or 5,
		Buttons = Config.Buttons or {},
		CanClose = Config.CanClose ~= false,
		UIElements = {},
		Closed = false,
	}
	--[[if Notification.CanClose == nil then
        Notification.CanClose = true
    end--]]
	NotificationModule.NotificationIndex = NotificationModule.NotificationIndex + 1
	NotificationModule.Notifications[NotificationModule.NotificationIndex] = Notification

	-- local UIStroke = New("UIStroke", {
	--     ThemeTag = {
	--         Color = "Text"
	--     },
	--     Transparency = 1, -- - .9
	--     Thickness = .6,
	-- })

	local Icon

	if Notification.Icon then
		-- if Creator.Icon(Notification.Icon) and Creator.Icon(Notification.Icon)[2] then
		--     Icon = New("ImageLabel", {
		--         Size = UDim2.new(0,26,0,26),
		--         Position = UDim2.new(0,NotificationModule.UIPadding,0,NotificationModule.UIPadding),
		--         BackgroundTransparency = 1,
		--         Image = Creator.Icon(Notification.Icon)[1],
		--         ImageRectSize = Creator.Icon(Notification.Icon)[2].ImageRectSize,
		--         ImageRectOffset = Creator.Icon(Notification.Icon)[2].ImageRectPosition,
		--         ThemeTag = {
		--             ImageColor3 = "Text"
		--         }
		--     })
		-- elseif string.find(Notification.Icon, "rbxassetid") then
		--     Icon = New("ImageLabel", {
		--         Size = UDim2.new(0,26,0,26),
		--         BackgroundTransparency = 1,
		--         Position = UDim2.new(0,NotificationModule.UIPadding,0,NotificationModule.UIPadding),
		--         Image = Notification.Icon
		--     })
		-- end

		Icon = Creator.Image(
			Notification.Icon,
			Notification.Title .. ":" .. Notification.Icon,
			0,
			Config.Window,
			"Notification",
			Notification.IconThemed
		)
		if Notification.IconColor and Icon.ImageLabel then
			Icon.ImageLabel.ImageColor3 = Notification.IconColor
		end
		Icon.Size = UDim2.new(0, 26, 0, 26)
		Icon.Position = UDim2.new(0, NotificationModule.UIPadding, 0, NotificationModule.UIPadding)
		-- Icon.LayoutOrder = -1
	end

	local CloseButton
	if Notification.CanClose then
		CloseButton = New("ImageButton", {
			Image = Creator.Icon("x")[1],
			ImageRectSize = Creator.Icon("x")[2].ImageRectSize,
			ImageRectOffset = Creator.Icon("x")[2].ImageRectPosition,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -NotificationModule.UIPadding, 0, NotificationModule.UIPadding),
			AnchorPoint = Vector2.new(1, 0),
			ThemeTag = {
				ImageColor3 = "Text",
			},
			ImageTransparency = 0.4,
		}, {
			New("TextButton", {
				Size = UDim2.new(1, 8, 1, 8),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = "",
			}),
		})
	end

	-- Original full-height countdown overlay, now in muted dark red.
	-- The parent clips its width down to zero over the notification duration.
	local Duration = Creator.NewRoundFrame(NotificationModule.UICorner, "Squircle", {
		Size = UDim2.new(0, 0, 1, 0),
		ImageColor3 = Color3.fromHex("#251016"),
		ImageTransparency = 0,
	})

	-- Full-height countdown remains inside the OLED notification card.
	New("UIGradient",{
		Name="PremiumCountdownGradient",Parent=Duration,
		Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromRGB(105,105,105)),
			ColorSequenceKeypoint.new(0.45,Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(145,145,145)),
		}),
	})
	Creator.AddThemeObject(Duration,{ImageColor3="Primary"})
	local TextContainer = New("Frame", {
		Size = UDim2.new(1, Notification.Icon and -28 - NotificationModule.UIPadding or 0, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = "Y",
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, NotificationModule.UIPadding),
			PaddingLeft = UDim.new(0, NotificationModule.UIPadding),
			PaddingRight = UDim.new(0, NotificationModule.UIPadding),
			PaddingBottom = UDim.new(0, NotificationModule.UIPadding),
		}),
		New("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -30 - NotificationModule.UIPadding, 0, 0),
			TextWrapped = true,
			TextXAlignment = "Left",
			RichText = true,
			BackgroundTransparency = 1,
			TextSize = 18,
			ThemeTag = {
				TextColor3 = "NotificationTitle",
				TextTransparency = "NotificationTitleTransparency",
			},
			Text = Notification.Title,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		}),
		New("UIListLayout", {
			Padding = UDim.new(0, NotificationModule.UIPadding / 3),
		}),
	})

	if Notification.Content then
		New("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			TextXAlignment = "Left",
			RichText = true,
			BackgroundTransparency = 1,
			--TextTransparency = .4,
			TextSize = 15,
			ThemeTag = {
				TextColor3 = "NotificationContent",
				TextTransparency = "NotificationContentTransparency",
			},
			Text = Notification.Content,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			Parent = TextContainer,
		})
	end

	local Main = Creator.NewRoundFrame(NotificationModule.UICorner, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(2, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		AutomaticSize = "Y",
		-- Solid OLED black, independent of the selected UI theme.
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0,
		--ZIndex = 20
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Name = "DurationFrame",
		}, {
			--[[Creator.NewRoundFrame(NotificationModule.UICorner, "SquircleOutline", {
				Size = UDim2.new(1, 0, 1, 0),
				ImageTransparency = 0.8,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			}),]]
			New("Frame", {
				Size = UDim2.new(1, 0, 1, 0), -- 0,0,1,0
				BackgroundTransparency = 1,
				ClipsDescendants = true,
			}, {
				Duration,
			}),

			-- New("UICorner", {
			--     CornerRadius = UDim.new(0,NotificationModule.UICorner),
			-- })
		}),
		New("ImageLabel", {
			Name = "Background",
			Image = Notification.Background,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScaleType = "Crop",
			ImageTransparency = Notification.BackgroundImageTransparency,
			--ZIndex = 19,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, NotificationModule.UICorner),
			}),
		}),

		TextContainer,
		Icon,
		CloseButton,
	})

	local IconScale
	if Icon then IconScale=New("UIScale",{Name="PremiumIconScale",Scale=0.75,Parent=Icon}) end
	local MainContainer = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = Config.Holder,
	}, {
		Main,
	})

	function Notification:Close()
		if not Notification.Closed then
			Notification.Closed = true
			Tween(
				MainContainer,
				0.45,
				{ Size = UDim2.new(1, 0, 0, -8) },
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			):Play()
			Tween(Main, 0.55, { Position = UDim2.new(2, 0, 1, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			task.wait(0.45)
			MainContainer:Destroy()
		end
	end

	task.spawn(function()
		task.wait()
		Tween(
			MainContainer,
			0.45,
			{ Size = UDim2.new(1, 0, 0, Main.AbsoluteSize.Y) },
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		):Play()
		Tween(Main, Creator.PremiumReduceMotion and 0.12 or 0.55,
			{Position=UDim2.new(0,0,1,0)},
			Creator.PremiumReduceMotion and Enum.EasingStyle.Sine or Enum.EasingStyle.Back,
			Enum.EasingDirection.Out):Play()
		if IconScale then
			if Creator.PremiumReduceMotion then IconScale.Scale=1
			else
				Tween(IconScale,0.42,{Scale=1},Enum.EasingStyle.Back,
					Enum.EasingDirection.Out):Play()
			end
		end
		if Notification.Duration then
			Duration.Size = UDim2.new(0, Main.DurationFrame.AbsoluteSize.X, 1, 0)
			Tween(
				Main.DurationFrame.Frame,
				Notification.Duration,
				{ Size = UDim2.new(0, 0, 1, 0) },
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut
			):Play()
			task.wait(Notification.Duration)
			Notification:Close()
		end
	end)

	if CloseButton then
		Creator.AddSignal(CloseButton.TextButton.MouseButton1Click, function()
			Creator.PlaySound("NotificationClose")
			Notification:Close()
		end)
	end

	--Tween():Play()
	return Notification
end

return NotificationModule
