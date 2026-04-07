# 更新日志 (Changelog)

本文档记录了 `flutter_upgrade_kit` 的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [0.1.0] - 2026-04-07

### 新增 (Added)

#### 核心功能
- ✨ 初始版本发布
- 🎯 默认升级对话框 UI 组件 (`upgrade_kit_dialog.dart`)
- 📥 纯 Dart 实现的下载管理器
  - 支持断点续传
  - 临时文件 (.part) 存储
  - SHA256 校验和验证
  - 可取消的下载任务
  - 实时进度回调
- 📊 下载进度事件流 (`UpgradeKitEvent`)
- ✅ 下载完成回调机制

#### 平台支持
- 🤖 Android 完整支持
- 🍎 iOS 完整支持
- 🌐 Web 支持 (使用 BrowserClient)
- 💻 Desktop 支持 (Windows/macOS/Linux)

#### API 接口
- `FlutterUpgradeKit.show()` - 显示升级对话框
- `FlutterUpgradeKit.download()` - 直接下载并返回文件路径
- `FlutterUpgradeKit.events` - 事件流监听

#### 数据模型
- `UpgradeKitInfo` - 升级信息模型
  - version (版本号)
  - downloadUrl (下载地址)
  - title (标题)
  - changelog (更新日志)
  - fileName (文件名)
  - force (是否强制更新)
  - fileSize (文件大小)
  - checksum (SHA256 校验和)
- `UpgradeKitStatus` - 状态枚举
  - idle (空闲)
  - dialogShown (对话框已显示)
  - downloading (下载中)
  - completed (完成)
  - failed (失败)
  - cancelled (已取消)
- `UpgradeKitState` - 状态模型
- `UpgradeKitEvent` - 事件流模型

#### 控制器
- `UpgradeKitController` - 状态管理控制器
  - 继承自 `ChangeNotifier`
  - 提供状态管理和事件广播
  - 支持 show/startDownload/complete/fail/cancel 操作

#### 架构设计
- 平台抽象层 (`UpgradeKitDownloaderPlatform`)
- 条件导入机制 (`dart.library.io` / `dart.library.html`)
- 响应式状态管理 (`ChangeNotifier` + `StreamController`)
- 不可变模型设计 (`const` 构造函数 + `copyWith` 方法)

#### 示例应用
- 📱 完整的示例应用 (`example/`)
  - 可配置的升级信息输入界面
  - 对话框模式演示
  - 直接下载模式演示
  - 实时状态显示卡片

#### 测试
- ✅ 控制器单元测试 (`upgrade_kit_controller_test.dart`)
- ✅ 下载器单元测试 (`upgrade_kit_downloader_test.dart`)

#### 文档
- 📖 完整的 README 文档
- 📝 详细的 API 使用说明
- 🏗️ 项目结构说明
- 🌐 平台支持说明

---

## 待发布 (Unreleased)

### 计划中 (Planned)
- 🔜 自定义对话框主题支持
- 🔜 多语言国际化 (i18n)
- 🔜 自动安装 APK (Android)
- 🔜 下载速度估算
- 🔜 剩余时间预测
- 🔜 通知栏进度显示
- 🔜 后台下载支持

---

## 版本说明

### 语义化版本规范

- **MAJOR.MINOR.PATCH** (主版本号。次版本号。修订号)
- **MAJOR** 版本：不兼容的 API 变更
- **MINOR** 版本：向后兼容的功能性新增
- **PATCH** 版本：向后兼容的问题修正

### 发布节奏

- PATCH 版本：按需发布（Bug 修复）
- MINOR 版本：每月或累积足够新功能时发布
- MAJOR 版本：每年或不兼容变更累积时发布

---

## 贡献者

感谢所有为 `flutter_upgrade_kit` 做出贡献的开发者！

[查看贡献者列表](https://github.com/bolong2114/flutter_upgrade_kit/graphs/contributors)

---

## 相关链接

- [GitHub 仓库](https://github.com/bolong2114/flutter_upgrade_kit)
- [Pub 包页面](https://pub.dev/packages/flutter_upgrade_kit)
- [问题反馈](https://github.com/bolong2114/flutter_upgrade_kit/issues)