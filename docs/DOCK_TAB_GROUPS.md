# RelaxUI — Dock 分页分组

底部 Dock 现在拥有独立的一级分页分组，而不再依靠单个 `LayoutOrder` 在一层列表里混排。

## 默认布局

```text
┌───────────────────────────────────────────────┐
│ 主分页组       │ 设置组                       │
│ [功能][视觉]…  │ [设置][搜索] ← 最右侧          │
└───────────────────────────────────────────────┘
```

- **主分页组（Main）**：现有自定义分页都在这里，左侧排列。
- **设置组（Settings）**：右侧，与主分页组有分隔线；最右侧是搜索图标，设置图标紧邻其左边。
- 右侧搜索按钮仍然调用 `Hub:OpenCommandPalette()`，没有改动功能或快捷键。
- 普通一级分页、二级分页、预览密钥 `DEMO` 均不需要修改。
- 每组有独立的 `UIListLayout` 和按内容自动扩展的宽度，因此有多个组时不会把搜索挤到左侧。

## 可复用的分页分组 API

```luau
local Hub = Rift:CreateHub({ Name = "RelaxUI" })

-- 也可以直接 Hub:Tab(...)，此时默认归入 Main。
local Combat = Hub:Tab({ Name = "战斗", Icon = "crosshair" })
Combat:Section({ Name = "主要设置" }):Toggle({ Name = "启用" })

local ExtraGroup = Hub:TabGroup({
    Name = "扩展",
    Order = 250,
    Separator = true,
})

local Extra = ExtraGroup:Tab({ Name = "工具", Icon = "wrench" })
Extra:Section({ Name = "功能" }):Button({ Name = "测试" })

-- 等价写法
Hub:Tab({ Name = "更多", Icon = "layers", Group = "扩展" })

-- 更改已有组的顺序
ExtraGroup:SetOrder(300)
```

已有组使用相同名称重新调用 `Hub:TabGroup({ Name = "扩展" })` 时返回现有组，不会重复创建。分组 API 支持重新初始化时按创建步骤重建。

## 兼容性

普通 `Hub:Tab`、`Tab:SubTab`、`Hub:OpenCommandPalette` 保持原有接口。源码与 `public/RiftUI.luau` 同步构建，默认 Dock 的功能不会重建。
