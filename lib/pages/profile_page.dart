import 'package:flutter/material.dart';
import 'privacy_page.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final ValueChanged<String> onNameChanged;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.onNameChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget _buildLanguageTile(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final currentLocale = localeProvider.locale.languageCode;
        final languageText = currentLocale == 'tr'
            ? 'Türkçe 🇹🇷'
            : 'English 🇬🇧';

        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Dil / Language'),
          subtitle: Text(
            languageText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Dil Seçin / Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: currentLocale == 'tr'
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.circle_outlined),
                        title: const Row(
                          children: [
                            Text('🇹🇷', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 12),
                            Text('Türkçe'),
                          ],
                        ),
                        onTap: () {
                          localeProvider.setLocale(const Locale('tr'));
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.languageSetTurkish ??
                                    'Dil Türkçe olarak ayarlandı',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: currentLocale == 'en'
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.circle_outlined),
                        title: const Row(
                          children: [
                            Text('🇬🇧', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 12),
                            Text('English'),
                          ],
                        ),
                        onTap: () {
                          localeProvider.setLocale(const Locale('en'));
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.languageSetEnglish ??
                                    'Language set to English',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('İptal / Cancel'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: widget.userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () => _showEditNameDialog(context),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Icon(Icons.edit, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                _buildLanguageTile(context),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(
                    localizations?.privacySecurity ?? 'Gizlilik ve Güvenlik',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(localizations?.helpSupport ?? 'Yardım ve Destek'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: widget.userName,
    );
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations?.editName ?? 'İsmi Düzenle'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: localizations?.enterName ?? 'İsminizi girin',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations?.cancel ?? 'İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  widget.onNameChanged(newName);
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text(localizations?.save ?? 'Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
