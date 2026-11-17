local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local Debris = cloneref(game:GetService("Debris"))
local SoundService = cloneref(game:GetService("SoundService"))

local SoundManager = {
	WindUI = nil,
	Request = http_request or (syn and syn.request) or request,
	Cache = {},
	Loading = {},
	LastPlayed = {},
	Warned = {},
}

local DEFAULT_BASE_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/sounds"
local FALLBACK_SOUND = "rbxasset://sounds/electronicpingshort.wav"

local Events = {
	"Hover",
	"Click",
	"Tab",
	"ToggleOn",
	"ToggleOff",
	"DropdownOpen",
	"DropdownClose",
	"Select",
	"SliderTick",
	"InputFocus",
	"InputSubmit",
	"Notification",
	"NotificationClose",
	"WindowOpen",
	"WindowClose",
	"Success",
	"Error",
}

local MUTED_EVENTS = {
	Notification = true,
	NotificationClose = true,
}

local Assets = {
	["soft-pop"] = "soft-pop.wav",
	["soft-tick"] = "soft-tick.wav",
	["minimal-tick"] = "minimal-tick.wav",
	["minimal-confirm"] = "minimal-confirm.wav",
	["error-buzz"] = "error-buzz.wav",
}

local Presets = {
	Soft = {
		Hover = { Sound = "soft-tick", Volume = 0.18, Pitch = 1.22 },
		Click = { Sound = "soft-tick", Volume = 0.72, Pitch = 1 },
		Tab = { Sound = "soft-pop", Volume = 0.62, Pitch = 1.06 },
		ToggleOn = { Sound = "soft-pop", Volume = 0.7, Pitch = 1.12 },
		ToggleOff = { Sound = "soft-tick", Volume = 0.55, Pitch = 0.86 },
		DropdownOpen = { Sound = "soft-pop", Volume = 0.54, Pitch = 1.2 },
		DropdownClose = { Sound = "soft-tick", Volume = 0.44, Pitch = 0.78 },
		Select = { Sound = "soft-tick", Volume = 0.62, Pitch = 1.08 },
		SliderTick = { Sound = "soft-tick", Volume = 0.24, Pitch = 1.28 },
		InputFocus = { Sound = "soft-tick", Volume = 0.34, Pitch = 1.16 },
		InputSubmit = { Sound = "soft-pop", Volume = 0.55, Pitch = 1 },
		Notification = false,
		NotificationClose = false,
		WindowOpen = { Sound = "soft-pop", Volume = 0.8, Pitch = 0.82 },
		WindowClose = { Sound = "soft-tick", Volume = 0.64, Pitch = 0.7 },
		Success = { Sound = "soft-pop", Volume = 0.82, Pitch = 1.18 },
		Error = { Sound = "error-buzz", Volume = 0.7, Pitch = 1 },
	},
	Minimal = {
		Hover = { Sound = "minimal-tick", Volume = 0.18, Pitch = 1.22 },
		Click = { Sound = "minimal-tick", Volume = 0.72, Pitch = 1 },
		Tab = { Sound = "minimal-confirm", Volume = 0.62, Pitch = 1.06 },
		ToggleOn = { Sound = "minimal-confirm", Volume = 0.7, Pitch = 1.12 },
		ToggleOff = { Sound = "minimal-tick", Volume = 0.55, Pitch = 0.86 },
		DropdownOpen = { Sound = "minimal-confirm", Volume = 0.54, Pitch = 1.2 },
		DropdownClose = { Sound = "minimal-tick", Volume = 0.44, Pitch = 0.78 },
		Select = { Sound = "minimal-tick", Volume = 0.62, Pitch = 1.08 },
		SliderTick = { Sound = "minimal-tick", Volume = 0.24, Pitch = 1.28 },
		InputFocus = { Sound = "minimal-tick", Volume = 0.34, Pitch = 1.16 },
		InputSubmit = { Sound = "minimal-confirm", Volume = 0.55, Pitch = 1 },
		Notification = false,
		NotificationClose = false,
		WindowOpen = { Sound = "minimal-confirm", Volume = 0.8, Pitch = 0.82 },
		WindowClose = { Sound = "minimal-tick", Volume = 0.64, Pitch = 0.7 },
		Success = { Sound = "minimal-confirm", Volume = 0.82, Pitch = 1.18 },
		Error = { Sound = "error-buzz", Volume = 0.7, Pitch = 1 },
	},
}

local RateLimits = {
	Hover = 0.075,
	SliderTick = 0.045,
	Click = 0.025,
	Tab = 0.04,
}

local function copyTable(value)
	local result = {}
	if typeof(value) == "table" then
		for key, item in pairs(value) do
			result[key] = typeof(item) == "table" and copyTable(item) or item
		end
	end
	return result
end

local function sanitize(value)
	return tostring(value):gsub("[^%w%-_]", "_"):sub(1, 80)
end

local function ensureFolder(path)
	if not makefolder then
		return
	end

	local current = ""
	for part in string.gmatch(path, "[^/]+") do
		current = current == "" and part or current .. "/" .. part
		if not isfolder or not isfolder(current) then
			pcall(makefolder, current)
		end
	end
end

local function mergeEntry(base, override)
	if override == false then
		return false
	end
	if typeof(override) == "string" then
		override = { Sound = override }
	end

	local result = copyTable(base)
	if typeof(override) == "table" then
		for key, value in pairs(override) do
			result[key] = value
		end
	end
	return result
end

function SoundManager:Init(WindUI)
	self.WindUI = WindUI
	self.Config = {
		Enabled = true,
		Preset = "Soft",
		Volume = 0.45,
		Pitch = 1,
		Folder = "VantaUI",
		BaseUrl = DEFAULT_BASE_URL,
		Overrides = {
			Notification = false,
			NotificationClose = false,
		},
		Assets = {},
	}
	self:_refreshMap()
	return self
end

function SoundManager:_warnOnce(key, message)
	if self.Warned[key] then
		return
	end
	self.Warned[key] = true
	warn("[VantaUI Sounds] " .. message)
end

function SoundManager:_download(url)
	local errors = {}

	if game.HttpGet then
		local success, body = pcall(function()
			return game:HttpGet(url)
		end)
		if success and typeof(body) == "string" and #body > 0 then
			return body
		end
		table.insert(errors, tostring(body))
	end

	if self.Request then
		local success, response = pcall(function()
			return self.Request({
				Url = url,
				Method = "GET",
				Headers = { ["User-Agent"] = "Roblox/Executor" },
			})
		end)
		local body = success and typeof(response) == "table" and (response.Body or response.body) or response
		if success and typeof(body) == "string" and #body > 0 then
			return body
		end
		table.insert(errors, tostring(response))
	end

	error("Unable to download sound: " .. table.concat(errors, "; "))
end

function SoundManager:_sourceFor(soundName)
	local source = self.Config.Assets[soundName] or Assets[soundName] or soundName
	if typeof(source) ~= "string" then
		return nil
	end

	if Assets[soundName] and not string.match(source, "^https?://") and not string.match(source, "^rbxasset") then
		return self.Config.BaseUrl:gsub("/+$", "") .. "/" .. source
	end

	return source
end

function SoundManager:_loadSoundId(soundName)
	local source = self:_sourceFor(soundName)
	if not source then
		return FALLBACK_SOUND
	end
	if string.match(source, "^rbxasset") or string.match(source, "^synasset") then
		return source
	end
	if not string.match(source, "^https?://") then
		return source
	end
	if self.Cache[source] then
		return self.Cache[source]
	end

	while self.Loading[source] do
		task.wait()
	end
	if self.Cache[source] then
		return self.Cache[source]
	end

	local getAsset = getcustomasset or getsynasset
	if not writefile or not getAsset then
		self:_warnOnce("unsupported", "This executor cannot load downloaded audio, so the built-in fallback sound is being used.")
		self.Cache[source] = FALLBACK_SOUND
		return FALLBACK_SOUND
	end

	self.Loading[source] = true
	local success, result = pcall(function()
		local cleanSource = source:match("^([^?#]+)") or source
		local extension = cleanSource:match("%.([%w]+)$") or "wav"
		local soundFolder = "WindUI/" .. sanitize(self.Config.Folder) .. "/sounds"
		local fileName = soundFolder .. "/" .. sanitize(soundName) .. "." .. string.lower(extension)
		ensureFolder(soundFolder)

		if not isfile or not isfile(fileName) then
			writefile(fileName, self:_download(source))
		end

		local loaded, asset = pcall(getAsset, fileName)
		if not loaded then
			writefile(fileName, self:_download(source))
			asset = getAsset(fileName)
		end
		return asset
	end)
	self.Loading[source] = nil

	if success and result then
		self.Cache[source] = result
		return result
	end

	self:_warnOnce(source, "Could not load " .. tostring(soundName) .. ": " .. tostring(result))
	self.Cache[source] = FALLBACK_SOUND
	return FALLBACK_SOUND
end

function SoundManager:_playEntry(eventName, entry, options)
	if MUTED_EVENTS[eventName] then
		return false
	end
	if not entry or entry == false or not entry.Sound then
		return false
	end

	options = options or {}
	local now = os.clock()
	local rateLimit = tonumber(options.RateLimit) or RateLimits[eventName] or 0
	if not options.Force and now - (self.LastPlayed[eventName] or 0) < rateLimit then
		return false
	end
	self.LastPlayed[eventName] = now

	task.spawn(function()
		local soundId = self:_loadSoundId(entry.Sound)
		local sound = Instance.new("Sound")
		sound.Name = "VantaUI_" .. sanitize(eventName)
		sound.SoundId = soundId
		sound.Volume = math.clamp((tonumber(options.Volume) or tonumber(entry.Volume) or 1) * self.Config.Volume, 0, 10)
		sound.PlaybackSpeed = math.clamp((tonumber(options.Pitch) or tonumber(entry.Pitch) or 1) * self.Config.Pitch, 0.25, 4)
		sound.Parent = SoundService
		sound:Play()
		Debris:AddItem(sound, 6)
	end)

	return true
end

function SoundManager:_refreshMap()
	self.ActiveMap = copyTable(Presets[self.Config.Preset] or Presets.Soft)
	for eventName, override in pairs(self.Config.Overrides) do
		self.ActiveMap[eventName] = mergeEntry(self.ActiveMap[eventName], override)
	end
	self.ActiveMap.Notification = false
	self.ActiveMap.NotificationClose = false
end

function SoundManager:Configure(config)
	if config == false then
		self.Config.Enabled = false
		return self:GetConfig()
	end

	config = config or {}
	if config.Enabled ~= nil then
		self.Config.Enabled = config.Enabled == true
	end
	if config.Preset and Presets[config.Preset] then
		self.Config.Preset = config.Preset
	end
	if config.Volume ~= nil then
		self.Config.Volume = math.clamp(tonumber(config.Volume) or self.Config.Volume, 0, 2)
	end
	if config.Pitch ~= nil then
		self.Config.Pitch = math.clamp(tonumber(config.Pitch) or self.Config.Pitch, 0.5, 2)
	end
	if config.Folder then
		self.Config.Folder = tostring(config.Folder)
	end
	if config.BaseUrl then
		self.Config.BaseUrl = tostring(config.BaseUrl)
	end
	if typeof(config.Assets) == "table" then
		for name, source in pairs(config.Assets) do
			self.Config.Assets[name] = source
		end
	end
	if typeof(config.Overrides) == "table" then
		for eventName, entry in pairs(config.Overrides) do
			if not MUTED_EVENTS[eventName] then
				self.Config.Overrides[eventName] = typeof(entry) == "table" and copyTable(entry) or entry
			end
		end
	end

	self.Config.Overrides.Notification = false
	self.Config.Overrides.NotificationClose = false
	self:_refreshMap()

	if self.Config.Enabled then
		self:PreloadPreset()
	end

	return self:GetConfig()
end

function SoundManager:SetEnabled(value)
	self.Config.Enabled = value == true
	if self.Config.Enabled then
		self:PreloadPreset()
	end
	return self.Config.Enabled
end

function SoundManager:SetPreset(name)
	if not Presets[name] then
		return false
	end
	self.Config.Preset = name
	self:_refreshMap()
	if self.Config.Enabled then
		self:PreloadPreset()
	end
	return true
end

function SoundManager:SetVolume(value)
	self.Config.Volume = math.clamp(tonumber(value) or self.Config.Volume, 0, 2)
	return self.Config.Volume
end

function SoundManager:SetPitch(value)
	self.Config.Pitch = math.clamp(tonumber(value) or self.Config.Pitch, 0.5, 2)
	return self.Config.Pitch
end

function SoundManager:SetSoundForEvent(eventName, sound, options)
	if not table.find(Events, eventName) then
		return false
	end
	if MUTED_EVENTS[eventName] then
		self.Config.Overrides[eventName] = false
		self:_refreshMap()
		return false
	end

	if sound == false then
		self.Config.Overrides[eventName] = false
	else
		local entry = typeof(sound) == "table" and copyTable(sound) or copyTable(options)
		if typeof(sound) == "string" then
			entry.Sound = sound
		end
		self.Config.Overrides[eventName] = entry
	end

	self:_refreshMap()
	return true
end

function SoundManager:ClearSoundOverride(eventName)
	if MUTED_EVENTS[eventName] then
		self.Config.Overrides[eventName] = false
	else
		self.Config.Overrides[eventName] = nil
	end
	self:_refreshMap()
end

function SoundManager:ClearSoundOverrides()
	self.Config.Overrides = {
		Notification = false,
		NotificationClose = false,
	}
	self:_refreshMap()
end

function SoundManager:Play(eventName, options)
	options = options or {}
	if MUTED_EVENTS[eventName] then
		return false
	end
	if not self.Config.Enabled and not options.Force then
		return false
	end
	return self:_playEntry(eventName, self.ActiveMap[eventName], options)
end

function SoundManager:Preview(soundName, options)
	options = copyTable(options)
	options.Force = true
	return self:_playEntry("Preview_" .. tostring(soundName), {
		Sound = soundName,
		Volume = 0.82,
		Pitch = 1,
	}, options)
end

function SoundManager:PreloadPreset()
	if not self.Config.Enabled then
		return
	end

	task.spawn(function()
		local seen = {}
		for eventName, entry in pairs(self.ActiveMap) do
			if not MUTED_EVENTS[eventName] and entry and entry.Sound and not seen[entry.Sound] then
				seen[entry.Sound] = true
				self:_loadSoundId(entry.Sound)
			end
		end
	end)
end

function SoundManager:GetConfig()
	return copyTable(self.Config)
end

function SoundManager:GetEvents()
	return copyTable(Events)
end

function SoundManager:GetPresetNames()
	return { "Soft", "Minimal" }
end

function SoundManager:GetSoundNames()
	local names = {}
	for name in pairs(Assets) do
		table.insert(names, name)
	end
	for name in pairs(self.Config.Assets) do
		if not table.find(names, name) then
			table.insert(names, name)
		end
	end
	table.sort(names)
	return names
end

return SoundManager
