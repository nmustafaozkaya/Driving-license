import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class QuizQuestionsPage extends StatefulWidget {
  final int yil;
  final String ay;
  final int gun;

  const QuizQuestionsPage({
    super.key,
    required this.yil,
    required this.ay,
    required this.gun,
  });

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  final Map<int, int?> _selectedAnswers = {};
  final Map<int, bool> _lockedAnswers = {};
  bool _isLoading = true;
  String? _error;
  bool _isExamFinished = false;

  // Timer
  Timer? _timer;
  int _elapsedSeconds = 0;
  static const int _totalExamTime = 2700; // 45 dakika = 2700 saniye

  // Exam results
  int _correctCount = 0;
  int _wrongCount = 0;
  int _emptyCount = 0;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  Future<void> _loadPreviousAnswers() async {
    try {
      if (_questions.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final examKey = 'y${widget.yil}-${widget.ay}-g${widget.gun}';

      // Check if exam was previously completed
      final total = prefs.getInt('exam_total_$examKey') ?? 0;
      final solved = prefs.getInt('exam_solved_$examKey') ?? 0;

      if (total > 0 && solved == total && _questions.isNotEmpty) {
        // Load previous answers for each question
        for (int i = 0; i < _questions.length && i < total; i++) {
          final answerKey = 'exam_answer_${examKey}_q$i';
          final savedAnswer = prefs.getInt(answerKey);
          if (savedAnswer != null) {
            _selectedAnswers[i] = savedAnswer;
            _lockedAnswers[i] = true;
          }
        }

        // Sınav tamamlanmışsa, tüm soruları kilitli yap (cevap kaydedilmemiş olsa bile)
        for (int i = 0; i < _questions.length; i++) {
          _lockedAnswers[i] = true;
        }

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_elapsedSeconds < _totalExamTime && !_isExamFinished) {
        setState(() {
          _elapsedSeconds++;
        });
      } else if (_elapsedSeconds >= _totalExamTime) {
        _finishExam();
      }
    });
  }

  int get _remainingSeconds => _totalExamTime - _elapsedSeconds;

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _loadQuestions() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get language code before async operation
      if (!mounted) return;
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final languageCode = localeProvider.locale.languageCode;
      final collectionName = languageCode == 'en' ? 'en_sorular' : 'tr_sorular';

      // Firebase'den soruları çek
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('yıl', isEqualTo: widget.yil)
          .where('ay', isEqualTo: widget.ay)
          .where('gün', isEqualTo: widget.gun)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        final localizations = AppLocalizations.of(context);
        if (!mounted) return;
        setState(() {
          _error =
              localizations?.noQuestionsFound ?? 'Bu tarihte soru bulunamadı.';
          _isLoading = false;
        });
        return;
      }

      final questions = snapshot.docs.map((doc) => doc.data()).toList();

      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      // Load previous answers after questions are loaded
      _loadPreviousAnswers();
    } catch (e) {
      if (!mounted) return;
      final localizations = AppLocalizations.of(context);
      if (!mounted) return;
      setState(() {
        _error =
            localizations?.noQuestionsFound ??
            'Sorular yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int answerIndex) {
    if (_lockedAnswers[_currentIndex] == true || _isExamFinished) return;

    setState(() {
      _selectedAnswers[_currentIndex] = answerIndex;
      _lockedAnswers[_currentIndex] = true;
    });
  }

  void _previousQuestion() {
    if (_currentIndex > 0 && !_isExamFinished) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1 && !_isExamFinished) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _calculateResults() {
    int correct = 0;
    int wrong = 0;
    int empty = 0;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final int correctAnswer = question['cevap'] is int
          ? question['cevap'] as int
          : int.tryParse('${question['cevap']}') ?? -1;
      final selectedAnswer = _selectedAnswers[i];

      if (selectedAnswer == null) {
        empty++;
      } else if (selectedAnswer == correctAnswer) {
        correct++;
      } else {
        wrong++;
      }
    }

    // Her soru 2 puan
    final totalScore = correct * 2;

    setState(() {
      _correctCount = correct;
      _wrongCount = wrong;
      _emptyCount = empty;
      _totalScore = totalScore;
    });

    // Save progress - Sınav bitince tüm sorular çözülmüş sayılır
    _saveProgress(_questions.length, _questions.length);
  }

  Future<void> _saveProgress(int solved, int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examKey = 'y${widget.yil}-${widget.ay}-g${widget.gun}';
      await prefs.setInt('exam_total_$examKey', total);
      await prefs.setInt('exam_solved_$examKey', solved);

      // Save each question's answer
      for (int i = 0; i < _questions.length; i++) {
        final answerKey = 'exam_answer_${examKey}_q$i';
        final selectedAnswer = _selectedAnswers[i];
        if (selectedAnswer != null) {
          await prefs.setInt(answerKey, selectedAnswer);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _finishExam() {
    if (_isExamFinished) return;

    _timer?.cancel();
    _calculateResults();

    setState(() {
      _isExamFinished = true;
    });

    // Show summary after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showSummary();
      }
    });
  }

  void _showSummary() {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languageCode = localeProvider.locale.languageCode;

    final totalPossible = _questions.length * 2;
    final percentage = totalPossible > 0
        ? (_totalScore / totalPossible * 100)
        : 0.0;
    final isPassed = percentage >= 70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          localizations?.examSummary ?? 'Sınav Özeti',
          style: TextStyle(
            color: isPassed ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başarı durumu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPassed
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle : Icons.warning,
                      color: isPassed ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isPassed
                            ? (localizations?.congratulations ?? 'Tebrikler')
                            : (localizations?.risky ?? 'Riskli'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Puan
              _buildSummaryRow(
                localizations?.yourScore ?? 'Puanınız',
                '$_totalScore / $totalPossible',
                isPassed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              // Yüzde
              _buildSummaryRow(
                languageCode == 'en' ? 'Percentage' : 'Yüzde',
                '${percentage.toStringAsFixed(1)}%',
                isPassed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              // Her soru 2 puan bilgisi
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizations?.pointsPerQuestion ?? 'Her soru 2 puan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[900],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Doğru
              _buildSummaryRow(
                localizations?.correctAnswers ?? 'Doğru Cevaplar',
                '$_correctCount',
                Colors.green,
              ),
              const SizedBox(height: 8),
              // Yanlış
              _buildSummaryRow(
                localizations?.wrongAnswers ?? 'Yanlış Cevaplar',
                '$_wrongCount',
                Colors.red,
              ),
              const SizedBox(height: 8),
              // Boş
              _buildSummaryRow(
                localizations?.emptyAnswers ?? 'Boş Cevaplar',
                '$_emptyCount',
                Colors.grey,
              ),
              const SizedBox(height: 8),
              // Süre
              _buildSummaryRow(
                localizations?.time ?? 'Süre',
                _formatTime(_elapsedSeconds),
                Colors.orange,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(localizations?.goBack ?? 'Geri Dön'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(localizations?.goBack ?? 'Geri Dön'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(localizations?.goBack ?? 'Geri Dön'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _error ??
                      (localizations?.noQuestionsFound ?? 'Soru bulunamadı'),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final String soru = (currentQuestion['soru'] ?? '').toString();
    final List<dynamic> cevaplar =
        (currentQuestion['cevaplar'] ?? []) as List<dynamic>;
    final int cevapIndex = currentQuestion['cevap'] is int
        ? currentQuestion['cevap'] as int
        : int.tryParse('${currentQuestion['cevap']}') ?? -1;
    final bool isLocked = _lockedAnswers[_currentIndex] ?? false;
    final int? selectedAnswer = _selectedAnswers[_currentIndex];

    // Calculate current stats
    int currentCorrect = 0;
    int currentWrong = 0;
    for (int i = 0; i <= _currentIndex; i++) {
      if (_lockedAnswers[i] == true && _selectedAnswers[i] != null) {
        final q = _questions[i];
        final int correctAns = q['cevap'] is int
            ? q['cevap'] as int
            : int.tryParse('${q['cevap']}') ?? -1;
        if (_selectedAnswers[i] == correctAns) {
          currentCorrect++;
        } else {
          currentWrong++;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(localizations?.goBack ?? 'Geri Dön'),
        actions: [
          // Süre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: _remainingSeconds < 300
                        ? Colors.red
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _remainingSeconds < 300
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: _remainingSeconds < 300
                          ? Colors.red
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Doğru
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '$currentCorrect',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Yanlış
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '$currentWrong',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.blue[400]! : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentIndex + 1}/${_questions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black12.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      soru,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(cevaplar.length, (i) {
                    final bool isSelected = selectedAnswer == i;
                    final bool isCorrect = i == cevapIndex;
                    Color? tileColor;
                    Color borderColor = isDark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!;
                    IconData? leadingIcon;

                    if (isLocked) {
                      if (isCorrect) {
                        // Doğru cevap - her zaman yeşil göster
                        tileColor = Colors.green.withValues(alpha: 0.12);
                        borderColor = Colors.green;
                        leadingIcon = Icons.check_circle;
                      } else if (isSelected && !isCorrect) {
                        // Yanlış seçilen cevap - kırmızı göster
                        tileColor = Colors.red.withValues(alpha: 0.12);
                        borderColor = Colors.red;
                        leadingIcon = Icons.cancel;
                      } else if (!isSelected && !isCorrect && isLocked) {
                        // Kilitli ama seçilmemiş yanlış cevap - normal görünüm
                        // Doğru cevap zaten yeşil gösteriliyor
                      }
                    } else if (isSelected) {
                      tileColor = (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.06);
                    }

                    final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
                    final String text = cevaplar[i] is Map<String, dynamic>
                        ? ((cevaplar[i] as Map<String, dynamic>)['metin'] ?? '')
                              .toString()
                        : cevaplar[i].toString();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                            color: leadingIcon != null
                                ? (isCorrect ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.15)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: leadingIcon != null
                              ? Icon(
                                  leadingIcon,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20,
                                )
                              : Text(
                                  letter,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                        ),
                        title: Text(text),
                        onTap: () => _selectAnswer(i),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0 && !_isExamFinished
                      ? _previousQuestion
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(localizations?.previous ?? 'Önceki'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: !_isExamFinished ? _finishExam : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(localizations?.finishExam ?? 'Sınavı Bitir'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _currentIndex < _questions.length - 1 && !_isExamFinished
                      ? _nextQuestion
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(localizations?.next ?? 'Sonraki'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
