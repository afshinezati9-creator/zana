class AppConstants {
  AppConstants._();

  static const String appName = 'زانا';
  static const String appNameEn = 'ZANA';
  static const String tagline = 'کمک به توسعه فردی و خودآگاهی';
  static const String subtitle = 'توسعه فردی و خودآگاهی';

  static const String packageName = 'ir.zana.app';

  // Storage keys
  static const String keyProgress = 'zana_progress';
  static const String keyPathResult = 'zana_path';
  static const String keyThemeMode = 'zana_theme_mode';
  static const String keyFontScale = 'zana_font_scale';
  static const String keyFirstLaunch = 'zana_first_launch';
  static const String keyRecent = 'zana_recent_methods';
  static const String keyPinned = 'zana_pinned_methods';
  static const String keyPinnedProblems = 'zana_pinned_problems';

  // Timing
  static const Duration splashDuration = Duration(milliseconds: 2400);
  static const Duration toastDuration = Duration(milliseconds: 2800);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Content counts (for validation)
  static const int totalMethods = 100;
  static const int totalProblems = 15;
  static const int totalQuestions = 8;
  static const int chaptersPerMethod = 7;
  static const int slidesPerProblem = 6;
}
