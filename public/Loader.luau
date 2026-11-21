-- SPDX-License-Identifier: MPL-2.0
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, obtain one at https://mozilla.org/MPL/2.0/.
-- Set getgenv().riftcommit to a commit SHA before running this loader.
-- With no pin, main is used. A failed pin never falls back to another revision.
local REPOSITORY = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/"
local env = typeof(getgenv) == "function" and getgenv() or _G
-- relaxcommit is the preferred name; keep the historical riftcommit alias.
-- Conflicting explicit pins must fail rather than silently selecting a revision.
if env.relaxcommit ~= nil and env.riftcommit ~= nil and env.relaxcommit ~= env.riftcommit then
    error("[RelaxUI loader] relaxcommit and riftcommit specify different revisions", 0)
end
local commit = env.relaxcommit or env.riftcommit
if commit == nil then
	commit = "main"
elseif type(commit) ~= "string" or #commit < 7 or #commit > 40 or not string.match(commit, "^%x+$") then
	error("[RelaxUI loader] relaxcommit/riftcommit must be a 7–40 character hexadecimal commit SHA", 0)
end

local base = REPOSITORY .. commit .. "/public/"
local url = base .. "RiftUI.luau"
local ok, source = pcall(function()
	return game:HttpGet(url)
end)
if not ok then
	error("[RelaxUI loader] couldn't fetch revision " .. commit .. " from " .. url .. ": " .. tostring(source), 0)
end
if type(source) ~= "string" or source == "" then
	error("[RelaxUI loader] revision " .. commit .. " returned an empty library", 0)
end
local chunk, compileError = loadstring(source, "RiftUI@" .. commit)
if not chunk then
	error("[RelaxUI loader] couldn't compile revision " .. commit .. ": " .. tostring(compileError), 0)
end
local loaded, Rift = pcall(chunk)
if not loaded then
	error("[RelaxUI loader] revision " .. commit .. " failed to initialise: " .. tostring(Rift), 0)
end
if type(Rift) ~= "table" or type(Rift.CreateHub) ~= "function" then
	error("[RelaxUI loader] revision " .. commit .. " didn't return a RiftUI library", 0)
end

Rift.AssetBase = base
-- Keep pinned icon sheets/shadows separate from assets cached for other revisions.
if commit ~= "main" then
	Rift.AssetCacheFolder = Rift.Folder .. "/assets/" .. commit
end
if commit ~= "main" then Rift.Version = string.lower(string.sub(commit, 1, 7)) end
Rift.Commit = commit
return Rift
