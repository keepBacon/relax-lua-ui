# RelaxUI 模块卡片与高级信息组织

本次为**增量功能**：不改变或删除原有 `Section`、`Group`、`Toggle`、`Slider`、`Dropdown`、`Button`、`Keybind`、`List`、`Console`、`Stat`、`Sparkline`、`Progress` 等控件，也不修改它们既有的公共方法。模块卡片内部直接复用 `Section` 的控件创建器、Flags 与配置系统。

## 模块卡片

```lua
local section = tab:Section({ Name = "Combat", Side = "Left" })
local card = section:ModuleCard({
    Name = "Aim Assist", Id = "aim-assist", Icon = "crosshair",
    Description = "瞄准辅助设置",
    Flag = "AimAssist", Toggle = true, Default = false,
    Collapsed = true, Favoritable = true,
    Status = "Ready", Tone = "Success",
})
local enabled = card:Toggle({ Name = "启用追踪", Flag = "AimTracking", Default = false })
local range = card:Slider({ Name = "范围", Flag = "AimRange", Min = 0, Max = 100, Default = 50 })
local keybind = card:Keybind({ Name = "热键", Flag = "AimKey", Default = Enum.KeyCode.H })

local advanced = card:ModuleCard({ Name = "高级设置", Collapsed = true })
advanced:Dropdown({ Name = "选择模式", Options = { "A", "B" }, Default = "A" })
```

支持 `card:Set(bool, silent?)`、`card:Get()`、`card:OnChanged(fn)`、`card:SetExpanded(bool, instant?)`、`card:IsExpanded()`、`card:SetFavorite(bool)`、`card:IsFavorite()`、`card:SetSummary(text)`、`card:SetStatus(text, tone?)`、`card:SetLocked(bool, reason?)`、`card:IsLocked()`、`card:Reset()`、`card:SetVisible(bool)`。

卡片开关受 `Flag`（或 `Toggle = true`）控制；不声明开关时卡片仅用作容器。展开状态保存于 `setup.json:ModuleCards`，收藏状态保存于 `setup.json:ModuleFavorites`。开关 Flag 与原有控件 Flag 一起参与配置存取。收藏通过 `UIListLayout.LayoutOrder` 提升显示位置，不重排或替换原来的控件对象。

可使用 `DependsOn = { Control = enabled, Equals = true, Behavior = "Disable" }`，或在依赖 Flag 已注册时使用 `DependsOn = { Flag = "AimTracking", Equals = true, Behavior = "Hide" }`。依赖状态仅影响禁用遮罩或显示，不销毁内容。

**搜索/命令跳转**：检索卡片名称或内部控件名称均能保留相应父级；搜索期间临时展开的卡片不覆盖用户保存的展开状态，退出搜索后恢复。

## 高级信息组织

```lua
local grid = section:InfoGrid({
    Name = "性能摘要", Columns = 2, MinCellWidth = 90,
    Items = {
        { Key = "fps", Label = "FPS", Value = "120", Tone = "Success", Detail = "帧率" },
        { Key = "ping", Label = "Ping", Value = "32ms" },
    },
})
grid:Update("fps", "132", "Success")
grid:Set({ { Key = "fps", Label = "FPS", Value = "145" } })

local details = section:InfoList({
    Name = "运行环境",
    Items = {
        { Key = "backend", Label = "后端", Value = "Ready", Tone = "Success" },
        { Key = "mode", Label = "渲染模式", Value = "Balanced" },
    },
})
details:Update("mode", "Performance")
```

两种信息组件都提供 `Set(items)`、`Update(key, value, tone?)`、`Get()`，不会代替现有 `Stat`、`List`、`Console` 及图表。InfoGrid 按实际可用宽度和 `MinCellWidth` 自动从单列切换到最多 `Columns` 列，信息值在更新时仅更新现有标签；InfoList 使用紧凑键值行与细分隔线。

## 兼容与验收

- 原有控件保留原公共 API；不对它们的值与回调进行重新包装。
- 模块卡片嵌套使用同一个 Tab/Section 和 Hub 的生命周期、主题与动画状态机。
- 模块卡片的展开/收起与 Chevron 采用统一 `Motion.play`，中断旧动画不会令高度重置。
- 测试：`node tests/module-cards.mjs`，`lune run tests/module-cards-lune`，原有 Node、Lune、WASM 和构建验证。
- 本次不包含大型数据表格、拖动排序、全局 OverlayManager 或 3D 视图；这些保留给路线图后续阶段。
- Android 的缩放布局、动态数据刷新和快速反复开合仍需 Roblox 实机观察。
