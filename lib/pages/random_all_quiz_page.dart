import 'package:flutter/material.dart';

class RandomAllQuizPage extends StatefulWidget {
  const RandomAllQuizPage({super.key});

  @override
  State<RandomAllQuizPage> createState() => _RandomAllQuizPageState();
}

class _RandomAllQuizPageState extends State<RandomAllQuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastgele Tüm Sorular'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shuffle, size: 64, color: Colors.grey[400]),
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
