# RUI-P3-01 — 统一输入与焦点管理

基准：`keepBacon/relax-lua-ui`。输入所有权由 Hub 统一协调；原有控件 API、OverlayStack 弹层优先级、通知外观与 `DEMO` 验证保持不变。

## 运行时架构

`lib/core/InputFocus.luau` 提供一个轻量的 Hub 私有协调器：

- **PointerOwner**：拖动和 ContextMenu 长按均通过 `_inputClaimPointer(owner, input)` / `_inputReleasePointer(owner, input?)` 独占一根指针，触摸结束、取消和销毁均释放。
- **KeyboardOwner**：Keybind 录入通过 `_inputBeginCapture(owner, cancel)` 抢占输入；启动另一个录入会先取消前者；完成后调用 `_inputEndCapture(owner)`。被录入中的按键不触发正常快捷键。
- **Text focus**：`_inputIsEditing()` 识别当前 TextBox，`_inputCanShortcut(gameProcessed)` 拒绝游戏已处理事件和编辑期间的普通快捷键。
- **Overlay focus**：OverlayStack 注册时记录当前 Hub TextBox / `GuiService.SelectedObject`，关闭后在 defer 阶段尝试恢复；如果目标已经销毁、不可见、又打开了更高弹层或用户已经开始编辑其他输入框，则跳过恢复。
- **Navigation**：Tab / Shift+Tab 顺序导航最顶层 Prompt、Popup、CommandPalette、Setup 的可见可用控件。手柄方向键可执行相同导航，ButtonB 返回到顶部弹层；无活跃弹层时不会占用游戏操作。

该协调器不创建新的 `UserInputService` 全局输入循环；Hub 原来的 `_bindInput()` 仍是共享路由，输入捕获与 UI 的具体回调保持在原控件。

### 兼容接口和销毁

```luau
local snapshot = Hub:_inputGetState()
-- snapshot.PointerCaptured / KeyboardCaptured / OverlayDepth
```

上述方法是用于调试和测试的 Hub 内部 API，不作为公共脚本的稳定 API。Hub 销毁时 `_inputFocusDispose()` 清理捕获与焦点记录。

保持 `Section:Keybind`、`Hub:OpenActionDialog`、`Hub:OpenContextMenu`、`bindPointerDrag`、`Section:Form` 原有 API 形状。键盘事件不再通过非顶层弹窗影响其他控件。ContextMenu 的长期触摸监听按既有位移阈值和手指取消规则运行。

## 验证

`tests/overlay-stack.mjs` 检查打包一致性、按键优先级、指针捕获与焦点恢复接线；`tests/overlay-stack-lune.luau` 验证同一 Hub 内互斥捕获、先后取消、弹层焦点堆栈与销毁。

设备验收仍必须检查：Android 横屏软键盘弹出和收起，TextBox 输入期间触发 ToggleKey / CommandKey / Keybind，长按与滚动互斥，多点触控终止，Tab / Shift+Tab 导航、弹窗关闭后的焦点恢复，以及手柄 ButtonB / 方向键。不应把 Native Lune 模拟器通过等同于 Android 真机完整适配。

多点触控边界：正在拖动的控件在第二根触摸输入开始时取消，恢复祖先 ScrollingFrame 的原有 ScrollingEnabled；打开 Prompt/Popup/Window 等顶层弹窗时，InputFocus 调用当前拖动所有者的 `CancelActive()` 终止后台手势。不会销毁控件本身的拖动订阅，用户之后仍可重新开始手势。
