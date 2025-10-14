import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Not: toplam soru sayısını hesaplayıp ana ekrana göstermek için istenirse SharedPreferences'a yazabiliriz.
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: const Text('ÇIKMIŞ SINAV SORULARI'),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Firebase Bağlantısı Kaldırıldı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Çıkmış sınav soruları özelliği Firebase\'e bağımlı olduğu için geçici olarak devre dışı bırakıldı. Bu özellik için yerel veri depolama veya alternatif bir API entegrasyonu gerekli.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
