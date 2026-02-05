import 'dart:io';

import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

/// iOS风格的照片查看器
/// 支持阴影、圆角和占位符
class PhotoViewer extends StatelessWidget {
  const PhotoViewer({
    required this.path,
    this.height = 200,
    this.borderRadius,
    this.showShadow = true,
    super.key,
  });

  final String? path;
  final double height;
  final double? borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;

    if (path == null || path!.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(radius),
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

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(
          File(path!),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text('图片加载失败', style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
