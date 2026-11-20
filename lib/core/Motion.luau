-- Motion runtime, inlined by scripts/bundle.mjs.
-- One owner per instance/property avoids overlapping tweens and unbounded listeners.
local motionByInstance = setmetatable({}, { __mode = "k" })
local motionTargets = setmetatable({}, { __mode = "k" })

local function cancelMotion(inst: Instance)
	local properties = motionByInstance[inst]
	if not properties then return end
	local seen = {}
	for _, active in properties do
		if not seen[active] then
			seen[active] = true
			active:Cancel()
		end
	end
	motionByInstance[inst] = nil
	motionTargets[inst] = nil
end

local function cancelHubMotion(gui: Instance?)
	if not gui then return end
	cancelMotion(gui)
	for _, inst in gui:GetDescendants() do
		cancelMotion(inst)
	end
end

local function tween(inst: Instance, info: TweenInfo, goals)
	local resolved = {}
	for prop, value in goals do
		if type(value) == "table" and rawget(value, "_theme") then
			local bindings = themeBindings[inst] or {}
			themeBindings[inst] = bindings
			bindings[prop] = value
			resolved[prop] = value._theme[value._key]
		else
			resolved[prop] = value
		end
	end
	local active = motionByInstance[inst]
	if not active then
		active = {}
		motionByInstance[inst] = active
	end
	local targets = motionTargets[inst] or {}
	local sameTween, identical = nil, true
	for prop, target in resolved do
		local current = targets[prop]
		if not current or current.Value ~= target or current.Info ~= info or
			(sameTween and sameTween ~= current.Tween) then
			identical = false
			break
		end
		sameTween = current.Tween
	end
	if identical and sameTween then return sameTween end
	local conflicting = {}
	for prop in resolved do
		local previous = active[prop]
		if previous then conflicting[previous] = true end
	end
	for previous in conflicting do previous:Cancel() end

	local tw = TweenService:Create(inst, info, resolved)
	motionTargets[inst] = targets
	for prop, target in resolved do
		active[prop] = tw
		targets[prop] = { Tween = tw, Value = target, Info = info }
	end
	local completed
	completed = tw.Completed:Connect(function()
		if completed then completed:Disconnect() completed = nil end
		for prop in resolved do
			if active[prop] == tw then active[prop] = nil end
			local target = targets[prop]
			if target and target.Tween == tw then targets[prop] = nil end
		end
		if not next(active) then
			motionByInstance[inst] = nil
			motionTargets[inst] = nil
		end
	end)
	tw:Play()
	return tw
end

-- Unified owner/id state transitions.  All component animations still use
-- the property-aware tween() above, so this does not create a second tween
-- registry.  A superseding state cancels the previous group as a unit.
local Motion = {}
Motion.Presets = {
    Micro = TweenInfo.new(.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Control = TweenInfo.new(.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Panel = TweenInfo.new(.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Ripple = TweenInfo.new(.52, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Dismiss = TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
}

local motionByOwner = setmetatable({}, { __mode = "k" })

local function dropMotionEntry(entry)
    if entry.Cancelled then return end
    entry.Cancelled = true
    for _, conn in entry.Connections do conn:Disconnect() end
    table.clear(entry.Connections)
    for _, active in entry.Tweens do active:Cancel() end
    table.clear(entry.Tweens)
end

function Motion.cancel(owner, id)
    local slots = motionByOwner[owner]
    if not slots then return end
    local entry = slots[id]
    if not entry then return end
    slots[id] = nil
    dropMotionEntry(entry)
    if not next(slots) then motionByOwner[owner] = nil end
end

function Motion.cancelAll(owner)
    local slots = motionByOwner[owner]
    if not slots then return end
    motionByOwner[owner] = nil
    for _, entry in slots do dropMotionEntry(entry) end
    table.clear(slots)
end

function Motion.getState(owner, id)
    local slots = motionByOwner[owner]
    local entry = slots and slots[id]
    return entry and entry.State or nil
end

function Motion.transition(owner, id, state, steps, preset, onComplete)
    assert(type(owner) == "table", "Motion owner must be a table")
    assert(id ~= nil, "Motion transition requires an id")
    if owner._destroyed then return nil end
    Motion.cancel(owner, id)
    local slots = motionByOwner[owner]
    if not slots then
        slots = {}
        motionByOwner[owner] = slots
    end
    local entry = { State = state, Tweens = {}, Connections = {}, Cancelled = false, Done = false }
    slots[id] = entry
    local count = 0
    local function finish()
        if entry.Cancelled or entry.Done or slots[id] ~= entry then return end
        entry.Done = true
        for _, conn in entry.Connections do conn:Disconnect() end
        table.clear(entry.Connections)
        table.clear(entry.Tweens)
        if onComplete and not owner._destroyed then onComplete(state) end
    end
    for _, step in steps or {} do
        local target = step.Target or step[1]
        local goals = step.Goals or step[2]
        if target and goals and target.Parent then
            count += 1
            local active = tween(target, step.Info or step.Preset or preset or Motion.Presets.Control, goals)
            table.insert(entry.Tweens, active)
            local conn = active.Completed:Connect(function(playback)
                if entry.Cancelled or slots[id] ~= entry then return end
                if playback ~= Enum.PlaybackState.Completed then
                    -- A competing property animation superseded this group.
                    Motion.cancel(owner, id)
                    return
                end
                count -= 1
                if count == 0 then finish() end
            end)
            table.insert(entry.Connections, conn)
        end
    end
    if count == 0 then finish() end
    return entry
end

function Motion.play(owner, id, target, goals, preset, onComplete)
    return Motion.transition(owner, id, id, {
        { Target = target, Goals = goals },
    }, preset, onComplete)
end

RiftUI.Motion = Motion
