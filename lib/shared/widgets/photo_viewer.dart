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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.photo, size: 32, color: AppColors.textSecondary),
              SizedBox(height: AppSpacing.sm),
              Text('暂无照片', style: AppTextStyles.bodyMuted),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Image.file(
        File(path!),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
