-- RelaxUI overlay stack and unified global input router.
-- One registration per overlay; local widget pointer/drag interactions are kept intact.
-- Match the actual root-layer ZIndex order (ScreenGui uses Sibling).
-- A later API call may create an overlay behind a still-visible modal;
-- its input priority must NOT jump in front of the visible modal.
local INPUT_OVERLAY_PRIORITY = {
    SubTabs = 40,
    Window = 79,
    CommandPalette = 81,
    Setup = 95,
    Popup = 98,
    Prompt = 100,
}

local function overlayRelease(item)
    if item.DestroyConnection then
        item.DestroyConnection:Disconnect()
        item.DestroyConnection = nil
    end
end

local function overlayView(owner)
    if typeof(owner) == "Instance" then return owner end
    if type(owner) == "table" then return owner.Layer end
    return nil
end

function Hub:_overlayStackInit()
    if not self._overlayStack then
        self._overlayStack = {}
        self._overlaySerial = 0
    end
    return self._overlayStack
end

function Hub:_overlayRegister(kind, owner, options)
    assert(INPUT_OVERLAY_PRIORITY[kind], "unknown overlay kind")
    assert(owner ~= nil, "overlay owner is required")
    local stack = self:_overlayStackInit()
    -- Re-registering an owner changes its order without retaining old
    -- Destroying subscriptions or producing duplicate stack entries.
    self:_overlayUnregister(kind, owner)
    self._overlaySerial += 1
    local item = {
        Kind = kind, Owner = owner, Serial = self._overlaySerial,
        Priority = INPUT_OVERLAY_PRIORITY[kind],
        Content = options and options.Content,
        Anchor = options and options.Anchor,
        Close = options and options.Close,
        Outside = options and options.Outside ~= false,
        Escape = options and options.Escape ~= false,
        Modal = options and options.Modal == true,
    }
    local target = overlayView(owner)
    if target and target.Destroying then
        item.DestroyConnection = target.Destroying:Connect(function()
            self:_overlayUnregister(kind, owner)
        end)
    end
    local index = #stack + 1
    for i, existing in stack do
        if item.Priority < existing.Priority then
            index = i
            break
        end
    end
    table.insert(stack, index, item)
    return item
end

function Hub:_overlayUnregister(kind, owner)
    local stack = self._overlayStack
    if not stack then return false end
    local removed = false
    for i = #stack, 1, -1 do
        local item = stack[i]
        if (kind == nil or item.Kind == kind)
            and (owner == nil or item.Owner == owner) then
            table.remove(stack, i)
            overlayRelease(item)
            removed = true
        end
    end
    return removed
end

function Hub:_overlayTop()
    local stack = self._overlayStack
    return stack and stack[#stack] or nil
end

function Hub:GetOverlayStack()
    local snapshot = {}
    for i, item in self._overlayStack or {} do
        snapshot[i] = { Kind = item.Kind, Serial = item.Serial }
    end
    return snapshot
end

function Hub:_overlayContains(target, position)
    if not target or not target.Parent or target.Visible == false then return false end
    return within(target, position)
end

function Hub:_overlayDismiss(item, reason)
    if not item or self._overlayClosing then return false end
    local top = self:_overlayTop()
    if top ~= item then return false end
    self._overlayClosing = true
    local ok, err = pcall(function()
        if item.Close then item.Close(reason) end
    end)
    self._overlayClosing = false
    if not ok then warn("[RelaxUI OverlayStack] " .. tostring(err)) end
    -- Close callbacks normally unregister their own entry. If an owner failed
    -- or was already destroyed, discard the stale layer to prevent deadlocks.
    if self:_overlayTop() == item then
        self:_overlayUnregister(item.Kind, item.Owner)
    end
    return true
end

function Hub:_routeOverlayKey(key)
    local top = self:_overlayTop()
    if key ~= Enum.KeyCode.Escape then return false end
    if top then
        if top.Escape then return self:_overlayDismiss(top, "escape") end
        return true
    end
    if self._open then self:Close(); return true end
    return false
end

function Hub:_routeOverlayPointer(position)
    local top = self:_overlayTop()
    if not top then
        -- The orb is only interactive without a blocking overlay in front.
        return self.Restore and self:_overlayContains(self.Restore, position) or false
    end
    if self:_overlayContains(top.Content, position) then return true end
    if self:_overlayContains(top.Anchor, position) then return true end
    -- Only one layer can dismiss for a single pointer-down. Do not forward
    -- this same gesture to the panel or to overlays underneath it.
    if top.Outside then self:_overlayDismiss(top, "outside") end
    return true
end

function Hub:_overlayClear()
    self._overlayClosing = false
    if self._overlayStack then
        for _, entry in self._overlayStack do overlayRelease(entry) end
        table.clear(self._overlayStack)
    end
end
