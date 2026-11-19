# RelaxUI — 天气背景（AsterUI / FlowUI 风格）

「背景切换」现在表示 **UI 后方的动态天气粒子**，不是背景图片切换。

## 设置

设置 → **背景切换**：

| 选项 | 内容 |
|---|---|
| 天气效果 | None / Rain / Snow / Ember / Sakura / Fireflies / Matrix |
| 天气区域 | Screen（全屏，在 UI 后面） / UI（仅面板内部） |
| 粒子密度 | 0–200% |
| 天气速度 | 25–250% |
| 天气不透明度 | 5–100% |

支持 AsterUI / FlowUI 的下雨、飘雪、余烬、樱花、萤火虫和代码雨。其中雪、雨、余烬使用其同款 Roblox 图片资源；樱花、萤火虫及代码雨采用不依赖执行器文件系统的 GUI 粒子实现。

「**UI背景**」仍控制原有六款图片预设、图片不透明度，主题工作室继续允许自定义图片。历史 `Hub:SwitchBackground(...)` / `SetBackgroundPreset` 等图像接口保留以兼容已有脚本，但不再称作天气背景。

## 调用示例

```luau
Hub:SetWeather("Snow")          -- 飘雪
Hub:SetWeather("Rain")          -- 下雨
Hub:SetWeather("Sakura")        -- 樱花
Hub:SetWeather("None")          -- 关闭天气

Hub:SetWeatherMode("Screen")    -- 全屏、位于主 UI 后方
Hub:SetWeatherMode("UI")        -- 限制在主面板内部
Hub:SetWeatherDensity(0.8)
Hub:SetWeatherSpeed(1.1)
Hub:SetWeatherOpacity(0.65)
```

启动时从 `setup.json` 恢复选择，保存或加载配置时也会包含天气模式及参数。

## 移动端性能与生命周期

- **最多 50 个粒子**（检测到触屏）；其他平台最多 100 个。
- 位置更新限制在约 30 FPS，避免为天气增加一条完整 60 FPS 重排负担。
- None 模式不创建粒子或帧更新连接。
- UI 主面板关闭/工具栏隐藏时，天气区域隐藏且停止粒子迭代。
- 销毁 Hub 时断开 RenderStepped、删除天气 GUI 与所有粒子。
- 与主 UI 分离的 `ScreenGui` 设置较低 `DisplayOrder`，不遮挡文字或触摸。

具体 FPS 成本会因 Android 机型、Roblox 客户端和游戏本身而异，需要 Delta 实机观察。
