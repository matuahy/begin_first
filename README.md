# 物品记录 App

一款帮助用户快速记录物品位置、减少忘带与找不到的 Flutter 跨端应用。

核心体验：10 秒记录、30 秒找回、轻提醒不打扰。

详细文档：
- 产品文档：`docs/产品文档.md`
- 技术架构：`docs/技术架构文档.md`

## 🎯 产品目标

- 10 秒内完成一次物品记录（选物品 → 拍照保存）
- 30 秒内找到物品最后一次记录的位置
- 轻提醒：不强迫、不计时、可忽略

## ✅ 当前已实现

- 物品管理：新增/编辑/删除、搜索、分类与重要程度
- 记录流程：拍照/相册、补全信息、时间线、记录详情编辑/删除
- 场景记录：场景管理、场景内物品选择、连续记录
- 找回模式：最新记录照片 + 位置 + 历史回看
- 出门检查：按场景筛选、清单勾选
- 轻提醒：意图池、随机提醒、定时调度、已安排与历史
- 引导流程：首次启动选择默认物品/场景
- 设置页：统计、权限开关、清理未使用图片

## 🧰 技术栈

- Flutter >= 3.16.0
- Dart >= 3.2.0
- Riverpod / GoRouter / Hive / Cupertino

## 🚀 快速开始

```bash
# 1. 克隆项目
git clone <repository-url>
cd begin_first

# 2. 生成平台目录（首次）
flutter create .

# 3. 安装依赖
flutter pub get

# 4. 运行
flutter run
```

## 🔐 权限配置

### iOS (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>需要相机权限来拍摄物品照片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要相册权限来选择照片</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要相册权限来保存物品照片</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限来记录物品位置</string>
```

### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

如需兼容 Android 12 及以下，可额外添加：

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

## 💾 本地存储

- Hive Boxes：`items` / `records` / `scenes` / `intents` / `settings` / `nudgeHistory`
- 图片目录：`getApplicationDocumentsDirectory()/images/`

## 🧪 测试

```bash
flutter test
```

## 🧩 代码生成（可选）

当前版本模型与 Adapter 为手写；如需启用 Freezed / Generator，可执行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 📝 规范

- 遵循 Effective Dart
- 提交前建议运行 `flutter analyze`
