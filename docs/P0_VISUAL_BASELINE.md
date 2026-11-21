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
