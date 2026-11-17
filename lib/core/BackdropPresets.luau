-- SPDX-License-Identifier: MPL-2.0
-- Background presets inspired by FlowUI and Aster UI.
-- Works without a custom-asset filesystem; existing file/URL backgrounds remain supported.
RiftUI.BackgroundPresets = {
    ["Deep Violet"] = "rbxassetid://136310484943077",
    ["Blood Red"] = "rbxassetid://121343473918667",
    ["Cyanic"] = "rbxassetid://95656189244173",
    ["Amber Glow"] = "rbxassetid://107795771598485",
    ["Bloomings"] = "rbxassetid://133541508207801",
    ["Lavender Pink"] = "rbxassetid://126107479485287",
}
RiftUI.BackgroundPresetOrder = {
    "Deep Violet", "Blood Red", "Cyanic", "Amber Glow", "Bloomings", "Lavender Pink",
}

local function resolveBackgroundPreset(value)
    if type(value) == "number" then
        return "rbxassetid://" .. tostring(math.floor(value)), nil
    end
    if type(value) ~= "string" then return nil, nil end
    local source = value:match("^%s*(.-)%s*$")
    local preset = RiftUI.BackgroundPresets[source]
    if preset then return preset, source end
    if source:match("^%d+$") then return "rbxassetid://" .. source, nil end
    if source:match("^rbxassetid://%d+$") or source:match("^rbxasset://") or source:match("^rbxthumb://") then
        return source, nil
    end
    return nil, nil
end

function RiftUI:ListBackgroundPresets()
    return table.clone(self.BackgroundPresetOrder)
end

function Hub:ListBackgrounds()
    local values = {"None"}
    for _, name in RiftUI.BackgroundPresetOrder do table.insert(values, name) end
    return values
end

function Hub:GetBackground()
    return self.Background and table.clone(self.Background) or nil
end

function Hub:SetBackgroundPreset(name)
    if name == "None" or name == nil then return self:SetBackground(nil) end
    if not RiftUI.BackgroundPresets[name] then return false, "unknown background preset" end
    return self:SetBackground(name)
end

function Hub:SetBackgroundTransparency(value)
    if self._destroyed then return false end
    local transparency = math.clamp(tonumber(value) or .4, 0, 1)
    self._backgroundTransparency = transparency
    if self.Background then self.Background.Opacity = 1 - transparency end
    for _, layer in self._bgLayers or {} do
        local image = layer:FindFirstChild("Image", true)
        if image then tween(image, FAST, { ImageTransparency = transparency }) end
    end
    local studio = self.SetupData and self.SetupData.Studio
    self:_saveStudio(studio and studio.Colors or {})
    return true
end
