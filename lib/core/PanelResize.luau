-- SPDX-License-Identifier: MPL-2.0
-- Native bottom-right resizer. One captured touch/mouse pointer per hub;
-- redraws the actual panel layout rather than scaling rendered text.
do
    function Hub:GetPanelSize()
        if self.PanelHolder then
            return Vector2.new(self.PanelHolder.Size.X.Offset, self.PanelHolder.Size.Y.Offset)
        end
        return Vector2.new(620, 380)
    end

    function Hub:SetPanelSize(width, height, save)
        if self._destroyed then return false end
        if type(width) ~= "number" or type(height) ~= "number"
            or width ~= width or height ~= height then return false end
        local vp = viewport() / math.max(self._scale, .01)
        local maxWidth = math.max(240, vp.X - 24)
        local maxHeight = math.max(160, vp.Y - topInset() / self._scale
            - self:_dockBottom() - 78)
        local target = {
            Width = math.clamp(width, math.min(340, maxWidth), maxWidth),
            Height = math.clamp(height, math.min(260, maxHeight), maxHeight),
        }
        self._panelSizeOverride = target
        if self._open then self:_fitPanel(self._open, false) end
        if save ~= false then self:_savePref("PanelSize", target) end
        return true
    end

    function Hub:ResetPanelSize()
        if self._destroyed then return end
        self._panelSizeOverride = nil
        self:_savePref("PanelSize", nil)
        if self._open then self:_fitPanel(self._open, false) end
    end

    function Hub:_setupPanelResize()
        if self.Options.Resizable == false then return end
        local grip = create("TextButton", {
            Name = "PanelResizeGrip", BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, Active = true,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.fromOffset(34, 34),
            ZIndex = 19, Parent = self.PanelHolder,
        })
        -- Three quiet diagonal grooves, no image asset dependency.
        for i = 0, 2 do
            create("Frame", {
                Name = "GripLine" .. tostring(i + 1),
                BackgroundColor3 = themeColor(self.Theme, "SubText"),
                BackgroundTransparency = .34, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.new(1, -(8 + i * 5), 1, -(13 + i * 5)),
                Rotation = -45,
                Size = UDim2.fromOffset(10, 2), ZIndex = 20, Parent = grip,
            }, { corner(2) })
        end
        local startPoint, startSize
        self._panelResizeGrip = grip
        self._panelResizeBinding = bindPointerDrag(self, grip, {
            Start = function(input)
                if not self._open then return end
                Motion.cancel(self, "panel-geometry")
                startPoint = Vector2.new(input.Position.X, input.Position.Y)
                startSize = self:GetPanelSize()
            end,
            Move = function(input)
                if not startPoint or not startSize or not self._open then return end
                local delta = (Vector2.new(input.Position.X, input.Position.Y) -
                    startPoint) / math.max(self._scale, .01)
                -- PanelHolder is center-anchored. Double delta so the
                -- bottom-right corner stays under the captured pointer.
                self:SetPanelSize(startSize.X + 2 * delta.X,
                    startSize.Y + 2 * delta.Y, false)
            end,
            End = function(cancelled)
                if startPoint and not cancelled and self._panelSizeOverride then
                    self:_savePref("PanelSize", self._panelSizeOverride)
                end
                startPoint, startSize = nil, nil
            end,
        }, true)
    end
end
