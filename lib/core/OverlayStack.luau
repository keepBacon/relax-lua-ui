-- RelaxUI overlay stack and unified global input router.
-- One registration per overlay; local widget pointer/drag interactions are kept intact.
local INPUT_OVERLAY_KINDS = {
    Popup = true, SubTabs = true, Window = true, CommandPalette = true,
    Prompt = true, Setup = true,
}

function Hub:_overlayStackInit()
    if not self._overlayStack then
        self._overlayStack = {}
        self._overlaySerial = 0
    end
    return self._overlayStack
end

function Hub:_overlayRegister(kind, owner, options)
    assert(INPUT_OVERLAY_KINDS[kind], "unknown overlay kind")
    local stack = self:_overlayStackInit()
    -- Registering the same overlay moves it to the top without duplicates.
    for i = #stack, 1, -1 do
        if stack[i].Owner == owner and stack[i].Kind == kind then
            table.remove(stack, i)
        end
    end
    self._overlaySerial += 1
    local item = {
        Kind = kind, Owner = owner, Serial = self._overlaySerial,
        Content = options and options.Content,
        Anchor = options and options.Anchor,
        Close = options and options.Close,
        Outside = options and options.Outside ~= false,
        Escape = options and options.Escape ~= false,
        Modal = options and options.Modal == true,
    }
    table.insert(stack, item)
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
    if self._overlayStack then table.clear(self._overlayStack) end
end
