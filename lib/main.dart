import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'pages/profile_page.dart';
import 'pages/announcements_page.dart';
import 'pages/privacy_page.dart';
import 'pages/faq_page.dart';
import 'pages/all_questions_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/meb_map_page.dart';
import 'pages/favorite_questions_page.dart';
import 'pages/random_category_quiz_page.dart';
import 'pages/daily_question_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EhliyetApp());
}

class EhliyetApp extends StatefulWidget {
  const EhliyetApp({super.key});

  @override
  State<EhliyetApp> createState() => _EhliyetAppState();
}

class _EhliyetAppState extends State<EhliyetApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trafik Koçu',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(onThemeToggle: toggleTheme),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey[300],
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
      cardColor: const Color(0xFF2A2A2A),
      dividerColor: Colors.grey[700],
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomePage({super.key, required this.onThemeToggle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  double _passProbability = 0.0;
  String _userName = 'Sürücü Adayı';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _totalQuestions = 0;
  int _solvedQuestions = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<Map<String, dynamic>> _getDailyQuestionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = DateTime.now().toIso8601String().substring(0, 10);
      final cachedKey = prefs.getString('daily_q_key');
      final cachedData = prefs.getString('daily_q_data');
      if (cachedKey == todayKey && cachedData != null) {
        return jsonDecode(cachedData) as Map<String, dynamic>;
      }

      final snap = await FirebaseFirestore.instance.collection('sorular').get();
      if (snap.docs.isEmpty) return {};
      final rng = Random();
      final doc = snap.docs[rng.nextInt(snap.docs.length)];
      final data = doc.data();
      final result = <String, dynamic>{
        'soru': (data['soru'] ?? '').toString(),
        'cevaplar': (data['cevaplar'] ?? []),
        'cevap': data['cevap'],
      };
      await prefs.setString('daily_q_key', todayKey);
      await prefs.setString('daily_q_data', jsonEncode(result));
      return result;
    } catch (_) {
      return {};
    }
  }

  void _showDailyQuestionDialog(Map<String, dynamic> d) {
    if (d.isEmpty) {
      _showMessage('Günün sorusu yüklenemedi.');
      return;
    }
    final String soru = (d['soru'] ?? '').toString();
    final List<dynamic> cevaplar = (d['cevaplar'] ?? []) as List<dynamic>;
    final int cevapIndex = d['cevap'] is int
        ? d['cevap'] as int
        : int.tryParse('${d['cevap']}') ?? -1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Günün Sorusu'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(soru, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ...List.generate(cevaplar.length, (i) {
                  final String text = cevaplar[i] is Map<String, dynamic>
                      ? ((cevaplar[i] as Map<String, dynamic>)['metin'] ?? '')
                            .toString()
                      : cevaplar[i].toString();
                  final String letter = String.fromCharCode(
                    'A'.codeUnitAt(0) + i,
                  );
                  final bool isCorrect = i == cevapIndex;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.withOpacity(0.10) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCorrect
                            ? Colors.green.withOpacity(0.15)
                            : null,
                        foregroundColor: isCorrect ? Colors.green : null,
                        child: Text(letter),
                      ),
                      title: Text(text),
                      trailing: isCorrect
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First, get all available exams from Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('sorular')
          .get();
      final docs = snapshot.docs.map((e) => e.data()).toList();

      // Get unique exam dates
      final Map<String, Map<String, dynamic>> uniqueDates = {};
      for (final d in docs) {
        final int yil = d['yıl'] is int ? d['yıl'] as int : 0;
        final String ay = (d['ay'] ?? '').toString();
        final int gun = d['gün'] is int ? d['gün'] as int : 0;
        final key = '$gun|$ay|$yil';
        uniqueDates[key] = {'gün': gun, 'ay': ay, 'yıl': yil};
      }

      final dateItems = uniqueDates.values.toList();
      // Calculate totals
      int totalSolved = 0;
      int totalQuestions = 0;

      for (final item in dateItems) {
        final int yil = item['yıl'] as int;
        final String ay = item['ay'] as String;
        final int gun = item['gün'] as int;
        final examKey = 'y$yil-$ay-g$gun';

        // Count questions for this exam
        final examQuestions = docs
            .where((d) => d['yıl'] == yil && d['ay'] == ay && d['gün'] == gun)
            .length;

        totalQuestions += examQuestions;

        // Get solved count from SharedPreferences
        final solved = prefs.getInt('exam_solved_$examKey') ?? 0;
        totalSolved += solved;

        // We no longer track per-exam completion breakdown on the home header
      }

      setState(() {
        _totalQuestions = totalQuestions;
        _solvedQuestions = totalSolved;
        _passProbability = totalQuestions > 0
            ? (totalSolved / totalQuestions).clamp(0.0, 1.0)
            : 0.0;
      });
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _currentIndex == 0
            ? _buildAppTitle()
            : const Text(
                'Profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
            tooltip: 'Tema Değiştir',
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      drawerEnableOpenDragGesture: true,
      body: _currentIndex == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLiveLessonContactCard(),
                  const SizedBox(height: 16),
                  _buildSocialMediaSection(),
                  const SizedBox(height: 16),
                  _buildMainExamCard(),
                  const SizedBox(height: 16),
                  _buildDailyAndRandomExams(),
                  const SizedBox(height: 16),
                  _buildBottomCategoriesGrid(),
                ],
              ),
            )
          : ProfilePage(
              userName: _userName,
              passProbability: _passProbability,
              onNameChanged: (newName) {
                setState(() {
                  _userName = newName;
                });
              },
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF1F2A44), Color(0xFF2A2A2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'K',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: _passProbability,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.limeAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_solvedQuestions/$_totalQuestions soru',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${(_passProbability * 100).round()}% tamamlandı',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.2,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _showMessage('Instagram');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: ClipOval(
                                  child: Image.asset(
                                    'lib/assests/icons/instagram.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Instagram',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FavoriteQuestionsPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Favoriler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sıra: Duyurular, E-Sınav, Ders Videoları
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Duyurular'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('E-Sınav'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MebMapPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Ders Videoları'),
              onTap: () {
                Navigator.of(context).pop();
                _showMessage('Ders videoları yakında eklenecek.');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Gizlilik Şartları'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const PrivacyPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz_outlined),
              title: const Text('Sıkça Sorulan Sorular'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const FAQPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Favori Sorularım'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FavoriteQuestionsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Uygulamayı Paylaş'),
              onTap: () {
                Navigator.of(context).pop();
                _showMessage('Paylaşım özelliği yakında.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_outlined),
              title: const Text('Uygulamayı Puanla'),
              onTap: () {
                Navigator.of(context).pop();
                _showMessage('Puanlama özelliği yakında.');
              },
            ),
            const Spacer(),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Uygulama Hakkında'),
              onTap: () {
                Navigator.of(context).pop();
                showAboutDialog(
                  context: context,
                  applicationName: 'Trafik Koçu',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF90CAF9), const Color(0xFF42A5F5)]
          : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'lib/assests/logo/logo.jpeg',
            height: 24,
            width: 24,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (bounds) =>
              gradient.createShader(Offset.zero & bounds.size),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Trafik Koçu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLiveLessonContactCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const String maleInstructorName = 'Hakim Hoca';
    const String femaleInstructorName = 'Ece Hoca';
    // Update these numbers with country code, without leading + or 00
    const String maleInstructorPhone = '905555555555';
    const String femaleInstructorPhone = '905555555556';

    Future<void> openWhatsApp(String phone, String name) async {
      final message =
          'Merhaba $name, Trafik Koçu uygulamasından canlı/özel ders talep ediyorum.';
      final uri = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
      );
      final deep = Uri.parse(
        'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(deep)) {
        final ok = await launchUrl(deep, mode: LaunchMode.externalApplication);
        if (ok) return;
      }
      if (await canLaunchUrl(uri)) {
        final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (ok) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp açılamadı. Lütfen gerçek cihazda deneyin.'),
        ),
      );
    }

    Widget person({
      required String assetPath,
      required String name,
      required String phone,
    }) {
      final ValueNotifier<double> scale = ValueNotifier<double>(1.0);
      final ValueNotifier<bool> hovered = ValueNotifier<bool>(false);
      return Expanded(
        child: MouseRegion(
          onEnter: (_) {
            hovered.value = true;
            scale.value = 1.03;
          },
          onExit: (_) {
            hovered.value = false;
            scale.value = 1.0;
          },
          child: GestureDetector(
            onTapDown: (_) => scale.value = 0.97,
            onTapCancel: () => scale.value = hovered.value ? 1.03 : 1.0,
            onTapUp: (_) => scale.value = hovered.value ? 1.03 : 1.0,
            onTap: () => openWhatsApp(phone, name),
            child: ValueListenableBuilder<double>(
              valueListenable: scale,
              builder: (context, s, _) {
                return AnimatedScale(
                  scale: s,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: hovered,
                    builder: (context, h, __) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF20262F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      h ? 0.10 : 0.06,
                                    ),
                                    blurRadius: h ? 22 : 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  assetPath,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () => openWhatsApp(phone, name),
                                icon: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Image.asset(
                                    'lib/assests/logo/whatsapp.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                label: const Text('WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                  Color(0xFF3B0764),
                ],
                stops: [0.0, 0.55, 1.0],
                begin: Alignment(-0.9, -1.0),
                end: Alignment(0.9, 1.0),
              )
            : const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFFE879F9),
                  Color(0xFFFB7185),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment(-1.0, -0.8),
                end: Alignment(1.0, 0.8),
              ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.video_call_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Uzman Eğitmenlerle Birebir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Eğitmenlerimizle WhatsApp üzerinden anında iletişim kurun',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                person(
                  assetPath: 'lib/assests/ManWoman/man.png',
                  name: maleInstructorName,
                  phone: maleInstructorPhone,
                ),
                const SizedBox(width: 12),
                person(
                  assetPath: 'lib/assests/ManWoman/woman.png',
                  name: femaleInstructorName,
                  phone: femaleInstructorPhone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
            );
          },
          child: _buildActionChip(Icons.campaign, 'Duyurular', chipBg),
        ),
        const SizedBox(width: 8),
        _buildActionChipImage(
          'lib/assests/icons/instagram.png',
          'Instagram',
          chipBg,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoriteQuestionsPage()),
            );
          },
          child: _buildActionChip(Icons.star, 'Favoriler', chipBg),
        ),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color bg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionChipImage(String asset, String label, Color bg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMainExamCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                'lib/assests/icons/question.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Çıkmış Sınav Soruları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gerçek sınav formatında sorularla hazırlanın',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AllQuestionsPage(
                    onProgressUpdated: () {
                      // Refresh home page progress when quiz progress is updated
                      _loadProgress();
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Başla'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAndRandomExams() {
    return Column(
      children: [
        _buildTodayExamCard(),
        const SizedBox(height: 12),
        _buildRandomExamCard(),
      ],
    );
  }

  Widget _buildTodayExamCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final data = await _getDailyQuestionData();
        if (!mounted) return;
        if (data.isEmpty) {
          _showMessage('Günün sorusu yüklenemedi.');
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DailyQuestionPage(data: data)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'lib/assests/icons/today_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Günün Sorusu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Her gün değişen rastgele soru',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomExamCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'lib/assests/icons/random_signal.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rastgele Sınav',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Karışık sorularla kendini test et',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white : Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCategoriesGrid() {
    final bottomCategories = [
      CategoryItem(
        title: 'Trafik ve Çevre Bilgisi',
        subtitle: 'kategori=Trafik ve Çevre Bilgisi',
        icon: Icons.traffic,
        color: Colors.red,
      ),
      CategoryItem(
        title: 'İlk Yardım Bilgisi',
        subtitle: 'kategori=İlk Yardım Bilgisi',
        icon: Icons.medical_services,
        color: Colors.orange,
      ),
      CategoryItem(
        title: 'Araç Teknik',
        subtitle: 'kategori=Araç Tekniği (Motor ve Araç Bakımı)',
        icon: Icons.build,
        color: Colors.blue,
      ),
      CategoryItem(
        title: 'Trafik Adabı',
        subtitle: 'kategori=Trafik Adabı',
        icon: Icons.handshake,
        color: Colors.purple,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3 / 2,
      children: bottomCategories
          .map((category) => _buildBottomCategoryCard(category))
          .toList(),
    );
  }

  Widget _buildBottomCategoryCard(CategoryItem category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        // subtitle encodes the kategori name
        final String kategori = category.subtitle.replaceFirst('kategori=', '');
        final int count = _inferCountFromTitle(category.title);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RandomCategoryQuizPage(
              title: category.title,
              kategori: kategori,
              questionCount: count,
            ),
          ),
        );
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: category.title == 'Polis İşaretleri'
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'lib/assests/icons/police_icon.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : category.title == 'Levhalar'
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'lib/assests/icons/traffic_icon.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : category.title == 'Hız Kuralları'
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'lib/assests/icons/speed_meter_icon.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : category.title == 'Dersler'
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'lib/assests/icons/lessons_icon.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : Icon(category.icon, color: Colors.white, size: 20),
            ),
            Column(
              children: [
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (category.subtitle.startsWith('kategori='))
                  Text(
                    category.subtitle.replaceFirst('kategori=', ''),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

int _inferCountFromTitle(String title) {
  // If title contains explicit count like "23 soru" parse it; otherwise map defaults
  final match = RegExp(r'(\d+)\s*soru').firstMatch(title);
  if (match != null) {
    return int.tryParse(match.group(1)!) ?? 10;
  }
  switch (title) {
    case 'Trafik ve Çevre Bilgisi':
      return 23;
    case 'İlk Yardım Bilgisi':
      return 12;
    case 'Araç Teknik':
    case 'Araç Tekniği (Motor ve Araç Bakımı)':
      return 9;
    case 'Trafik Adabı':
      return 6;
    default:
      return 10;
  }
}
