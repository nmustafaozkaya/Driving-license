import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class TrafficSignsPage extends StatefulWidget {
  const TrafficSignsPage({super.key});

  @override
  State<TrafficSignsPage> createState() => _TrafficSignsPageState();
}

class _TrafficSignsPageState extends State<TrafficSignsPage> {
  List<TrafficSignCategory> categories = [];
  bool isLoading = true;
  String selectedCategoryId = 'tehlike_uyari'; // Varsayılan olarak ilk kategori
  LocaleProvider?
  _localeProvider; // Save reference to avoid context access in dispose

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to LocaleProvider when dependencies are available
    if (_localeProvider == null) {
      _localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      _localeProvider!.addListener(_onLocaleChanged);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTrafficSigns();
  }

  void _onLocaleChanged() {
    if (mounted) {
      _loadTrafficSigns();
    }
  }

  @override
  void dispose() {
    // Use saved reference instead of accessing context
    _localeProvider?.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Future<void> _loadTrafficSigns() async {
    try {
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final locale = localeProvider.locale;
      final String jsonFileName = locale.languageCode == 'en'
          ? 'lib/data/traffic_signs_en.json'
          : 'lib/data/traffic_signs.json';

      final String jsonString = await rootBundle.loadString(jsonFileName);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        categories = (jsonData['categories'] as List)
            .map((cat) => TrafficSignCategory.fromJson(cat))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        final localeProvider = Provider.of<LocaleProvider>(
          context,
          listen: false,
        );
        final isEnglish = localeProvider.locale.languageCode == 'en';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEnglish
                  ? 'Error loading data: $e'
                  : 'Veriler yüklenirken hata oluştu: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.trafficSigns ?? 'Trafik İşaretleri'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(
              child: Text(
                'Trafik işaretleri yüklenemedi.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                _buildCategoryTabs(isDark),
                Expanded(child: _buildSignsList(isDark)),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: categories.map((category) {
          final isSelected = category.id == selectedCategoryId;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategoryId = category.id;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.2))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.orange
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.orange[300] : Colors.orange[700])
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignsList(bool isDark) {
    final category = categories.firstWhere(
      (cat) => cat.id == selectedCategoryId,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : TrafficSignCategory(id: '', name: '', icon: '', signs: []),
    );

    if (category.signs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final localeProvider = Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                );
                final isEnglish = localeProvider.locale.languageCode == 'en';
                return Text(
                  isEnglish
                      ? 'No signs in this category yet'
                      : 'Bu kategoride henüz işaret bulunmuyor',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: category.signs.length,
      itemBuilder: (context, index) {
        final sign = category.signs[index];
        return _buildSignItem(sign, isDark);
      },
    );
  }

  Widget _buildSignItem(TrafficSign sign, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gerçek trafik işareti resmi
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  sign.image,
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Resim yüklenemezse varsayılan ikon göster
                    return Container(
                      color: Colors.red[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          Text(
                            'HATA',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sign.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sign.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrafficSignCategory {
  final String id;
  final String name;
  final String icon;
  final List<TrafficSign> signs;

  TrafficSignCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.signs,
  });

  factory TrafficSignCategory.fromJson(Map<String, dynamic> json) {
    return TrafficSignCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      signs: (json['signs'] as List)
          .map((sign) => TrafficSign.fromJson(sign))
          .toList(),
    );
  }
}

class TrafficSign {
  final String id;
  final String name;
  final String description;
  final String image;

  TrafficSign({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory TrafficSign.fromJson(Map<String, dynamic> json) {
    return TrafficSign(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
}
