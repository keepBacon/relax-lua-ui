-- SPDX-License-Identifier: MPL-2.0
-- Lightweight hub resource ownership, inspired by OasisUI's Maid and MacUI's Cleanup.
local function disposeRiftResource(resource)
    if type(resource) == "function" then
        resource()
    elseif typeof(resource) == "RBXScriptConnection" then
        resource:Disconnect()
    elseif typeof(resource) == "Instance" then
        resource:Destroy()
    elseif type(resource) == "table" then
        if type(resource.Disconnect) == "function" then resource:Disconnect()
        elseif type(resource.Destroy) == "function" then resource:Destroy()
        elseif type(resource.Cancel) == "function" then resource:Cancel()
        end
    end
end

-- Reuse the same disposal policy from extension-owned scopes.
function Hub:_disposeResource(resource)
    return disposeRiftResource(resource)
end

function Hub:Own(resource)
    if self._destroyed then
        pcall(disposeRiftResource, resource)
        return resource
    end
    self._owned = self._owned or {}
    table.insert(self._owned, resource)
    return resource
end

function Hub:_releaseOwned()
    local owned = self._owned or {}
    self._owned = nil
    for i = #owned, 1, -1 do
        local ok, err = pcall(disposeRiftResource, owned[i])
        if not ok then warn("[RiftUI] resource cleanup: " .. tostring(err)) end
        owned[i] = nil
    end
end
