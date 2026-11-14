import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/content_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../providers/app_state_provider.dart';

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.about, isDark: isDark);
    final sources = ContentService().sources;
    final intl = sources.where((s) => s['type'] == 'بین‌المللی').toList();
    final local = sources.where((s) => s['type'] == 'داخلی').toList();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('منابع علمی معتبر'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            'این فهرست برای مطالعه و ارجاع است. زانا محتوا را از منابع رسمی و مقالات معتبر گردآوری می‌کند و جایگزین تشخیص یا درمان تخصصی نیست.',
            style: TextStyle(fontSize: 13.5, color: palette.muted, height: 1.65),
          ),
          const SizedBox(height: 16),
          Text(
            'بین‌المللی',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 8),
          ...intl.map((s) => _SourceTile(source: s, palette: palette)),
          const SizedBox(height: 16),
          Text(
            'داخلی',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 8),
          ...local.map((s) => _SourceTile(source: s, palette: palette)),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final Map<String, dynamic> source;
  final ZanaPalette palette;

  const _SourceTile({required this.source, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final uri = Uri.parse(source['url'] as String);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_balance_rounded,
                      color: palette.primaryDark, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source['n'] as String,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        source['desc'] as String? ?? '',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: palette.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        source['url'] as String,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.primary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, size: 16, color: palette.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
