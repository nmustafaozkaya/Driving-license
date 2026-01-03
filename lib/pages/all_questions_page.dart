import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';
import 'quiz_questions_page.dart';

class AllQuestionsPage extends StatefulWidget {
  final VoidCallback? onProgressUpdated;
  final bool isLatestExam;
  final Map<String, dynamic>? latestExamData;

  const AllQuestionsPage({
    super.key,
    this.onProgressUpdated,
    this.isLatestExam = false,
    this.latestExamData,
  });

  @override
  State<AllQuestionsPage> createState() => _AllQuestionsPageState();
}

class _AllQuestionsPageState extends State<AllQuestionsPage> {
  int? _selectedYear;
  String? _selectedMonth;
  int? _selectedDay;
  Map<String, ExamProgress> _examProgress = {};

  static const Map<String, int> monthIndexTr = {
    'Ocak': 1,
    'Şubat': 2,
    'Mart': 3,
    'Nisan': 4,
    'Mayıs': 5,
    'Haziran': 6,
    'Temmuz': 7,
    'Ağustos': 8,
    'Eylül': 9,
    'Ekim': 10,
    'Kasım': 11,
    'Aralık': 12,
  };

  static const Map<String, int> monthIndexEn = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  Map<String, int> get _monthIndex {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale.languageCode == 'en'
        ? monthIndexEn
        : monthIndexTr;
  }

  @override
  void initState() {
    super.initState();
    _loadExamProgress();
  }

  Future<void> _loadExamProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = <String, ExamProgress>{};

      // Load all exam progress data
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('exam_total_')) {
          final examKey = key.substring('exam_total_'.length);
          final total = prefs.getInt(key) ?? 0;
          final solved = prefs.getInt('exam_solved_$examKey') ?? 0;
          progressMap[examKey] = ExamProgress(total: total, solved: solved);
        }
      }

      setState(() {
        _examProgress = progressMap;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  String _getExamKey(int yil, String ay, int gun) {
    return 'y$yil-$ay-g$gun';
  }

  ExamProgress _getExamProgress(int yil, String ay, int gun) {
    final key = _getExamKey(yil, ay, gun);
    return _examProgress[key] ?? ExamProgress(total: 0, solved: 0);
  }

  String _getStatusText(ExamProgress progress, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (progress.total == 0) {
      return localizations?.notSolved ?? 'Çözülmedi';
    }
    if (progress.solved == 0) {
      return localizations?.notSolved ?? 'Çözülmedi';
    }
    if (progress.solved == progress.total) {
      return localizations?.solved ?? 'Çözüldü';
    }
    return localizations?.continueExam ?? 'Devam Et';
  }

  Color _getStatusColor(ExamProgress progress) {
    if (progress.total == 0) return Colors.grey;
    if (progress.solved == 0) return Colors.red;
    if (progress.solved == progress.total) return Colors.green;
    return Colors.orange;
  }

  void _showYearSheet(BuildContext context, List<int> years) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BottomSheetSelector<int?>(
        title: localizations?.selectYear ?? 'Yıl Seç',
        items: [null, ...years],
        itemLabel: (v) => v == null ? (localizations?.all ?? 'Hepsi') : '$v',
        onSelected: (v) => setState(() {
          _selectedYear = v;
          _selectedMonth = null;
          _selectedDay = null;
        }),
      ),
    );
  }

  void _showMonthSheet(BuildContext context, List<String> months) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BottomSheetSelector<String?>(
        title: localizations?.selectMonth ?? 'Ay Seç',
        items: [null, ...months],
        itemLabel: (v) => v ?? (localizations?.all ?? 'Hepsi'),
        onSelected: (v) => setState(() {
          _selectedMonth = v;
          _selectedDay = null;
        }),
      ),
    );
  }

  void _showDaySheet(BuildContext context, List<int> days) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BottomSheetSelector<int?>(
        title: localizations?.selectDay ?? 'Gün Seç',
        items: [null, ...days],
        itemLabel: (v) => v == null ? (localizations?.all ?? 'Hepsi') : '$v',
        onSelected: (v) => setState(() => _selectedDay = v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final languageCode = localeProvider.locale.languageCode;
    final collectionName = languageCode == 'en' ? 'en_sorular' : 'tr_sorular';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(localizations?.allQuestions ?? 'SINAV SORULARI'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dil değiştirme uyarısı
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.orange.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations?.languageChangeWarning ??
                            'Dil değiştirmek soruları da değiştirecektir.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(collectionName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      localizations?.noQuestionsFound ?? 'Soru bulunamadı',
                    ),
                  );
                }

                final docs = snapshot.data!.docs.map((e) => e.data()).toList();

                // Debug: Firestore'dan kaç belge çekildiğini log'la
                developer.log(
                  'Firestore: $collectionName koleksiyonundan ${docs.length} belge çekildi',
                  name: 'AllQuestionsPage',
                );

                final Map<String, Map<String, dynamic>> uniqueDates = {};
                for (final d in docs) {
                  final int yil = d['yıl'] is int ? d['yıl'] as int : 0;
                  final String ay = (d['ay'] ?? '').toString();
                  final int gun = d['gün'] is int ? d['gün'] as int : 0;
                  final key = '$gun|$ay|$yil';
                  uniqueDates[key] = {'gün': gun, 'ay': ay, 'yıl': yil};
                }

                // Debug: Kaç benzersiz tarih bulundu
                developer.log(
                  'Toplam ${uniqueDates.length} benzersiz sınav tarihi bulundu',
                  name: 'AllQuestionsPage',
                );

                final dateItems = uniqueDates.values.toList();

                // Options for filters
                final years =
                    (dateItems.map((e) => e['yıl'] as int).toSet().toList()
                      ..sort());
                final months =
                    (dateItems
                        .where(
                          (e) =>
                              _selectedYear == null ||
                              e['yıl'] == _selectedYear,
                        )
                        .map((e) => e['ay'] as String)
                        .toSet()
                        .toList()
                      ..sort((a, b) {
                        final monthIndex = _monthIndex;
                        return (monthIndex[a] ?? 0).compareTo(
                          monthIndex[b] ?? 0,
                        );
                      }));
                final days =
                    (dateItems
                        .where(
                          (e) =>
                              (_selectedYear == null ||
                                  e['yıl'] == _selectedYear) &&
                              (_selectedMonth == null ||
                                  e['ay'] == _selectedMonth),
                        )
                        .map((e) => e['gün'] as int)
                        .toSet()
                        .toList()
                      ..sort());

                // Apply filters
                final filtered =
                    dateItems.where((e) {
                      final bool yOk =
                          _selectedYear == null || e['yıl'] == _selectedYear;
                      final bool mOk =
                          _selectedMonth == null || e['ay'] == _selectedMonth;
                      final bool dOk =
                          _selectedDay == null || e['gün'] == _selectedDay;
                      return yOk && mOk && dOk;
                    }).toList()..sort((a, b) {
                      final int da = (a['gün'] ?? 0) as int;
                      final int db = (b['gün'] ?? 0) as int;
                      final monthIndex = _monthIndex;
                      final int ma = monthIndex[(a['ay'] ?? '') as String] ?? 0;
                      final int mb = monthIndex[(b['ay'] ?? '') as String] ?? 0;
                      final int ya = (a['yıl'] ?? 0) as int;
                      final int yb = (b['yıl'] ?? 0) as int;
                      // En güncel tarih en üste: önce yıl, sonra ay, sonra gün (azalan sıralama)
                      final cy = yb.compareTo(ya);
                      if (cy != 0) return cy;
                      final ca = mb.compareTo(ma);
                      if (ca != 0) return ca;
                      return db.compareTo(da);
                    });

                return Column(
                  children: [
                    // Modern filtre barı – kaydırılabilir pill butonlar ve alt sayfa seçimleri
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterPill(
                                label:
                                    _selectedYear?.toString() ??
                                    '${localizations?.year ?? 'Yıl'}: ${localizations?.all ?? 'Hepsi'}',
                                icon: Icons.calendar_today,
                                onTap: () => _showYearSheet(context, years),
                              ),
                              const SizedBox(width: 8),
                              _FilterPill(
                                label:
                                    _selectedMonth ??
                                    '${localizations?.month ?? 'Ay'}: ${localizations?.all ?? 'Hepsi'}',
                                icon: Icons.date_range,
                                onTap: () => _showMonthSheet(context, months),
                              ),
                              const SizedBox(width: 8),
                              _FilterPill(
                                label:
                                    _selectedDay?.toString() ??
                                    '${localizations?.day ?? 'Gün'}: ${localizations?.all ?? 'Hepsi'}',
                                icon: Icons.event,
                                onTap: () => _showDaySheet(context, days),
                              ),
                              const SizedBox(width: 8),
                              if (_selectedYear != null ||
                                  _selectedMonth != null ||
                                  _selectedDay != null)
                                _FilterPill(
                                  label: localizations?.clear ?? 'Temizle',
                                  icon: Icons.clear,
                                  onTap: () => setState(() {
                                    _selectedYear = null;
                                    _selectedMonth = null;
                                    _selectedDay = null;
                                  }),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 0),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          final item = filtered[index];
                          final int yil = item['yıl'] as int;
                          final String ay = item['ay'] as String;
                          final int gun = item['gün'] as int;
                          final progress = _getExamProgress(yil, ay, gun);
                          final statusText = _getStatusText(progress, context);
                          final statusColor = _getStatusColor(progress);
                          final progressPercentage = progress.total > 0
                              ? (progress.solved / progress.total)
                              : 0.0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => QuizQuestionsPage(
                                        yil: yil,
                                        ay: ay,
                                        gun: gun,
                                      ),
                                    ),
                                  )
                                  .then((_) {
                                    // Refresh progress when returning from quiz
                                    _loadExamProgress();
                                    // Notify parent to refresh home page progress
                                    widget.onProgressUpdated?.call();
                                  });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.lightBlue[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          languageCode == 'en'
                                              ? '$gun $ay $yil Exam Questions Dated'
                                              : '$gun $ay $yil Tarihli Sınav Soruları',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: statusColor.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (progress.total > 0) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                languageCode == 'en'
                                                    ? 'Progress: ${progress.solved}/${progress.total}'
                                                    : 'İlerleme: ${progress.solved}/${progress.total}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: progressPercentage,
                                                  minHeight: 6,
                                                  backgroundColor: isDark
                                                      ? Colors.white10
                                                      : Colors.grey[300],
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(statusColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${(progressPercentage * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white10 : Colors.grey[100],
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetSelector<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onSelected;

  const _BottomSheetSelector({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(height: 0),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final v = items[index];
                return ListTile(
                  title: Text(itemLabel(v)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(v);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExamProgress {
  final int total;
  final int solved;

  ExamProgress({required this.total, required this.solved});
}
