import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/progress_service.dart';
import '../../core/theme/zana_colors.dart';
import '../../domain/entities/path_result.dart';

/// تب فعال فعلی
final currentTabProvider = StateProvider<ZanaTab>((ref) => ZanaTab.home);

/// حالت تاریک
final isDarkModeProvider = StateProvider<bool>((ref) => false);

/// مقیاس فونت کل اپ (دسترسی‌پذیری)
final fontScaleProvider = StateProvider<double>((ref) => 1.0);

/// آیا مودال بحران باز است
final crisisModalOpenProvider = StateProvider<bool>((ref) => false);

/// افزایش بعد از ذخیره/حذف در تب مدیریت تا لیست‌ها رفرش شوند
final contentRevisionProvider = StateProvider<int>((ref) => 0);

/// با هر ذخیره/حذف مسیر زیاد می‌شود تا خانه و تب مسیر رفرش شوند
final pathRevisionProvider = StateProvider<int>((ref) => 0);

/// نتیجهٔ مسیر ذخیره‌شده (null = هنوز مسیر تمام نشده یا حذف شده)
final pathResultProvider = Provider<PathResult?>((ref) {
  ref.watch(pathRevisionProvider);
  return ProgressService().getPathResultEntity();
});
