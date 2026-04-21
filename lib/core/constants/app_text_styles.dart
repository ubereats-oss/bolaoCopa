import 'package:flutter/material.dart';
import 'app_colors.dart';
class AppTextStyles {
  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const subtitle = TextStyle(fontSize: 16, color: AppColors.textMuted);
  static const label = TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
  static const muted = TextStyle(fontSize: 12, color: AppColors.textMuted);
  static const success = TextStyle(
      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success);
  static const error = TextStyle(fontSize: 14, color: AppColors.error);
}
