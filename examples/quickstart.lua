-- Roblox executor quickstart (requires loadstring + game:HttpGet support)
-- Source: https://github.com/keepBacon/relax-lua-ui
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/VortexionUI.lua"
))()

local Window = UI.CreateWindow({
    Title = "VortexionLua",
    Subtitle = "示例服务器",
    Theme = "Dark",
    Transparency = 0.1,
    Animations = true,
    -- Icon = "rbxassetid://YOUR_UPLOADED_ICON_ID",
})

local general = Window:CreateTabGroup("主要功能")
local home = general:CreateTab("首页", {Selected = true})
home:CreateSection("功能")
home:CreateParagraph({Title = "Relax UI", Content = "独立的 Luau UI 库；不依赖 WindUI。"})
home:CreateButton({Title = "测试通知", ButtonText = "显示", Callback = function()
    Window:Notify({Title = "Relax UI", Content = "按钮回调已执行", Duration = 3})
end})
home:CreateToggle({Title = "功能开关", Default = false, Callback = function(value)
    print("Toggle:", value)
end})
home:CreateSlider({Title = "移动速度", Min = 0, Max = 100, Step = 5, Default = 30, Callback = function(value)
    print("Slider:", value)
end})
home:CreateInput({Title = "备注", Default = "", Placeholder = "输入文本", Callback = function(value)
    print("Input:", value)
end})
home:CreateDropdown({Title = "模式", Options = {"普通", "快速", "省电"}, Default = "普通", Callback = function(value)
    print("Dropdown:", value)
end})

local tools = Window:CreateTabGroup("扩展", {Collapsed = false})
local settings = tools:CreateTab("设置")
settings:CreateKeybind({Title = "快捷键", Default = Enum.KeyCode.RightShift, Callback = function()
    Window:Toggle()
end})
settings:CreateButton({Title = "切换主题", ButtonText = "切换", Callback = function()
    Window:SetTheme(Window.ThemeName == "Dark" and "Light" or "Dark")
end})
settings:CreateButton({Title = "确认对话框", ButtonText = "打开", Callback = function()
    Window:Confirm({Title = "确认", Content = "是否继续？", Callback = function(ok)
        print("Confirmed:", ok)
    end})
end})

-- On exit: Window:Destroy()
