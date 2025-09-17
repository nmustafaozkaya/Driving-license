import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Firestore',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DatePickerPage(),
    );
  }
}

// 📅 Tarih Seçme Sayfası
class DatePickerPage extends StatefulWidget {
  const DatePickerPage({super.key});

  @override
  State<DatePickerPage> createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> {
  DateTime? _selectedDate;

  final _aylar = const [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _goToQuestions() {
    if (_selectedDate == null) return;

    final yil = _selectedDate!.year;
    final ay = _aylar[_selectedDate!.month - 1];
    final gun = _selectedDate!.day;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizQuestionsPage(yil: yil, ay: ay, gun: gun),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tarih Seç")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedDate == null
                  ? "Henüz tarih seçilmedi"
                  : DateFormat("d MMMM yyyy", "tr_TR").format(_selectedDate!),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDate,
              child: const Text("Tarih Seç"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _goToQuestions,
              child: const Text("Sorulara Git"),
            ),
          ],
        ),
      ),
    );
  }
}

// ❓ Soru Listesi Sayfası
class QuizQuestionsPage extends StatefulWidget {
  final int yil;
  final String ay;
  final int gun;

  const QuizQuestionsPage({
    super.key,
    required this.yil,
    required this.ay,
    required this.gun,
  });

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  Query<Map<String, dynamic>> _query() {
    return FirebaseFirestore.instance
        .collection('sorular')
        .where('yıl', isEqualTo: widget.yil)
        .where('ay', isEqualTo: widget.ay)
        .where('gün', isEqualTo: widget.gun);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sorular: ${widget.gun} ${widget.ay} ${widget.yil}'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Soru bulunamadı'));
          }

          final docs = snapshot.data!.docs.map((e) => e.data()).toList();

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final String soru = (d['soru'] ?? '').toString();
              final List<dynamic> secenekler =
                  (d['cevaplar'] ?? []) as List<dynamic>;
              final int cevapIndex = d['cevap'] is int
                  ? d['cevap'] as int
                  : int.tryParse('${d['cevap']}') ?? -1;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        soru,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(secenekler.length, (i) {
                        return ListTile(
                          title: Text('${secenekler[i]}'),
                          onTap: () {
                            final correct = i == cevapIndex;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(correct ? 'Doğru ✅' : 'Yanlış ❌'),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
