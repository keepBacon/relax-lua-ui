-- SPDX-License-Identifier: MPL-2.0
-- Invisible bottom-right resize hit target, with independent geometry per page.
-- All touch/mouse capture continues to use the hub-owned PointerDrag manager.
do
    function Hub:_panelSizeKey(tab)
        local page = tab and self:_contentTab(tab)
        if not page then return nil end
        local primary = page.ParentTab or page
        local group = primary.Group
        -- Include primary tab and group to distinguish identical child names.
        local prefix = tostring(group and group.Name or "Main") .. "/" .. tostring(primary.Name)
        if page.IsSubTab then
            return prefix .. "/sub/" .. tostring(page.Name)
        end
        return prefix .. "/main"
    end

    function Hub:_panelSizeFor(tab)
        local key = self:_panelSizeKey(tab)
        local size = key and self._panelSizes and self._panelSizes[key]
        if type(size) ~= "table" then return nil end
        local w, h = tonumber(size.Width), tonumber(size.Height)
        if not w or not h or w ~= w or h ~= h then return nil end
        return { Width = w, Height = h }
    end

    function Hub:_savePanelSize(key)
        if not key or not self._panelSizes then return end
        self:_savePref("PanelSizes", table.clone(self._panelSizes))
    end

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
        local page = self._open or self.Tabs[1]
        local key = self:_panelSizeKey(page)
        if not key then return false end
        local vp = viewport() / math.max(self._scale, .01)
        local maxWidth = math.max(240, vp.X - 24)
        local maxHeight = math.max(160, vp.Y - topInset() / self._scale
            - self:_dockBottom() - 78)
        local size = {
            Width = math.clamp(width, math.min(340, maxWidth), maxWidth),
            Height = math.clamp(height, math.min(260, maxHeight), maxHeight),
        }
        self._panelSizes = self._panelSizes or {}
        self._panelSizes[key] = size
        if self._open then self:_fitPanel(self._open, false) end
        if save ~= false then self:_savePanelSize(key) end
        return true
    end

    function Hub:ResetPanelSize()
        if self._destroyed then return end
        local key = self:_panelSizeKey(self._open or self.Tabs[1])
        if not key then return end
        self._panelSizes = self._panelSizes or {}
        self._panelSizes[key] = nil
        self:_savePanelSize(key)
        if self._open then self:_fitPanel(self._open, false) end
    end

    function Hub:_setupPanelResize()
        if self.Options.Resizable == false then return end
        -- The 34x34 target remains draggable but has NO grooves or visual mark.
        local grip = create("TextButton", {
            Name = "PanelResizeGrip", BackgroundTransparency = 1, TextTransparency = 1,
            Text = "", AutoButtonColor = false, Active = true,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.fromOffset(34, 34),
            ZIndex = 19, Parent = self.PanelHolder,
        })
        local startPoint, startSize, startPage, startKey
        self._panelResizeGrip = grip
        self._panelResizeBinding = bindPointerDrag(self, grip, {
            Start = function(input)
                if not self._open then return end
                Motion.cancel(self, "panel-geometry")
                startPage = self:_contentTab(self._open)
                startKey = self:_panelSizeKey(startPage)
                startPoint = Vector2.new(input.Position.X, input.Position.Y)
                startSize = self:GetPanelSize()
            end,
            Move = function(input)
                if not startPoint or not startSize or not self._open
                    or startPage ~= self:_contentTab(self._open) then return end
                local delta = (Vector2.new(input.Position.X, input.Position.Y) -
                    startPoint) / math.max(self._scale, .01)
                -- Center anchored: double delta to keep the bottom-right corner
                -- under the drag pointer. Refit only the active page.
                self:SetPanelSize(startSize.X + 2 * delta.X,
                    startSize.Y + 2 * delta.Y, false)
            end,
            End = function(cancelled)
                if startPoint and not cancelled and startKey
                    and self:_panelSizeKey(self._open) == startKey
                    and self._panelSizes and self._panelSizes[startKey] then
                    self:_savePanelSize(startKey)
                end
                startPoint, startSize, startPage, startKey = nil, nil, nil, nil
            end,
        }, true)
    end
end
