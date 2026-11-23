# R8 — Android 触控、选择框圆角与 3D 预览验收

目标：修复 2026-11-23 反馈的三个真实 UI 问题。优先使用既有组件和 Hub 服务，不增加新的常驻循环。

## 1. 选择框四角异常浅色边

症状：深色主题下，展开选择框后四个圆角露出背景或高亮层像素。原因是普通 Frame + UICorner 不能完整遮罩其子级绘制：选中行背景填满弹层矩形时，角落发生穿透。

- 旧版 DropdownList / SearchSelectPopup / PlayerList 改为 CanvasGroup + UICorner，统一遮罩内容；保留一层低对比描边。
- Dropdown 选项内容离四边 4px，不再覆盖裁剪圆角；筛选框同样增加内边距。
- PlayerPicker 采用相同蒙版实现；深色 Graphite/Ink 以及 Slate/Ember 检查普通/选中/触摸态。

## 2. 底部内容滚动不到

- 普通 Tab、SubTab、WindowTab 均使用 Hub:_bindPageCanvas 统一测量并更新 ScrollingFrame.CanvasSize。按照实际 Columns/列高度和当前 UIScale 转换逻辑尺寸，附加底部 44/36/32 px 缓冲。
- 监听 Columns/左右列的 AbsoluteSize、列 UIListLayout.AbsoluteContentSize、滚动视口尺寸与 UIScale.Scale；task.defer 合并重测请求。
- SubTab 现在具备 _syncCanvas，可在 Accordion/ModuleCard 展开后更新；WindowTab 不再只依赖 AutomaticCanvasSize。
- PlayerPicker 下拉菜单不再强行改写 PopupViewport.Size。通过 InnerScroll 将触控、滚轮交给真正的选项列表；根据实际条目数计算 CanvasSize，动态筛选后重新调用弹层布局器。
- 保留一次性或尺寸变化触发的测量，没有添加 Heartbeat/RenderStepped 常驻扫描。

## 3. 3D 预览没有内容、无法交互

- examples/showcase.luau（/p 加载）和 public/RelaxUI_Preview.luau 都放入本地创建的三部分立体样例；不请求外部模型资产、不读取游戏资产。
- 默认允许触摸旋转（Interactive ~= false），支持 SetModel / SetObject / Clear / SetZoom / Rotate / ResetView / Destroy；缩放按钮和鼠标滚轮可用。
- 根据模型包围盒和 ViewportFrame 的横纵比调整 Camera 距离，模型被复制、静态化，移除脚本并关闭碰撞；不会移动或破坏调用者的原始 Instance。
- 无模型时提供明确说明；缺失 ViewportFrame/WorldModel/Camera 时提供错误文案而非黑框；视口尺寸变化重新适配相机。
- 开关、拖动事件、相机、克隆模型随控件销毁清理。没有添加持续自动旋转循环。

## 验收清单

- [ ] 在真实 Android Roblox 客户端，打开 /p 预览，输入 DEMO。外观/选项中检查四角；切换 Graphite、Ink、Slate、Ember 和 Default、Rounded。
- [ ] 在主 Tab、二级 Tab、独立窗口 Tab 建立足够多的长内容；展开/折叠 Accordion、ModuleCard，多次调整 UI 缩放和横竖屏，最后一项应完整露出且可触摸。
- [ ] PlayerPicker 列表在多人服务器超过 6 人时可滚至最后一行；搜索缩短列表后无残留的双重滚动。
- [ ] Showcase 中的 3D 模型有实体，单指拖动可旋转，± 缩放有反应，重置视角恢复初始方位；无外部资产加载。
- [ ] 3D 模型从一个 Model/BasePart 切换到另一对象，Clear 后显示提示；错误对象返回说明，关闭 Hub 时不残留相机和鼠标/触摸监听。
- [ ] CI：RiftUI runtime verification + Verify nested tabs with native Lune 两工作流都通过，且发布版包含与源码一致的修复。

注意：CI 的 native Lune 是 Roblox API 模拟，不提供手机真实 GPU 渲染/手指触控。最后的 Android 真机项目必须实际运行才能完成打勾，不用模拟测试代替实际截图验收。
