import 'dart:io';

import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class PhotoViewer extends StatelessWidget {
  const PhotoViewer({
    required this.path,
    this.height = 200,
    super.key,
  });

  final String? path;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Center(
          child: Icon(CupertinoIcons.photo, size: 32),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.file(
        File(path!),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
