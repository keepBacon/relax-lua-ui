-- SPDX-License-Identifier: MPL-2.0
-- Coalesce continuous input callbacks, leaving state/UI updates immediate.
local continuousControls = { Slider = true, RangeSlider = true, ColorPicker = true }
local queuedControlCallbacks = setmetatable({}, { __mode = 'k' })

local function scheduleControlCallback(control, args, callback)
    local hub = control.Section.Hub
    if hub._destroyed then return end
    if not continuousControls[control.Type] then
        task.spawn(function()
            if not hub._destroyed then callback(args) end
        end)
        return
    end
    local pending = queuedControlCallbacks[control]
    if pending then pending.Args = args return end
    pending = { Args = args }
    queuedControlCallbacks[control] = pending
    task.defer(function()
        if queuedControlCallbacks[control] ~= pending then return end
        queuedControlCallbacks[control] = nil
        if not hub._destroyed then callback(pending.Args) end
    end)
end

local function cancelHubCallbacks(hub)
    for control in queuedControlCallbacks do
        if control.Section.Hub == hub then
            queuedControlCallbacks[control] = nil
        end
    end
end
