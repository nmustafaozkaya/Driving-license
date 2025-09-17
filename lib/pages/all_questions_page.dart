import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_questions_page.dart';

class AllQuestionsPage extends StatefulWidget {
  const AllQuestionsPage({super.key});

  @override
  State<AllQuestionsPage> createState() => _AllQuestionsPageState();
}

class _AllQuestionsPageState extends State<AllQuestionsPage> {
  int? _selectedYear;
  String? _selectedMonth;
  int? _selectedDay;

  final List<String> _aylar = const [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const Map<String, int> monthIndex = {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çıkmış Sınav Soruları')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('sorular').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Soru bulunamadı'));
          }

          final docs = snapshot.data!.docs.map((e) => e.data()).toList();

          final Map<String, Map<String, dynamic>> uniqueDates = {};
          for (final d in docs) {
            final int yil = d['yıl'] is int ? d['yıl'] as int : 0;
            final String ay = (d['ay'] ?? '').toString();
            final int gun = d['gün'] is int ? d['gün'] as int : 0;
            final key = '$gun|$ay|$yil';
            uniqueDates[key] = {'gün': gun, 'ay': ay, 'yıl': yil};
          }

          final dateItems = uniqueDates.values.toList();

          // Options for filters
          final years = (dateItems.map((e) => e['yıl'] as int).toSet().toList()
            ..sort());
          final months =
              (dateItems
                  .where(
                    (e) => _selectedYear == null || e['yıl'] == _selectedYear,
                  )
                  .map((e) => e['ay'] as String)
                  .toSet()
                  .toList()
                ..sort((a, b) => monthIndex[a]!.compareTo(monthIndex[b]!)));
          final days =
              (dateItems
                  .where(
                    (e) =>
                        (_selectedYear == null || e['yıl'] == _selectedYear) &&
                        (_selectedMonth == null || e['ay'] == _selectedMonth),
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
                final int ma = monthIndex[(a['ay'] ?? '') as String] ?? 0;
                final int mb = monthIndex[(b['ay'] ?? '') as String] ?? 0;
                final int ya = (a['yıl'] ?? 0) as int;
                final int yb = (b['yıl'] ?? 0) as int;
                final cg = da.compareTo(db);
                if (cg != 0) return cg;
                final ca = ma.compareTo(mb);
                if (ca != 0) return ca;
                return ya.compareTo(yb);
              });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(labelText: 'Yıl'),
                        value: _selectedYear,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Hepsi'),
                          ),
                          ...years.map(
                            (y) => DropdownMenuItem<int?>(
                              value: y,
                              child: Text('$y'),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _selectedYear = v;
                          _selectedMonth = null;
                          _selectedDay = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(labelText: 'Ay'),
                        value: _selectedMonth,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Hepsi'),
                          ),
                          ...months.map(
                            (m) => DropdownMenuItem<String?>(
                              value: m,
                              child: Text(m),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _selectedMonth = v;
                          _selectedDay = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(labelText: 'Gün'),
                        value: _selectedDay,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Hepsi'),
                          ),
                          ...days.map(
                            (g) => DropdownMenuItem<int?>(
                              value: g,
                              child: Text('$g'),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedDay = v),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final int yil = item['yıl'] as int;
                    final String ay = item['ay'] as String;
                    final int gun = item['gün'] as int;

                    return ListTile(
                      title: Text('$gun $ay $yil'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                QuizQuestionsPage(yil: yil, ay: ay, gun: gun),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
