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

## 5. TreeView — 分层数据视图

```lua
local tree = Section:TreeView({
    Name = "功能树", MaxVisible = 6, ExpandRoots = true,
    Nodes = {
        { Id = "combat", Label = "战斗", Children = {
            { Id = "aim", Label = "自动瞄准" },
            { Id = "esp", Label = "ESP" },
        } },
    },
    Callback = function(id, node) print(id) end,
})
tree:SetExpanded("combat", false)
tree:ExpandAll()
tree:SetQuery("ESP") -- 查询自动展示匹配节点及祖先
tree:Select("esp")
tree:Update("esp", { Detail = "运行中" })
tree:GetTree()      -- 独立树形快照
tree:GetVisible()   -- 当前展示的节点快照
tree:Remove("esp")
tree:Destroy()
```

- 支持 14 层深度、4096 个节点以内的数据模型，输入前置校验唯一 ID 和子节点循环引用。
- 按滚动位置复用最多 `MaxVisible+2` 个 GUI 行，保留展开状态（同 ID 节点重建时）。
- 展开/折叠、过滤、只读详情、选择和禁用状态，不对配置文件持久化完整树模型。
- 查询只改变临时可见层级，不覆盖用户已有展开偏好。
- 适用于模块树、配置导航、分组状态；移动端使用 24px 展开按钮和独立行选择区域。

## 6. DataTable 手机响应式模式

`DataTable` 新增 `LayoutMode = "Auto" | "Table" | "Cards"` 和 `CompactBelow`。
- `Auto`：UI 有效宽度小于阈值（默认 300）时使用卡片；否则保留原表格和横向滚动。
- `Table`：强制列式表格，保持原有表头排序。
- `Cards`：每行显示所有声明字段（标题 + 值），复用当前可见行池；分页、搜索、排序、选择仍使用同一数据模型。
- 运行时可以通过 `SetLayoutMode(mode)` 切换，通过 `GetLayoutMode()` 查询当前实际模式。
- UI 宽度变化时自动切换，不重置分页或选中记录；输入法/横竖屏测试仍需 Android 实机验收。

```lua
local grid = Section:DataTable({
    Name = "玩家", LayoutMode = "Auto", CompactBelow = 310,
    Columns = { { Key = "Name" }, { Key = "Ping" }, { Key = "State" } },
    Rows = { { Id = "1", Name = "Player", Ping = 42, State = "Ready" } },
})
grid:SetLayoutMode("Cards")
grid:SetLayoutMode("Auto")
```

## 7. TreeView 状态持久化

TreeView 使用稳定 `Id`（建议指定）自动保存展开节点及选中项至 Hub `setup.json` 中的 `TreeStates`。支持文件系统时跨重启恢复；否则通过 `GetState/SetState` 手动保存。Hub 命名配置 `SaveConfig/LoadConfig` 同步写入 TreeStates，`Reinitialize` 重建时恢复；旧配置无 TreeStates 仍兼容。

```lua
local tree = Section:TreeView({ Id = "features", Persist = true, Nodes = nodes })
local saved = tree:GetState() -- { Version=1, Expanded={[id]=boolean}, SelectedId=id? }
tree:SetState(saved, true)
tree:OnStateChanged(function(state) print(state.SelectedId) end)
```

`Persist=false` 会禁用自动持久化，也不写入命名配置。无效状态输入不会改动节点状态；删除的节点不会被恢复。

## 8. 移动端触控与组件联动

- DataTable 卡片顶部提供排序字段切换与升降序按钮。
- `SwipePaging` 默认启用，水平滑动超过 65px 且方向明显水平时翻页；纵向滚动仍交给原生 ScrollingFrame。
- 长滑动不会再触发行选中。可通过 `SwipePaging=false` 关闭滑动翻页。
- `control:OnDataEvent(event, fn)` 返回 `Disconnect()` 订阅，独立于原有 Callback。
- `Hub:LinkData(source,target,{Event,Action,Map?,Apply?,Immediate?})` 明确地连接同 Hub 内的组件。Action 支持 Select、SetQuery、SetFilter、SetExpanded、SetLayoutMode、Update、Append；控件销毁和 Hub 退出自动解绑。

```lua
local link = Hub:LinkData(tree, grid, {
    Event = "Selection", Action = "Select",
    Map = function(id) return ({ aim = "player-a" })[id] end,
})
Hub:LinkData(statuses, grid, {
    Event = "Filter", Action = "SetQuery",
    Map = function(filter) return filter == "All" and "" or filter end,
})
link:Disconnect()
```

**验收界限：** CI 检查 Luau 状态恢复、订阅生命周期及滚动代码路径；Android 多指滑动、不同屏幕方向、执行器差异仍须实机确认。

## 9. 可靠性修复：批量写入、重建联动、触控资源清理

- TreeView 在内存中立即更新状态，同时将文件写入合并到约 350ms 窗口；`tree:FlushState()` 可以显式刷新，控件销毁与 Hub 销毁前会刷新未提交的状态。适合连续展开/折叠时避免每一次点击都进行同步文件 I/O。
- `Hub:Reinitialize()` 现在保留活动的显式 `LinkData` 链接，使用原来组件创建配方对应的新控件重绑，不在重建中触发 `Immediate` 副作用。外部保留的旧链接句柄在重建后仍可调用 `Disconnect()`。
- DataTable 仅在列表数据区域跟踪触点，排序和分页按钮手势不再触发卡片横滑翻页；卡片/表格行显式注册触点，销毁时释放控件级输入连接。
- 分页输入拒绝 NaN 和正负无穷；数据排序、重筛选和数据替换重置卡片滚动位置，避免用户看到旧页面的残留位置。

自动化原生 Luau 测试覆盖 Hub 重初始化、链接恢复与解绑、树状态刷新以及表格控件清理；Android 真机连续多指、系统手势、不同执行器兼容仍属于实机验收范围。

- `DataTable:Update(id, changes, silent)` 现在发送结构化 `Data` 事件 `{ Operation = "Update", Id = id }`，而不是误报为 `Upsert`；仍只触发一次旧式 Callback。对应原生回归覆盖事件类型。


## 高级组件联动：ModuleCard × InfoGrid/InfoList

现在 `ModuleCard` 可以触发 `Value`、`Status`、`Summary`、`Favorite`、`Expanded` 等事件，信息组件的 `Data` 事件包含 `Operation` 与单条更新的 `Key`、`Item`。

```luau
local link = Hub:LinkData(card, metrics, {
    Event = "Status", Action = "Update", Immediate = true,
    Map = function(s) return { Key = "status", Value = s.Status, Tone = s.Tone } end,
})
local reverse = Hub:LinkData(metrics, card, {
    Event = "Data", Action = "SetSummary",
    Map = function(e)
        return e.Key == "fps" and ("FPS: " .. e.Item.Value) or nil
    end,
})
```

`LinkData` 新增 `Set`、`SetStatus`、`SetSummary`、`SetFavorite`、`SetLocked`、`SetOrder`、`UpdateMany` 动作。目标为 InfoGrid/InfoList 的 `Update` 使用 `{ Key, Value, Tone? }`。 `Immediate=true` 根据事件选取对应 getter，避免对状态事件错误读取选择状态。链接在 Hub 销毁时清理，可显式 `Disconnect()`。
