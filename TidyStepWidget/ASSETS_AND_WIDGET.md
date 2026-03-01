# 资源位置与小组件说明

## 一、Asset 放在哪里

### 主 App 的图片/颜色资源
- **路径**：`TidyStep/Resources/Assets.xcassets/`
- 在 Xcode 中：左侧项目导航 → 选中 **TidyStep** → 展开 **Resources** → 点 **Assets.xcassets**
- 在这里可以新建 Image Set（如 `MyImage.imageset`）、Color Set 等，主 App 和部分共享资源都放这里

### 小组件专用图标（右下角图标）
- **路径**：`TidyStepWidget/Assets.xcassets/WidgetIcon.imageset/`
- 在 Xcode 中：左侧项目导航 → 选中 **TidyStepWidget** → 点 **Assets.xcassets** → 点 **WidgetIcon**
- **请把你要用的图标图片放这里**：
  - 至少放一张图，命名为 **WidgetIcon.png**，放进 `WidgetIcon.imageset` 文件夹里（或在该 imageset 的 1x 槽位里指定该文件）
  - 可选：为 2x、3x 准备更高清图（如 `WidgetIcon@2x.png`、`WidgetIcon@3x.png`），在 imageset 里勾选对应 scale 并选文件
- 小组件右下角会显示这个图标；若未放图，该位置可能空白或需在代码里加兜底

---

## 二、小组件会显示什么

### 小号组件（systemSmall）
- **TidyStep** 标题
- **本周整理次数**（数字 + “sessions”）
- **最近一次整理**：Today / Yesterday / X days ago，或 “No tidy yet”
- **提醒时间**（若已开启）：如 “08:00” 或 “Every 3 days · 08:00”
- **右下角**：你放在 `WidgetIcon.imageset` 里的图标

### 中号组件（systemMedium）
- 左侧：与上面相同的信息（TidyStep、本周次数、最近一次、提醒时间）
- 右侧：
  - **同一枚小组件图标**（WidgetIcon）
  - **一句鼓励语**（见下）

### 中号组件鼓励语规则
- **本周 0 次**：随机一句，如 “Start a tidy today!” / “A little tidy goes a long way.” / “Ready when you are.”
- **本周 1～2 次**：如 “Nice work!” / “Every tidy counts.” / “Keep the momentum!”
- **本周 ≥3 次**：如 “You're on fire!” / “Amazing consistency!” / “Keep it up!”

（具体文案在 `TidyStepWidget.swift` 的 `encouragementText` 里，可按需改中英文。）

---

## 三、中号组件怎么设置

- 用户添加小组件时：长按主屏幕 → 点左上角 “+” → 选 **TidyStep** → 在尺寸里选 **中号**（中间那个）
- 代码已支持：`supportedFamilies([.systemSmall, .systemMedium])`，无需再改配置即可选小号或中号
- 中号会显示上述内容，**并且会显示鼓励语**（右侧薄荷绿那句）

---

## 四、总结

| 问题 | 答案 |
|------|------|
| 主 App 的 Asset 放哪？ | `TidyStep/Resources/Assets.xcassets/`（在 Xcode 里是 TidyStep → Resources → Assets.xcassets） |
| 小组件右下角图标放哪？ | `TidyStepWidget/Assets.xcassets/WidgetIcon.imageset/`，至少放 **WidgetIcon.png** |
| 小组件显示什么？ | 见上面「小组件会显示什么」 |
| 中号怎么设置？ | 添加小组件时选「中号」即可 |
| 中号会放鼓励语吗？ | 会，在右侧显示一句根据本周次数变化的鼓励语 |
