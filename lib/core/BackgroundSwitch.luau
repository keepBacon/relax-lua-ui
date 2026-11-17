-- SPDX-License-Identifier: MPL-2.0
-- Extended background-source switching, based on the source types and fading
-- semantics of AsterUI and FlowUI. This is separate from the six UI backgrounds.
local BACKGROUND_TRANSITIONS = { Crossfade = true, Fade = true, Instant = true }

function Hub:GetBackgroundTransition()
    local selected = self._bgTransition
        or (self.SetupData and self.SetupData.BackgroundTransition)
        or (self.Options and self.Options.BackgroundTransition)
        or "Crossfade"
    return BACKGROUND_TRANSITIONS[selected] and selected or "Crossfade"
end

function Hub:SetBackgroundTransition(mode: string)
    if self._destroyed then return false, "hub destroyed" end
    if not BACKGROUND_TRANSITIONS[mode] then
        return false, "transition must be Crossfade, Fade or Instant"
    end
    self._bgTransition = mode
    self:_savePref("BackgroundTransition", mode)
    return true
end

-- Accepts the same kinds of image sources as AsterUI/FlowUI:
-- preset name, asset ID, HTTPS/HTTP image URL, or local executor image path.
-- SetBackground({Url=..., File=..., Asset=...}) continues to work unchanged.
function Hub:SwitchBackground(source)
    if self._destroyed then return false, "hub destroyed" end
    if source == nil or source == false then return self:SetBackground(nil) end
    if type(source) == "table" or type(source) == "number" then
        return self:SetBackground(source)
    end
    if type(source) ~= "string" then return false, "invalid image source" end
    local value = source:match("^%s*(.-)%s*$")
    if value == "" or value == "None" then return self:SetBackground(nil) end
    if RiftUI.BackgroundPresets[value] then return self:SetBackgroundPreset(value) end
    if resolveBackgroundPreset(value) then return self:SetBackground(value) end
    if value:match("^https?://") then
        return self:SetBackground({ Url = value })
    end
    if type(isfile) == "function" and isfile(value) then
        return self:SetBackground({ File = value })
    end
    return false, "use a preset, asset ID, direct image URL or existing image file"
end
