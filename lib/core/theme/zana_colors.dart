import 'package:flutter/material.dart';

/// پالت رنگی هر تب + دارک‌مود کامل
/// این فایل منبع حقیقت رنگ‌های زانا است.

enum ZanaTab { home, library, path, problems, about, manage }

class ZanaPalette {
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color accent;
  final Color accentDark;
  final Color accentSoft;
  final Color background;
  final Color surface;
  final Color surface2;
  final Color text;
  final Color muted;
  final Color border;
  final LinearGradient headerGradient;
  final LinearGradient pageGradient;

  const ZanaPalette({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.accent,
    required this.accentDark,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.border,
    required this.headerGradient,
    required this.pageGradient,
  });
}

class ZanaColors {
  ZanaColors._();

  // ─── رنگ‌های سراسری ثابت ───────────────────────────────────────────────
  static const Color danger = Color(0xFFE07856);
  static const Color success = Color(0xFFD4A94A);
  static const Color adultLock = Color(0xFFC44A2C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A0A0D);

  // ─── پالت روشن ────────────────────────────────────────────────────────
  static const Map<ZanaTab, ZanaPalette> light = {
    ZanaTab.home: ZanaPalette(
      primary: Color(0xFF5B8A72),
      primaryDark: Color(0xFF3D6B56),
      primarySoft: Color(0xFFE3EDE8),
      accent: Color(0xFFE8A87C),
      accentDark: Color(0xFFC17F52),
      accentSoft: Color(0xFFFBEEE3),
      background: Color(0xFFF3F8F4),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFF8FAF9),
      text: Color(0xFF1F2D26),
      muted: Color(0xFF6E7C74),
      border: Color(0xFFE0E9E3),
      headerGradient: LinearGradient(
        colors: [Color(0xFF5B8A72), Color(0xFF3D6B56)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFFE3EDE8), Color(0xFFEEF5F1), Color(0xFFF3F8F4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.library: ZanaPalette(
      primary: Color(0xFF3A7CA5),
      primaryDark: Color(0xFF2C5D7D),
      primarySoft: Color(0xFFDBE9F2),
      accent: Color(0xFFD4A94A),
      accentDark: Color(0xFFB8902F),
      accentSoft: Color(0xFFFBF2D9),
      background: Color(0xFFF0F6FA),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFF5F9FC),
      text: Color(0xFF1A2B3A),
      muted: Color(0xFF5F7383),
      border: Color(0xFFD8E4ED),
      headerGradient: LinearGradient(
        colors: [Color(0xFF3A7CA5), Color(0xFF2C5D7D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFFDBE9F2), Color(0xFFE9F1F7), Color(0xFFF0F6FA)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.path: ZanaPalette(
      primary: Color(0xFF7D6FB0),
      primaryDark: Color(0xFF5D5090),
      primarySoft: Color(0xFFEAE5F5),
      accent: Color(0xFFE08A6B),
      accentDark: Color(0xFFB86B4F),
      accentSoft: Color(0xFFFAE5DB),
      background: Color(0xFFF4F2F8),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFF9F7FC),
      text: Color(0xFF2D2640),
      muted: Color(0xFF726A87),
      border: Color(0xFFE2DCEC),
      headerGradient: LinearGradient(
        colors: [Color(0xFF7D6FB0), Color(0xFF5D5090)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFFEAE5F5), Color(0xFFF1EEF8), Color(0xFFF4F2F8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.problems: ZanaPalette(
      primary: Color(0xFFC96B6E),
      primaryDark: Color(0xFFA04F52),
      primarySoft: Color(0xFFF6E3E3),
      accent: Color(0xFF4A9B9C),
      accentDark: Color(0xFF357778),
      accentSoft: Color(0xFFDCEFEF),
      background: Color(0xFFFAF4F4),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFFDF8F8),
      text: Color(0xFF3A2226),
      muted: Color(0xFF8A6D6F),
      border: Color(0xFFECD9D9),
      headerGradient: LinearGradient(
        colors: [Color(0xFFC96B6E), Color(0xFFA04F52)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFFF6E3E3), Color(0xFFF9EFEF), Color(0xFFFAF4F4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.about: ZanaPalette(
      primary: Color(0xFF6B7280),
      primaryDark: Color(0xFF4B5563),
      primarySoft: Color(0xFFE5E7EB),
      accent: Color(0xFF8B95A5),
      accentDark: Color(0xFF5F6B7A),
      accentSoft: Color(0xFFEEF0F3),
      background: Color(0xFFF5F6F8),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFFAFBFC),
      text: Color(0xFF1F242C),
      muted: Color(0xFF6E7580),
      border: Color(0xFFE2E5EA),
      headerGradient: LinearGradient(
        colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFFE5E7EB), Color(0xFFEFF1F4), Color(0xFFF5F6F8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.manage: ZanaPalette(
      primary: Color(0xFF6B5B95),
      primaryDark: Color(0xFF4F4370),
      primarySoft: Color(0xFFEDE8F5),
      accent: Color(0xFFD4A94A),
      accentDark: Color(0xFFB8902F),
      accentSoft: Color(0xFFF7F0DC),
      background: Color(0xFFF6F4FA),
      surface: Color(0xFFFFFFFF),
      surface2: Color(0xFFF9F7FC),
      text: Color(0xFF2A2438),
      muted: Color(0xFF7A7289),
      border: Color(0xFFE4DFEC),
      headerGradient: LinearGradient(
        colors: [Color(0xFF6B5B95), Color(0xFF4F4370)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFFEDE8F5), Color(0xFFF3F0F8), Color(0xFFF6F4FA)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  };

  // ─── پالت تاریک کامل ─────────────────────────────
  static const Map<ZanaTab, ZanaPalette> dark = {
    ZanaTab.home: ZanaPalette(
      primary: Color(0xFF7BAF96),
      primaryDark: Color(0xFF5B8A72),
      primarySoft: Color(0xFF24332C),
      accent: Color(0xFFE8A87C),
      accentDark: Color(0xFFC17F52),
      accentSoft: Color(0xFF3A2E24),
      background: Color(0xFF1A2420),
      surface: Color(0xFF222E29),
      surface2: Color(0xFF2A3832),
      text: Color(0xFFE8EDE9),
      muted: Color(0xFF9AA8A0),
      border: Color(0xFF2F4038),
      headerGradient: LinearGradient(
        colors: [Color(0xFF3D6B56), Color(0xFF2A4D3D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFF1A2420), Color(0xFF1F2A25), Color(0xFF1A2420)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.library: ZanaPalette(
      primary: Color(0xFF5A9BC4),
      primaryDark: Color(0xFF3A7CA5),
      primarySoft: Color(0xFF1E2E38),
      accent: Color(0xFFD4A94A),
      accentDark: Color(0xFFB8902F),
      accentSoft: Color(0xFF3A3420),
      background: Color(0xFF1A2228),
      surface: Color(0xFF222D35),
      surface2: Color(0xFF2A3740),
      text: Color(0xFFE4EDF4),
      muted: Color(0xFF8FA3B3),
      border: Color(0xFF2F3F4A),
      headerGradient: LinearGradient(
        colors: [Color(0xFF2C5D7D), Color(0xFF1E4058)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFF1A2228), Color(0xFF1F2930), Color(0xFF1A2228)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.path: ZanaPalette(
      primary: Color(0xFF9B8DC8),
      primaryDark: Color(0xFF7D6FB0),
      primarySoft: Color(0xFF2A2538),
      accent: Color(0xFFE08A6B),
      accentDark: Color(0xFFB86B4F),
      accentSoft: Color(0xFF3A2C26),
      background: Color(0xFF1F1C28),
      surface: Color(0xFF292533),
      surface2: Color(0xFF322E3E),
      text: Color(0xFFECE8F4),
      muted: Color(0xFFA89DB8),
      border: Color(0xFF3A3448),
      headerGradient: LinearGradient(
        colors: [Color(0xFF5D5090), Color(0xFF433A6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFF1F1C28), Color(0xFF252230), Color(0xFF1F1C28)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.problems: ZanaPalette(
      primary: Color(0xFFD98A8C),
      primaryDark: Color(0xFFC96B6E),
      primarySoft: Color(0xFF332526),
      accent: Color(0xFF4A9B9C),
      accentDark: Color(0xFF357778),
      accentSoft: Color(0xFF1E3333),
      background: Color(0xFF241C1D),
      surface: Color(0xFF2E2425),
      surface2: Color(0xFF382C2D),
      text: Color(0xFFF2E8E8),
      muted: Color(0xFFB89A9B),
      border: Color(0xFF423334),
      headerGradient: LinearGradient(
        colors: [Color(0xFFA04F52), Color(0xFF7A3A3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFF241C1D), Color(0xFF2A2122), Color(0xFF241C1D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.about: ZanaPalette(
      primary: Color(0xFF8B95A5),
      primaryDark: Color(0xFF6B7280),
      primarySoft: Color(0xFF2A2E34),
      accent: Color(0xFF8B95A5),
      accentDark: Color(0xFF5F6B7A),
      accentSoft: Color(0xFF2E3238),
      background: Color(0xFF1C1E22),
      surface: Color(0xFF262A30),
      surface2: Color(0xFF30353C),
      text: Color(0xFFE8EAED),
      muted: Color(0xFF9AA3AD),
      border: Color(0xFF3A4048),
      headerGradient: LinearGradient(
        colors: [Color(0xFF4B5563), Color(0xFF374151)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFF1C1E22), Color(0xFF22252A), Color(0xFF1C1E22)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    ZanaTab.manage: ZanaPalette(
      primary: Color(0xFF9B8BC4),
      primaryDark: Color(0xFF7A6BA3),
      primarySoft: Color(0xFF2A2438),
      accent: Color(0xFFD4A94A),
      accentDark: Color(0xFFB8902F),
      accentSoft: Color(0xFF3A3420),
      background: Color(0xFF141218),
      surface: Color(0xFF1C1824),
      surface2: Color(0xFF221E2C),
      text: Color(0xFFF0ECF6),
      muted: Color(0xFFA89EB8),
      border: Color(0xFF322C40),
      headerGradient: LinearGradient(
        colors: [Color(0xFF4F4370), Color(0xFF3A3254)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pageGradient: LinearGradient(
        colors: [Color(0xFF1C1824), Color(0xFF18141F), Color(0xFF141218)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  };

  static ZanaPalette of(ZanaTab tab, {required bool isDark}) {
    return isDark ? dark[tab]! : light[tab]!;
  }
}
