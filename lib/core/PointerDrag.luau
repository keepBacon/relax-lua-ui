-- Pointer capture shared by sliders, floating cards and colour pickers.
-- Global input listeners only exist while a pointer is active.
local function bindPointerDrag(hub, handle: GuiObject, callbacks, scoped: boolean?)
	local pointer = nil
	local moveConn, endConn
	local handleConn
	local binding = {}

	local function stop(cancelled)
		if not pointer then return end
		pointer = nil
		if moveConn then moveConn:Disconnect() moveConn = nil end
		if endConn then endConn:Disconnect() endConn = nil end
		if hub._activeDrags then hub._activeDrags[binding] = nil end
		if callbacks.End then callbacks.End(cancelled) end
	end
	local function begin(input)
		if hub._destroyed or pointer or not isPointer(input) then return end
		pointer = input
		hub._activeDrags = hub._activeDrags or {}
		hub._activeDrags[binding] = true
		if callbacks.Start then callbacks.Start(input) end
		if not pointer then return end
		moveConn = UserInputService.InputChanged:Connect(function(changed)
			if not pointer or hub._destroyed then return end
			local isTouch = pointer.UserInputType == Enum.UserInputType.Touch
			if (isTouch and changed == pointer) or (not isTouch and changed.UserInputType == Enum.UserInputType.MouseMovement) then
				if callbacks.Move then callbacks.Move(changed) end
			end
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if not pointer then return end
			if ended == pointer then stop(false) end
		end)
	end
	handleConn = scoped and handle.InputBegan:Connect(begin) or hub:_connect(handle.InputBegan, begin)
	function binding:Disconnect()
		stop(true)
		if handleConn then handleConn:Disconnect() handleConn = nil end
	end
	binding.Cancel = binding.Disconnect
	return binding
end
