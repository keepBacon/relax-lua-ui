-- SPDX-License-Identifier: MPL-2.0
-- RiftUI UI sounds. Inspired by VantaUI's Soft/Minimal event maps (MIT).
-- Original synthesized WAVs: MrRos3/VantaUI, see assets/sounds/LICENSE-VantaUI.txt.
-- Lazy, cached, rate-limited and safe on executors without custom sound assets.
local SOUND_BASE = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/assets/sounds/"
local SOUND_FALLBACK = "rbxasset://sounds/electronicpingshort.wav"
local SOUND_FILES = {
    ["soft-pop"] = "soft-pop.wav", ["soft-tick"] = "soft-tick.wav",
    ["minimal-tick"] = "minimal-tick.wav", ["minimal-confirm"] = "minimal-confirm.wav",
    ["error-buzz"] = "error-buzz.wav",
}
local SOUND_PRESETS = {
    Soft = {
        Click = {"soft-tick", .36, 1}, Tab = {"soft-pop", .43, 1.07},
        ToggleOn = {"soft-pop", .44, 1.1}, ToggleOff = {"soft-tick", .3, .9},
        DropdownOpen = {"soft-pop", .35, 1.12}, DropdownClose = {"soft-tick", .3, .9},
        Select = {"soft-tick", .33, 1.06}, SliderTick = {"soft-tick", .14, 1.22},
        InputFocus = {"soft-tick", .22, 1.1}, InputSubmit = {"soft-pop", .35, 1},
        WindowOpen = {"soft-pop", .45, .92}, WindowClose = {"soft-tick", .32, .82},
        Success = {"soft-pop", .48, 1.1}, Error = {"error-buzz", .35, 1},
    },
    Minimal = {
        Click = {"minimal-tick", .36, 1}, Tab = {"minimal-confirm", .43, 1.07},
        ToggleOn = {"minimal-confirm", .44, 1.1}, ToggleOff = {"minimal-tick", .3, .9},
        DropdownOpen = {"minimal-confirm", .35, 1.12}, DropdownClose = {"minimal-tick", .3, .9},
        Select = {"minimal-tick", .33, 1.06}, SliderTick = {"minimal-tick", .14, 1.22},
        InputFocus = {"minimal-tick", .22, 1.1}, InputSubmit = {"minimal-confirm", .35, 1},
        WindowOpen = {"minimal-confirm", .45, .92}, WindowClose = {"minimal-tick", .32, .82},
        Success = {"minimal-confirm", .48, 1.1}, Error = {"error-buzz", .35, 1},
    },
}
local SOUND_LIMIT = { SliderTick = .09, Click = .05, Tab = .06, DropdownOpen = .08, Select = .05 }
local soundCache, soundLoading = {}, {}
local soundWarnings = {}

local function soundWarnOnce(key, err)
    if soundWarnings[key] then return end
    soundWarnings[key] = true
    warn("[RiftUI Sounds] " .. tostring(err))
end

local function soundEnsureFolder(path)
    if type(makefolder) ~= "function" then return end
    local cursor = ""
    for part in string.gmatch(path, "[^/]+") do
        cursor = cursor == "" and part or cursor .. "/" .. part
        if type(isfolder) ~= "function" or not isfolder(cursor) then
            pcall(makefolder, cursor)
        end
    end
end

local function soundResolveAsset(soundName: string, hub)
    local config = hub._soundConfig
    local source = (config.Assets and config.Assets[soundName]) or SOUND_FILES[soundName] or soundName
    if type(source) ~= "string" then return SOUND_FALLBACK end
    if source:match("^rbxasset") or source:match("^synasset") then return source end
    if hub.Stealth or type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
        return SOUND_FALLBACK
    end
    local url = source:match("^https?://") and source or (SOUND_BASE .. source)
    local key = (url:gsub("[^%w]", "_")):sub(-70)
    if soundCache[key] then return soundCache[key] end
    if soundLoading[key] then return SOUND_FALLBACK end
    soundLoading[key] = true
    local ok, result = pcall(function()
        local dir = RiftUI.Folder .. "/sounds"
        local path = dir .. "/" .. key .. ".wav"
        soundEnsureFolder(dir)
        if type(isfile) ~= "function" or not isfile(path) then
            local body = nil
            local req = (syn and syn.request) or http_request or request
            if req then
                local response = req({Url = url, Method = "GET"})
                body = response and (response.Body or response.body)
            else
                body = game:HttpGet(url)
            end
            if type(body) ~= "string" or #body < 44 or body:sub(1, 4) ~= "RIFF" or body:sub(9, 12) ~= "WAVE" then
                error("invalid WAV data for " .. soundName)
            end
            writefile(path, body)
        end
        return getcustomasset(path)
    end)
    soundLoading[key] = nil
    if not ok or type(result) ~= "string" or result == "" then
        soundWarnOnce(key, result)
        result = SOUND_FALLBACK
    end
    soundCache[key] = result
    return result
end

function Hub:GetUISounds()
    return table.clone(self._soundConfig or { Enabled = true, Preset = "Soft", Volume = .65 })
end

function Hub:SetUISounds(options)
    local current = self._soundConfig or { Enabled = true, Preset = "Soft", Volume = .65, Pitch = 1, Assets = {} }
    if type(options) == "boolean" then
        current.Enabled = options
    elseif type(options) == "table" then
        if options.Enabled ~= nil then current.Enabled = options.Enabled == true end
        if options.Preset == "Soft" or options.Preset == "Minimal" then current.Preset = options.Preset end
        if options.Volume ~= nil then current.Volume = math.clamp(tonumber(options.Volume) or current.Volume, 0, 2) end
        if options.Pitch ~= nil then current.Pitch = math.clamp(tonumber(options.Pitch) or current.Pitch, .5, 2) end
        if type(options.Assets) == "table" then
            current.Assets = table.clone(options.Assets)
        end
    end
    self._soundConfig = current
    return self:GetUISounds()
end

function Hub:PlayUISound(eventName: string, options)
    if self._destroyed then return false end
    local cfg = self._soundConfig
    if not cfg or not cfg.Enabled then return false end
    local entry = (SOUND_PRESETS[cfg.Preset] or SOUND_PRESETS.Soft)[eventName]
    if not entry then return false end
    local now = os.clock()
    self._soundLast = self._soundLast or {}
    local limit = SOUND_LIMIT[eventName] or .035
    if now - (self._soundLast[eventName] or -100) < limit then return false end
    self._soundLast[eventName] = now
    task.spawn(function()
        local soundId = soundResolveAsset(entry[1], self)
        if self._destroyed or not self._soundConfig or not self._soundConfig.Enabled then return end
        local ok, sound = pcall(Instance.new, "Sound")
        if not ok or not sound then return end
        local opts = type(options) == "table" and options or {}
        local played, reason = pcall(function()
            sound.Name = "RiftUI_" .. eventName
            sound.SoundId = soundId
            sound.Volume = math.clamp((tonumber(opts.Volume) or entry[2]) * cfg.Volume, 0, 2)
            sound.PlaybackSpeed = math.clamp((tonumber(opts.Pitch) or entry[3]) * cfg.Pitch, .25, 4)
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 5)
        end)
        if not played then sound:Destroy(); soundWarnOnce(eventName, reason) end
    end)
    return true
end
