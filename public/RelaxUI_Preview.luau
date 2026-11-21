-- RelaxUI instant preview for Roblox / Android executors.
-- A standalone showcase: no key gate, no setup wizard, no gameplay modifications.
local BASE = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/"

local function showFailure(message)
    message = tostring(message)
    warn("[RelaxUI Preview] " .. message)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local parent
        if type(gethui) == "function" then
            local ok, result = pcall(gethui)
            if ok and typeof(result) == "Instance" then parent = result end
        end
        if not parent and player then parent = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5) end
        if not parent then parent = game:GetService("CoreGui") end
        local old = parent:FindFirstChild("RelaxUI_Preview_Error")
        if old then old:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "RelaxUI_Preview_Error"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 20000
        gui.Parent = parent
        local frame = Instance.new("Frame")
        frame.Name = "ErrorCard"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.fromScale(0.5, 0.5)
        frame.Size = UDim2.new(1, -32, 0, 160)
        frame.BackgroundColor3 = Color3.fromRGB(23, 25, 30)
        frame.Parent = gui
        local limit = Instance.new("UISizeConstraint")
        limit.MaxSize = Vector2.new(380, 180)
        limit.Parent = frame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Name = "Message"
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(16, 12)
        label.Size = UDim2.new(1, -32, 1, -24)
        label.TextColor3 = Color3.fromRGB(243, 246, 250)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextWrapped = true
        label.Text = "RelaxUI 预览加载失败 / Preview failed\n\n" .. string.sub(message, 1, 320) .. "\n\n请检查 Delta 控制台及网络连接。"
        label.Parent = frame
    end)
end

local ok, err = xpcall(function()
    local response = game:HttpGet(BASE .. "RiftUI.luau")
    assert(type(response) == "string" and #response > 1000, "RelaxUI source download failed or was incomplete")
    local chunk, compileError = loadstring(response)
    assert(chunk, "RelaxUI compile error: " .. tostring(compileError))
    local UI = chunk()
    assert(type(UI) == "table" and type(UI.CreateHub) == "function", "Invalid RelaxUI library result")
    UI.AssetBase = BASE

    -- Fixed Id ensures re-executing replaces the previous preview rather than stacking it.
    local Hub = UI:CreateHub({
        Name = "RelaxUI",
        Id = "relaxui-instant-preview",
        Subtitle = "Android / UI Showcase",
        HubIcon = "layers-3",
        Language = "zh",
        Setup = false,       -- never block the preview with first-run onboarding
        Loading = false,     -- never leave the toolbar hidden behind a loading card
        ColorTheme = "Graphite",
        ControlTheme = "Rounded",
        ToggleKey = Enum.KeyCode.RightShift,
    })
    assert(Hub and type(Hub.Tab) == "function" and type(Hub.Open) == "function", "Hub creation did not complete")

    local Home = Hub:Tab({ Name = "主页", Icon = "home", Description = "基础交互预览" })
    local Main = Home:Section({ Name = "基础控件", Side = "Left" })
    Main:Label("欢迎体验 RelaxUI · 可直接操作全部演示控件")
    Main:Button({ Name = "点击测试", Description = "显示通知", Callback = function()
        Hub:Notify({ Title = "RelaxUI", Content = "按钮工作正常", Duration = 3 })
    end })
    local enabled = Main:Toggle({ Name = "功能开关", Flag = "PreviewEnabled", Default = true })
    Main:Slider({ Name = "强度", Flag = "PreviewStrength", Min = 0, Max = 100, Default = 62, Suffix = "%" })
    Main:Dropdown({ Name = "运行模式", Flag = "PreviewMode", Options = { "均衡", "流畅", "画质" }, Default = "均衡" })
    Main:Input({ Name = "文本输入", Flag = "PreviewText", Placeholder = "在此输入文本", Default = "RelaxUI" })
    local Extra = Home:Section({ Name = "其他交互", Side = "Right" })
    Extra:Segmented({ Name = "质量预设", Flag = "PreviewQuality", Options = { "低", "中", "高" }, Default = "中" })
    Extra:Stepper({ Name = "数量", Flag = "PreviewCount", Min = 1, Max = 10, Default = 3 })
    Extra:RangeSlider({ Name = "数值区间", Flag = "PreviewRange", Min = 0, Max = 100, Default = { 20, 80 } })
    Extra:ColorPicker({ Name = "强调色选择", Flag = "PreviewColor", Default = Color3.fromRGB(125, 165, 255) })
    Extra:Keybind({ Name = "测试快捷键", Flag = "PreviewKey", Default = Enum.KeyCode.G })
    Extra:Button({ Name = "切换工具栏", Callback = function() Hub:ToggleToolbar() end })

    -- New advanced component families are isolated: if one fails, the core preview stays open.
    local Modules = Hub:Tab({ Name = "模块", Icon = "layers", Description = "模块卡片与信息布局" })
    local modSection = Modules:Section({ Name = "ModuleCard", Side = "Left" })
    local cardsOk, cardsErr = pcall(function()
        local card = modSection:ModuleCard({
            Name = "性能模块", Id = "preview-perf", Icon = "activity",
            Description = "卡片开关、折叠和子控件", Flag = "PreviewPerformance",
            Toggle = true, Default = true, Collapsed = false,
            Favoritable = true, Status = "Ready", Tone = "Success",
        })
        card:Toggle({ Name = "启用效果", Flag = "PreviewParticles", Default = true })
        card:Slider({ Name = "渲染质量", Flag = "PreviewRender", Min = 0, Max = 100, Default = 75 })
        card:Dropdown({ Name = "渲染模式", Options = { "Auto", "Fast", "Quality" }, Default = "Auto" })
        modSection:Button({ Name = "更新卡片状态", Callback = function()
            card:SetStatus("Healthy", "Success")
            card:SetSummary("已完成演示状态更新")
        end })
    end)
    if not cardsOk then modSection:Label("ModuleCard unavailable: " .. tostring(cardsErr)) end

    local infoSection = Modules:Section({ Name = "高级信息组织", Side = "Right" })
    local infoOk, infoErr = pcall(function()
        local metrics = infoSection:InfoGrid({
            Name = "模拟运行指标", Columns = 2,
            Items = {
                { Key = "fps", Label = "FPS", Value = "120", Tone = "Success" },
                { Key = "ping", Label = "Ping", Value = "28 ms" },
                { Key = "cpu", Label = "CPU", Value = "35%" },
                { Key = "memory", Label = "Memory", Value = "180 MB" },
            },
        })
        infoSection:InfoList({
            Name = "组件状态",
            Items = {
                { Key = "touch", Label = "触控", Value = "Ready", Tone = "Success" },
                { Key = "theme", Label = "主题", Value = "Graphite" },
                { Key = "mode", Label = "交互", Value = "Mobile" },
            },
        })
        infoSection:Button({ Name = "刷新模拟数据", Callback = function()
            metrics:Update("fps", tostring(math.random(95, 145)), "Success")
            metrics:Update("ping", tostring(math.random(20, 65)) .. " ms")
        end })
    end)
    if not infoOk then infoSection:Label("Info components unavailable: " .. tostring(infoErr)) end

    local Data = Hub:Tab({ Name = "数据", Icon = "table-2", Description = "列表、表格、状态、树形控件" })
    local listSection = Data:Section({ Name = "数据表与排序", Side = "Left" })
    local dataOk, dataErr = pcall(function()
        local tableView = listSection:DataTable({
            Name = "演示数据表", PageSize = 5, LayoutMode = "Auto", CompactBelow = 310,
            Columns = {
                { Key = "Name", Title = "模块", Width = 130, Sortable = true },
                { Key = "FPS", Title = "FPS", Width = 70, Sortable = true },
                { Key = "Status", Title = "状态", Width = 110 },
            },
            Rows = {
                { Id = "a", Name = "Renderer", FPS = 124, Status = "Ready" },
                { Id = "b", Name = "Input", FPS = 117, Status = "Ready" },
                { Id = "c", Name = "Network", FPS = 110, Status = "Warning" },
                { Id = "d", Name = "Audio", FPS = 119, Status = "Ready" },
                { Id = "e", Name = "Weather", FPS = 108, Status = "Healthy" },
            },
        })
        listSection:Button({ Name = "按 FPS 排序", Callback = function() tableView:SetSort("FPS", true) end })
        listSection:OrderList({
            Name = "优先级排序", Flag = "PreviewOrder", MaxVisible = 4,
            Items = {
                { Id = "ui", Label = "UI" }, { Id = "input", Label = "Input" },
                { Id = "visual", Label = "Visual" }, { Id = "sound", Label = "Sound" },
            },
        })
    end)
    if not dataOk then listSection:Label("DataTable / OrderList unavailable: " .. tostring(dataErr)) end

    local stateSection = Data:Section({ Name = "状态与树形导航", Side = "Right" })
    local treeOk, treeErr = pcall(function()
        stateSection:StatusList({
            Name = "组件健康状态", MaxVisible = 4,
            Items = {
                { Id = "ui", Label = "UI", State = "Healthy", Detail = "Connected" },
                { Id = "network", Label = "Network", State = "Warning", Detail = "Demo" },
                { Id = "input", Label = "Input", State = "Ready", Detail = "Touch enabled" },
            },
        })
        stateSection:TreeView({
            Name = "功能层级", Id = "preview-tree", MaxVisible = 5,
            Nodes = {
                { Id = "core", Label = "核心", Children = {
                    { Id = "render", Label = "渲染器" },
                    { Id = "gesture", Label = "输入路由" },
                } },
                { Id = "features", Label = "组件", Children = {
                    { Id = "cards", Label = "ModuleCard" },
                    { Id = "table", Label = "DataTable" },
                } },
            },
        })
    end)
    if not treeOk then stateSection:Label("StatusList / TreeView unavailable: " .. tostring(treeErr)) end

    local Theme = Hub:Tab({ Name = "外观", Icon = "palette", Description = "设计令牌与主题" })
    local themeSection = Theme:Section({ Name = "主题", Side = "Left" })
    themeSection:Label("选择主题后可返回主页检查效果。")
    for _, name in ipairs({ "Graphite", "Ink", "Slate", "Ember" }) do
        themeSection:Button({ Name = name, Callback = function() Hub:SetTheme(name) end })
    end
    local shapeSection = Theme:Section({ Name = "控件形状", Side = "Right" })
    shapeSection:Button({ Name = "默认", Callback = function() Hub:SetControlTheme("Default") end })
    shapeSection:Button({ Name = "圆润", Callback = function() Hub:SetControlTheme("Rounded") end })
    shapeSection:Button({ Name = "减少动画", Callback = function() Hub:SetMotionMode("Reduced") end })
    shapeSection:Button({ Name = "标准动画", Callback = function() Hub:SetMotionMode("Full") end })

    -- A library-only load returns a table; opening a tab is what actually reveals the panel.
    -- Deferred open gives Roblox one frame to calculate the new content geometry.
    task.defer(function()
        task.wait(0.2)
        if Hub._destroyed then return end
        Hub:SetToolbarVisible(true)
        Hub:Open(Home)
        Hub:Notify({ Title = "RelaxUI Preview", Content = "已自动打开主页；底部 Dock 可切换分页。", Duration = 4 })
    end)
end, function(e)
    return tostring(e)
end)
if not ok then showFailure(err) end
