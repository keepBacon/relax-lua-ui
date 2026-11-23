# P0 视觉回归基线 — Relax UI（2026-11-22）

> 范围：RUI-P0-04。自动化回归数据来自 `public/RelaxUI_Preview.luau` 中的「P0验收」及现有「模块」「数据」「外观」「设置」「联动」分页。此文件是**截图清单和拍摄规范**，不等同于实际 Android 真机测试已通过。

## 固定测试入口

```luau
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/public/RelaxUI_Preview.luau"))()
```

演示密钥必须输入 `DEMO`，且 `Remember=false`。独立的库 Loader 不要求预览密钥。

### 可重复数据

- 「P0验收」包含固定 ModuleCard ID：`p0-module-fixture`；长标题「性能优化与显示调节 · 中文长标题」和一段固定中文描述。
- 固定开关为 `true`；Slider = `62`；Dropdown 默认「第二项」；ColorPicker RGB = (125,165,255)。
- 锁定按钮「P0锁定测试」包含固定原因、详情和两个横向按钮；同一按钮可在「锁定/可用」间切换。
- InfoGrid 固定数据：`FPS 120`、`Ping 28 ms`、`Memory 180 MB`。
- 原版通知视觉必须保持 **RiftUI 细条展开 + 计时**，而非圆角滑入通知。

## 图像采集矩阵

| 截图场景 | 固定检查内容 | 必须采集状态 |
|---|---|---|
| ModuleCard | 左圆形图标，中标题/描述，右上展开+收藏，右下开关；不能出现 Ready/Healthy 状态胶囊 | 初始、展开、折叠、锁定、依赖禁用、中文长文本 |
| 二级分页 | 二级导航与主窗口不重叠，不共享其它分页尺寸；分页收放丝滑 | 初始、展开、切换、关闭、快速重复 |
| DataTable | 表头、选中行、最底行、滚动条，表格内容可触达 | 静态、触控滚动中、最后一行、选中 |
| TreeView | 父子层级、箭头、展开内容和选中态 | 初始、展开、折叠、快速切换 |
| StatusList | 状态条目分隔、文字颜色、最后一行留白 | 初始、数据更新、长文案 |
| 锁定弹窗 | 遮罩、中心锁图标、详情滚动区、竖列/右侧横列按钮 | 锁定、反复点击、展开说明、弹窗关闭 |
| 设置 | 两列/单列、自定义主题、面板拉伸、右下隐形手柄 | 初始、缩放、窄视口、重置 |
| 主题 | Graphite/Ink/Slate/Ember，文本与背景色阶 | 深色、浅色候选、切换中、切换后 |

每个控件如适用，还需要拍摄 **Hover/Press（桌面）**、**触控中（Android）**、**锁定/可用**、**关闭弹窗后**的状态。

## 屏幕与字体测试

矩阵涵盖三种模拟横宽比 **4:3、16:9、20:9**，分别在 **70%、100%、140% UI Scale** 下执行。优先 Android 横屏，再复核桌面键鼠。每种组合重点检查：

1. 面板是否触及顶部 Roblox 系统栏或底部 Dock / 安全区。
2. Dropdown、ColorPicker、PlayerPicker、Keybind、二级分页展开后能完整触达菜单项；尤其是贴近左右、上下边缘的触控目标。
3. 点击与滑动使用独立触点归属，长按悬浮球 1 秒不会穿透下层控件，取消拖动恢复普通交互。
4. 打开/关闭 Android 输入法后能继续使用弹窗操作按钮，焦点不会把游戏快捷键误触发。
5. 字体中文清晰，文字不使用 CanvasGroup 位图缩放；长标题不压碎右上收藏/展开。
6. 缺失 Lucide 图标资源时，按钮保留可辨识的字符或几何回退，不出现「□」占位。

## 命名与验收证据

每张实机截图建议命名为 `p0_<scene>_<aspect>_<scale>_<state>_<theme>.png`，录屏为对应的 `.mp4`，并记录 Roblox 版本、Android 版本、设备型号、执行环境及是否开启动态背景。

| 证据类别 | 来源 | 当前状态 |
|---|---|---|
| 发布入口 & bundle 源码一致性 | `tests/release-entry.mjs`、`tests/loader.luau` | CI 验证 |
| 控件锁定 100 次状态/弹窗压力测试 | `tests/module-cards-lune.luau` | Lune 验证 |
| 弹层优先级、边缘弹窗尺寸、清理 | `tests/overlay-stack-lune.luau` | Lune 验证 |
| 固定文案、状态和视觉场景存在性 | `tests/p0-visual-regression.mjs` | 静态检查 |
| Android 实机截图 / 触控 / 帧时间 | 用户设备 | **待实机验收，不能由 CI 代替** |

不应将「脚本没有运行时异常」等同于「真实设备上没有裁切、字体模糊和拖动延迟」。如果截图比对失败，需要把具体机型、Scale 和状态写入问题复现步骤并修复。


## R9 — Group 动态布局与圆角表面验收（2026-11-23）

此轮解决「Controls → Basics → Tuning 二级功能组」的原有布局问题。`Section:Group` 现在对参与 `UIListLayout` 的**真实 Group 行**与 `GroupClip` 同时播放约 220ms 的可中断高度动画；此前绝对定位的 `GroupSpace` 不再存在。下面的 Dropdown、Button 等控件应跟着行高度连续下移或上移，而不是保持原位、在动画结束后跳跃或直接被覆盖。

- **展开状态**：启用 Basics → Feature enabled，展开 Tuning；在 70%、100%、140% Scale 下观察 Strength、Smoothing 出现，以及下面 Mode / Layers 随 Group 高度向下移动。
- **折叠状态**：关闭开关或点击 Group 标题；Strength、Smoothing 被原生 `Frame.ClipsDescendants` 收起，Mode / Layers 随真实行高度向上移动，不出现空白占位。
- **快速中断**：连续触发「开 → 关 → 开」，最终箭头和可见行高度一致，没有旧 Tween 抢写最后状态。另检查 Group 子控件动态增长、搜索临时展开与多次 Hub Reinitialize。
- **面板圆角**：测试右上角、右下角和其他两角。面板使用同心的实色外壳和内缩 1px 的圆角表面，而非在两张独立圆角图层之间绘制 `UIStroke`；应看不到露出的背景色、原生矩形 BorderPixel 或锯齿小缺口。
- **选择框圆角**：Dropdown、SearchSelect、PlayerPicker 的菜单都共享 `roundedPopupSurface`，外层 `CanvasGroup` 裁剪，边框用底层实色填充、内容内缩 1px；触发 Chip 明确 `BorderSizePixel = 0`。检查四角无白边，并分别对选中项/未选中项、顶部和底部菜单及界面缩放拍摄截图。

这些描述是**验收标准，不是真机通过声明**。GitHub CI 验证代码结构和模拟 Luau 生命周期；Roblox Android GPU 裁剪、字体采样和真实触控仍须在用户设备现场复测。


## R10 — 一级 Section 收展动画（视频反馈：2026-11-24）

问题：一级功能组（`Tab:Section`）收起时，`Section:_applyCollapse` 在高度 Tween 启动前就把 `RowsClip.Visible` 设为 `false`，导致子控件瞬间消失，未形成与二级 `Section:Group` 一致的连续裁剪动画。

修复：在展开和收起的整个 Tween 期间保持 `RowsClip.Visible = true`，仅在收起真正完成后隐藏；关闭与打开时均由 `Motion.play` 中断旧过渡，从当前裁剪高度接续。测量优先取实际 `Rows.AbsoluteSize`，并结合 `UIListLayout.AbsoluteContentSize` 处理原先隐藏的组。完成后恢复展开状态的 `AutomaticSize.Y`，保持 `Section:SetCollapsed`、`IsCollapsed`、`Collapsed` 偏好及搜索临时展开接口不变。

Android 真机验收（不以 CI 代替）：

- [ ] 在控件页连续展开、收起一级 Section：内容应随着高度逐渐显示/裁剪，紧邻分组同步移动，不得瞬间隐藏后留下空白。
- [ ] 在约 1/3 的收起进度反向展开，重复 20 次：内容、箭头及 `IsCollapsed()` 与最终状态一致，没有旧完成回调隐藏已经展开的内容。
- [ ] 当 Section 包含嵌套 Group、ModuleCard、Slider、Dropdown 或长文案时仍按真实内容高度收展；在 70%、100%、140% 缩放下最后一项可触达。
- [ ] 测试 `Full`/`Reduced`/`Off` 动画模式；关闭动画时保持正确的最终可见性；中文文本保持原生绘制清晰。
- [ ] 搜索临时展开和偏好恢复、切页/Destroy 期间没有残留 Tween 或悬空裁剪状态。

CI：`tests/motion-state-lune.luau` 覆盖初始/中途可见、快速反向与最终隐藏；`tests/p0-visual-regression.mjs` 保证源码及发布产物均在动画期间保持裁剪容器可见。

## R12 — Graphite 极简最小化悬浮窗（视觉参照：2026-11-24）

目标：将原黑色圆盘、彩色渐变光环和红色横杠改为 Graphite 小型圆角方块。外观从用户提供的设计参考提取为：深灰黑 `#111316`、36×36px 可视区域、9px 圆角、1px 低对比边框、轻微阴影和居中 14×2px 灰白横杠。禁止常驻旋转渐变、外层圆形光环及红色/绿色常态图标。

设计与交互约束：

- 面板展开时显示白色短横杠；面板隐藏时白色加号提示可恢复，状态以短动画过渡。
- 保持 44×44px 透明可点击范围、1 秒长按解锁拖动、单触点捕获、位置存储、视口边缘避让和弹层输入优先级。
- 仅长按拖动确认时使用低强度绿色描边；松手恢复 Graphite 灰色描边，点击反馈仅使用轻量缩放和一次性的圆角方形细轮廓。
- 保留 `_setToolbarOrbSpin` 旧内部调用入口，但不运行无限循环的装饰性 Tween。

Android 真机检查（未执行，需复测）：

- [ ] 默认外观是圆角方块而非圆盘；没有模糊的蓝紫环，白色横杠视觉居中且不被遮挡。
- [ ] 面板展开为减号、隐藏为加号；连续点击 20 次无残留图标状态、丢触控或外圈闪烁。
- [ ] 触控范围 44px 可点击但不可见；按住 1 秒出现绿色边框并可拖动，松手恢复深灰边框且位置重启后保留。
- [ ] 70%／100%／140% 缩放和横竖屏均保证悬浮入口留在安全可触达区域。
- [ ] 弹层打开时不会误抢点击；快速切换主题、页面与销毁 Hub 不会遗留动画或悬浮实例。

源文件 `lib/core/ToolbarOrb.luau`；正式脚本由 `scripts/bundle.mjs` 组合为 `public/RiftUI.luau`。原生模拟测试与静态测试验证代码和实例行为，但不能代替 Roblox Android GPU 实机验收。
