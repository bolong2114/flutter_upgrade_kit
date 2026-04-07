# Flutter Upgrade Kit

一个纯 Flutter 实现的应用内升级提示和下载管理工具包。

[![Pub Version](https://img.shields.io/badge/version-0.1.0-blue)](https://pub.dev/packages/flutter_upgrade_kit)
[![Flutter SDK](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue)](https://flutter.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D2.17.0-blue)](https://dart.dev)

## 📖 简介

**flutter_upgrade_kit** 提供了完整的版本更新提示 UI、下载进度跟踪和文件管理功能。无需原生代码，纯 Dart/Flutter 实现跨平台下载管理。

## ✨ 特性

- ✅ **默认升级对话框 UI** - 开箱即用的美观升级提示界面
- ✅ **纯 Dart 下载管理器** - 无需原生插件，跨平台一致体验
- ✅ **实时进度事件流** - 精确跟踪下载进度
- ✅ **下载完成回调** - 灵活的完成状态处理
- ✅ **多平台支持** - Android、iOS、Web、Desktop 全覆盖
- ✅ **断点续传** - 支持中断后继续下载
- ✅ **SHA256 校验** - 确保下载文件完整性
- ✅ **可取消下载** - 用户可随时取消下载任务

## 🚀 快速开始

### 安装

将以下依赖添加到您的 `pubspec.yaml` 文件中：

```yaml
dependencies:
  flutter_upgrade_kit: ^0.1.0
```

然后运行：

```bash
flutter pub get
```

### 基本用法

#### 显示升级对话框

```dart
import 'package:flutter_upgrade_kit/flutter_upgrade_kit.dart';

// 显示升级对话框
FlutterUpgradeKit.show(UpgradeKitInfo(
  version: '2.0.0',
  downloadUrl: 'https://example.com/app.apk',
  title: '新版本可用',
  changelog: ['功能改进', 'Bug 修复'],
  force: false, // 是否强制更新
));
```

#### 直接下载

```dart
// 直接下载并返回文件路径
final filePath = await FlutterUpgradeKit.download(
  info: upgradeInfo,
  savePath: '/custom/path', // 可选，默认为临时目录
);
```

#### 监听事件流

```dart
FlutterUpgradeKit.events.listen((event) {
  print('状态：${event.status}');
  print('进度：${event.progress}%');
  print('已下载：${event.downloadedBytes}/${event.totalBytes}');
});
```

## 📚 API 文档

### FlutterUpgradeKit (静态入口类)

| 方法/属性 | 说明 |
|-----------|------|
| `show(UpgradeKitInfo info)` | 显示升级对话框 |
| `download({required UpgradeKitInfo info, String? savePath})` | 开始下载，返回文件路径 |
| `events` | 获取事件流 |

### UpgradeKitInfo (升级信息模型)

```dart
UpgradeKitInfo({
  required String version,      // 版本号 (必填)
  required String downloadUrl,  // 下载地址 (必填)
  String title = 'New Version Available',  // 标题
  List<String> changelog = [],  // 更新日志列表
  String? fileName,             // 可选的文件名
  bool force = false,           // 是否强制更新
  int? fileSize,                // 文件大小（字节）
  String? checksum,             // SHA256 校验和
})
```

### UpgradeKitStatus (状态枚举)

| 状态 | 说明 |
|------|------|
| `idle` | 空闲状态 |
| `dialogShown` | 对话框已显示 |
| `downloading` | 下载中 |
| `completed` | 下载完成 |
| `failed` | 下载失败 |
| `cancelled` | 已取消 |

### UpgradeKitController (状态管理器)

继承自 `ChangeNotifier`，提供以下功能：

- `state` - 当前状态
- `events` - 事件流控制器
- `show(info)` - 设置升级信息并显示对话框
- `startDownload()` - 开始下载
- `complete(filePath)` - 标记下载完成
- `fail(message)` - 标记下载失败
- `cancel()` - 取消下载

## 🏗️ 项目结构

```
lib/
├── flutter_upgrade_kit.dart          # 公共导出入口
└── src/
    ├── core/                         # 核心下载逻辑
    │   ├── upgrade_kit_downloader.dart           # 主下载器类（平台抽象）
    │   ├── upgrade_kit_downloader_platform.dart  # 下载器平台接口定义
    │   ├── upgrade_kit_downloader_io.dart        # IO 平台实现 (Android/iOS/Desktop)
    │   ├── upgrade_kit_downloader_web.dart       # Web 平台实现
    │   ├── upgrade_kit_downloader_stub.dart      # 不支持平台的存根实现
    │   ├── upgrade_kit_download_types.dart       # 下载相关类型定义
    │   └── upgrade_kit_manager.dart              # FlutterUpgradeKit 静态入口类
    ├── controller/                   # 控制器和状态管理
    │   └── upgrade_kit_controller.dart           # ChangeNotifier 控制器
    ├── models/                       # 数据模型和枚举
    │   ├── upgrade_kit_info.dart                 # 升级信息模型
    │   ├── upgrade_kit_state.dart                # 状态模型
    │   ├── upgrade_kit_status.dart               # 状态枚举
    │   └── upgrade_kit_event.dart                # 事件流模型
    └── ui/                           # UI 组件
        └── upgrade_kit_dialog.dart               # 默认升级对话框
```

## 🌐 平台支持

| 平台 | 支持情况 | 实现文件 |
|------|----------|----------|
| Android | ✅ 完全支持 | `upgrade_kit_downloader_io.dart` |
| iOS | ✅ 完全支持 | `upgrade_kit_downloader_io.dart` |
| Web | ✅ 完全支持 | `upgrade_kit_downloader_web.dart` |
| Desktop | ✅ 完全支持 | `upgrade_kit_downloader_io.dart` |

### 下载器特性

#### IO 平台 (Android/iOS/Desktop)
- 支持断点续传
- 临时文件 (.part) 存储
- SHA256 校验和验证
- 可取消的下载
- 实时进度回调

#### Web 平台
- 使用 BrowserClient 进行 HTTP 下载
- 自动触发浏览器下载
- Object URL 生成
- SHA256 校验和验证

## 🎯 目标范围 (Scope)

- ✅ 默认升级对话框 UI
- ✅ Dart 实现的下载管理器
- ✅ 下载进度事件流
- ✅ 下载完成回调

## ❌ 非目标 (Non-goals)

- ❌ 原生下载逻辑（使用纯 Dart 实现）
- ❌ 无宿主集成时的 APK 自动安装

## 📦 依赖项

```yaml
dependencies:
  flutter: sdk: flutter
  crypto: ^3.0.3      # SHA256 校验
  http: ^1.2.2        # HTTP 客户端

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^3.0.0
```

## 🧪 运行示例应用

示例应用位于 `example/` 目录，包含：
- 可配置的升级信息输入界面
- 两种模式演示：
  - 对话框模式 (`Show Upgrade Dialog`)
  - 直接下载模式 (`Start Download Directly`)
- 实时状态显示卡片

```bash
cd example
flutter run
```

## 📝 设计模式

1. **平台抽象层**: 通过 `UpgradeKitDownloaderPlatform` 接口实现跨平台兼容
2. **条件导入**: 使用 `if (dart.library.io)` / `if (dart.library.html)` 实现平台特定代码
3. **响应式状态**: 使用 `ChangeNotifier` + `StreamController` 实现状态管理和事件广播
4. **不可变模型**: 所有模型类使用 `const` 构造函数和 `copyWith` 方法

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。