import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_service.dart';
import '../../../core/theme/zana_colors.dart';
import '../../providers/app_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CrisisModal extends ConsumerWidget {
  const CrisisModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.problems, isDark: isDark);
    final crisis = ContentService().crisis;
    final phones = (crisis['phones'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final online = (crisis['online'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 620),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // هدر
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
                  decoration: BoxDecoration(
                    color: ZanaColors.danger.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety_rounded,
                          color: ZanaColors.danger, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'کمک فوری',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ZanaColors.danger,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(crisisModalOpenProvider.notifier).state =
                              false;
                        },
                        icon: Icon(Icons.close_rounded, color: palette.muted),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    shrinkWrap: true,
                    children: [
                      Text(
                        crisis['disclaimer'] as String? ??
                            'زانا درمان نیست. در مواقع بحرانی تماس بگیر.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: palette.muted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'تلفن‌های اضطراری',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...phones.map((h) => _HotlineTile(
                            name: h['n'] as String,
                            number: h['num'] as String,
                            desc: h['desc'] as String? ?? '',
                            palette: palette,
                          )),
                      if (online.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          'منابع آنلاین',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: palette.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...online.map((o) => _OnlineTile(
                              name: o['n'] as String,
                              url: o['url'] as String,
                              desc: o['desc'] as String? ?? '',
                              palette: palette,
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HotlineTile extends StatelessWidget {
  final String name;
  final String number;
  final String desc;
  final ZanaPalette palette;

  const _HotlineTile({
    required this.name,
    required this.number,
    required this.desc,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: palette.text,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: palette.muted),
                ),
              ],
            ),
          ),
          Material(
            color: ZanaColors.danger,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: number);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineTile extends StatelessWidget {
  final String name;
  final String url;
  final String desc;
  final ZanaPalette palette;

  const _OnlineTile({
    required this.name,
    required this.url,
    required this.desc,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.surface2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.public_rounded, size: 18, color: palette.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: palette.text,
                        ),
                      ),
                      Text(
                        desc,
                        style: TextStyle(fontSize: 11, color: palette.muted),
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
