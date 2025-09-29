# 我的健康应用 (My Health App)

一个基于 Flutter 开发的现代化健康数据管理应用，提供直观的数据可视化和全面的健康指标追踪功能。

## ✨ 主要功能

### 📊 数据可视化
- **交互式散点图**：支持 iOS 风格的缩放和平移操作
- **健康雷达图**：多维度健康指标展示
- **环形进度图**：直观的目标完成度显示
- **趋势图表**：血压、心率、体重、睡眠等数据的时间趋势分析

### 🏥 健康管理
- **健康记录**：步数、心率、血压、体重等基础指标追踪
- **医疗记录**：就诊记录、用药信息、检查报告管理
- **生物标记**：基因组数据和生物指标分析
- **个人档案**：用户基本信息和健康概况

### 📱 用户体验
- **现代化 UI**：采用 Material Design 设计语言
- **响应式布局**：适配不同屏幕尺寸
- **流畅动画**：丰富的交互动效和页面转场
- **直观导航**：底部标签栏导航，操作简单便捷

## 🛠 技术栈

- **框架**：Flutter 3.x
- **状态管理**：Provider
- **路由管理**：go_router
- **图表库**：fl_chart
- **数据存储**：shared_preferences, sqflite
- **健康数据**：health (HealthKit/Google Fit 集成)
- **UI 组件**：Material Design + 自定义组件

## 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   └── health_models.dart
├── providers/                # 状态管理
│   └── health_provider.dart
├── router/                   # 路由配置
│   └── app_router.dart
├── screens/                  # 页面组件
│   ├── home_screen.dart
│   ├── health_records_screen.dart
│   ├── medical_records_screen.dart
│   ├── profile_screen.dart
│   ├── scatter_chart_screen.dart
│   └── ...
├── services/                 # 业务服务
│   └── health_service.dart
└── widgets/                  # 自定义组件
    ├── scatter_chart_widget.dart
    ├── health_radar_chart.dart
    ├── circular_progress_chart.dart
    └── ...
```

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.0+
- Dart 3.0+
- iOS 12.0+ / Android API 21+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd my_health_app
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **iOS 配置**（如需要）
   ```bash
   cd ios && pod install
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

## 📱 主要页面

### 🏠 首页 (Home)
- 底部导航栏
- 快速访问各功能模块

### 📈 健康记录 (Health Records)
- 健康指标卡片展示
- 数据图表可视化
- 历史趋势分析

### 🏥 医疗记录 (Medical Records)
- 就诊记录管理
- 用药提醒
- 检查报告存储

### 👤 个人资料 (Profile)
- 用户信息管理
- 健康目标设置
- 应用设置

### 📊 数据图表
- **散点图**：支持多点触控缩放，iOS 风格交互
- **雷达图**：多维度健康评估
- **趋势图**：时间序列数据展示

## 🎯 核心特性

### 交互式图表
- **手势支持**：缩放、平移、点击交互
- **动画效果**：流畅的数据更新动画
- **响应式设计**：自适应不同屏幕尺寸

### 数据管理
- **本地存储**：支持离线数据访问
- **健康平台集成**：自动同步 HealthKit/Google Fit 数据
- **数据导出**：支持健康数据导出功能

### 用户体验
- **主题系统**：统一的视觉设计语言
- **无障碍支持**：符合无障碍设计标准
- **性能优化**：流畅的 60fps 用户体验

## 🔧 开发说明

### 自定义组件
项目包含多个可复用的自定义组件：
- `ScatterChartWidget`：交互式散点图组件
- `HealthRadarChart`：健康雷达图组件
- `CircularProgressChart`：环形进度图组件
- `BiomarkerRangeIndicator`：生物标记指示器

### 状态管理
使用 Provider 模式进行状态管理，主要包括：
- `HealthProvider`：健康数据状态管理
- 用户信息管理
- 健康记录和医疗记录管理

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来帮助改进项目！

---

**注意**：本应用仅用于健康数据展示和管理，不能替代专业医疗建议。如有健康问题，请咨询专业医生。
