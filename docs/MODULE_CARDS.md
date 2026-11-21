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


## 稳定性修复与增量数据接口（2026-11-20）

**状态存储**：`ModuleCards` 使用明确的 `"expanded"` 或 `"collapsed"` 值，避免 Lua 的 `false/nil` 判断抹掉展开偏好。旧的布尔值保持可读。`ModuleFavorites` 保留 true/false；取消收藏写入 false。搜索临时展开不修改保存状态。

**父级继承**：ModuleCard → Group → Slider/Toggle 等路径继承原卡片上下文。搜索匹配嵌套组内控件时临时展开其 Group 和外层 ModuleCard，清空搜索恢复原有折叠状态。旧 Group API 不变。

**依赖即时性**：Card 开关变化以及静默配置恢复时，依赖的子模块立即同步。卡片额外提供 `OffChanged(callback)` 取消监听。

**默认值**：显式 `Default` 在控件注册时立即捕获，异步读取仅用于没有声明 `Default` 的旧控件；`ModuleCard:Reset()` 会恢复卡片及嵌套组中的初始值。

**InfoGrid / InfoList 新增的数据方法**：

```lua
grid:UpdateMany({
    fps = 142,
    ping = { Value = "28 ms", Tone = "Success" },
})
grid:Upsert({ Key = "memory", Label = "Memory", Value = "220 MB" })
grid:Remove("memory")
grid:Clear()
local snapshot = grid:Get()

details:UpdateMany({ runtime = "Ready", mode = { Value = "Balanced", Tone = "Accent" } })
details:Upsert({ Key = "build", Label = "Build", Value = "R2" })
details:Remove("build")
```

`Set()` 接收键序相同的数据时复用原 UI 行，只更新变化的文字与颜色；键顺序或数量发生变化时才重建。单项 `Update()` 使用键索引，减少实时指标刷新成本。返回的 `Get()` 为独立的浅层记录快照，修改快照不会影响控件内部状态。

**验证重点**：扩展 `tests/module-cards-lune.luau` 与 `tests/module-cards.mjs`，覆盖依赖切换、Group 搜索、旧控件默认值重置、持久化与信息增量更新。


## 信息组织与联动增强（2026-11-21）

ModuleCard 已可以作为 `Hub:LinkData` 的数据源，使用 `OnDataEvent(event, fn)` 订阅 `Value`、`Status`、`Summary`、`Favorite`、`Expanded`、`Locked`、`Visibility` 事件。订阅返回可 `Disconnect()` 的句柄，Hub 销毁时失效。状态查询有 `GetStatus()`（返回 `{ Status, Tone }`）和 `GetSummary()`。

InfoGrid 与 InfoList 新增：

```luau
local sub = metrics:OnDataEvent("Data", function(e)
    print(e.Operation, e.Key, e.Item and e.Item.Value)
end)
local fps = metrics:GetItem("fps") -- 单条浅拷贝，找不到返回 nil
metrics:SetOrder({ "ping", "fps" }) -- 重新排序但复用现有 GUI 对象
metrics:UpdateMany({ fps = 130, ping = "25ms" }) -- 仅一次 Batch 事件
sub:Disconnect()
```

数据事件包含 `Operation = Set/Update/Batch/Upsert/Remove/Order`；更新/插入事件包含 `Key`、`Item`，集合事件包含 `Items`。 `Set(items, true)`、`Update(key,value,tone,true)` 可静默更新。重复 Key 会在提交前被拒绝，旧数据保持不变；`SetOrder` 必须包含所有现有 Key 且无重复，错误输入返回 `false, reason`。排序仅改变当前顺序和 GUI 布局，不影响 Flags 或旧控件接口。


## 增量优化：移动端、批量更新与嵌套状态（2026-11-21）

- ModuleCard 的开关视觉仍为 28×17 像素，但透明触控命中区域提升到 **44×44 像素**，加入按压缩放反馈；其余外观和点击回调不变。
- 嵌套卡片可选择 `InheritParentState = true`。父卡片开关关闭、手动锁定或依赖被禁用时，子卡片采用现有锁定遮罩并同步向下传播，不清除任何 Flag 或配置值。默认关闭此行为，兼容旧脚本。
- InfoGrid/InfoList 在 `Set/Upsert/Remove` 导致 Key 集变化时，改为按 **Key** 对现有 GUI 进行对账，复用未变动行。 `SetOrder` 继续直接调整顺序。
- `UpdateMany(values)` 原有的容错计数行为保持不变。`UpdateMany(values, true)` 或 `UpdateManyStrict(values)` 新增严格批处理：先检查全部 Key 和 Value，再一次性修改数据并发送一条 Batch 事件。校验失败返回 `false, reason`，原状态保持不变。

```luau
local child = parentCard:ModuleCard({ Name = "高级", InheritParentState = true })
local count = metrics:UpdateManyStrict({ fps = 120, ping = "31ms" })
local ok, err = metrics:UpdateMany({ fps = 120, unknown = 1 }, true)
-- ok == false；已存在的 fps 不被提前更新
```

这些改动不增加 RenderStepped 循环或新的全局触控监听，仍需在 Android / Delta 实机验证点击命中与视觉层级。


### 最终收尾：高频指标与触控布局

- 没有 `Data` 订阅者时，InfoGrid/InfoList 更新保留所有数据写入与 GUI 同步，但跳过仅供事件使用的整组快照。存在订阅时维持原来的单次 Batch 事件格式。
- ModuleCard 保持 28×17 可见开关和 44×44 点击区域，将命中区域避开收藏按钮，并加高标题行避免按钮底部越界。
- 嵌套依赖卡片销毁时解除父模块的变更回调。
- Native Lune 压力用例覆盖两个 36 项信息组件分别执行 90 次完整严格批量更新，共 6,480 次值写入，并检查 GUI 复用与单批次事件数。这不是 Android 真机 FPS 测量。


### 状态色与组件销毁一致性（2026-11-21）

- `card:SetStatus("Rechecking")` 未提供 Tone 时只改变文字，保留之前的状态颜色。需要恢复默认文本色时应显式提供 `"SubText"`。
- ModuleCard 销毁后不执行尚未运行的异步开关回调，并清空本地观察者集合。
- InfoGrid / InfoList 增加 `UpdateMany(values, { Strict = true, Silent = true })`；与旧版 `UpdateMany(values, true)` 兼容。
