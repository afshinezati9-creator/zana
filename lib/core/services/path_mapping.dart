import '../../domain/entities/path_result.dart';
import 'content_service.dart';

/// نگاشت پاسخ‌های مسیر → دسته / ابزار / مشکل (P0 + P3)
class PathMapping {
  PathMapping._();

  static const q1Labels = <String, String>{
    's_fatigue': 'خستگی از همان صبح',
    's_loop': 'فکر تکراری که ول‌کن نیست',
    's_storm': 'موج اضطراب یا از کنترل خارج شدن',
    's_people': 'اصطکاک با آدم‌های مهم',
    's_delay': 'کار و درس که هی می‌ماند برای بعد',
    's_stuck': 'حس گیر کردن یا عقب‌ماندن',
    's_urge': 'عادت یا وسوسه‌ای که فرمان می‌دهد',
  };

  static const q2Labels = <String, String>{
    'f_job': 'فشار کار و محیط شغلی',
    'f_care': 'مراقبت از دیگران',
    'f_empty': 'پوچی با وجود پیش‌رفتن کارها',
    'f_body': 'خستگی همراه با بدن',
    'l_past': 'نشخوار گذشته',
    'l_future': 'نکنه‌های آینده',
    'l_check': 'چک کردن مکرر',
    'l_meta': 'خستگی از خودِ فکر',
    't_panic': 'اضطراب شدید',
    't_anger': 'زودترکیدن خشم',
    't_numb': 'بی‌حسی',
    't_swing': 'نوسان خلق',
    'p_family': 'خانواده',
    'p_partner': 'رابطه عاطفی',
    'p_work': 'محیط کار',
    'p_please': 'کوتاه آمدن همیشگی',
    'd_start': 'سخت بودن شروع',
    'd_distract': 'حواس‌پرتی وسط کار',
    'd_perfect': 'کمال‌گرایی',
    'd_avoid': 'اجتناب از خودِ کار',
    'k_compare': 'مقایسه با بقیه',
    'k_meaning': 'گم شدن معنا',
    'k_choice': 'فلج تصمیم',
    'k_after': 'پوچی بعد از موفقیت',
    'u_screen': 'صفحه و شبکه',
    'u_body': 'خوردن و ظاهر',
    'u_sex': 'الگوی جنسی اجباری',
    'u_work': 'کار افراطی برای فرار',
  };

  static const q3Labels = <String, String>{
    'm_short_light': 'چند روز تا چند هفته؛ هنوز سبک‌تر',
    'm_months_mid': 'چند ماهه و در حال سنگین شدن',
    'm_long_heavy': 'خیلی وقت است و فرسوده‌کننده',
  };

  static const q4Labels = <String, String>{
    'want_understand': 'بیشتر فهمیدن',
    'want_do': 'یک قدم عملی کوچک',
    'want_both': 'هم فهم هم عمل',
  };

  static final preferredProblems = <String, List<String>>{
    'f_job': ['job_burnout', 'decision_fatigue', 'meaninglessness_at_work'],
    'f_care': ['caregiver_burnout', 'parental_burnout', 'family_emotional_burnout'],
    'f_empty': ['emptiness_after_success', 'weekend_emptiness', 'meaninglessness_at_work'],
    'f_body': ['chronic_fatigue', 'fatigue_after_insufficient_sleep', 'persistent_lethargy'],
    'l_past': ['rumination', 'stuck_on_a_sentence'],
    'l_future': ['what_if_thoughts', 'worrying_about_worrying', 'anticipatory_anxiety'],
    'l_check': ['compulsive_checking', 'doubting_own_memory'],
    'l_meta': ['rumination', 'worrying_about_worrying'],
    't_panic': ['anxiety_palpitations_and_choking', 'anticipatory_anxiety'],
    't_anger': ['anger_burst', 'suppressed_anger'],
    't_numb': ['persistent_lethargy', 'loss_of_interest'],
    't_swing': ['anger_burst', 'sudden_crying'],
    'p_family': ['weak_boundaries_family_of_origin', 'breadwinning_pressure'],
    'p_partner': ['anxious_attachment', 'avoidant_attachment', 'trust_after_infidelity'],
    'p_work': ['job_burnout', 'decision_fatigue'],
    'p_please': ['avoidance_of_asking_for_help', 'weak_boundaries_family_of_origin'],
    'd_start': ['difficulty_starting_tasks', 'chronic_procrastination'],
    'd_distract': ['difficulty_with_prioritization', 'too_many_ideas_no_follow_through'],
    'd_perfect': ['analysis_paralysis', 'chronic_procrastination'],
    'd_avoid': ['avoidance_of_administrative_responsibilities', 'chronic_procrastination'],
    'k_compare': ['feeling_left_behind', 'social_shame_what_will_people_say'],
    'k_meaning': ['meaninglessness_at_work', 'loss_of_passion'],
    'k_choice': ['analysis_paralysis', 'feeling_stuck_in_life'],
    'k_after': ['emptiness_after_success', 'weekend_emptiness'],
    'u_screen': ['social_media_burnout'],
    'u_body': ['emotional_eating', 'weight_anxiety', 'yo_yo_dieting'],
    'u_sex': [],
    'u_work': ['job_burnout', 'decision_fatigue'],
  };

  static final preferredMethods = <String, List<int>>{
    'f_job': [16, 46, 35, 5],
    'f_care': [50, 46, 27],
    'f_empty': [27, 11, 20],
    'f_body': [45, 46, 5],
    'l_past': [8, 10, 36],
    'l_future': [27, 8, 5],
    'l_check': [8, 31, 39],
    'l_meta': [8, 58, 10],
    't_panic': [5, 14, 58],
    't_anger': [5, 14, 11],
    't_numb': [46, 50, 11],
    't_swing': [5, 46, 8],
    'p_family': [9, 61, 27],
    'p_partner': [9, 62, 63],
    'p_work': [9, 16, 31],
    'p_please': [9, 27, 11],
    'd_start': [43, 39, 1, 36],
    'd_distract': [1, 38, 35, 37],
    'd_perfect': [31, 42, 39],
    'd_avoid': [43, 27, 36],
    'k_compare': [11, 20, 27],
    'k_meaning': [20, 11, 18],
    'k_choice': [31, 30, 16],
    'k_after': [20, 11, 46],
    'u_screen': [38, 1, 35],
    'u_body': [46, 5, 39],
    'u_sex': [5, 8],
    'u_work': [46, 35, 16],
  };

  static List<String> primaryCatsFor(String q1, String q2) {
    switch (q1) {
      case 's_fatigue':
        if (q2 == 'f_body') return ['burnout', 'body_signal'];
        if (q2 == 'f_care') return ['burnout', 'relation'];
        return ['burnout'];
      case 's_loop':
        return ['intrusive', 'inner_world'];
      case 's_storm':
        return ['storm', 'body_signal'];
      case 's_people':
        if (q2 == 'p_family') return ['relation', 'cultural'];
        return ['relation'];
      case 's_delay':
        return ['impulse', 'neuro'];
      case 's_stuck':
        return ['burnout', 'cultural', 'inner_world'];
      case 's_urge':
        if (q2 == 'u_body') return ['shame', 'body_image'];
        if (q2 == 'u_sex') return ['shame', 'impulse'];
        return ['shame', 'impulse'];
      default:
        return ['burnout'];
    }
  }

  static List<String> methodCatsFor(String q1, String q4) {
    List<String> base;
    switch (q1) {
      case 's_delay':
        base = ['time', 'habit', 'goal'];
        break;
      case 's_loop':
        base = ['mental', 'mind', 'self'];
        break;
      case 's_storm':
        base = ['stress', 'mental', 'mind'];
        break;
      case 's_people':
        base = ['rel', 'self'];
        break;
      case 's_fatigue':
        base = ['stress', 'career', 'self'];
        break;
      case 's_stuck':
        base = ['self', 'goal', 'career'];
        break;
      case 's_urge':
        base = ['habit', 'mental', 'stress'];
        break;
      default:
        base = ['self', 'mental'];
    }
    if (q4 == 'want_do') {
      return [
        ...base.where((c) => c == 'time' || c == 'habit' || c == 'stress'),
        ...base,
      ];
    }
    return base;
  }

  static String buildSummaryLine(Map<String, String> answers) {
    final q1 = answers['q1'] ?? '';
    final q2 = answers['q2'] ?? '';
    final q3 = answers['q3'] ?? '';
    final q4 = answers['q4'] ?? '';
    final parts = <String>[
      if (q1Labels[q1] != null) q1Labels[q1]!,
      if (q2Labels[q2] != null) q2Labels[q2]!,
      if (q3Labels[q3] != null) q3Labels[q3]!,
      if (q4Labels[q4] != null) q4Labels[q4]!,
    ];
    return parts.isEmpty ? 'مسیر اخیر' : parts.join(' · ');
  }

  static List<int> resolveMethodIds(
    String q1,
    String q2,
    String q4, {
    int limit = 6,
  }) {
    final cs = ContentService();
    final existing = cs.methods.map((m) => m.id).toSet();
    final out = <int>[];
    final seen = <int>{};

    void addId(int id) {
      if (existing.contains(id) && seen.add(id)) out.add(id);
    }

    for (final id in preferredMethods[q2] ?? const <int>[]) {
      addId(id);
      if (out.length >= limit) return out;
    }

    final preferCats = methodCatsFor(q1, q4);
    for (final cat in preferCats) {
      for (final m in cs.methods) {
        if (m.categoryId == cat) {
          addId(m.id);
          if (out.length >= limit) return out;
        }
      }
    }
    return out;
  }

  static List<String> resolveProblemIds(
    String q1,
    String q2, {
    int limit = 4,
  }) {
    final cs = ContentService();
    final byId = {for (final p in cs.problems) p.id: p};
    final out = <String>[];
    final seen = <String>{};

    void addId(String id) {
      if (byId.containsKey(id) && seen.add(id)) out.add(id);
    }

    for (final id in preferredProblems[q2] ?? const <String>[]) {
      addId(id);
      if (out.length >= limit) return out;
    }

    final cats = primaryCatsFor(q1, q2);
    for (final cat in cats) {
      for (final p in cs.problems) {
        if (p.categoryId == cat) {
          addId(p.id);
          if (out.length >= limit) return out;
        }
      }
    }
    return out;
  }

  static PathResult buildResult({
    required Map<String, String> answers,
    required List<String> pathNodes,
    List<String>? suggestedProblemIds,
    List<int>? suggestedMethodIds,
  }) {
    final q1 = answers['q1'] ?? '';
    final q2 = answers['q2'] ?? '';
    final q4 = answers['q4'] ?? 'want_both';
    final q5 = answers['q5'] ?? '';
    final crisis = q5 == 'safe_crisis';

    final methods = crisis
        ? <int>[]
        : (suggestedMethodIds ?? resolveMethodIds(q1, q2, q4));
    final problems = crisis
        ? <String>[]
        : (suggestedProblemIds ?? resolveProblemIds(q1, q2));

    return PathResult.create(
      answers: answers,
      path: pathNodes,
      crisis: crisis,
      summaryLine:
          crisis ? 'مسیر به کمک فوری هدایت شد' : buildSummaryLine(answers),
      suggestedProblemIds: problems,
      suggestedMethodIds: methods,
      primaryCats: primaryCatsFor(q1, q2),
    );
  }
}
