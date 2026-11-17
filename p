-- RelaxUI/RiftUI preview short entry; the showcase retains the DEMO key gate.
local source = game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/examples/showcase.luau")
local chunk, err = loadstring(source, "RelaxUI Preview")
if not chunk then error("[RelaxUI Preview] " .. tostring(err), 0) end
return chunk()
