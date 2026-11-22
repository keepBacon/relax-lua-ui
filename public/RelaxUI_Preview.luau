-- RelaxUI instant preview for Roblox / Android executors.
-- Standalone interactive preview with the original DEMO key entry (no setup wizard).
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

    -- Restore the original RiftUI key entry before creating the demo Hub.
    -- Demo-only local validation, not an external authentication service.
    local accepted = UI:CreateAuth({
        Name = "RelaxUI Preview",
        Id = "relaxui-instant-preview",
        Subtitle = "输入预览密钥继续 / Enter preview key",
        Note = "演示密钥 / Demo key: DEMO",
        Remember = false,
        Request = function(key)
            if string.upper(key) == "DEMO" then
                return true, "-- demo preview approved"
            end
            return false, "Invalid key. The demo key is DEMO."
        end,
    })
    if not accepted then return end

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
    local lockedExample = Main:Button({
        Name = "锁定功能展示", Locked = true,
        Lock = {
            Reason = "当前演示功能尚未解锁",
            ButtonLayout = "HorizontalRight",
            Details = "点击下方选项可查看原因，也可以返回正常状态。",
            Actions = {
                { Text = "为什么锁定", KeepOpen = true, Callback = function(_, dialog)
                    dialog:SetContent("可通过 SetLocked(false) 恢复可用。")
                    return false
                end },
                { Text = "知道了", Primary = true },
            },
        },
        Callback = function() Hub:Notify({ Title = "功能可用", Content = "状态已解除" }) end,
    })
    Main:Button({ Name = "锁定状态切换", Callback = function()
        lockedExample:SetAvailability(lockedExample:IsLocked() and "Available" or "Locked")
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
    Extra:Button({ Name = "竖列操作弹窗", Callback = function()
        Hub:OpenActionDialog({
            Title = "竖列按钮", Content = "按钮各占一行。",
            ButtonLayout = "Vertical",
            Buttons = { { Text = "帮助" }, { Text = "关闭", Primary = true } },
        })
    end })
    Extra:Button({ Name = "横向右对齐弹窗", Callback = function()
        Hub:OpenActionDialog({
            Title = "横向按钮", Content = "按钮水平排在弹窗右下。",
            ButtonLayout = "HorizontalRight",
            Buttons = { { Text = "取消" }, { Text = "确定", Primary = true } },
        })
    end })
    Extra:Button({ Name = "重置面板尺寸", Callback = function() Hub:ResetPanelSize() end })

    -- P2 interactive controls: search, context actions and compact disclosures.
    local Advanced = Hub:Tab({ Name = "高级交互", Icon = "list-filter", Description = "搜索选择、右键菜单与手风琴" })
    local searchSection = Advanced:Section({ Name = "SearchSelect", Side = "Left" })
    local names = {}
    for index = 1, 120 do names[index] = string.format("玩家 / 条目 %03d", index) end
    local searchSelect = searchSection:SearchSelect({
        Name = "搜索单选", Flag = "PreviewSearchOne",
        Options = names, Default = names[12], MaxVisible = 6,
        Callback = function(value)
            Hub:Notify({ Title = "SearchSelect", Content = tostring(value) })
        end,
    })
    searchSection:SearchSelect({
        Name = "多选模式", Flag = "PreviewSearchMulti", Multi = true,
        Options = { "移动端", "高帧率", "低延迟", "自动保存", "自定义背景", "辅助提示" },
        Default = { "移动端", "高帧率" },
    })
    searchSection:Button({ Name = "动态刷新选项", Callback = function()
        searchSelect:SetOptions({ "Graphite", "Ink", "Slate", "Ember", "Custom" })
        searchSelect:Set("Graphite")
    end })
    local menus = Advanced:Section({ Name = "ContextMenu", Side = "Right" })
    local context = menus:ContextMenu({
        Name = "点击 / 右键 / 长按",
        Items = {
            { Id = "copy", Text = "复制", Icon = "copy", Shortcut = "Ctrl+C" },
            { Id = "group", Text = "更多操作", Icon = "more-horizontal", Children = {
                { Id = "pin", Text = "固定", Icon = "pin" },
                { Id = "reset", Text = "重置", Icon = "rotate-ccw" },
            } },
            { Separator = true },
            { Id = "delete", Text = "删除", Danger = true },
            { Id = "disabled", Text = "不可用操作", Disabled = true },
        },
        Callback = function(id)
            Hub:Notify({ Title = "ContextMenu", Content = "动作: " .. id })
        end,
    })
    menus:Button({ Name = "通过 API 打开菜单", Callback = function() context:Open() end })
    local accordion = menus:Accordion({
        Name = "FAQ", Flag = "PreviewAccordion", Single = false,
        Items = {
            { Id = "intro", Title = "什么是 Accordion？",
                Content = "用于轻量内容分组。支持多个独立展开，不包含模块开关与收藏功能。" },
            { Id = "mobile", Title = "移动端如何使用？",
                Content = "直接点击 42px 高的标题区域即可展开或收起。内容不会被 CanvasGroup 降采样。" },
            { Id = "api", Title = "开发 API",
                Content = "Expand(id)、Collapse(id)、Toggle(id)、SetItems(items)、GetExpanded()。" },
        },
        Default = { intro = true },
    })
    menus:Button({ Name = "展开全部 FAQ", Callback = function()
        accordion:Set({ intro = true, mobile = true, api = true })
    end })

    -- New advanced component families are isolated: if one fails, the core preview stays open.
    local Modules = Hub:Tab({ Name = "模块", Icon = "layers", Description = "模块卡片与信息布局" })
    local modSection = Modules:Section({ Name = "ModuleCard", Side = "Left" })
    local previewCard
    local cardsOk, cardsErr = pcall(function()
        local card = modSection:ModuleCard({
            Name = "性能模块", Id = "preview-perf", Icon = "activity",
            Description = "卡片开关、折叠和子控件", Flag = "PreviewPerformance",
            Toggle = true, Default = true, Collapsed = false,
            Favoritable = true, Status = "Ready", Tone = "Success",
        })
        previewCard = card
        card:Toggle({ Name = "启用效果", Flag = "PreviewParticles", Default = true })
        card:Slider({ Name = "渲染质量", Flag = "PreviewRender", Min = 0, Max = 100, Default = 75 })
        card:Dropdown({ Name = "渲染模式", Options = { "Auto", "Fast", "Quality" }, Default = "Auto" })
        card:Button({ Name = "更新卡片状态", Callback = function()
            card:SetStatus("Healthy", "Success")
            card:SetSummary("已完成演示状态更新")
        end })
    end)
    if not cardsOk then modSection:Label("ModuleCard unavailable: " .. tostring(cardsErr)) end

    local infoSection = Modules:Section({ Name = "高级信息组织", Side = "Right" })
    local previewMetrics
    local infoOk, infoErr = pcall(function()
        local metrics = infoSection:InfoGrid({
            Name = "模拟运行指标", Columns = 2,
            Items = {
                { Key = "fps", Label = "FPS", Value = "120", Tone = "Success" },
                { Key = "ping", Label = "Ping", Value = "28 ms" },
                { Key = "cpu", Label = "CPU", Value = "35%" },
                { Key = "status", Label = "Module", Value = "Ready" },
        { Key = "memory", Label = "Memory", Value = "180 MB" },
            },
        })
        previewMetrics = metrics
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

    if previewCard and previewMetrics then
        Hub:LinkData(previewCard, previewMetrics, {
            Event = "Status", Action = "Update", Immediate = true,
            Map = function(state)
                return { Key = "status", Value = state.Status, Tone = state.Tone }
            end,
        })
        Hub:LinkData(previewMetrics, previewCard, {
            Event = "Data", Action = "SetSummary",
            Map = function(change)
                if change.Key == "fps" and change.Item then
                    return "FPS: " .. change.Item.Value
                end
            end,
        })
    end

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

    -- Demonstrate off-screen linking: module state updates the summary on a
    -- different primary tab without forcing navigation to that page.
    local linkedTab = Hub:Tab({ Name = "联动", Icon = "workflow", Description = "跨分页数据同步" })
    local linkedPage = linkedTab:SubTab({ Name = "状态同步", Icon = "activity" })
    local linkedSection = linkedPage:Section({ Name = "跨分页联动状态" })
    local remoteStats = linkedSection:InfoList({
        Name = "后台联动（无轮询）",
        Items = {
            { Key = "state", Label = "模块状态", Value = "Waiting" },
            { Key = "updates", Label = "传递次数", Value = "0" },
        },
    })
    if previewCard then
        local link = Hub:LinkData(previewCard, remoteStats, {
            Event = "Status", Action = "Update", Immediate = true,
            Map = function(status)
                return { Key = "state", Value = status.Status, Tone = status.Tone }
            end,
        })
        linkedSection:Button({ Name = "暂停联动", Callback = function() link:Pause() end })
        linkedSection:Button({ Name = "恢复并同步", Callback = function() link:Resume(true) end })
        linkedSection:Button({ Name = "查看传递次数", Callback = function()
            remoteStats:Update("updates", tostring(link:GetStats().Delivered))
        end })
    end

    local Theme = Hub:Tab({ Name = "外观", Icon = "palette", Description = "设计令牌与主题" })
    local themeSection = Theme:Section({ Name = "主题", Side = "Left" })
    local activeTheme = themeSection:_info("当前主题", Hub:GetColorTheme())
    themeSection:Label("选择后立即应用主题，可返回主页查看效果。")
    local themeButtons = {}
    local function refreshThemeChoices()
        local current = Hub:GetColorTheme()
        activeTheme:Set(current)
        for name, button in themeButtons do
            button:SetText((name == current and "✓  " or "     ") .. name)
        end
    end
    for _, name in ipairs({ "Graphite", "Ink", "Slate", "Ember" }) do
        themeButtons[name] = themeSection:Button({
            Name = name,
            Callback = function()
                Hub:SetColorTheme(name)
                refreshThemeChoices()
            end,
        })
    end
    refreshThemeChoices()
    local shapeSection = Theme:Section({ Name = "控件形状", Side = "Right" })
    local activeShape = shapeSection:_info("当前形状", Hub:GetControlTheme())
    local shapeButtons = {}
    local function refreshShapeChoices()
        local current = Hub:GetControlTheme()
        activeShape:Set(current == "Rounded" and "圆润" or "默认")
        for key, button in shapeButtons do
            button:SetText((key == current and "✓  " or "     ") .. (key == "Rounded" and "圆润" or "默认"))
        end
    end
    for _, style in ipairs({ "Default", "Rounded" }) do
        shapeButtons[style] = shapeSection:Button({
            Name = style == "Rounded" and "圆润" or "默认",
            Callback = function()
                Hub:SetControlTheme(style)
                refreshShapeChoices()
            end,
        })
    end
    refreshShapeChoices()
    local motionSection = Theme:Section({ Name = "动画偏好", Side = "Right" })
    local motionInfo = motionSection:_info("当前动画", Hub:GetMotionMode() == "Reduced" and "减少动画" or "标准动画")
    local motionButtons = {}
    local function refreshMotionChoices()
        local current = Hub:GetMotionMode()
        motionInfo:Set(current == "Reduced" and "减少动画" or current == "Off" and "关闭动画" or "标准动画")
        for mode, button in motionButtons do
            local label = mode == "Reduced" and "减少动画" or "标准动画"
            button:SetText((mode == current and "✓  " or "     ") .. label)
        end
    end
    for _, mode in ipairs({ "Reduced", "Full" }) do
        motionButtons[mode] = motionSection:Button({
            Name = mode == "Reduced" and "减少动画" or "标准动画",
            Callback = function()
                Hub:SetMotionMode(mode)
                refreshMotionChoices()
            end,
        })
    end
    refreshMotionChoices()

    -- Fixed P0 visual regression fixtures. Do not randomize these strings or data:
    -- the same labels and values are used to compare screenshots across commits.
    local auditTab = Hub:Tab({
        Name = "P0验收", Icon = "clipboard-check",
        Description = "固定样例 · 安卓布局与交互回归",
    })
    local auditLeft = auditTab:Section({ Name = "ModuleCard · 锁定", Side = "Left" })
    local auditCard = auditLeft:ModuleCard({
        Name = "性能优化与显示调节 · 中文长标题",
        Id = "p0-module-fixture", Icon = "activity",
        Description = "这里是用于验证中文描述自动换行、图标与右侧操作区对齐的固定文案。",
        Toggle = true, Default = true, Collapsed = false,
    })
    auditCard:Toggle({ Name = "固定示例开关", Default = true })
    auditCard:Slider({ Name = "固定强度", Min = 0, Max = 100, Default = 62 })
    local auditLock = auditLeft:Button({
        Name = "P0锁定测试", Locked = true,
        Lock = {
            Reason = "此示例已锁定：需要完成预览权限验证。",
            Details = "长文本验收：弹窗应可滚动，锁图标应正确振动，连续点击不会重复堆叠弹窗。",
            ButtonLayout = "HorizontalRight",
            Actions = { { Text = "了解原因", KeepOpen = true }, { Text = "知道了", Primary = true } },
        },
    })
    auditLeft:Button({ Name = "切换锁定状态", Callback = function()
        auditLock:SetAvailability(auditLock:IsLocked() and "Available" or "Locked")
    end })
    local auditRight = auditTab:Section({ Name = "输入与边界", Side = "Right" })
    auditRight:Dropdown({ Name = "P0选择器", Options = {
        "第一项", "第二项", "第三项", "第四项", "第五项", "第六项", "第七项", "第八项", "第九项",
    }, Default = "第二项" })
    auditRight:ColorPicker({ Name = "P0颜色选择", Default = Color3.fromRGB(125, 165, 255) })
    auditRight:Input({ Name = "P0输入焦点", Default = "中文输入法与长文案验收" })
    auditRight:InfoGrid({ Name = "固定运行指标", Items = {
        { Key = "fps", Label = "FPS", Value = "120" },
        { Key = "ping", Label = "Ping", Value = "28 ms" },
        { Key = "memory", Label = "Memory", Value = "180 MB" },
    } })
    auditRight:Button({ Name = "恢复本页窗口尺寸", Callback = function()
        Hub:ResetPanelSize()
    end })

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
