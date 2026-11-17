-- Motion runtime, inlined by scripts/bundle.mjs.
-- One owner per instance/property avoids overlapping tweens and unbounded listeners.
local motionByInstance = setmetatable({}, { __mode = "k" })

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
	local conflicting = {}
	for prop in resolved do
		local previous = active[prop]
		if previous then conflicting[previous] = true end
	end
	for previous in conflicting do previous:Cancel() end

	local tw = TweenService:Create(inst, info, resolved)
	for prop in resolved do active[prop] = tw end
	local completed
	completed = tw.Completed:Connect(function()
		if completed then completed:Disconnect() completed = nil end
		for prop in resolved do
			if active[prop] == tw then active[prop] = nil end
		end
		if not next(active) then motionByInstance[inst] = nil end
	end)
	tw:Play()
	return tw
end
