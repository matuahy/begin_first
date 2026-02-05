class ImageUtils {
  static String buildFileName({required String itemId, required DateTime timestamp}) {
    final epoch = timestamp.millisecondsSinceEpoch;
    return '${itemId}_$epoch.jpg';
  }
}
