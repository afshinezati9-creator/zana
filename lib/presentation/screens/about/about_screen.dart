import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/zana_colors.dart';
import '../../providers/app_state_provider.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  bool _revealed = false;

  static const _sheba = 'IR240560611828005412941301';
  static const _card = '6219861939293428';
  static const _email = 'afshinezati9@gmail.com';

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label کپی شد'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _mail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': 'نظر درباره زانا'},
    );
    try {
      await launchUrl(uri);
    } catch (_) {
      await _copy(_email, 'ایمیل');
    }
  }

  String get _cardFormatted {
    final c = _card;
    return '${c.substring(0, 4)} ${c.substring(4, 8)} ${c.substring(8, 12)} ${c.substring(12)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final palette = ZanaColors.of(ZanaTab.about, isDark: isDark);
    final bg = isDark ? const Color(0xFF12141C) : const Color(0xFFF1F5F9);

    return ColoredBox(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── پروفایل (راست‌چین) ──
          Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'افشین عزتی',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'AFSHIN EZATI',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xB3FFFFFF),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // ایمیل — پالت کوچک‌تر، هم‌تراز
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.mail_outline_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _email,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'کپی ایمیل',
                        onPressed: () => _copy(_email, 'ایمیل'),
                        icon: const Icon(Icons.copy_rounded,
                            color: Colors.white, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        tooltip: 'ارسال ایمیل',
                        onPressed: _mail,
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'اگر نقد، پیشنهاد یا ایده برای نسخه‌های بعدی داری، همین‌جا برام بنویس. با علاقه می‌خونم.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.65,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _ContentCard(
            title: 'زانا چیه؟',
            body:
                'زانا یک کتابخانهٔ خودآگاهی و رشد شخصی به زبان ساده است. این‌جا معجزه وعده نمی‌دیم و نمی‌گیم فردا همه‌چیز درست می‌شه. هدف اینه که با بحران‌ها و الگوهای تکراری زندگی‌ات آشناتر بشی، بفهمی از کجا آب می‌خوره، و با ابزارهایی که پشتوانه‌ی علمی دارند یک قدم کوچک و واقعی برداری.',
            isDark: isDark,
          ),
          _ContentCard(
            title: 'چرا زانا؟',
            body:
                'خیلی‌جاها یا پر از شعار انگیزشی‌اند، یا آن‌قدر تخصصی نوشته شده‌اند که آدم عادی وسطش گم می‌شود، یا برای دیده شدن طراحی شده‌اند نه برای فهمیدن. من دنبال جایی بودم که صادق باشد، ساده و روشن حرف بزند، منبع داشته باشد، و بگوید از کجا شروع کنی — بدون اینکه وانمود کند همه‌چیز را حل می‌کند. وقتی چیزی به این شکل پیدا نکردم، زانا را ساختم.',
            isDark: isDark,
          ),
          _ContentCard(
            title: 'برای کی ساخته شده؟',
            body:
                'برای کسی که حس می‌کند گیر کرده، خسته است، مدام فکر تکراری دارد، با آدم‌های مهم زندگی‌اش به هم می‌ریزد، کارها را عقب می‌اندازد، یا یک عادت دارد کنترل روزش را می‌گیرد — و هنوز می‌خواهد بفهمد قضیه از چه قرار است. برای دانشجو، والد، کارمند، فریلنسر، و هر کسی که یک قدم کوچک می‌خواهد، نه نسخه‌ی یک‌شبه.',
            isDark: isDark,
          ),
          _ContentCard(
            title: 'محتوای زانا از کجا میاد؟',
            body:
                'ابزارها و مطلب‌ها بر پایهٔ منابع علمی و حرفه‌ای نوشته شده‌اند؛ از پژوهش‌های روان‌شناسی و علوم رفتاری تا چارچوب‌های شناخته‌شدهٔ مدیریت زمان و تصمیم‌گیری. جایی که شواهد قوی‌تر است شفاف می‌گوییم، جایی که محدود است هم صادقانه می‌گوییم. منابعی مثل سازمان جهانی بهداشت، انجمن‌های تخصصی و مرورهای پژوهشی در بخش منابع و کمک فوری در دسترس‌اند. زانا جای روان‌شناس یا پزشک نیست.',
            isDark: isDark,
          ),
          _ContentCard(
            title: 'هشدارهای مهم',
            body:
                'زانا آموزش، خودآگاهی و ارجاع مسئولانه است — نه تشخیص و نه درمان. اگر حالت خیلی سخت است، افکار آسیب داری، یا ایمنی‌ات را تضمین نمی‌کنی، لطفاً از کمک فوری و متخصص واقعی استفاده کن. اپ فقط یک همراه آموزشی است.',
            isDark: isDark,
          ),
          _ContentCard(
            title: 'حریم خصوصی',
            body:
                'زانا برای کار کردن به اینترنت وصل نمی‌شود و هیچ اطلاعاتی از تو به سرور نمی‌فرستد و از جایی هم دادهٔ شخصی دریافت نمی‌کند. پیشرفت و نتیجهٔ مسیر فقط روی همین دستگاه می‌ماند. کاملاً رایگان است؛ تبلیغ ندارد و اشتراک پولی ندارد. با خیال راحت استفاده کن.',
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          // ── حمایت مالی ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'حمایت از مسیر زانا',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'استفاده از زانا کاملاً رایگانه. من فقط برای توسعه مداوم و ساخت اپ‌های بعدی به حمایت شما نیاز دارم.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _BankRow(
                        label: 'شماره شبا',
                        value: _revealed
                            ? _sheba
                            : 'IR************************',
                        actions: [
                          _BankBtn(
                            label: _revealed ? 'مخفی' : 'نمایش',
                            onTap: () =>
                                setState(() => _revealed = !_revealed),
                          ),
                          if (_revealed)
                            _BankBtn(
                              label: 'کپی',
                              onTap: () => _copy(_sheba, 'شبا'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _BankRow(
                        label: 'شماره کارت',
                        value: _revealed
                            ? _cardFormatted
                            : '**** **** **** ****',
                        actions: [
                          if (_revealed)
                            _BankBtn(
                              label: 'کپی',
                              onTap: () => _copy(_card, 'کارت'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'به نام: افشین عزتی',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text(
            'زانا · یک قدم کوچک، هر روز',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: palette.muted,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isDark;

  const _ContentCard({
    required this.title,
    required this.body,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2F3C) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.75,
              color: isDark
                  ? const Color(0xFFA8B0C0)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label;
  final String value;
  final List<Widget> actions;

  const _BankRow({
    required this.label,
    required this.value,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
        ),
        ...actions.map((w) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: w,
            )),
      ],
    );
  }
}

class _BankBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BankBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
