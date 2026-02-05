# 物品记录 App

一款帮助用户快速记录物品位置、减少忘带和找不到的 Flutter 跨端应用。

## 📖 产品定位

**核心价值**：10 秒记录，30 秒找回，轻提醒不打扰

- ✅ **快速记录**：选物品 → 拍照 → 自动保存（10 秒内完成）
- 🔍 **快速找回**：打开物品详情，查看最后一次记录的照片、时间、地点
- 💡 **轻提醒**：温柔提醒推进意图，不强迫、不计时、可随时忽略

详细产品文档：[`docs/产品文档.md`](docs/产品文档.md)

---

## 🏗️ 技术架构

### 架构设计

采用 **Feature-First + Clean Architecture 简化版**，分层清晰、易维护、可扩展。

```
lib/
├── app/           # 应用入口、路由、主题
├── core/          # 工具、常量、扩展
├── data/          # 数据层（Hive 实现）
├── domain/        # 领域层（模型、Repository 接口）
├── features/      # 功能模块（按功能划分）
├── services/      # 服务层（相机、定位、通知）
└── shared/        # 共享组件
```

详细架构文档：[`docs/技术架构文档.md`](docs/技术架构文档.md)

### 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | >= 3.16.0 |
| 语言 | Dart | >= 3.2.0 |
| 状态管理 | Riverpod | ^2.4.0 |
| 路由 | GoRouter | ^12.0.0 |
| 本地存储 | Hive | ^2.2.0 |
| UI 风格 | Cupertino | Flutter 内置 |

---

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- iOS 开发：Xcode（macOS）
- Android 开发：Android Studio / Android SDK

### 安装步骤

```bash
# 1. 克隆项目
git clone <repository-url>
cd begin_first

# 2. 安装依赖
flutter pub get

# 3. （首次运行）生成平台目录
flutter create .

# 4. 运行项目
flutter run
```

### 代码生成

项目使用 Freezed、Riverpod Generator、Hive Generator 进行代码生成：

```bash
# 生成代码
dart run build_runner build --delete-conflicting-outputs

# 监听文件变化自动生成
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📁 项目结构

### 核心模块

| 模块 | 说明 | 路径 |
|------|------|------|
| 物品管理 | 物品 CRUD、详情、搜索 | `lib/features/items/` |
| 记录功能 | 拍照记录、时间线 | `lib/features/records/` |
| 场景管理 | 场景化记录入口 | `lib/features/scenes/` |
| 找回模式 | 查看最后记录、翻阅历史 | `lib/features/retrieve/` |
| 出门检查 | 清单勾选、防忘带 | `lib/features/checkout/` |
| 轻提醒 | 意图池、温柔提醒 | `lib/features/nudges/` |
| 设置 | 统计、权限、偏好设置 | `lib/features/settings/` |

### 数据模型

| 模型 | 说明 | 文件 |
|------|------|------|
| Item | 物品（名称、类别、重要程度） | `lib/domain/models/item.dart` |
| Record | 记录（照片、时间、地点、标签） | `lib/domain/models/record.dart` |
| Scene | 场景（回家、到公司、下车等） | `lib/domain/models/scene.dart` |
| Intent | 意图（轻提醒的任务池） | `lib/domain/models/intent.dart` |

### 服务层

| 服务 | 说明 | 文件 |
|------|------|------|
| CameraService | 相机拍照、相册选择 | `lib/services/camera_service.dart` |
| ImageStorageService | 图片保存、压缩、删除 | `lib/services/image_storage_service.dart` |
| LocationService | 定位、逆地理编码 | `lib/services/location_service.dart` |
| NotificationService | 本地通知调度 | `lib/services/notification_service.dart` |
| PermissionService | 权限统一管理 | `lib/services/permission_service.dart` |

---

## 💾 本地存储

### Hive Boxes

| Box 名称 | 存储内容 | Key 类型 |
|----------|----------|----------|
| `items` | Item 对象 | String (id) |
| `records` | Record 对象 | String (id) |
| `scenes` | Scene 对象 | String (id) |
| `intents` | Intent 对象 | String (id) |
| `settings` | 用户设置 | String (key) |
| `nudgeHistory` | 提醒历史 | int (index) |

### 数据持久化位置

- **iOS**：`~/Library/Application Support/`
- **Android**：`/data/data/<package>/app_flutter/`
- **图片存储**：`getApplicationDocumentsDirectory()/images/`

---

## 🔐 权限配置

### iOS (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>需要相机权限来拍摄物品照片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要相册权限来选择照片</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限来记录物品位置</string>
```

### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## 🛠️ 开发指南

### 添加新功能

1. 在 `lib/features/` 下创建新模块目录
2. 按照 `providers/`、`screens/`、`widgets/` 组织代码
3. 在 `lib/app/router.dart` 添加路由
4. 如需数据持久化，在 `lib/domain/` 添加模型和 Repository

### 状态管理

使用 Riverpod + Riverpod Generator：

```dart
// 定义 Provider
@riverpod
Future<List<Item>> items(ItemsRef ref) async {
  final repository = ref.read(itemRepositoryProvider);
  return repository.getAllItems();
}

// 使用 Provider
class ItemsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    return itemsAsync.when(
      data: (items) => ListView(...),
      loading: () => CupertinoActivityIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### 数据模型

使用 Freezed 定义不可变模型：

```dart
@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String name,
    required Category category,
  }) = _Item;
}
```

---

## 📋 开发阶段

### ✅ 已完成

- [x] 项目基础架构搭建
- [x] 数据模型定义（Item、Record、Scene、Intent）
- [x] Repository 接口设计
- [x] 服务层接口定义
- [x] 路由框架搭建
- [x] 底部 Tab 导航
- [x] 基础 UI 组件

### 🚧 进行中

- [ ] 物品 CRUD 功能实现
- [ ] 记录拍照功能
- [ ] 物品详情页（最后记录 + 时间线）
- [ ] 找回模式

### 📅 计划中

- [ ] 场景管理
- [ ] 出门检查
- [ ] 轻提醒 + 意图池
- [ ] Onboarding 引导
- [ ] 统计功能

---

## 🧪 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/domain/models/item_test.dart

# 生成测试覆盖率
flutter test --coverage
```

---

## 📝 代码规范

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 规范
- 使用 `flutter_lints` 进行代码检查
- 提交前运行 `flutter analyze` 确保无警告

---

## 🤝 贡献指南

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 📮 联系方式

如有问题或建议，欢迎提交 Issue 或 Pull Request。
