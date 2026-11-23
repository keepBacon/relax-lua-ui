-- SPDX-License-Identifier: MPL-2.0
-- Optional native Roblox 3D preview. No RenderStepped loops, no remote assets.
-- Clones source objects; never reparents or destroys caller-owned instances.
function Section:ViewportPreview(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local previewHeight = math.clamp(tonumber(options.Height) or 190, 110, 380)
    local row = self:_row(previewHeight + (options.Name and 27 or 0) + 7,
        "ViewportPreview_" .. (options.Name or "Preview"))
    local c = self:_control("ViewportPreview", options, row)
    local alive = true
    c.Interactive = options.Interactive ~= false
    c.Yaw, c.Pitch = 0, math.rad(-10)
    c.Zoom = 1
    c.Source = options.Object or options.Model
    c.AutoRotate = false
    c.Available = false
    local origin = options.Name and 26 or 0
    if options.Name then
        text({ Name = "Title", Parent = row, Text = c.Name,
            TextSize = 13, FontFace = inter(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
    end
    local surface = create("Frame", {
        Name = "ViewportSurface", Parent = row, BackgroundColor3 = themeColor(theme, "Field"),
        Position = UDim2.fromOffset(0, origin),
        Size = UDim2.new(1, 0, 0, previewHeight), ClipsDescendants = true,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke")) })
    local fallback = text({ Name = "ViewportFallback", Parent = surface,
        Text = "未设置预览模型 · 使用 SetModel(model) 显示 3D 对象",
        TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
        TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true,
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0) })
    local available, viewport = pcall(function()
        return create("ViewportFrame", {
            Name = "NativeViewport", Parent = surface, BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1), Active = c.Interactive,
            Ambient = Color3.fromRGB(195, 195, 205),
            LightColor = Color3.fromRGB(255, 255, 255),
            LightDirection = Vector3.new(-1, -1, -1),
        })
    end)
    if not available or not viewport then
        c.Error = "ViewportFrame is unsupported"
        function c:SetModel(instance) self.Source = instance; return false, self.Error end
        function c:Get() return self.Source end
        function c:SetInteractive(on) self.Interactive = on == true end
        function c:ResetView() self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1 end
        function c:Destroy()
            if not alive then return end
            alive = false
            complexForgetControl(self)
            row:Destroy()
        end
        return hub:_finishRequiredControl(c)
    end

    viewport.Visible = false -- never draw an empty black viewport over the status label
    fallback.ZIndex = viewport.ZIndex + 1
    local world, camera
    local ok3d, err3d = pcall(function()
        world = Instance.new("WorldModel")
        world.Name = "PreviewWorld"
        world.Parent = viewport
        camera = Instance.new("Camera")
        camera.Name = "PreviewCamera"
        camera.FieldOfView = 45
        camera.Parent = viewport
        viewport.CurrentCamera = camera
    end)
    if not ok3d then
        c.Error = tostring(err3d)
        viewport:Destroy()
        fallback.Visible = true
        function c:SetModel(instance) self.Source = instance; return false, self.Error end
        function c:Get() return self.Source end
        function c:SetInteractive(on) self.Interactive = on == true end
        function c:ResetView() self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1 end
        function c:Destroy()
            if not alive then return end
            alive = false
            complexForgetControl(self)
            row:Destroy()
        end
        return hub:_finishRequiredControl(c)
    end
    c.Available = true
    local cloned
    local center = Vector3.zero
    local fitDistance = 6
    local modelSize = Vector3.one
    local function showStatus(message)
        fallback.Text = message
        fallback.Visible = true
        viewport.Visible = false
    end
    local function fit()
        if not camera or not viewport.Parent then return end
        local aspect = math.max(.25, viewport.AbsoluteSize.X /
            math.max(1, viewport.AbsoluteSize.Y))
        local vertical = math.rad(camera.FieldOfView * .5)
        local horizontal = math.atan(math.tan(vertical) * aspect)
        local radius = math.max(.12, modelSize.Magnitude * .5)
        fitDistance = math.max(
            radius / math.max(.05, math.sin(vertical)),
            radius / math.max(.05, math.sin(horizontal))) * 1.12
    end
    local function view()
        if not alive or hub._destroyed or not camera or not camera.Parent then return end
        local distance = fitDistance * math.clamp(c.Zoom, .6, 3.5)
        local cosPitch = math.cos(c.Pitch)
        local offset = Vector3.new(
            math.sin(c.Yaw) * cosPitch * distance,
            math.sin(c.Pitch) * distance,
            math.cos(c.Yaw) * cosPitch * distance)
        camera.CFrame = CFrame.lookAt(center + offset, center)
    end
    function c:SetModel(source)
        if not alive then return false, "destroyed" end
        if source ~= nil and (typeof(source) ~= "Instance"
            or not (source:IsA("Model") or source:IsA("BasePart"))) then
            return false, "ViewportPreview accepts a Model or BasePart"
        end
        local fresh
        if source then
            local success, result = pcall(function() return source:Clone() end)
            if not success or not result then
                self.Error = "无法克隆模型（检查 Archivable 属性）"
                showStatus(self.Error)
                return false, self.Error
            end
            fresh = result
            -- The clone is static preview content, never an executable game copy.
            for _, node in fresh:GetDescendants() do
                if node:IsA("LuaSourceContainer") then node:Destroy()
                elseif node:IsA("BasePart") then
                    node.Anchored = true
                    node.CanCollide = false
                    node.CanTouch = false
                    node.CanQuery = false
                end
            end
            if fresh:IsA("BasePart") then
                fresh.Anchored = true
                fresh.CanCollide = false
                fresh.CanTouch = false
                fresh.CanQuery = false
            end
            local partCount = fresh:IsA("BasePart") and 1 or 0
            for _, node in fresh:GetDescendants() do
                if node:IsA("BasePart") then partCount += 1 end
            end
            if partCount == 0 then
                fresh:Destroy()
                self.Error = "模型不包含可渲染的 BasePart"
                showStatus(self.Error)
                return false, self.Error
            end
        end
        if cloned then cloned:Destroy(); cloned = nil end
        self.Source = source
        self.Error = nil
        cloned = fresh
        center, fitDistance, modelSize = Vector3.zero, 6, Vector3.one
        if cloned then
            cloned.Parent = world
            local ok, cf, size = pcall(function()
                if cloned:IsA("Model") then return cloned:GetBoundingBox()
                else return cloned.CFrame, cloned.Size end
            end)
            if not ok or not cf or not size then
                cloned:Destroy()
                cloned = nil
                self.Error = "无法计算模型包围盒"
                showStatus(self.Error)
                return false, self.Error
            end
            center, modelSize = cf.Position, size
            fit()
            viewport.Visible = true
            fallback.Visible = false
        else
            showStatus("未设置预览模型 · 使用 SetModel(model) 显示 3D 对象")
        end
        self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1
        view()
        return true
    end
    function c:Get() return self.Source end
    function c:Clear() return self:SetModel(nil) end
    function c:SetObject(instance) return self:SetModel(instance) end
    function c:SetInteractive(on)
        self.Interactive = on == true
        viewport.Active = self.Interactive
    end
    function c:Rotate(deltaX, deltaY)
        self.Yaw += (tonumber(deltaX) or 0) * .008
        self.Pitch = math.clamp(self.Pitch + (tonumber(deltaY) or 0) * .008,
            math.rad(-75), math.rad(75))
        view()
    end
    function c:SetZoom(value)
        self.Zoom = math.clamp(tonumber(value) or 1, .6, 3.5)
        view()
    end
    function c:ResetView()
        self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1
        view()
    end
    function c:Destroy()
        if not alive then return end
        alive = false
        if self._previewDrag then self._previewDrag:Disconnect(); self._previewDrag = nil end
        if self._previewScrollConn then self._previewScrollConn:Disconnect(); self._previewScrollConn = nil end
        if self._previewResizeConn then self._previewResizeConn:Disconnect(); self._previewResizeConn = nil end
        if cloned then cloned:Destroy(); cloned = nil end
        if camera then camera:Destroy(); camera = nil end
        if world then world:Destroy(); world = nil end
        complexForgetControl(self)
        row:Destroy()
    end
    local lastPosition
    c._previewDrag = bindPointerDrag(hub, viewport, {
        Start = function(input)
            if not c.Interactive or not c:IsAvailable() then error("preview is not interactive") end
            lastPosition = Vector2.new(input.Position.X, input.Position.Y)
        end,
        Move = function(input)
            if not lastPosition then return end
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            c:Rotate(pos.X - lastPosition.X, pos.Y - lastPosition.Y)
            lastPosition = pos
        end,
        End = function() lastPosition = nil end,
    }, true)
    c._previewScrollConn = viewport.InputChanged:Connect(function(input)
        if c.Interactive and input.UserInputType == Enum.UserInputType.MouseWheel then
            c:SetZoom(c.Zoom * (input.Position.Z > 0 and .9 or 1.1))
        end
    end)
    c._previewResizeConn = viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if cloned then fit(); view() end
    end)
    local zoomOut = create("TextButton", {
        Name = "ZoomOut", Text = "−", Parent = surface,
        Position = UDim2.new(1, -72, 1, -30), Size = UDim2.fromOffset(29, 25),
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .12, TextColor3 = themeColor(theme, "Text"),
        TextSize = 16, AutoButtonColor = false, Visible = c.Interactive, ZIndex = 6,
    }, { corner(6) })
    local zoomIn = create("TextButton", {
        Name = "ZoomIn", Text = "+", Parent = surface,
        Position = UDim2.new(1, -37, 1, -30), Size = UDim2.fromOffset(29, 25),
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .12, TextColor3 = themeColor(theme, "Text"),
        TextSize = 16, AutoButtonColor = false, Visible = c.Interactive, ZIndex = 6,
    }, { corner(6) })
    hub:_connect(zoomOut.MouseButton1Click, function() c:SetZoom(c.Zoom * 1.2) end)
    hub:_connect(zoomIn.MouseButton1Click, function() c:SetZoom(c.Zoom / 1.2) end)
    hub:_connect(row.Destroying, function()
        if alive then c:Destroy() end
    end)
    local setInteractive = c.SetInteractive
    function c:SetInteractive(on)
        setInteractive(self, on)
        zoomOut.Visible, zoomIn.Visible = self.Interactive, self.Interactive
    end
    if c.Source then
        local success, why = c:SetModel(c.Source)
        if not success then c.Error = why end
    else showStatus("未设置预览模型 · 使用 SetModel(model) 显示 3D 对象") end
    return hub:_finishRequiredControl(c)
end
