# Relax UI — 系统化架构与开发者能力分轮实施

项目：`keepBacon/relax-lua-ui`。目标：让开发者不依赖复制库内部代码，也能扩展、调试、复现和维护高质量 Luau UI。此计划从 **2026-11-23** 的 `main` 开始；每一轮是独立、可测试、可合并的 PR。

## 架构原则

- 一套运行时：`Hub` 是生命周期所有者；`Section` 是控件注册入口；`Design Tokens v2` 管主题；`OverlayStack` 管弹层；`InputFocus` 管输入；`Motion` 管动画；`ResourceScope` 管资源。
- **优先在现有边界上扩展**，不复制 UI 框架或新开全局事件循环。
- 公开 API 是稳定契约；旧 `Flag`、`Get/Set`、Callback、配置、ModuleCard 和 `DEMO` 授权规则不得破坏。保持 RiftUI 原通知外观。
- 对外错误采用 `false, reason` 或 `nil, reason`，开发者回调隔离异常；运行时状态查询返回快照，避免外部直接修改内部表。
- 资源必须有明确拥有者，Close/Destroy/Reinitialize 后不留下事件监听、任务、悬浮层和临时状态。移动端的实机验收与 CI 分开。

## 分轮交付

| 轮次 | 主要目标 | 具体交付与验收 | 状态 |
|---|---|---|---|
| **R1 — Developer SDK 基础** | 扩展生命周期 + 诊断 | `RegisterExtension`、`CreateDeveloperScope`、本地事件、限长诊断、Developer 页统计、Reinitialize 恢复；Node + Native Lune 断言 | 已完成（#77） |
| **R2 — 可扩展控件契约** | 让第三方控件无需修改主库 | 注册自定义控件构造器、标准 Value/Flag/Callback/主题/可用性/销毁、冲突检查、兼容旧创建 API | 本轮 |
| R3 — 开发调试与问题复现 | 加强现有 Visual Inspector | 触控命中框、父级裁剪、Token 来源、组件树与状态导出、诊断与视觉联动；覆盖层仅手动启用 | 待实施 |
| R4 — SDK 文档与开发工具链 | 降低二次开发成本 | API 参数/返回/生命周期文档、Luau 类型定义、可运行 Showcase、迁移指南、兼容性测试样例 | 待实施 |
| R5 — 性能与发布验收体系 | 量化质量与回归 | 100/300 控件基线、千行 DataTable、主题与弹窗压力、重复初始化资源审计、CI 报告与 Android 设备记录 | 待实施 |

每轮只改动相应边界，通过测试后再合并；不会仅凭静态代码存在就宣称真机适配成功。

## R1 — Developer SDK API

入口文件：`lib/core/DeveloperKit.luau`。Hub 上的 API 不依赖 Developer Mode 是否打开；只有 UI 统计显示在已有 Developer 页，其他页面不会自动出现调试覆盖层。

### 注册与卸载扩展

```luau
local received = 0

local ok, infoOrError = hub:RegisterExtension("example.metrics", {
    Version = "1.0.0",
    Start = function(targetHub, scope)
        scope:Own(targetHub:OnDeveloperEvent("metric.sample", function(data)
            received += data.Value
        end))

        -- 接口连接、Instance、具有 Destroy/Disconnect/Cancel 的对象及函数
        -- 均可加入 scope；卸载时按后进先出的顺序释放。
        scope:Defer(function()
            print("metrics extension released")
        end)
    end,
    Stop = function(targetHub, scope)
        print("metrics extension stopping")
    end,
})

hub:EmitDeveloperEvent("metric.sample", { Value = 3 })
print(hub:GetExtension("example.metrics"))  -- 元数据快照
print(hub:ListExtensions())                    -- 已注册名称数组
hub:UnregisterExtension("example.metrics")
```

`RegisterExtension(name, descriptor)` 成功返回 `true, metadata`；重复名称、无效参数、初始化抛错均返回 `false, reason`，失败初始化会回滚 Scope。名称只接受字母、数字、`_`、`-`、`.`，最长 72 字符。使用 `Start(hub,scope)` 初始化；`Stop(hub,scope)` 可选。Start 可以返回一个清理函数或清理资源，该资源由 Scope 自动拥有。

`UnregisterExtension` 会先执行 Stop，再释放 Scope。Hub 销毁时按扩展注册顺序的逆序卸载。Reinitialize 会按原始注册顺序对新 Hub 重新调用 Start；旧监听器与实例必须由原 Scope 释放。**扩展 Start 中创建的控件不会额外写入常规控件重放配方**，防止重建时创建两次；不保证跨重建保留扩展自有对象的旧 Lua 引用。

### 独立资源域

```luau
local scope = hub:CreateDeveloperScope("network-panel")
local signal = someInstance:GetPropertyChangedSignal("Visible")
scope:Connect(signal, function()
    print(someInstance.Visible)
end)
scope:Own(anotherInstance)
scope:Defer(function()
    print("cleanup")
end)
scope:Close()
```

`CreateDeveloperScope(name?)` 返回 Scope 或 `nil, reason`；Scope 支持 `:Own(resource)`、`:Connect(signal, fn)`、`:Defer(fn)`、`:Close()`，最后一个接口可安全重复调用。独立 Scope 在 Hub 销毁时也会清理。资源清理与已有 `Hub:Own()` 复用一致策略。

### 局部开发者事件

```luau
local subscription = hub:OnDeveloperEvent("feature.updated", function(payload, event, owner)
    print(event, payload.Key)
end, scope) -- 传入 Scope 会在卸载时自动断开

local ok, delivered = hub:EmitDeveloperEvent("feature.updated", { Key = "enabled" })
subscription:Disconnect() -- 手动取消也是幂等操作
```

每个 Hub 拥有独立事件表；派发不借助额外全局 `UserInputService` 监听或每帧轮询。一个监听器错误只记录诊断，不中断其他监听器。所有非 Scope 订阅必须显式 Disconnect；Hub 最终销毁时统一释放。

### 诊断与计数

```luau
hub:ReportDeveloperDiagnostic("Warning", "layout.overflow", "Content clipped", "panel")
local history = hub:GetDeveloperDiagnostics("Warning")
local stats = hub:GetDeveloperStats()
-- stats.Extensions / Scopes / Listeners / Diagnostics / Events / Faults
hub:ClearDeveloperDiagnostics()
```

级别：`Info`、`Warning`、`Error`；最近 80 条记录以只读快照返回，默认不写磁盘、不上传网络、不显示 Toast。首次调用惰性初始化 SDK；调用者应在正式环境中避免把密码、私有 Token 等机密信息放进诊断消息。

### 验收

- Node：验证模块打包一致性、扩展 API、资源回收接线、源码不包含 Heartbeat/RenderStepped 循环。
- Native Luau：验证事件发送/断订、监听错误隔离、资源逆序清理、诊断容量与防外部修改、注册重复拒绝、失败回滚、Reinitialize 自动恢复、最终销毁。
- Android 实机：尚需额外检查长时间使用、后台切换、热重建及多次加载后的连接/实例数。Native Lune 不等于设备验收。

## 后续执行口径

用户说「继续」时从 **R2：自定义控件契约** 开始，而不是重新开发现有 Design Tokens、OverlayStack 或 Visual Inspector。每轮附源码、预览、文档、自动化测试与真实设备验收说明。


## R2 — 自定义控件协议

入口：`lib/core/CustomComponents.luau`。**控件定义属于 Hub，不修改全局 Section 类或覆盖内置控件。** 开发者用 `Hub:RegisterComponent(name, descriptor, ownerScope?)` 注册；然后用 `Section:Component(name, options)` 创建。Group 与 ModuleCard 继承 Section 接口，因此同样支持 `:Component()`。

```luau
local ok, metadata = hub:RegisterComponent("demo.badge", {
    Version = "1.0.0", Height = 44, Default = 0,
    Validate = function(value, options, control)
        return type(value) == "number", "value must be numeric"
    end,
    Render = function(context, options)
        local button = Instance.new("TextButton")
        button.Parent = context.Frame
        button.Size = UDim2.fromScale(1, 1)
        context:BindToken(button, "TextColor3", "Color.TextPrimary")
        context:Connect(button.MouseButton1Click, function()
            context:Emit(context.Control:Get() + 1)
        end)
        return {
            Set = function(_, value)
                button.Text = tostring(value)
                return true
            end,
        }
    end,
})
local badge = section:Component("demo.badge", {
    Name = "Badge", Flag = "MyBadge", Default = 2,
    Callback = function(value) print(value) end,
})
badge:Set(10)        -- 同步变更，异步通知 Callback / OnChanged
print(badge:Get())   -- 10
badge:SetLocked(true, "不可用")
badge:Destroy()
hub:UnregisterComponent("demo.badge")
```

**注册契约：** `Render(context, options)` 必填，返回可选视图对象 `{Set?, Get?, Destroy?}` 或 `nil`；`Validate(value, options, control)` 可选。注册时拒绝重复名称、内置 Section 方法名和非法描述符。默认高度 44，限制在 28–320 逻辑像素；`options.AutoHeight=true` 允许容器随子节点变化。Registry 查询：`hub:GetComponent(name)` 返回名称、版本、实例数的快照，`hub:ListComponents()` 返回名称数组。

`context` 包含 `Hub`、`Section`、`Frame`、`Control`、`Scope`；还有 `:BindToken(inst,prop,path,transform?)`、`:Connect(signal,callback)`、`:OnDestroy(callback)`、`:Emit(value,silent?)`。控件复用 `_control()`，因而可使用普通控件的 `:Get()/Set()`、`:OnChanged()/OffChanged()`、`:OnDataEvent()`、`:SetLocked()`、`:SetAvailability()`、Requires、`Flag`、Tooltips 和 ModuleCard 可用性遮罩。

**Flag 与配置：** 默认可持久化的 Component 通过现有 JSON 配置使用 `{Value = ...}` 序列化；只应保存基础 JSON 值或相容的嵌套表，不直接保存 Roblox Instance / Color3 等自定义 userdata。设 `Persist=false` 可以禁止配置保存。静默赋值仍进行验证和渲染，但不调度 Callback/OnChanged。自定义渲染器若需要颜色主题，请使用 `context:BindToken`（已有 Design Tokens v2）。普通 UI 控件方法没有被改名。

**实例生命周期：** Render 出错会返回 `nil, reason`，并撤销已注册的 Flag、Section 行、DataLink 与开发者资源；Render **成功后**才进入 `_recipe`。显式 Destroy、父 Row Destroy 或 `Hub:UnregisterComponent(name)` 都会释放 Scope、token 绑定、事件订阅与子控件。Hub 重建时，先恢复独立注册的自定义定义，再回放普通 Section 配方；同一扩展 Start 中动态创建的控件则在扩展启动时重建，不重复写配方。

**扩展集成：** `hub:RegisterComponent(name, descriptor, scope)` 把定义绑定到 R1 的开放 Scope；Scope 关闭会自动注销该类型和所属实例。扩展自己注册的类型应在 Start 中重新注册，Stop/卸载时无需另写清理逻辑。不强制将所有控件实例都绑定到扩展；需要该行为时可通过 `scope:Own(component)` 管理。

**验收：** Node 检查模块与发布产物一致；Native Lune 创建 Section/Group/ModuleCard 自定义控件，验证数值、锁定、Flag/配置、Render 出错回滚、Scoped 注册注销、Reinitialize 和逆序销毁；Android 触控、字体与长列表流畅度仍须真机验证。

**下一轮：R3 — Inspector 与问题复现工具**。增强已有 Visual Inspector：命中框、裁剪祖先、Token 来源、只读组件状态与本地导出；避免在正常游戏模式下常驻调试渲染开销。
