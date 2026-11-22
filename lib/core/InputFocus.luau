-- SPDX-License-Identifier: MPL-2.0
-- Hub-owned keyboard, pointer, text and overlay focus coordination.
-- This is an input ownership layer, not a second event router.
do
    local function liveInHub(hub, node)
        if not node or not hub.Gui then return false end
        local ok, valid = pcall(function()
            return node:IsDescendantOf(hub.Gui) and node.Visible ~= false
        end)
        return ok and valid == true
    end

    function Hub:_inputFocusInit()
        if self._inputFocus then return self._inputFocus end
        local state = {
            Pointer = nil, PointerOwner = nil,
            KeyboardOwner = nil, KeyboardCancel = nil,
            FocusHistory = {}, FocusSerial = 0, NavIndex = 0,
        }
        self._inputFocus = state
        return state
    end

    function Hub:_inputGetState()
        local state = self:_inputFocusInit()
        return {
            PointerCaptured = state.Pointer ~= nil,
            KeyboardCaptured = state.KeyboardOwner ~= nil,
            OverlayDepth = #state.FocusHistory,
        }
    end

    function Hub:_inputClaimPointer(owner, input)
        if self._destroyed or not owner or not input then return false end
        local state = self:_inputFocusInit()
        if state.Pointer and (state.Pointer ~= input or state.PointerOwner ~= owner) then
            return false
        end
        state.Pointer = input
        state.PointerOwner = owner
        return true
    end

    function Hub:_inputReleasePointer(owner, input)
        local state = self._inputFocus
        if not state or state.PointerOwner ~= owner then return false end
        if input and state.Pointer ~= input then return false end
        state.Pointer, state.PointerOwner = nil, nil
        return true
    end

    function Hub:_inputBeginCapture(owner, cancel)
        if self._destroyed or not owner then return false end
        local state = self:_inputFocusInit()
        if state.KeyboardOwner and state.KeyboardOwner ~= owner then
            -- An earlier keybind capture must be cancelled before switching.
            local old = state.KeyboardCancel
            state.KeyboardOwner, state.KeyboardCancel = nil, nil
            if old then pcall(old) end
        end
        state.KeyboardOwner = owner
        state.KeyboardCancel = cancel
        self._listening = true
        return true
    end

    function Hub:_inputEndCapture(owner)
        local state = self._inputFocus
        if not state or state.KeyboardOwner ~= owner then return false end
        state.KeyboardOwner, state.KeyboardCancel = nil, nil
        self._listening = false
        return true
    end

    function Hub:_inputIsEditing()
        local ok, box = pcall(function() return UserInputService:GetFocusedTextBox() end)
        return ok and box ~= nil
    end

    function Hub:_inputCanShortcut(gameProcessed)
        return not self._destroyed and not gameProcessed
            and not self._listening and not self:_inputIsEditing()
    end

    function Hub:_inputOverlayOpened(kind, owner, content)
        if self._destroyed or not owner then return end
        local state = self:_inputFocusInit()
        if state.PointerOwner and kind ~= "SubTabs" then
            local cancel = state.PointerOwner.CancelActive
            if type(cancel) == "function" then
                pcall(cancel, state.PointerOwner)
            end
        end
        for _, entry in state.FocusHistory do
            if entry.Owner == owner then return end
        end
        local ok, box = pcall(function() return UserInputService:GetFocusedTextBox() end)
        if not ok or not liveInHub(self, box) then box = nil end
        local selected
        pcall(function() selected = GuiService.SelectedObject end)
        if not liveInHub(self, selected) then selected = nil end
        state.FocusSerial += 1
        table.insert(state.FocusHistory, {
            Owner = owner, Kind = kind, Content = content,
            TextBox = box, Selected = selected, Serial = state.FocusSerial,
        })
        state.NavIndex = 0
        -- Do not leave a text cursor editing an obscured input field.
        if box and kind ~= "Popup" then
            pcall(function() box:ReleaseFocus() end)
        end
    end

    function Hub:_inputOverlayClosed(owner)
        local state = self._inputFocus
        if not state or not owner then return end
        local matched
        for i = #state.FocusHistory, 1, -1 do
            if state.FocusHistory[i].Owner == owner then
                matched = table.remove(state.FocusHistory, i)
                break
            end
        end
        if not matched then return end
        state.FocusSerial += 1
        local serial = state.FocusSerial
        state.NavIndex = 0
        task.defer(function()
            if self._destroyed or not self._inputFocus
                or self._inputFocus.FocusSerial ~= serial then return end
            local top = self:_overlayTop()
            local function unblocked(node)
                return liveInHub(self, node) and (not top or
                    (top.Content and node:IsDescendantOf(top.Content)))
            end
            if not unblocked(matched.TextBox) and not unblocked(matched.Selected) then
                return
            end
            -- Do not overwrite a fresh focus chosen after dismissal.
            if self:_inputIsEditing() then return end
            if unblocked(matched.TextBox) then
                pcall(function() matched.TextBox:CaptureFocus() end)
            elseif unblocked(matched.Selected) then
                pcall(function() GuiService.SelectedObject = matched.Selected end)
            end
        end)
    end

    function Hub:_inputNavigate(direction)
        if self._destroyed or self:_inputIsEditing() then return false end
        local top = self:_overlayTop()
        if not top or not top.Content or not top.Content.Parent then return false end
        if top.Kind ~= "Prompt" and top.Kind ~= "CommandPalette"
            and top.Kind ~= "Popup" and top.Kind ~= "Setup" then return false end
        local nodes = {}
        for _, node in top.Content:GetDescendants() do
            if (node:IsA("TextButton") or node:IsA("ImageButton") or node:IsA("TextBox"))
                and node.Visible ~= false and node.Active ~= false then
                local visible = true
                local ancestor = node.Parent
                while ancestor and ancestor ~= top.Content do
                    if ancestor:IsA("GuiObject") and ancestor.Visible == false then
                        visible = false
                        break
                    end
                    ancestor = ancestor.Parent
                end
                if visible then table.insert(nodes, node) end
            end
        end
        if #nodes == 0 then return false end
        local current
        pcall(function() current = GuiService.SelectedObject end)
        local index = table.find(nodes, current) or self:_inputFocusInit().NavIndex
        if index == 0 and direction < 0 then index = #nodes + 1 end
        index = (index + (direction < 0 and -2 or 0)) % #nodes + 1
        self._inputFocus.NavIndex = index
        local target = nodes[index]
        -- Prefer engine-managed selection for both keyboard and gamepad;
        -- selecting an object must not synthesize a click or submit.
        pcall(function() GuiService.SelectedObject = target end)
        return true
    end

    function Hub:_inputFocusDispose()
        local state = self._inputFocus
        if not state then return end
        if state.KeyboardCancel then pcall(state.KeyboardCancel) end
        state.Pointer, state.PointerOwner = nil, nil
        state.KeyboardOwner, state.KeyboardCancel = nil, nil
        table.clear(state.FocusHistory)
        self._inputFocus = nil
        self._listening = false
    end
end
