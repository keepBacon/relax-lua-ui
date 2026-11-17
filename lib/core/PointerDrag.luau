-- SPDX-License-Identifier: MPL-2.0
-- Per-hub pointer capture, touch cancellation and scroll ownership (Oasis-inspired).
local function bindPointerDrag(hub, handle: GuiObject, callbacks, scoped: boolean?)
    local pointer: InputObject? = nil
    local moveConn, endConn, stateConn, destroyConn
    local handleConn
    local locked = {}
    local binding = {}

    local function disconnectActive()
        if moveConn then moveConn:Disconnect() moveConn = nil end
        if endConn then endConn:Disconnect() endConn = nil end
        if stateConn then stateConn:Disconnect() stateConn = nil end
        for frame, previous in locked do
            pcall(function() frame.ScrollingEnabled = previous end)
            locked[frame] = nil
        end
    end

    local function stop(cancelled: boolean)
        if not pointer then return end
        pointer = nil
        disconnectActive()
        if hub._capturedDrag == binding then hub._capturedDrag = nil end
        if hub._activeDrags then hub._activeDrags[binding] = nil end
        if callbacks.End then
            local ok, err = pcall(callbacks.End, cancelled)
            if not ok then warn('[RiftUI] drag end: ' .. tostring(err)) end
        end
    end

    local function begin(input: InputObject)
        if hub._destroyed or pointer or not isPointer(input) then return end
        if hub._capturedDrag and hub._capturedDrag ~= binding then return end
        pointer = input
        hub._capturedDrag = binding
        hub._activeDrags = hub._activeDrags or {}
        hub._activeDrags[binding] = true
        if input.UserInputType == Enum.UserInputType.Touch then
            local node = handle.Parent
            while node and not node:IsA('LayerCollector') do
                if node:IsA('ScrollingFrame') then
                    locked[node] = node.ScrollingEnabled
                    node.ScrollingEnabled = false
                end
                node = node.Parent
            end
            stateConn = input:GetPropertyChangedSignal('UserInputState'):Connect(function()
                local state = input.UserInputState
                if state == Enum.UserInputState.Cancel or state == Enum.UserInputState.End then
                    stop(state == Enum.UserInputState.Cancel)
                end
            end)
        end
        if callbacks.Start then
            local ok, err = pcall(callbacks.Start, input)
            if not ok then
                warn('[RiftUI] drag start: ' .. tostring(err))
                stop(true)
                return
            end
        end
        if not pointer then return end
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if not pointer or hub._destroyed then return end
            local touch = pointer.UserInputType == Enum.UserInputType.Touch
            if (touch and changed == pointer) or (not touch and changed.UserInputType == Enum.UserInputType.MouseMovement) then
                if callbacks.Move then
                    local ok, err = pcall(callbacks.Move, changed)
                    if not ok then
                        warn('[RiftUI] drag move: ' .. tostring(err))
                        stop(true)
                    end
                end
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
            if not pointer then return end
            -- Touch must match the captured InputObject; mouse release is a separate event.
            local touch = pointer.UserInputType == Enum.UserInputType.Touch
            if (touch and ended == pointer) or
                (not touch and ended.UserInputType == Enum.UserInputType.MouseButton1) then
                stop(false)
            end
        end)
    end

    handleConn = scoped and handle.InputBegan:Connect(begin) or hub:_connect(handle.InputBegan, begin)
    function binding:Disconnect()
        stop(true)
        if handleConn then handleConn:Disconnect() handleConn = nil end
        if destroyConn then destroyConn:Disconnect() destroyConn = nil end
    end
    binding.Cancel = binding.Disconnect
    destroyConn = handle.Destroying:Connect(function() binding:Disconnect() end)
    return binding
end
