# My Health App — 开发指南

## 项目概述

Flutter 健康管理 App，集成 iOS HealthKit，追踪步数/心率/血压/体重/睡眠等指标，管理医疗记录。

## 快速开始

```bash
flutter pub get
flutter run -d <device_id>
```

## 项目结构

```
lib/
├── main.dart                    # 入口，MultiProvider
├── theme/app_theme.dart         # Apple Health 设计系统
├── models/
│   ├── health_models.dart       # HealthRecord, MedicalRecord, HealthBubble
│   └── reminder_models.dart     # Reminder, ReminderType
├── providers/
│   ├── health_provider.dart     # 用户信息 + 健康/医疗记录 + HealthKit 缓存
│   ├── reminder_provider.dart   # 提醒管理
│   └── app_settings_provider.dart # 主题模式
├── services/
│   └── health_service.dart      # HealthKit 原生接口封装
├── router/
│   └── app_router.dart          # GoRouter 路由配置
├── screens/
│   ├── dashboard_screen.dart    # 概览（底部Tab 0）
│   ├── health_records_screen.dart # 健康数据（底部Tab 1）
│   ├── medical_records_screen.dart # 医疗记录（底部Tab 2）
│   ├── profile_screen.dart      # 我的（底部Tab 3）
│   ├── health_charts_screen.dart # 健康图表（5 Tab）
│   ├── scatter_chart_screen.dart # 散点图分析
│   ├── biomarkers_screen.dart   # 生物标记物
│   ├── reminders_screen.dart    # 健康提醒
│   └── settings_screen.dart     # 设置
│   └── widgets/                 # 图表组件
├── widgets/
│   ├── main_navigation.dart     # 底部导航栏
│   ├── health_radar_chart.dart  # 六维雷达图 (CustomPainter)
│   ├── circular_progress_chart.dart # 圆环进度图
│   └── biomarker_range_indicator.dart # 范围指示器
```

## 架构要点

### 状态管理: Provider
- 3 个 ChangeNotifier
- 页面使用 `Consumer` 或 `Selector`（推荐 Selector 减少 rebuild）
- HealthProvider 是核心，持所有数据

### 路由: GoRouter
- 4 个底部 Tab（ShellRoute）
- 独立路由（无底栏）：/health-charts, /biomarkers, /scatter-chart, /reminders, /settings, /profile
- 导航统一用 `context.push()` / `context.pop()`

### 数据流
- HealthKit 数据 → HealthService → HealthProvider.syncFromHealthKit() → 页面
- 偏好存储：SharedPreferences（JSON 序列化）

## 设计系统

使用 Apple Health 风格，定义在 `theme/app_theme.dart`：

- `AppColors` — 各指标专属色：心率红、步数橙、睡眠紫、体重青蓝、血压红
- `AppTypography` — SF Pro 风格字号（largeTitle 34pt, title2 22pt, metricValue 36pt）
- `AppRadius` / `AppSpacing` — 统一间距圆角（card 14px）
- `AppTheme.light` / `.dark` — 完整 ThemeData

### 页面布局规范
- 背景色：`AppColors.background`（#F2F2F7）
- 卡片纯白圆角 14px，无阴影（依靠底色分隔）
- 分组间用 Divider 或间距 10px
- Section header：`AppTypography.title2` + padding LTRB(20,4,20,0)

## 常用命令

```bash
dart analyze          # 代码检查
flutter build ios --no-codesign --debug  # iOS 构建
flutter build ios --no-codesign --release  # 发布构建
flutter run -d <id>   # 运行到设备
```

## 开发约定

- 不要使用 `font_awesome_flutter`（不兼容 Flutter 3.9+）
- 不要使用 `withOpacity()`，使用 `.withValues(alpha: x)`
- 图标全部使用 Material Icons
- 新页面继承 `StatefulWidget` 或 `StatelessWidget`
- 大数据列表使用 `ListView.builder`
- 页面内多次监听 Provider 用 `Selector` 减少 rebuild
- CustomPainter 务必实现正确的 `shouldRepaint`
- NetworkImage 不要用（必应图床不稳定），用 CircleAvatar 首字母
