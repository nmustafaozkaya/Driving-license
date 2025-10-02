import 'package:flutter/material.dart';

class PoliceIsaretleriPage extends StatelessWidget {
  const PoliceIsaretleriPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Polis işaretleri listesi
    final policeSigns = [
      PoliceSign(
        name: 'Polis İşareti 1',
        description: 'Bir kırmızı fazda trafiğin çekilmesi işareti.',
        imagePath: 'lib/assests/police/1.jpg',
        color: Colors.red,
      ),
      PoliceSign(
        name: 'Polis İşareti 2',
        description: 'Araç durdurma işareti sağa doğru.',
        imagePath: 'lib/assests/police/2.jpg',
        color: Colors.blue,
      ),
      PoliceSign(
        name: 'Polis İşareti 3',
        description: 'Araç durdurma işareti sola doğru.',
        imagePath: 'lib/assests/police/3.jpg',
        color: Colors.green,
      ),
      PoliceSign(
        name: 'Polis İşareti 4',
        description:
            'Ön ve arka taraftaki trafik duracak her iki kol yönündeki trafik hareket edebilir.',
        imagePath: 'lib/assests/police/4.jpg',
        color: Colors.orange,
      ),
      PoliceSign(
        name: 'Polis İşareti 5',
        description:
            'Ön ve arka taraftaki trafik duracak her iki kol yönündeki trafik hareket edebilir',
        imagePath: 'lib/assests/police/5.jpg',
        color: Colors.purple,
      ),
      PoliceSign(
        name: 'Polis İşareti 6',
        description: 'Sağ taraftaki trafik sola gidebilir.',
        imagePath: 'lib/assests/police/6.jpg',
        color: Colors.teal,
      ),
      PoliceSign(
        name: 'Polis İşareti 7',
        description: 'Sol taraftaki trafik sağa gidebilir.',
        imagePath: 'lib/assests/police/7.jpg',
        color: Colors.amber,
      ),
      PoliceSign(
        name: 'Polis İşareti 8',
        description: 'Trafğin bütün istikametlere kapatılması sağ kol.	',
        imagePath: 'lib/assests/police/8.jpg',
        color: Colors.cyan,
      ),
      PoliceSign(
        name: 'Polis İşareti 9',
        description: 'Trafğin bütün istikametlere kapatılması sol kol.',
        imagePath: 'lib/assests/police/9.jpg',
        color: Colors.indigo,
      ),
      PoliceSign(
        name: 'Polis İşareti 10',
        description: 'Trafiği hızlandırma hareketi sol kol.',
        imagePath: 'lib/assests/police/10.jpg',
        color: Colors.teal,
      ),
      PoliceSign(
        name: 'Polis İşareti 11',
        description: 'Trafiği yavaşlatma hareketi sağ kol.',
        imagePath: 'lib/assests/police/11.jpg',
        color: Colors.deepOrange,
      ),
      PoliceSign(
        name: 'Polis İşareti 12',
        description: 'Gece dönüş işareti.',
        imagePath: 'lib/assests/police/12.jpg',
        color: Colors.deepPurple,
      ),
      PoliceSign(
        name: 'Polis İşareti 13',
        description: 'Gece geç işareti.',
        imagePath: 'lib/assests/police/13.jpg',
        color: Colors.lime,
      ),
      PoliceSign(
        name: 'Polis İşareti 14',
        description: 'Gece dur işareti.',
        imagePath: 'lib/assests/police/14.jpg',
        color: Colors.pink,
      ),
      PoliceSign(
        name: 'Polis İşareti 15',
        description: 'Yön tayini sağa işareti.',
        imagePath: 'lib/assests/police/15.jpg',
        color: Colors.brown,
      ),
      PoliceSign(
        name: 'Polis İşareti 16',
        description: 'Yön tayini sola işareti.',
        imagePath: 'lib/assests/police/16.jpg',
        color: Colors.grey,
      ),
      PoliceSign(
        name: 'Polis İşareti 17',
        description: 'Kırmızı ışıkta trafği çekme işareti.',
        imagePath: 'lib/assests/police/17.jpg',
        color: Colors.blueGrey,
      ),
      PoliceSign(
        name: 'Polis İşareti 18',
        description: 'Trafik akımını kesme işareti.',
        imagePath: 'lib/assests/police/18.jpg',
        color: Colors.redAccent,
      ),
      PoliceSign(
        name: 'Polis İşareti 19',
        description: 'Trafik akımının trafik ışıklarına bırakılması işareti.',
        imagePath: 'lib/assests/police/19.jpg',
        color: Colors.greenAccent,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Polis İşaretleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Icon(Icons.local_police, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Polis İşaretleri Rehberi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trafik polislerinin kullandığı el işaretlerini öğrenin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Önemli notlar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Önemli Notlar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Polis işaretleri trafik kurallarının üstündedir.\n'
                    '• İşaretlere mutlaka uyun!\n'
                    '• Belirsizlik durumunda polise sorun!\n'
                    '• İşaretleri takip etmek zorunludur.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // İşaretler listesi
            Text(
              'Polis İşaretleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: policeSigns.length,
              itemBuilder: (context, index) {
                return _buildPoliceSignCard(
                  context,
                  policeSigns[index],
                  isDark,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliceSignCard(
    BuildContext context,
    PoliceSign sign,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tek resim
            Center(
              child: Container(
                width: 200,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    sign.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: sign.color.withOpacity(0.1),
                        child: Icon(
                          Icons.local_police,
                          color: sign.color,
                          size: 80,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Başlık
            Text(
              sign.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Açıklama
            Text(
              sign.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PoliceSign {
  final String name;
  final String description;
  final String imagePath;
  final Color color;

  PoliceSign({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}
