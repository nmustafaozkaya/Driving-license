import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Sayfa: Soru Ekleme Sayfası
/// Açıklama: Firestore'a yeni soru eklemek için kullanılan admin sayfası
/// en_sorular ve tr_sorular koleksiyonlarına soru eklenebilir
class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _soruController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _cevapController = TextEditingController();
  final _yilController = TextEditingController();
  final _ayController = TextEditingController();
  final _gunController = TextEditingController();
  final _soruVideosuController = TextEditingController();

  // Cevaplar için controller'lar
  final List<TextEditingController> _cevapMetinControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _cevapResimControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // Soru resimleri için controller'lar
  final List<TextEditingController> _soruResimControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String _selectedLanguage = 'tr'; // 'tr' veya 'en'
  bool _isLoading = false;

  // Ay listeleri
  final List<String> _turkishMonths = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  final List<String> _englishMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void dispose() {
    _soruController.dispose();
    _kategoriController.dispose();
    _cevapController.dispose();
    _yilController.dispose();
    _ayController.dispose();
    _gunController.dispose();
    _soruVideosuController.dispose();
    for (var controller in _cevapMetinControllers) {
      controller.dispose();
    }
    for (var controller in _cevapResimControllers) {
      controller.dispose();
    }
    for (var controller in _soruResimControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Soruyu Firestore'a ekle
  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Koleksiyon adını belirle
      final collectionName = _selectedLanguage == 'en' ? 'en_sorular' : 'tr_sorular';

      // Ay değerini belirle
      String ayValue;
      if (_selectedLanguage == 'en') {
        ayValue = _ayController.text.isNotEmpty
            ? _englishMonths[int.tryParse(_ayController.text) ?? 1 - 1]
            : _englishMonths[0];
      } else {
        ayValue = _ayController.text.isNotEmpty
            ? _turkishMonths[int.tryParse(_ayController.text) ?? 1 - 1]
            : _turkishMonths[0];
      }

      // Cevaplar array'ini oluştur
      final List<Map<String, String>> cevaplar = [];
      for (int i = 0; i < 4; i++) {
        if (_cevapMetinControllers[i].text.isNotEmpty) {
          cevaplar.add({
            'metin': _cevapMetinControllers[i].text,
            'resim_url': _cevapResimControllers[i].text,
          });
        }
      }

      // Soru resimleri array'ini oluştur
      final List<String> soruResimleri = [];
      for (int i = 0; i < 4; i++) {
        if (_soruResimControllers[i].text.isNotEmpty) {
          soruResimleri.add(_soruResimControllers[i].text);
        } else {
          soruResimleri.add('');
        }
      }

      // Firestore dokümanı oluştur
      final questionData = {
        'ay': ayValue,
        'cevap': int.tryParse(_cevapController.text) ?? 0,
        'cevaplar': cevaplar,
        'gün': int.tryParse(_gunController.text) ?? 1,
        'kategori': _kategoriController.text,
        'soru': _soruController.text,
        'soru_resimleri': soruResimleri,
        'soru_videosu': _soruVideosuController.text.isNotEmpty
            ? _soruVideosuController.text
            : '',
        'yıl': int.tryParse(_yilController.text) ?? DateTime.now().year,
      };

      // Firestore'a ekle
      await FirebaseFirestore.instance
          .collection(collectionName)
          .add(questionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Soru başarıyla eklendi! ($collectionName)',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Formu temizle
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Formu sıfırla
  void _resetForm() {
    _soruController.clear();
    _kategoriController.clear();
    _cevapController.clear();
    _yilController.text = DateTime.now().year.toString();
    _ayController.clear();
    _gunController.clear();
    _soruVideosuController.clear();
    for (var controller in _cevapMetinControllers) {
      controller.clear();
    }
    for (var controller in _cevapResimControllers) {
      controller.clear();
    }
    for (var controller in _soruResimControllers) {
      controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _yilController.text = DateTime.now().year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru Ekle'),
        actions: [
          // Dil seçici
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'tr', label: Text('TR')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {_selectedLanguage},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedLanguage = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Soru metni
              TextFormField(
                controller: _soruController,
                decoration: const InputDecoration(
                  labelText: 'Soru',
                  hintText: 'Soruyu giriniz',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Soru metni gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Örn: Vehicle Technical, Trafik ve Çevre Bilgisi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tarih bilgileri
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yilController,
                      decoration: const InputDecoration(
                        labelText: 'Yıl',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yıl gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _ayController,
                      decoration: InputDecoration(
                        labelText: 'Ay (1-12)',
                        hintText: '1-12',
                        border: const OutlineInputBorder(),
                        helperText: _selectedLanguage == 'en'
                            ? '1=January, 12=December'
                            : '1=Ocak, 12=Aralık',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ay gereklidir';
                        }
                        final ay = int.tryParse(value);
                        if (ay == null || ay < 1 || ay > 12) {
                          return '1-12 arası olmalı';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _gunController,
                      decoration: const InputDecoration(
                        labelText: 'Gün',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gün gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Doğru cevap
              TextFormField(
                controller: _cevapController,
                decoration: const InputDecoration(
                  labelText: 'Doğru Cevap (0-3)',
                  hintText: '0=A, 1=B, 2=C, 3=D',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Doğru cevap gereklidir';
                  }
                  final cevap = int.tryParse(value);
                  if (cevap == null || cevap < 0 || cevap > 3) {
                    return '0-3 arası olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cevaplar
              const Text(
                'Cevaplar (A, B, C, D)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cevap ${String.fromCharCode(65 + index)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cevapMetinControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Cevap Metni',
                              border: OutlineInputBorder(),
                            ),
                            validator: index == 0
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'En az bir cevap gereklidir';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cevapResimControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Resim URL (Opsiyonel)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Soru resimleri
              const SizedBox(height: 16),
              const Text(
                'Soru Resimleri (Opsiyonel)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: _soruResimControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Resim ${index + 1} URL',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),

              // Soru videosu
              const SizedBox(height: 16),
              TextFormField(
                controller: _soruVideosuController,
                decoration: const InputDecoration(
                  labelText: 'Soru Videosu URL (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Ekle butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _addQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Soruyu Ekle',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

