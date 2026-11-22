# RelaxUI 控件状态与锁定弹窗

普通控件与 `ModuleCard` 具有完全一致的两种**可用性状态**：

| 状态 | 外观 | 行为 |
|---|---|---|
| `Available` | 不加任何额外标记或遮罩 | 保持原有交互 |
| `Locked` | 半透明黑色遮罩 + 居中锁图标 | 拦截触控；点击锁图标会轻微振动并弹出锁定原因和操作 |

两种状态不会影响 ModuleCard 的标题/描述/收藏布局，也不会新增 Ready 等状态标签。原有 `SetStatus` / `GetStatus` 仍是独立的数据接口。

## 创建时配置

```luau
local locked = section:Button({
    Name = "高级功能",
    State = "Locked", -- 或 Locked = true
    Lock = {
        Title = "高级功能已锁定",
        Reason = "需要先完成权限验证。",
        Details = "你可以查看帮助文档，或者稍后重新尝试。",
        Icon = "lock",
        Width = 382,
        CloseOnOutside = false,
        Actions = {
            {
                Text = "帮助",
                KeepOpen = true,
                Callback = function(control, dialog)
                    dialog:SetContent("详细说明可通过此按钮更新。")
                    return false -- 保持弹窗打开
                end,
            },
            { Text = "关闭", Primary = true },
        },
    },
    Callback = function()
        print("Unlocked")
    end,
})
```

`State = "Available"` 和省略 `State` 默认完全正常显示，不会添加图标或背景。可用 `Locked = true` / `LockReason` / `LockDetails` / `LockActions` 作为简写。

`ModuleCard` 可使用相同的初始化选项；锁定罩覆盖整张卡片（包含标题、开关和展开内容），而不是只覆盖内容区。

## 运行时方法

```luau
locked:SetAvailability("Available")                    -- 无遮罩
locked:SetAvailability("Locked", "操作被临时禁用")        -- 显示遮罩
locked:SetLocked(true, "需要完成权限验证")               -- 等价
locked:SetLocked(false)                                 -- 解锁
local state, reason = locked:GetAvailability()          -- "Available" / "Locked"
local lockedNow = locked:IsLocked()
locked:SetLockActions({
    { Text = "重试", Callback = function(control, dialog)
        -- 返回 false 保持弹窗打开
    end },
    { Text = "知道了", Primary = true },
})
locked:ShowLockReason()                                  -- 通过代码主动显示原因弹窗
```

所有状态切换都会保留现有控件的数值与回调。锁定时遮罩阻止触控，支持 `Set` 的普通交互控件也会拒绝通过对应 API 修改值（返回 `false, reason`）。

`Requires` 的动态依赖仍受 `Hub:CanUse` 管理；即使手动解除锁定，未满足依赖时仍显示锁定罩和依赖原因。模块卡片的 `DependsOn` / `InheritParentState` 继续同步覆盖层。

## 弹窗能力

`Hub:OpenActionDialog(options)` 独立于锁定控件也能直接调用。支持以下字段：

- `Title`、`Icon`、`Content`（或 `Reason`）、`Details`、`Width`。
- `Buttons = { { Text, Primary?, Danger?, KeepOpen?, Callback? } }`。按钮按垂直排列，适合 Android 触控和较长文案。
- `CloseOnOutside`（默认不允许点外部关闭）、`Escape`、`OnClose`。
- 返回句柄支持 `:Close()`、`:SetError(text)`、`:SetContent(text)`。

在直接调用 `Hub:OpenActionDialog` 时 `Buttons.Callback(dialog)`；控件 `Lock.Actions.Callback(control, dialog)`。回调返回 `false` 或设置 `KeepOpen = true` 时弹窗保持打开；异常将在弹窗内显示，不会中断主 UI。

弹窗使用原生 Frame、主题颜色、统一 Motion 和 OverlayStack：不会将文字复合到 CanvasGroup 纹理，关闭时注销弹层及连接，阻止遮罩点击穿透。

## 验证

运行现有的 `node tests/module-cards.mjs`、`lune run tests/module-cards-lune`、`lune run tests/overlay-stack-lune`，以及 GitHub Actions 完整构建。Android 真机上仍需检查不同界面比例、锁图标资源、手指快速连续点击与长文本滚动表现。

## 2026-11-22：弹窗布局与锁图标更新

锁定遮罩继续覆盖控件，`LockPlate` 改为完全透明的图标动画载体，中央仅显示锁图标，不再绘制黑色圆形底板。

`ButtonLayout`（别名 `ActionsLayout`、`Layout`）可以指定两种按钮方向：

- `"Vertical"`：默认竖列按钮，每个按钮占据一整行。
- `"HorizontalRight"` / `"Horizontal"`：右下角水平排列，可配置 1～3 个按钮。屏幕过窄或按钮过多时自动回退到竖列，避免溢出。

```lua
Hub:OpenActionDialog({
    Title = "确认操作", Content = "请选择后续操作",
    ButtonLayout = "HorizontalRight",
    Buttons = { { Text = "取消" }, { Text = "确定", Primary = true } },
})
```

单独的锁定控件支持 `Lock = { ButtonLayout = "HorizontalRight" }`。

## 2026-11-22 — P1-04 action dialog interaction polish

`Hub:OpenActionDialog` remains the only action-dialog API and continues to register with OverlayStack. The heading now uses one subtle separator. Every action has Motion-based hover/press feedback without scaling/rasterizing text.

- `handle:SetLoading(true/false)` prevents repeated button submission, dims the row and shows the active button's `LoadingText` (default `处理中…`). `handle.Loading` is observable.
- `handle:SetFeedback(true, "已保存")` displays success in `Color.Success`; `handle:SetFeedback(false, message)` and the compatible `SetError(message)` display an error in `Color.DialogErrorText`. Feedback updates with the active theme.
- `SetContent(message)` continues to remeasure the native scrolling body. The modal height tracks the available viewport and action buttons fall back to vertical layout when horizontal targets cannot fit. One-button, two-button and multiple-action configurations all use the existing ButtonLayout options.
- A native click can only act on the top-most registered dialog. Escape continues through OverlayStack. Callback failures show inline errors and clear the busy state, rather than dismissing the dialog.
- Action callbacks receive `(handle, handle)` for compatibility with both `Callback(dialog)` and legacy `Callback(_, dialog)`. A `false` return keeps the dialog open. For asynchronous work, use `KeepOpen = true, Async = true`; after completion, call `handle:SetLoading(false)`, then `SetFeedback` or `Close`.
- Destroying the dialog cancels its owned hover/press motion slots and disconnects its event listeners.

Automated Luau coverage includes busy state, feedback colors and content update. True touch/keyboard accessibility, IME resize and visual regression need Android acceptance.
