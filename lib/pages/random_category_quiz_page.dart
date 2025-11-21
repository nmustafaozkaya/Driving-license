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
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Özellik yakında eklenecek',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Firebase bağlantısı yakında eklenecek.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
