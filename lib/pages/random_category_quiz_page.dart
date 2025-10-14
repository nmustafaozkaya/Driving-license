import 'package:flutter/material.dart';

class RandomCategoryQuizPage extends StatefulWidget {
  final String title;
  final String kategori;
  final int questionCount;

  const RandomCategoryQuizPage({
    super.key,
    required this.title,
    required this.kategori,
    required this.questionCount,
  });

  @override
  State<RandomCategoryQuizPage> createState() => _RandomCategoryQuizPageState();
}

class _RandomCategoryQuizPageState extends State<RandomCategoryQuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                'Kategori sınav soruları özelliği Firebase\'e bağımlı olduğu için geçici olarak devre dışı bırakıldı.',
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
