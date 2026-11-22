-- SPDX-License-Identifier: MPL-2.0
-- Shared empty/error/loading presentation. One static, bounded skeleton; no idle loop.
do
    function Hub:_createDataState(parent, options)
        options = type(options) == "table" and options or {}
        local hub = self
        local fill = options.FillParent == true
        local height = math.clamp(tonumber(options.Height) or 112, 64, 240)
        local root = create("Frame", {
            Name = "DataState", Parent = parent, BackgroundTransparency = 1,
            Size = fill and UDim2.fromScale(1, 1) or UDim2.new(1, 0, 0, height),
        })
        local icon = iconLabel(options.Icon or "inbox", 22, hub:GetToken("Color.TextMuted"), {
            Parent = root, AnchorPoint = Vector2.new(.5, 0),
            Position = UDim2.new(.5, 0, 0, 8),
        })
        local fallback
        if not icon then
            fallback = text({
                Name = "StateGlyph", Parent = root, Text = "—",
                TextColor3 = hub:GetToken("Color.TextMuted"), TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                Position = UDim2.new(.5, -14, 0, 7),
                Size = UDim2.fromOffset(28, 26),
            })
            hub:BindToken(fallback, "TextColor3", "Color.TextMuted")
        else
            hub:BindToken(icon, "ImageColor3", "Color.TextMuted")
        end
        local title = text({
            Name = "StateTitle", Parent = root,
            Text = tostring(options.Title or "暂无内容"),
            FontFace = inter(Enum.FontWeight.Medium), TextSize = 13,
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(8, 39),
            Size = UDim2.new(1, -16, 0, 20),
        })
        local detail = text({
            Name = "StateDescription", Parent = root,
            Text = tostring(options.Description or ""),
            TextWrapped = true, TextSize = 11,
            TextColor3 = hub:GetToken("Color.TextSecondary"),
            TextXAlignment = Enum.TextXAlignment.Center,
            Position = UDim2.fromOffset(12, 61),
            Size = UDim2.new(1, -24, 0, 30),
        })
        hub:BindToken(title, "TextColor3", "Color.TextPrimary")
        hub:BindToken(detail, "TextColor3", "Color.TextSecondary")
        local action = create("TextButton", {
            Name = "StateAction", Parent = root, Text = "",
            TextSize = 12, FontFace = inter(Enum.FontWeight.Medium),
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            BackgroundColor3 = hub:GetToken("Color.Surface2"),
            AnchorPoint = Vector2.new(.5, 1),
            Position = UDim2.new(.5, 0, 1, -5),
            Size = UDim2.fromOffset(116, 30),
            Visible = false, AutoButtonColor = false,
        }, { corner(7), stroke(hub:GetToken("Color.BorderSubtle"), 1, .55) })
        hub:BindToken(action, "BackgroundColor3", "Color.Surface2")
        hub:BindToken(action, "TextColor3", "Color.TextPrimary")
        local bars = create("Frame", {
            Name = "SkeletonRows", Parent = root, BackgroundTransparency = 1,
            Size = UDim2.new(1, -26, 1, -24),
            Position = UDim2.fromOffset(13, 12), Visible = false,
        }, { list(Enum.FillDirection.Vertical, 10) })
        for i = 1, math.clamp(tonumber(options.Rows) or 3, 1, 5) do
            local bar = create("Frame", {
                Name = "Skeleton_" .. i, Parent = bars, BorderSizePixel = 0,
                BackgroundColor3 = hub:GetToken("Color.SurfaceActive"),
                BackgroundTransparency = .28,
                Size = UDim2.new(i == 3 and .66 or (i % 2 == 0 and .83 or 1), 0, 0, 18),
                LayoutOrder = i,
            }, { corner(6) })
            hub:BindToken(bar, "BackgroundColor3", "Color.SurfaceActive")
        end
        local view = { Frame = root, Mode = "Empty", Action = nil, Destroyed = false }
        function view:SetAction(spec)
            self.Action = type(spec) == "table" and table.clone(spec) or nil
            action.Text = self.Action and tostring(self.Action.Text or "重试") or ""
            action.Visible = self.Mode ~= "Loading" and self.Action ~= nil
            return self
        end
        function view:Set(mode, data)
            if self.Destroyed then return false end
            assert(mode == "Loading" or mode == "Empty" or mode == "Error",
                "DataState mode must be Empty/Loading/Error")
            data = type(data) == "table" and data or {}
            self.Mode = mode
            local loading = mode == "Loading"
            bars.Visible = loading
            title.Visible, detail.Visible = not loading, not loading
            if icon then icon.Visible = not loading end
            if fallback then fallback.Visible = not loading end
            title.Text = tostring(data.Title or (mode == "Error" and "加载失败"
                or options.Title or "暂无内容"))
            detail.Text = tostring(data.Description or (mode == "Error" and "请重试"
                or options.Description or ""))
            action.Visible = not loading and self.Action ~= nil
            return true
        end
        function view:Destroy()
            if self.Destroyed then return end
            self.Destroyed = true
            root:Destroy()
        end
        action.MouseButton1Click:Connect(function()
            if view.Destroyed or not view.Action or not view.Action.Callback
                or (options.CanAct and not options.CanAct()) then return end
            local ok, err = pcall(view.Action.Callback)
            if not ok then warn("[RelaxUI EmptyState] " .. tostring(err)) end
        end)
        view:SetAction(options.Action)
        view:Set(options.State or "Empty")
        return view
    end

    function Section:EmptyState(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(math.clamp(tonumber(options.Height) or 112, 64, 240),
            "EmptyState_" .. tostring(options.Name or ""))
        local kind = options._componentType == "Skeleton" and "Skeleton" or "EmptyState"
        local c = self:_control(kind, options, row)
        local state = hub:_createDataState(row, {
            State = options.State or (kind == "Skeleton" and "Loading" or "Empty"),
            Title = options.Title or options.Name, Description = options.Description,
            Icon = options.Icon, Rows = options.Rows, Height = options.Height,
            CanAct = function() return c:IsAvailable() end,
            Action = options.Action,
        })
        c.Value = state.Mode
        function c:Get() return self.Value end
        function c:Set(mode, silent)
            if type(mode) == "table" then
                local data = mode
                mode = data.State or self.Value
                if data.Action ~= nil then state:SetAction(data.Action) end
                if not state:Set(mode, data) then return false end
            elseif not state:Set(mode) then return false end
            self.Value = mode
            if not silent then self:_emit(mode) end
            return true
        end
        function c:SetLoading(on)
            return self:Set(on and "Loading" or "Empty", true)
        end
        function c:SetError(message)
            return self:Set({ State = "Error", Description = tostring(message or "") }, true)
        end
        function c:SetAction(actionSpec) state:SetAction(actionSpec) end
        function c:Destroy()
            if self._disposed then return end
            self._disposed = true
            if self.Flag and RiftUI.Flags[self.Flag] == self then RiftUI.Flags[self.Flag] = nil end
            local index = table.find(self.Section.Controls, self)
            if index then table.remove(self.Section.Controls, index) end
            for i = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[i].Result == self then table.remove(hub._recipe, i) end
            end
            local parent = self._moduleCard
            if parent and parent._moduleControls then
                local i = table.find(parent._moduleControls, self)
                if i then table.remove(parent._moduleControls, i) end
            end
            for subscription in self._dataSubscriptions or {} do subscription:Disconnect() end
            state:Destroy()
            row:Destroy()
        end
        row.Destroying:Connect(function() c._disposed = true; state.Destroyed = true end)
        return hub:_finishRequiredControl(c)
    end

    function Section:Skeleton(options)
        options = type(options) == "table" and table.clone(options) or {}
        options._componentType = "Skeleton"
        options.State = "Loading"
        return self:EmptyState(options)
    end
end
