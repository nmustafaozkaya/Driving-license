import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class RandomCategoryQuizPage extends StatefulWidget {
  final String title;
  final String kategori;
  final int questionCount;

  const RandomCategoryQuizPage({
    super.key,
    required this.title,
    required this.kategori,
    required this.questionCount,
  });

  @override
  State<RandomCategoryQuizPage> createState() => _RandomCategoryQuizPageState();
}

class _RandomCategoryQuizPageState extends State<RandomCategoryQuizPage> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategoryQuestions();
  }

  /// Maps app category names to Firebase category names
  String _getFirebaseCategoryName(String appCategory, String languageCode) {
    if (languageCode == 'tr') {
      // Turkish category mapping - map app category names to Firebase category names
      if (appCategory == 'Trafik ve Çevre Bilgisi') {
        return 'Trafik ve Çevre';
      } else if (appCategory == 'İlk Yardım Bilgisi') {
        return 'İlk Yardım';
      } else if (appCategory == 'Motor ve Araç Bakımı') {
        return 'Motor ve Araç Bakımı';
      } else if (appCategory == 'Trafik Adabı') {
        return 'Trafik Ahlakı';
      }
      // Fallback: try to use the category as-is
      return appCategory;
    } else {
      // English category mapping
      // Note: subtitle might still be in Turkish format, so we need to map both
      if (appCategory == 'Traffic and Environment' ||
          appCategory == 'Trafik ve Çevre Bilgisi') {
        return 'Traffic and Environment';
      } else if (appCategory == 'First Aid' ||
          appCategory == 'İlk Yardım Bilgisi') {
        return 'First Aid';
      } else if (appCategory == 'Vehicle Technical' ||
          appCategory == 'Motor ve Araç Bakımı') {
        return 'Vehicle Technical';
      } else if (appCategory == 'Traffic Ethics' ||
          appCategory == 'Trafik Adabı') {
        return 'Traffic Ethics';
      }
      // Fallback: try to use the category as-is
      return appCategory;
    }
  }

  Future<void> _loadCategoryQuestions() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get language code
      if (!mounted) return;
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final languageCode = localeProvider.locale.languageCode;
      final collectionName = languageCode == 'en' ? 'en_sorular' : 'tr_sorular';

      // Map app category to Firebase category
      final firebaseCategory = _getFirebaseCategoryName(
        widget.kategori,
        languageCode,
      );

      // Fetch questions from Firebase filtered by category
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('kategori', isEqualTo: firebaseCategory)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        final localizations = AppLocalizations.of(context);
        if (!mounted) return;
        setState(() {
          _error = localizations?.noQuestionsFound ??
              'Bu kategoride soru bulunamadı.';
          _isLoading = false;
        });
        return;
      }

      // Convert to list and shuffle for random order
      final allQuestions =
          snapshot.docs.map((doc) => doc.data()).toList();
      allQuestions.shuffle();

      // Limit to questionCount
      final limitedQuestions = allQuestions.take(widget.questionCount).toList();

      if (!mounted) return;
      setState(() {
        _questions = limitedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final localizations = AppLocalizations.of(context);
      if (!mounted) return;
      setState(() {
        _error = localizations?.noQuestionsFound ??
            'Sorular yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  void _startQuiz() {
    if (_questions.isEmpty) return;

    // Navigate to quiz page
    // Since we don't have a date-based quiz, we'll create a custom quiz page
    // For now, we'll use a simplified approach - show questions in a quiz format
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryQuizQuestionsPage(
          title: widget.title,
          questions: _questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
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
                  _error ?? (localizations?.noQuestionsFound ?? 'Soru bulunamadı'),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations?.goBack ?? 'Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              '${_questions.length} ${localizations?.questions ?? 'soru'} hazır',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations?.allQuestionsDesc ??
                  'Kategoriye özel sorularla hazırlanın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.play_arrow),
              label: Text(localizations?.start ?? 'Başla'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom quiz page for category-based questions
class CategoryQuizQuestionsPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> questions;

  const CategoryQuizQuestionsPage({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<CategoryQuizQuestionsPage> createState() =>
      _CategoryQuizQuestionsPageState();
}

class _CategoryQuizQuestionsPageState
    extends State<CategoryQuizQuestionsPage> {
  int _currentIndex = 0;
  final Map<int, int?> _selectedAnswers = {};
  final Map<int, bool> _lockedAnswers = {};
  bool _isExamFinished = false;

  // Timer
  Timer? _timer;
  int _elapsedSeconds = 0;
  static const int _totalExamTime = 2700; // 45 dakika

  // Exam results
  int _correctCount = 0;
  int _wrongCount = 0;
  int _emptyCount = 0;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    if (_currentIndex < widget.questions.length - 1 && !_isExamFinished) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _calculateResults() {
    int correct = 0;
    int wrong = 0;
    int empty = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
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

    final totalScore = correct * 2;

    setState(() {
      _correctCount = correct;
      _wrongCount = wrong;
      _emptyCount = empty;
      _totalScore = totalScore;
    });
  }

  void _finishExam() {
    if (_isExamFinished) return;

    _timer?.cancel();
    _calculateResults();

    setState(() {
      _isExamFinished = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showSummary();
      }
    });
  }

  void _showSummary() {
    final localizations = AppLocalizations.of(context);

    final totalPossible = widget.questions.length * 2;
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
              _buildSummaryRow(
                localizations?.yourScore ?? 'Puanınız',
                '$_totalScore / $totalPossible',
                isPassed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Yüzde',
                '${percentage.toStringAsFixed(1)}%',
                isPassed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                localizations?.correctAnswers ?? 'Doğru Cevaplar',
                '$_correctCount',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                localizations?.wrongAnswers ?? 'Yanlış Cevaplar',
                '$_wrongCount',
                Colors.red,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                localizations?.emptyAnswers ?? 'Boş Cevaplar',
                '$_emptyCount',
                Colors.grey,
              ),
              const SizedBox(height: 8),
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

    final currentQuestion = widget.questions[_currentIndex];
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
        final q = widget.questions[i];
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
        title: Text(widget.title),
        actions: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '$currentCorrect',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '$currentWrong',
                    style: const TextStyle(
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
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.questions.length,
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
                  '${_currentIndex + 1}/${widget.questions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
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
                        tileColor = Colors.green.withValues(alpha: 0.12);
                        borderColor = Colors.green;
                        leadingIcon = Icons.check_circle;
                      } else if (isSelected && !isCorrect) {
                        tileColor = Colors.red.withValues(alpha: 0.12);
                        borderColor = Colors.red;
                        leadingIcon = Icons.cancel;
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
                      _currentIndex < widget.questions.length - 1 &&
                              !_isExamFinished
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
