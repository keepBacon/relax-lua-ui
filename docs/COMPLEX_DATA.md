# RelaxUI P2：复杂数据组件

本阶段在保留所有原有控件的基础上，以模块化方式新增：
`OrderList`、`DataTable`、`StatusList` 和可选 `ViewportPreview`。
源码位于 `lib/core/`；构建后统一嵌入 `public/RiftUI.luau`。
无需新增第三方包或运行时网络请求。

## 1. OrderList — 可配置的优先级顺序

```lua
local priorities = Section:OrderList({
    Name = "优先级",
    Flag = "ModulePriority",
    MaxVisible = 6,
    Items = {
        { Id = "aim", Label = "Aiming" },
        { Id = "esp", Label = "ESP" },
        { Id = "core", Label = "Core", Disabled = true },
        { Id = "ui", Label = "UI" },
    },
    Callback = function(order)
        print(table.concat(order, ","))
    end,
})
priorities:GetOrder()
priorities:SetOrder({ "esp", "aim", "core", "ui" })
priorities:Move("esp", 1)
priorities:OnOrderChanged(function(ids) end)
priorities:SetItems(newItems) -- keep still-known ids in prior order
priorities:Reset(true)
```

- 显示行：编号、名称、拖动把手、上下移动按钮；安卓无需精准拖动也能排序。
- `Disabled` 行保持固定位置，不能拖动，也不能被其他项跨越。
- `SetOrder(ids, silent?)` 支持按 Id 恢复顺序，未知或重复 Id 返回失败而不破坏既有状态。
- `SetItems` 允许动态增删条目；`GetOrder` 返回独立副本；`Flag` 按现有配置系统存储顺序数组。
- 拖动使用已有 `bindPointerDrag`，取消或销毁时释放触点及滚动锁。
- 组件提供 `Destroy()`，不保留专属全局输入循环。

## 2. DataTable — 有状态数据表

```lua
local tableView = Section:DataTable({
    Name = "任务统计", PageSize = 8,
    Columns = {
        { Key = "Name", Title = "名称", Width = 130, Sortable = true },
        { Key = "FPS", Title = "FPS", Width = 80, Align = "Right" },
        { Key = "Status", Title = "状态", Width = 110 },
    },
    Rows = {
        { Id = "render", Name = "Renderer", FPS = 122, Status = "Ready" },
        { Id = "network", Name = "Network", FPS = 104, Status = "Warning" },
    },
    Callback = function(id, row) print(id) end, -- 仅行选择调用
})
tableView:SetSort("FPS", true)
tableView:SetQuery("Ready")
tableView:SetPage(1)
tableView:Update("render", { FPS = 135 })
tableView:Upsert({ Id = "input", Name = "Input", FPS = 120, Status = "Ready" })
tableView:Remove("network")
tableView:Select("render")
tableView:Get()          -- 所有未排序原始记录的独立副本
tableView:GetVisible()   -- 当前排序与筛选后的记录
tableView:SetLoading(true)
tableView:SetError("Failed to fetch")
tableView:SetError(nil)
```

- 列配置支持 `Key`/`Title`/`Width`/`Align`/`Sortable`/`Format(value,row)`。
- 表头点击可排序；内部区分原始数据、筛选排序视图和当前页。
- `Id` 稳定索引；更新只涉及现有记录和当前页 GUI，不因 1,000 条数据创建 1,000 个行实例。
- 每页显示上限为 40 行，支持翻页按钮、手机横向滚动与纵向滚动。
- 行选中效果、空状态、加载和错误状态具备独立显示。
- `Get()` 返回快照，不暴露内部索引，不让外部修改意外影响视图。

## 3. StatusList — 只读状态监测

```lua
local states = Section:StatusList({
    Name = "实时状态", MaxVisible = 6,
    Items = {
        { Id = "net", Label = "Network", State = "Healthy", Detail = "Connected" },
        { Id = "sync", Label = "Sync", State = "Warning", Detail = "Retrying" },
    },
})
states:Update("net", { State = "Warning", Detail = "High latency" })
states:Upsert({ Id = "host", Label = "Runtime", State = "Ready" })
states:SetFilter("Warning")   -- 状态值或主题语义色
states:SetFilter("All")
states:Remove("host")
states:SetLoading(true)
states:SetError(nil)
states:Clear()
```

- 语义色：Healthy/Online/Ready 为 Success，Warning/Degraded 为 Warning，
  Error/Offline 为 Danger，Idle/Unknown 为 Muted。也支持自定义 `Tone`。
- `Id` 唯一，可按 Id 更新/删除。默认不提供点击或修改数据状态的控件。
- 有界行池，最多 `MaxVisible+2` 个实际状态行，滚动时重用，避免长表阻塞。
- `Get()` 返回独立数据副本，数据与布局状态分离。

## 4. ViewportPreview — 可选 Roblox 3D 预览

```lua
local preview = Section:ViewportPreview({ Name = "模型", Height = 200, Interactive = true })
local ok, err = preview:SetModel(workspace.SomeModel)
preview:SetInteractive(true)
preview:Rotate(10, -5)
preview:SetZoom(1.3)
preview:ResetView()
```

- 首先检测 `ViewportFrame`、`WorldModel` 和 `Camera` 是否受支持。
- 仅克隆 `Model` 或 `BasePart`，不会修改原模型所有权；移除克隆内脚本。
- 手势仅在显式开启 `Interactive` 时允许，使用统一输入捕获；
  提供 zoom +/- 按钮、鼠标滚轮缩放和拖动旋转。
- `SetModel(nil)` 清空，`Destroy()` 删除预览资源。
- 引擎不支持 3D（例如某些 Web/Lune 模拟器）时，返回错误原因并显示降级说明，不阻断 UI。
- 无永久 `RenderStepped` 循环。

## 兼容性与测试

所有组件经 `Section:_control` 接入原有 Hub、Section、ModuleCard 和 Group。
`OrderList` 的有状态 `Flag` 参与配置保存；DataTable、StatusList、ViewportPreview 视作只读或运行时数据，
不把大量列表或 Roblox Instance 引用写入配置。新增接口不更改 `List`、`Console`、`InfoGrid`、`InfoList` 等已有控件。

构建：`node scripts/bundle.mjs`。
静态检查：`node tests/complex-data.mjs`。
原生测试：`lune run tests/complex-data-lune`。
完整验证由 GitHub Actions 的两条 workflow 自动执行。

## Android 实机验收

应检查：横向滚动与分页/纵向滚动不冲突；排序拖动和父级 `ScrollingFrame` 的滚动锁；
方向切换时重新排版；快速连续更新 500/1,000 条数据的输入响应；组件销毁后无遗留捕获；
高频状态变更不产生 GUI 实例增长；3D 预览模型缺失、不可克隆、不支持 ViewportFrame 时的回退。

### 大规模数据回归

原生 Lune 测试新增 750 条 DataTable 行、360 条 StatusList 记录的构造、局部更新及 GUI 池大小验证：前者每页仅创建 `PageSize` 个行节点（此例为 3），后者不超过 `MaxVisible+2`（此例为 5）。该检查验证实例数量上界，不等同于真实安卓设备上的 FPS/耗时基准；仍需实机测量。

### 显式销毁与注册表一致性

四类组件的 `Destroy()` 除删除其 GUI 和交互资源，还会从 `Section.Controls`、关联 `ModuleCard`、全局 Flag 注册表，以及 Hub 的重建配方中取消注册，防止后续搜索、配置保存或重新初始化再次引用已经销毁的控件。销毁后不应再直接调用该控件的操作 API。
