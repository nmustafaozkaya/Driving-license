import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveLessonPage extends StatelessWidget {
  final String? headerText;

  const LiveLessonPage({super.key, this.headerText});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Ders'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Özel Ders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber[600]!, Colors.amber[300]!],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    headerText ?? 'Profesyonel eğitmenlerimize WhatsApp üzerinden hızla ulaşın.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InstructorCard(name: 'Abdulhakim Hoca'),
            const SizedBox(height: 12),
            _InstructorCard(name: 'Tuğçe Hoca'),
          ],
        ),
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  final String name;
  const _InstructorCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.amber[700],
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'E',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'WhatsApp üzerinden hızlıca iletişime geçin.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: ElevatedButton.icon(
              onPressed: () async {
              final text = 'Merhaba, Trafik Koçu uygulamasından özel ders talep ediyorum.';
              final deepLink = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
              final webLink = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
              if (await canLaunchUrl(deepLink)) {
                final ok = await launchUrl(deepLink, mode: LaunchMode.externalApplication);
                if (ok) return;
              }
              if (await canLaunchUrl(webLink)) {
                final ok = await launchUrl(webLink, mode: LaunchMode.platformDefault);
                if (ok) return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('WhatsApp açılamadı. Lütfen gerçek cihazda deneyin.')),
              );
              },
              icon: SizedBox(
                width: 16,
                height: 16,
                child: Image.asset('lib/assests/logo/whatsapp.png', fit: BoxFit.contain),
              ),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366), width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                minimumSize: const Size(0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


