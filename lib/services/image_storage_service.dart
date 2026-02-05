import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

abstract class ImageStorageService {
  Future<String> saveImage(String sourcePath, {String? fileName});
  Future<void> deleteImage(String path);
  Future<String> getImageDirectory();
  Future<String> compressImage(String sourcePath, {int quality = 80});
  Future<String> getThumbnail(String sourcePath);
  Future<int> cleanupUnusedImages(Set<String> inUsePaths);
}

class ImageStorageServiceImpl implements ImageStorageService {
  static const String _folderName = 'images';

  @override
  Future<String> saveImage(String sourcePath, {String? fileName}) async {
    final imageDir = await getImageDirectory();
    final compressedPath = await compressImage(sourcePath);
    final resolvedName = fileName ?? _buildFileName(prefix: 'img');
    final targetPath = '$imageDir${Platform.pathSeparator}$resolvedName';
    final saved = await File(compressedPath).copy(targetPath);
    return saved.path;
  }

  @override
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<String> getImageDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final images = Directory('${dir.path}${Platform.pathSeparator}$_folderName');
    if (!await images.exists()) {
      await images.create(recursive: true);
    }
    return images.path;
  }

  @override
  Future<String> compressImage(String sourcePath, {int quality = 80}) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}${Platform.pathSeparator}${_buildFileName(prefix: 'compressed')}';
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: quality,
    );
    return result?.path ?? sourcePath;
  }

  @override
  Future<String> getThumbnail(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}${Platform.pathSeparator}${_buildFileName(prefix: 'thumb')}';
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 60,
      minWidth: 320,
      minHeight: 320,
    );
    return result?.path ?? sourcePath;
  }

  @override
  Future<int> cleanupUnusedImages(Set<String> inUsePaths) async {
    final imageDir = await getImageDirectory();
    final dir = Directory(imageDir);
    if (!await dir.exists()) {
      return 0;
    }
    final files = dir.listSync().whereType<File>().toList();
    var removed = 0;
    for (final file in files) {
      if (!inUsePaths.contains(file.path)) {
        await file.delete();
        removed += 1;
      }
    }
    return removed;
  }

  String _buildFileName({required String prefix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.jpg';
  }
}
