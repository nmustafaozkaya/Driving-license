import 'package:flutter/material.dart';
import 'dart:async';
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

          return _QuestionFlow(docs: docs);
        },
      ),
    );
  }
}

class _QuestionFlow extends StatefulWidget {
  final List<Map<String, dynamic>> docs;
  const _QuestionFlow({required this.docs});

  @override
  State<_QuestionFlow> createState() => _QuestionFlowState();
}

class _QuestionFlowState extends State<_QuestionFlow> {
  int _index = 0;
  int? _selectedOption;
  bool _locked = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  Duration _remaining = const Duration(minutes: 45);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    if (_index < widget.docs.length - 1) {
      setState(() {
        _index++;
        _selectedOption = null;
        _locked = false;
      });
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() {
        _index--;
        _selectedOption = null;
        _locked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.docs[_index];
    final String soru = (d['soru'] ?? '').toString();
    final List<dynamic> secenekler = (d['cevaplar'] ?? []) as List<dynamic>;
    final int cevapIndex = d['cevap'] is int
        ? d['cevap'] as int
        : int.tryParse('${d['cevap']}') ?? -1;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = widget.docs.length;
    final progress = (_index + 1) / total;
    String two(int n) => n.toString().padLeft(2, '0');
    final timerText = '${two(_remaining.inMinutes.remainder(60))}:${two(_remaining.inSeconds.remainder(60))}';

    return Column(
      children: [
        // Top status row
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Text('(${_index + 1}/$total) Kalan', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text('$_correctCount', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                child: Row(children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text('$_wrongCount', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                ]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                child: Text(timerText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (Theme.of(context).brightness != Brightness.dark)
                        BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    soru,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(secenekler.length, (i) {
                  final bool isSelected = _selectedOption == i;
                  final bool isCorrect = i == cevapIndex;
                  Color? tileColor;
                  Color borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
                  IconData? leadingIcon;

                  if (_locked) {
                    if (isCorrect) {
                      tileColor = Colors.green.withOpacity(0.12);
                      borderColor = Colors.green;
                      leadingIcon = Icons.check_circle;
                    } else if (isSelected && !isCorrect) {
                      tileColor = Colors.red.withOpacity(0.12);
                      borderColor = Colors.red;
                      leadingIcon = Icons.cancel;
                    }
                  } else if (isSelected) {
                    tileColor = (isDark ? Colors.white : Colors.black).withOpacity(0.06);
                  }

                  final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2),
                          color: leadingIcon != null
                              ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.15)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: leadingIcon != null
                                ? (isCorrect ? Colors.green : Colors.red)
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      title: Text('${secenekler[i]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      onTap: () {
                        if (_locked) return;
                        final tappedCorrect = i == cevapIndex;
                        setState(() {
                          _selectedOption = i;
                          _locked = true;
                          if (tappedCorrect) {
                            _correctCount++;
                          } else {
                            _wrongCount++;
                          }
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _index > 0 ? _prev : null,
                  icon: const Icon(Icons.navigate_before),
                  label: const Text('Önceki'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Bitir'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _index < widget.docs.length - 1 ? _next : null,
                  icon: const Icon(Icons.navigate_next),
                  label: const Text('Sonraki'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
