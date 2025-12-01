import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final languageCode = localeProvider.locale.languageCode;

    final privacyData = languageCode == 'en'
        ? {
            'title': 'Privacy Policy',
            'sections': [
              {
                'icon': Icons.privacy_tip,
                'title': 'Privacy Policy',
                'content':
                    'The Driving License app processes minimal data to improve user experience and provide basic functions. '
                    'Collected data is used only for app operation, storing user progress, and basic analytics. '
                    'Data is processed in accordance with law and honesty rules; limited to purpose, measured and transparent.',
              },
              {
                'icon': Icons.storage_rounded,
                'title': 'Data Usage',
                'content':
                    'The app may store local device data such as solved questions, success percentage, and theme preferences. '
                    'This information is used to show progress on your profile and provide a personalized experience. '
                    'None of your personal data is shared with third parties without your explicit consent.',
              },
              {
                'icon': Icons.security_rounded,
                'title': 'Data Security',
                'content':
                    'Data security is considered at every stage of design. '
                    'Locally stored information is protected by security measures provided by the operating system. '
                    'For redirects to external services (e.g., YouTube), the relevant platform\'s privacy and security policies apply.',
              },
              {
                'icon': Icons.balance,
                'title': 'User Rights',
                'content':
                    'Users have the right to access, correct, delete, and restrict processing of their data. '
                    'You can manage your in-app profile information. '
                    'You can reach us through the app or the store page for privacy-related questions or requests.',
              },
            ],
          }
        : {
            'title': 'Gizlilik Şartları',
            'sections': [
              {
                'icon': Icons.privacy_tip,
                'title': 'Gizlilik Şartları',
                'content':
                    'Driving License uygulaması, kullanıcıların deneyimini iyileştirmek ve temel işlevleri sağlamak amacıyla asgari düzeyde veri işler. '
                    'Toplanan veriler yalnızca uygulamanın çalışması, kullanıcı ilerlemesinin saklanması ve temel analizler için kullanılır. '
                    'Veriler, hukuka ve dürüstlük kurallarına uygun şekilde; amaçla sınırlı, ölçülü ve şeffaf biçimde işlenir.',
              },
              {
                'icon': Icons.storage_rounded,
                'title': 'Verilerin Kullanımı',
                'content':
                    'Uygulama; çözülen sorular, başarı yüzdesi ve tema tercihleri gibi yerel cihaz verilerini saklayabilir. '
                    'Bu bilgiler, profilinizde ilerleme göstermek ve kişiselleştirilmiş bir deneyim sunmak için kullanılır. '
                    'Herhangi bir kişisel veriniz, açık onayınız olmadan üçüncü taraflarla paylaşılmaz.',
              },
              {
                'icon': Icons.security_rounded,
                'title': 'Veri Güvenliği',
                'content':
                    'Veri güvenliği, tasarımın her aşamasında göz önünde bulundurulur. '
                    'Yerel depolanan bilgiler işletim sisteminin sağladığı güvenlik önlemleri ile korunur. '
                    'Harici servislere yönlendirmelerde (ör. YouTube) ilgili platformun gizlilik ve güvenlik ilkeleri geçerlidir.',
              },
              {
                'icon': Icons.balance,
                'title': 'Kullanıcı Hakları',
                'content':
                    'Kullanıcılar; verilerine erişme, düzeltme, silme ve işlenmesini kısıtlama haklarına sahiptir. '
                    'Uygulama içi profil bilgileriniz üzerinde tasarruf edebilirsiniz. '
                    'Gizlilikle ilgili sorularınız veya talepleriniz için bize uygulama içinden veya mağaza sayfasından ulaşabilirsiniz.',
              },
            ],
          };

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.privacy ?? privacyData['title'] as String),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final section in privacyData['sections'] as List<Map<String, dynamic>>)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _section(
                  context,
                  icon: section['icon'] as IconData,
                  title: section['title'] as String,
                  content: section['content'] as String,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
                  color: isDark ? Colors.blueGrey : Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
