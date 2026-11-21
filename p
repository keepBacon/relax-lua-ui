-- RelaxUI/RiftUI preview short entry; the showcase retains the DEMO key gate.
local url = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/examples/showcase.luau"
local ok, source = pcall(function() return game:HttpGet(url) end)
if not ok or type(source) ~= "string" or source == "" then
    error("[RelaxUI Preview] showcase download failed at " .. url .. ": " .. tostring(source), 0)
end
local chunk, err = loadstring(source, "RelaxUI Preview")
if not chunk then error("[RelaxUI Preview] " .. tostring(err), 0) end
return chunk()
