import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/content_service.dart';
import 'core/services/progress_service.dart';
import 'core/theme/zana_colors.dart';
import 'core/theme/zana_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/providers/app_state_provider.dart';
import 'core/utils/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Future.wait([
    ContentService().loadAll(),
    ProgressService().init(),
  ]);

  final dark = ProgressService().isDarkMode();
  final scale = ProgressService().fontScale();

  runApp(
    ProviderScope(
      overrides: [
        isDarkModeProvider.overrideWith((ref) => dark),
        fontScaleProvider.overrideWith((ref) => scale),
      ],
      child: const ZanaApp(),
    ),
  );
}

class ZanaApp extends ConsumerWidget {
  const ZanaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ZanaTheme.light(ZanaTab.home);
    final fontScale = ref.watch(fontScaleProvider);

    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      title: 'زانا · توسعه فردی و خودآگاهی',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: ZanaTheme.dark(ZanaTab.home),
      themeMode: ThemeMode.light,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // دسکتاپ/تبلت عریض: پایهٔ خوانایی کمی بزرگ‌تر؛ موبایل: همان مقیاس کاربر
        final shortest = media.size.shortestSide;
        final deviceBase = shortest >= 700
            ? 1.08
            : shortest >= 500
                ? 1.03
                : 1.0;
        final effective = (fontScale * deviceBase).clamp(0.9, 1.65);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(effective),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
