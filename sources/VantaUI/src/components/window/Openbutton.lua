local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local UserInputService = cloneref(game:GetService("UserInputService"))

function OpenButton.New(Window)
    local OpenButtonMain = {
        Button = nil,
        Icon = nil,
        Hitbox = nil,
        Dragging = false,
        WasDragged = false,
        OnlyIcon = false,
    }

    local Icon
    local CurrentImageZoom = 1

    local Title = New("TextLabel", {
        Text = Window.Title,
        TextSize = 16,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
    })

    local Container = New("Frame", {
        Size = UDim2.fromOffset(44, 44),
        Position = UDim2.new(0.5, 0, 0, 46 + 44 / 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = Window.Parent,
        BackgroundTransparency = 1,
        Active = true,
        Visible = false,
    })

    local UIScale = New("UIScale", {
        Scale = 1,
    })

    local Button = New("Frame", {
        Name = "OpenButton",
        Size = UDim2.fromOffset(44, 44),
        Parent = Container,
        Active = true,
        BackgroundTransparency = 0.12,
        ZIndex = 99,
        BackgroundColor3 = Color3.fromHex("#0B0E14"),
        ClipsDescendants = true,
    }, {
        UIScale,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        New("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new(Color3.fromHex("#151923"), Color3.fromHex("#0B0E14")),
        }),
        New("UIStroke", {
            Thickness = 1,
            ApplyStrokeMode = "Border",
            Color = Color3.new(1, 1, 1),
            Transparency = 0.15,
        }, {
            New("UIGradient", {
                Color = ColorSequence.new(Color3.fromHex("#5DE7FF"), Color3.fromHex("#7C8CFF")),
            }),
        }),
    })

    local Drag = New("Frame", {
        Name = "Drag",
        Size = UDim2.fromOffset(36, 36),
        Position = UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = Button,
        BackgroundTransparency = 1,
        ZIndex = 101,
    }, {
        New("ImageLabel", {
            Image = Creator.Icon("move")[1],
            ImageRectOffset = Creator.Icon("move")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("move")[2].ImageRectSize,
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ThemeTag = {
                ImageColor3 = "Icon",
            },
            ImageTransparency = 0.4,
        }),
    })

    local Divider = New("Frame", {
        Name = "Divider",
        Size = UDim2.new(0, 1, 1, -8),
        Position = UDim2.new(0, 44, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = Button,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.88,
        ZIndex = 101,
    })

    local ContentButton = New("TextButton", {
        Name = "TextButton",
        AutomaticSize = Enum.AutomaticSize.X,
        Active = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 36),
        Position = UDim2.new(0, 49, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ClipsDescendants = true,
        Parent = Button,
        ZIndex = 101,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(1, -4),
        }),
        New("UIListLayout", {
            Padding = UDim.new(0, Window.UIPadding),
            FillDirection = "Horizontal",
            VerticalAlignment = "Center",
            SortOrder = "LayoutOrder",
        }),
        Title,
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
        }),
    })

    local BadgeHolder = New("Frame", {
        Name = "BadgeHolder",
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = Button,
        ZIndex = 200,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 11),
        }),
    })

    local Hitbox = New("TextButton", {
        Name = "DragHitbox",
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Active = true,
        Selectable = false,
        Parent = Button,
        ZIndex = 10000,
    })

    OpenButtonMain.Button = Button
    OpenButtonMain.Hitbox = Hitbox

    local function updateRegularWidth()
        if OpenButtonMain.OnlyIcon then
            return
        end
        local width = math.max(88, 53 + ContentButton.AbsoluteSize.X)
        Button.Size = UDim2.fromOffset(width, 44)
        Container.Size = Button.Size
    end

    local function applyIconLayout()
        if not Icon then
            return
        end

        if OpenButtonMain.OnlyIcon then
            Icon.Parent = BadgeHolder
            Icon.Size = UDim2.fromScale(1, 1)
            Icon.Position = UDim2.fromScale(0, 0)
            Icon.AnchorPoint = Vector2.new(0, 0)
            Icon.ZIndex = 201

            if Icon.ImageLabel then
                Icon.ImageLabel.ZIndex = 201
                Icon.ImageLabel.ScaleType = Enum.ScaleType.Crop
                Icon.ImageLabel.Size = UDim2.fromScale(CurrentImageZoom, CurrentImageZoom)
                Icon.ImageLabel.Position = UDim2.fromScale(0.5, 0.5)
                Icon.ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            end
        else
            Icon.Parent = ContentButton
            Icon.Size = UDim2.fromOffset(22, 22)
            Icon.Position = UDim2.fromOffset(0, 0)
            Icon.AnchorPoint = Vector2.new(0, 0)
            Icon.LayoutOrder = -1
            Icon.ZIndex = 102

            if Icon.ImageLabel then
                Icon.ImageLabel.ZIndex = 102
                Icon.ImageLabel.ScaleType = Enum.ScaleType.Crop
                Icon.ImageLabel.Size = UDim2.fromScale(1, 1)
                Icon.ImageLabel.Position = UDim2.fromScale(0.5, 0.5)
                Icon.ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            end
        end
    end

    function OpenButtonMain:SetIcon(newIcon)
        if newIcon == OpenButtonMain.Icon and Icon then
            applyIconLayout()
            return
        end

        if Icon then
            Icon:Destroy()
            Icon = nil
        end

        if newIcon then
            local isBrandIcon = Window.BrandImage
                and (newIcon == Window.BrandImage or newIcon == Window.Branding.OpenButtonIcon)
            local iconRadius = isBrandIcon
                and (Window.Branding.OpenButtonIconRadius or Window.Branding.IconRadius or 7)
                or 0

            Icon = Creator.Image(
                newIcon,
                Window.Title,
                iconRadius,
                Window.Folder,
                "OpenButton",
                true,
                Window.IconThemed
            )

            applyIconLayout()
        end

        OpenButtonMain.Icon = newIcon
        updateRegularWidth()
    end

    if Window.Icon then
        OpenButtonMain:SetIcon(Window.Icon)
    end

    Creator.AddSignal(ContentButton:GetPropertyChangedSignal("AbsoluteSize"), updateRegularWidth)

    Creator.AddSignal(Hitbox.MouseEnter, function()
        if not OpenButtonMain.OnlyIcon then
            Tween(ContentButton, 0.16, { BackgroundTransparency = 0.9 }):Play()
        end
    end)

    Creator.AddSignal(Hitbox.MouseLeave, function()
        if not OpenButtonMain.OnlyIcon then
            Tween(ContentButton, 0.16, { BackgroundTransparency = 1 }):Play()
        end
    end)

    -- The badge owns its own drag handling. No layout object touches this hitbox,
    -- so every visible pixel can start the drag on mouse or touch.
    local dragEnabled = true
    local dragging = false
    local dragStart
    local dragStartPosition
    local activeInput

    Creator.AddSignal(Hitbox.InputBegan, function(input)
        if not dragEnabled or dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            OpenButtonMain.Dragging = true
            OpenButtonMain.WasDragged = false
            activeInput = input
            dragStart = input.Position
            dragStartPosition = Container.Position
        end
    end)

    Creator.AddSignal(UserInputService.InputChanged, function(input)
        if not dragging or not dragEnabled or not activeInput then
            return
        end

        local validInput = false
        if activeInput.UserInputType == Enum.UserInputType.MouseButton1 then
            validInput = input.UserInputType == Enum.UserInputType.MouseMovement
        elseif activeInput.UserInputType == Enum.UserInputType.Touch then
            validInput = input == activeInput
        end

        if not validInput then
            return
        end

        local delta = input.Position - dragStart
        if math.abs(delta.X) > 2 or math.abs(delta.Y) > 2 then
            OpenButtonMain.WasDragged = true
        end

        Container.Position = UDim2.new(
            dragStartPosition.X.Scale,
            dragStartPosition.X.Offset + delta.X,
            dragStartPosition.Y.Scale,
            dragStartPosition.Y.Offset + delta.Y
        )
    end)

    Creator.AddSignal(UserInputService.InputEnded, function(input)
        if not dragging or not activeInput then
            return
        end

        local ended = input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1)

        if not ended then
            return
        end

        local wasDragged = OpenButtonMain.WasDragged

        dragging = false
        OpenButtonMain.Dragging = false
        activeInput = nil

        if wasDragged then
            task.delay(0.2, function()
                OpenButtonMain.WasDragged = false
            end)
        else
            OpenButtonMain.WasDragged = false
            if Window.Open then
                Window:Open()
            end
        end
    end)

    function OpenButtonMain:Visible(v)
        Container.Visible = v
    end

    function OpenButtonMain:SetScale(scale)
        UIScale.Scale = scale
    end

    function OpenButtonMain:Edit(OpenButtonConfig)
        local OpenButtonModule = {
            Title = OpenButtonConfig.Title,
            Icon = OpenButtonConfig.Icon,
            Enabled = OpenButtonConfig.Enabled,
            Position = OpenButtonConfig.Position,
            OnlyIcon = OpenButtonConfig.OnlyIcon == true,
            Draggable = OpenButtonConfig.Draggable,
            OnlyMobile = OpenButtonConfig.OnlyMobile,
            CornerRadius = OpenButtonConfig.CornerRadius or UDim.new(1, 0),
            StrokeThickness = OpenButtonConfig.StrokeThickness or 1,
            Scale = OpenButtonConfig.Scale or 1,
            ImageZoom = OpenButtonConfig.ImageZoom or 1,
            Color = OpenButtonConfig.Color
                or ColorSequence.new(Color3.fromHex("#5DE7FF"), Color3.fromHex("#7C8CFF")),
        }

        if OpenButtonModule.Enabled == false then
            Window.IsOpenButtonEnabled = false
        end

        if OpenButtonModule.OnlyMobile ~= false then
            OpenButtonModule.OnlyMobile = true
        else
            Window.IsPC = false
        end

        OpenButtonMain.OnlyIcon = OpenButtonModule.OnlyIcon
        CurrentImageZoom = OpenButtonModule.ImageZoom
        dragEnabled = OpenButtonModule.Draggable ~= false

        if OpenButtonModule.Position then
            Container.Position = OpenButtonModule.Position
        end

        if OpenButtonMain.OnlyIcon then
            Title.Visible = false
            Drag.Visible = false
            Divider.Visible = false
            ContentButton.Visible = false
            ContentButton.Active = false
            BadgeHolder.Visible = true

            Button.Size = UDim2.fromOffset(44, 44)
            Container.Size = UDim2.fromOffset(44, 44)
        else
            Title.Visible = true
            Drag.Visible = dragEnabled
            Divider.Visible = dragEnabled
            ContentButton.Visible = true
            ContentButton.Active = true
            BadgeHolder.Visible = false
            updateRegularWidth()
        end

        if OpenButtonModule.Title then
            Title.Text = OpenButtonModule.Title
            Creator:ChangeTranslationKey(Title, OpenButtonModule.Title)
        end

        if OpenButtonModule.Icon then
            OpenButtonMain:SetIcon(OpenButtonModule.Icon)
        else
            applyIconLayout()
        end

        Button.UIStroke.UIGradient.Color = OpenButtonModule.Color
        Button.UIStroke.Thickness = OpenButtonModule.StrokeThickness
        Button.UICorner.CornerRadius = OpenButtonModule.CornerRadius
        ContentButton.UICorner.CornerRadius = OpenButtonModule.CornerRadius
        BadgeHolder.UICorner.CornerRadius = OpenButtonModule.CornerRadius

        OpenButtonMain:SetScale(OpenButtonModule.Scale)
    end

    return OpenButtonMain
end

return OpenButton
