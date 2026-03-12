import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const RamadanApp());
}

// ══════════════════════════════════════════
//  APP ROOT
// ══════════════════════════════════════════
class RamadanApp extends StatelessWidget {
  const RamadanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نور Ramadan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFFC9A227)),
      ),
      home: const MainScreen(),
    );
  }
}

// ══════════════════════════════════════════
//  COLORS  (use anywhere as AppC.gold etc.)
// ══════════════════════════════════════════
class AppC {
  static const bg      = Color(0xFF0A0E1A);
  static const card    = Color(0xFF141B2D);
  static const border  = Color(0xFF1E2D4A);
  static const gold    = Color(0xFFC9A227);
  static const goldLt  = Color(0xFFE8C547);
  static const teal    = Color(0xFF2DD4BF);
  static const txtPri  = Color(0xFFE8EAF6);
  static const txtSec  = Color(0xFF8892B0);
}

// ══════════════════════════════════════════
//  PRAYER TIMES  (hardcoded – replace with
//  your city's times or add an API later)
// ══════════════════════════════════════════
class PrayerData {
  static DateTime _t(int h, int m) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  static final fajr    = _t(05, 15);
  static final sunrise = _t(06, 24);
  static final dhuhr   = _t(13, 00);
  static final asr     = _t(16, 00);
  static final maghrib = _t(18, 03);
  static final isha    = _t(20, 00);

  static DateTime get sehri   => fajr.subtract(const Duration(minutes: 10));

  static DateTime get iftar   => maghrib;

  static Duration get toIftar {
    final d = iftar.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  static Duration get toSehri {
    var s = sehri;
    if (s.isBefore(DateTime.now())) s = s.add(const Duration(days: 1));
    return s.difference(DateTime.now());
  }

  static bool get isFasting =>
      DateTime.now().isAfter(fajr) && DateTime.now().isBefore(maghrib);

  static String fmt(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  static String fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// ══════════════════════════════════════════
//  MAIN SCREEN  (bottom nav with 4 tabs)
// ══════════════════════════════════════════
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  final _screens = const [
    HomeTab(),
    PrayerTab(),
    DuasTab(),
    TrackerTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_tab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppC.card,
          border: Border(top: BorderSide(color: AppC.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavBtn(emoji: '🏠', label: 'HOME',    idx: 0, cur: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavBtn(emoji: '🕌', label: 'PRAYER',  idx: 1, cur: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavBtn(emoji: '🤲', label: 'DUAS',    idx: 2, cur: _tab, onTap: (i) => setState(() => _tab = i)),
                _NavBtn(emoji: '🖲️', label: 'TRACKER', idx: 3, cur: _tab, onTap: (i) => setState(() => _tab = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String emoji, label;
  final int idx, cur;
  final void Function(int) onTap;
  const _NavBtn({required this.emoji, required this.label, required this.idx, required this.cur, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = idx == cur;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(idx),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: active ? 24 : 20)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: active ? AppC.gold : AppC.txtSec, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  TAB 1 — HOME
// ══════════════════════════════════════════
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppC.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('رَمَضَان مُبَارَك 🌙',
                          style: TextStyle(fontSize: 24, color: AppC.gold, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(' ${DateTime.now().year} ',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppC.txtPri)),
                    ],
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppC.gold, AppC.goldLt]),
                    ),
                    child: const Center(child: Text('👤', style: TextStyle(fontSize: 20))),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Hero Card ─────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A2A4A), Color(0xFF0F1E35)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppC.border),
                ),
                child: Column(
                  children: [
                    // Moon phase dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(20, (i) {
                        final lit = i < (DateTime.now().day * 0.67).round();
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lit ? AppC.goldLt : AppC.border,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Sehri / Iftar boxes
                    Row(
                      children: [
                        Expanded(child: _TimeBox(emoji: '🌙', label: 'SEHRI', time: PrayerData.fmt(PrayerData.sehri))),
                        const SizedBox(width: 12),
                        Expanded(child: _TimeBox(emoji: '🌅', label: 'IFTAR', time: PrayerData.fmt(PrayerData.iftar))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Countdown ─────────────────────────
              _Card(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PrayerData.isFasting ? 'Time until Iftar' : 'Time until Sehri',
                        style: const TextStyle(fontSize: 18, color: AppC.txtSec, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PrayerData.fmtDuration(PrayerData.isFasting ? PrayerData.toIftar : PrayerData.toSehri),
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppC.goldLt, letterSpacing: 2),
                      ),
                      Text(
                        PrayerData.isFasting ? '⏳ Currently fasting' : '🌙 Fast begins at Fajr',
                        style: const TextStyle(fontSize: 12, color: AppC.teal, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Text('⏱️', style: TextStyle(fontSize: 36)),
                ],
              )),

              const SizedBox(height: 20),

              // ── Prayer mini grid ──────────────────
              const Text('Today\'s Prayers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppC.txtPri)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PrayerChip(name: 'Fajr',    emoji: '🌄', time: PrayerData.fmt(PrayerData.fajr)),
                  _PrayerChip(name: 'Dhuhr',   emoji: '🌞', time: PrayerData.fmt(PrayerData.dhuhr)),
                  _PrayerChip(name: 'Asr',     emoji: '🌇', time: PrayerData.fmt(PrayerData.asr)),
                  _PrayerChip(name: 'Maghrib', emoji: '🌆', time: PrayerData.fmt(PrayerData.maghrib)),
                  _PrayerChip(name: 'Isha',    emoji: '🌙', time: PrayerData.fmt(PrayerData.isha)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Dua of day ────────────────────────
              const Text('Dua of the Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppC.txtPri)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF14102A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 22, color: AppC.goldLt, height: 1.8),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '"O Allah, You are Pardoning and love pardon, so pardon me."\n— Tirmidhi 3513',
                        style: TextStyle(fontSize: 22, color: AppC.txtSec, fontStyle: FontStyle.italic, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Laylatul Qadr banner ──────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2A1060), Color(0xFF1A0A40)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
                ),
                child: const Row(
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Laylatul Qadr is near!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFC4B5FD))),
                          SizedBox(height: 4),
                          Text('Seek it in the last 10 odd nights (21, 23, 25, 27, 29).',
                              style: TextStyle(fontSize: 12, color: AppC.txtSec, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Small reusable widgets used on Home tab
class _TimeBox extends StatelessWidget {
  final String emoji, label, time;
  const _TimeBox({required this.emoji, required this.label, required this.time});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: AppC.txtSec, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]),
        const SizedBox(height: 6),
        Text(time, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppC.txtPri)),
      ],
    ),
  );
}

class _PrayerChip extends StatelessWidget {
  final String name, emoji, time;
  const _PrayerChip({required this.name, required this.emoji, required this.time});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppC.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppC.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppC.txtSec)),
          const SizedBox(height: 3),
          Text(time, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppC.txtPri)),
        ],
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppC.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppC.border),
    ),
    child: child,
  );
}

// ══════════════════════════════════════════
//  TAB 2 — PRAYER TIMES
// ══════════════════════════════════════════
class PrayerTab extends StatelessWidget {
  const PrayerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      {'name': 'Fajr',    'arabic': 'الفجر',   'emoji': '🌄', 'time': PrayerData.fajr,    'sub': 'Sehri ends'},
      {'name': 'Sunrise', 'arabic': 'الشروق',  'emoji': '☀️', 'time': PrayerData.sunrise, 'sub': ''},
      {'name': 'Dhuhr',   'arabic': 'الظهر',   'emoji': '🌞', 'time': PrayerData.dhuhr,   'sub': ''},
      {'name': 'Asr',     'arabic': 'العصر',   'emoji': '🌇', 'time': PrayerData.asr,     'sub': ''},
      {'name': 'Maghrib', 'arabic': 'المغرب',  'emoji': '🌆', 'time': PrayerData.maghrib, 'sub': 'Iftar'},
      {'name': 'Isha',    'arabic': 'العشاء',  'emoji': '🌙', 'time': PrayerData.isha,    'sub': ''},
    ];

    return Scaffold(
      backgroundColor: AppC.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prayer Times 🕌', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppC.txtPri)),
              const SizedBox(height: 4),
              const Text('Nankana Sahib, Pakistan  •  Lahore Method', style: TextStyle(fontSize: 12, color: AppC.txtSec)),
              const SizedBox(height: 20),

              // Qibla card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppC.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppC.border),
                ),
                child: const Row(
                  children: [
                    Text('🧭', style: TextStyle(fontSize: 36)),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qibla Direction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppC.txtPri)),
                        SizedBox(height: 4),
                        Text('242° toward Makkah Al-Mukarramah', style: TextStyle(fontSize: 12, color: AppC.txtSec)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Prayer list
              Expanded(
                child: ListView.separated(
                  itemCount: prayers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = prayers[i];
                    final isCurrent = DateTime.now().isAfter(p['time'] as DateTime) &&
                        (i == prayers.length - 1 || DateTime.now().isBefore(prayers[i + 1]['time'] as DateTime));
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppC.gold.withOpacity(0.1) : AppC.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isCurrent ? AppC.gold : AppC.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent ? AppC.gold : AppC.border,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(p['emoji'] as String, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(p['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppC.txtPri)),
                                    if ((p['sub'] as String).isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppC.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                        child: Text(p['sub'] as String, style: const TextStyle(fontSize: 10, color: AppC.gold, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(p['arabic'] as String, style: const TextStyle(fontSize: 13, color: AppC.txtSec)),
                              ],
                            ),
                          ),
                          Text(
                            PrayerData.fmt(p['time'] as DateTime),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppC.goldLt),
                          ),
                          const SizedBox(width: 10),
                          Icon(isCurrent ? Icons.notifications_active : Icons.notifications_outlined,
                              color: isCurrent ? AppC.gold : AppC.txtSec, size: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  TAB 3 — DUAS & TASBEEH
// ══════════════════════════════════════════
class DuasTab extends StatefulWidget {
  const DuasTab({super.key});
  @override State<DuasTab> createState() => _DuasTabState();
}

class _DuasTabState extends State<DuasTab> {
  int _tsCount = 0;
  int _tsSet   = 0;

  static const _sets = [
    {'arabic': 'سُبْحَانَ اللَّهِ',      'roman': 'SubhanAllah',    'meaning': 'Glory be to Allah',           'max': 33},
    {'arabic': 'الْحَمْدُ لِلَّهِ',     'roman': 'Alhamdulillah',  'meaning': 'Praise be to Allah',           'max': 33},
    {'arabic': 'اللَّهُ أَكْبَرُ',       'roman': 'Allahu Akbar',   'meaning': 'Allah is the Greatest',        'max': 34},
    {'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ', 'roman': 'La Ilaha IllAllah', 'meaning': 'No god but Allah',   'max': 100},
    {'arabic': 'أَسْتَغْفِرُ اللَّهَ',  'roman': 'Astaghfirullah', 'meaning': 'I seek Allah\'s forgiveness', 'max': 100},
  ];


  static const _duas = [
    {
      'title': '🌙 Sehri Dua',
      'arabic': 'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ',
      'meaning': 'I intend to keep the fast for tomorrow in the month of Ramadan.',
      'ref': 'Abu Dawud',
    },
    {
      'title': '🌅 Iftar Dua',
      'arabic': 'اللَّهُمَّ اِنِّى لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ',
      'meaning': 'O Allah! I fasted for You, I believe in You, and I put my trust in You.',
      'ref': 'Abu Dawud 2358',
    },
    {
      'title': '⭐ Laylatul Qadr Dua',
      'arabic': 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      'meaning': 'O Allah, You are Pardoning and love pardon, so pardon me.',
      'ref': 'Tirmidhi 3513',
    },
    {
      'title': '🌤️ Morning Dua',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'meaning': 'We have entered the morning and the kingdom belongs to Allah.',
      'ref': 'Muslim 2723',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cur = _sets[_tsSet];
    final max = cur['max'] as int;

    return Scaffold(
      backgroundColor: AppC.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Duas & Zikr 🤲', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppC.txtPri)),
              const SizedBox(height: 20),

              // ── Tasbeeh Counter ───────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppC.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppC.border),
                ),
                child: Column(
                  children: [
                    // Set selector
                    SizedBox(
                      height: 34,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _sets.length,
                        itemBuilder: (_, i) {
                          final sel = i == _tsSet;
                          return GestureDetector(
                            onTap: () => setState(() { _tsSet = i; _tsCount = 0; }),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel ? AppC.gold : AppC.bg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(_sets[i]['roman'] as String,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? AppC.bg : AppC.txtSec)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(cur['arabic'] as String,
                        style: const TextStyle(fontSize: 26, color: AppC.goldLt, height: 1.6),
                        textDirection: TextDirection.rtl),
                    const SizedBox(height: 4),
                    Text(cur['meaning'] as String, style: const TextStyle(fontSize: 12, color: AppC.txtSec)),
                    const SizedBox(height: 16),
                    // Count
                    Text('$_tsCount', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: AppC.goldLt, height: 1)),
                    Text('of $max', style: const TextStyle(fontSize: 13, color: AppC.txtSec)),
                    const SizedBox(height: 14),
                    // Dots
                    Wrap(
                      spacing: 5, runSpacing: 5,
                      children: List.generate(max.clamp(0, 33), (i) => Container(
                        width: 9, height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _tsCount ? AppC.gold : AppC.border,
                        ),
                      )),
                    ),
                    const SizedBox(height: 18),
                    // Big tap button
                    GestureDetector(
                      onTap: () => setState(() => _tsCount = (_tsCount + 1) % (max + 1)),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [AppC.gold, AppC.goldLt]),
                          boxShadow: [BoxShadow(color: AppC.gold.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: const Center(child: Text('☝️', style: TextStyle(fontSize: 36))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _tsCount = 0),
                      child: const Text('RESET', style: TextStyle(fontSize: 11, color: AppC.txtSec, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('Daily Duas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppC.txtPri)),
              const SizedBox(height: 12),

              // ── Duas list ──────────────────────────
              ..._duas.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppC.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppC.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(d['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppC.gold)),
                    ),
                    const SizedBox(height: 10),
                    Text(d['arabic']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 18, color: AppC.goldLt, height: 1.8)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('"${d['meaning']!}"\n— ${d['ref']!}',
                          style: const TextStyle(fontSize: 12, color: AppC.txtSec, fontStyle: FontStyle.italic, height: 1.6)),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  TAB 4 — TRACKER
// ══════════════════════════════════════════
class TrackerTab extends StatefulWidget {
  const TrackerTab({super.key});
  @override State<TrackerTab> createState() => _TrackerTabState();
}

class _TrackerTabState extends State<TrackerTab> {
  // Track which items are checked
  final Map<String, bool> _checked = {
    'sehri':         false,
    'fasting':       false,
    'fajr':          false,
    'dhuhr':         false,
    'asr':           false,
    'maghrib':       false,
    'isha':          false,
    'quran':         false,
    'morningAdhkar': false,
    'sadaqah':       false,
    'taraweeh':      false,
    'tahajjud':      false,
  };

  void _toggle(String key) => setState(() => _checked[key] = !_checked[key]!);

  int get _done    => _checked.values.where((v) => v).length;
  int get _total   => _checked.length;
  double get _pct  => _done / _total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppC.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Activity Tracker 🖲️', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppC.txtPri)),
              const SizedBox(height: 20),

              // ── Progress ring card ────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppC.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppC.border)),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70, height: 70,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _pct,
                            backgroundColor: AppC.border,
                            valueColor: const AlwaysStoppedAnimation(AppC.gold),
                            strokeWidth: 6,
                          ),
                          Text('${(_pct * 100).toInt()}%',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppC.gold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Today's Progress", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppC.txtPri)),
                        const SizedBox(height: 4),
                        Text('$_done of $_total tasks completed', style: const TextStyle(fontSize: 12, color: AppC.txtSec)),
                        const SizedBox(height: 8),
                        Text(
                          _pct == 1.0 ? '🎉 Perfect day!' : _pct > 0.6 ? '💪 Great progress!' : '🌙 Keep going!',
                          style: const TextStyle(fontSize: 12, color: AppC.gold, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Sections ──────────────────────────
              _Section(title: '🌙 Fasting', items: [
                _Item('sehri',   '🌙', 'Ate Sehri',        _checked),
                _Item('fasting', '⏳', 'Kept the Fast',     _checked),
              ], onToggle: _toggle),

              _Section(title: '🕌 Prayers (${_checked.entries.where((e) => ['fajr','dhuhr','asr','maghrib','isha'].contains(e.key) && e.value).length}/5)', items: [
                _Item('fajr',    '🌄', 'Fajr',    _checked),
                _Item('dhuhr',   '🌞', 'Dhuhr',   _checked),
                _Item('asr',     '🌇', 'Asr',     _checked),
                _Item('maghrib', '🌆', 'Maghrib', _checked),
                _Item('isha',    '🌙', 'Isha',    _checked),
              ], onToggle: _toggle),

              _Section(title: '📖 Quran', items: [
                _Item('quran', '📖', 'Read Quran today', _checked),
              ], onToggle: _toggle),

              _Section(title: '⭐ Good Deeds', items: [
                _Item('morningAdhkar', '🤲', 'Morning Adhkar',  _checked),
                _Item('sadaqah',       '💰', 'Gave Sadaqah',    _checked),
                _Item('taraweeh',      '🕌', 'Taraweeh Prayer', _checked),
                _Item('tahajjud',      '🌌', 'Tahajjud Prayer', _checked),
              ], onToggle: _toggle),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final void Function(String) onToggle;

  const _Section({required this.title, required this.items, required this.onToggle});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppC.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppC.border)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppC.txtPri)),
        const SizedBox(height: 10),
        ...items,
      ],
    ),
  );
}

class _Item extends StatelessWidget {
  final String field, emoji, label;
  final Map<String, bool> checked;

  const _Item(this.field, this.emoji, this.label, this.checked);

  @override
  Widget build(BuildContext context) {
    final done = checked[field] ?? false;
    return GestureDetector(
      onTap: () {
        // find TrackerTab state and call toggle
        final state = context.findAncestorStateOfType<_TrackerTabState>();
        state?._toggle(field);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: done ? AppC.gold.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: done ? AppC.txtSec : AppC.txtPri,
                    decoration: done ? TextDecoration.lineThrough : null,
                  )),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppC.gold : Colors.transparent,
                border: Border.all(color: done ? AppC.gold : AppC.border, width: 2),
              ),
              child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}
