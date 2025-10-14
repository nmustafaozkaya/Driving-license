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
      appBar: AppBar(title: const Text('Rastgele Tüm Sorular')),
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
                'Rastgele sınav soruları özelliği Firebase\'e bağımlı olduğu için geçici olarak devre dışı bırakıldı.',
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
