-- SPDX-License-Identifier: MPL-2.0
-- Relax UI Developer SDK tutorial: an actual hub, no bundled demo-key bypass.
-- R1 extension + scopes/events; R2 custom Section control; R3 inspector export.
-- Run in an executor that supports game:HttpGet and loadstring.
local Rift = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/Loader.luau"
))()

xpcall(function()
    local hub = Rift:CreateHub({
        Name = "Developer SDK Example",
        Id = "relax-dev-sdk",
        Subtitle = "Extensions · custom controls · reports",
        Setup = false,
        Settings = false,
    })
    local tab = hub:Tab({ Name = "Developer", Icon = "wrench" })
    local section = tab:Section({ Name = "Custom controls" })

    -- Own both the definition and its instance inside Start. Reinitialize
    -- replays ordinary Tab/Section recipes first, then re-runs extension Start.
    -- Building the scoped component outside Start would fail on replay.
    local registered, reason = hub:RegisterExtension("example.counter", {
        Version = "1.0.0",
        Start = function(owner, scope)
            local ok, failure = owner:RegisterComponent("example.counter", {
                Version = "1.0.0",
                Height = 46,
                Default = 0,
                Validate = function(value)
                    return type(value) == "number" and value >= 0,
                        "counter must be a non-negative number"
                end,
                Render = function(context)
                    local button = Instance.new("TextButton")
                    button.Name = "CounterAction"
                    button.Size = UDim2.fromScale(1, 1)
                    button.AutoButtonColor = false
                    button.BorderSizePixel = 0
                    button.Parent = context.Frame
                    context:BindToken(button, "BackgroundColor3", "Color.Surface2")
                    context:BindToken(button, "TextColor3", "Color.TextPrimary")
                    context:Connect(button.MouseButton1Click, function()
                        context:Emit(context.Control:Get() + 1)
                    end)
                    return {
                        Set = function(_, value)
                            button.Text = "Count: " .. tostring(value) .. "  ·  tap to increment"
                            return true
                        end,
                    }
                end,
            }, scope)
            assert(ok, tostring(failure))
            local counter, createError = section:Component("example.counter", {
                Name = "Counter",
                Flag = "DeveloperCounter",
                Default = 1,
                Callback = function(value)
                    owner:EmitDeveloperEvent("example.counter.changed", { Value = value })
                end,
            })
            assert(counter, tostring(createError))
            scope:Own(counter)
            scope:Own(owner:OnDeveloperEvent("example.counter.changed", function(data)
                print("[Relax UI SDK] counter:", data.Value)
            end))
            scope:Defer(function()
                print("[Relax UI SDK] extension cleaned up")
            end)
        end,
    })
    assert(registered, tostring(reason))

    section:Button({
        Name = "Print Developer Report",
        Callback = function()
            local report, failure = hub:CaptureDeveloperReport({ MaxNodes = 120 })
            if not report then
                warn("[Relax UI SDK] " .. tostring(failure))
                return
            end
            print("[Relax UI SDK] GUI nodes:", #report.Tree.Nodes,
                "truncated:", report.Tree.Truncated,
                "extensions:", report.Stats.Extensions,
                "diagnostics:", #report.Diagnostics)
            -- Explicit JSON export is optional. No automatic network uploads.
            -- print(game:GetService("HttpService"):JSONEncode(report))
        end,
    })
    section:Button({
        Name = "Open Visual Inspector",
        Callback = function()
            hub:OpenVisualInspector({ Limit = 80 })
        end,
    })
end, Rift.HandleError)
