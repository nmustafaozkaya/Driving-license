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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Özel Ders – Premium Deneyim',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber[600],
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Premium',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    headerText ??
                        'Bu bölüm, özel ders talebinde bulunmak isteyen kullanıcılarımız için hazırlanmıştır. Sayfanın alt kısmında yer alan ‘WhatsApp’tan Ulaşın’ butonuna tıkladığınızda, WhatsApp uygulamanız üzerinden profesyonel koçlarmıza otomatik bir mesaj gönderilir. Bu mesaj, özel ders almak istediğinizi bildirir ve doğrudan iletişime geçmenizi sağlar. Böylece ek bir işlem yapmadan hızlı ve güvenli şekilde özel ders talebinizi iletebilirsiniz',
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
            ElevatedButton.icon(
              onPressed: () async {
                final phone = '+905415619802';
                final text = 'Merhaba, Trafik Koçu uygulamasından özel ders talep ediyorum.';
                final waDeepLink = Uri.parse('whatsapp://send?phone=${phone.replaceAll('+', '')}&text=${Uri.encodeComponent(text)}');
                final waWeb = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}?text=${Uri.encodeComponent(text)}');

                // 1) WhatsApp yüklüyse derin link
                if (await canLaunchUrl(waDeepLink)) {
                  final ok = await launchUrl(waDeepLink, mode: LaunchMode.externalApplication);
                  if (ok) return;
                }
                // 2) Web fallback (emülatör veya WhatsApp yüklü değilse)
                if (await canLaunchUrl(waWeb)) {
                  final ok = await launchUrl(waWeb, mode: LaunchMode.platformDefault);
                  if (ok) return;
                }
                // 3) Son çare: bilgilendir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('WhatsApp veya tarayıcı açılamadı. Lütfen gerçek cihazda deneyin.')),
                );
              },
              icon: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  'lib/assests/logo/whatsapp.png',
                  fit: BoxFit.contain,
                ),
              ),
              label: const Text('WhatsApp’tan Ulaşın'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF25D366), width: 1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


