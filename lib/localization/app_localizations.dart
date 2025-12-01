import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Turkish translations
  static const Map<String, String> _tr = {
    'app_name': 'Driver App',
    'home': 'Ana Sayfa',
    'profile': 'Profil',
    'all_questions': 'Çıkmış Sınav Soruları',
    'all_questions_desc': 'Gerçek sınav formatında sorularla hazırlanın',
    'today_exam': 'Günün Sınavı',
    'today_exam_desc': 'En güncel tarihli sınav',
    'start': 'Başla',
    'favorites': 'Favoriler',
    'traffic_signs': 'Trafik İşaretleri',
    'police_signals': 'Polis İşaretleri',
    'speed_rules': 'Hız Kuralları',
    'questions': 'Soru',
    'correct': 'Doğru',
    'wrong': 'Yanlış',
    'empty': 'Boş',
    'next': 'Sonraki',
    'previous': 'Önceki',
    'finish_exam': 'Sınavı Bitir',
    'share': 'Paylaş',
    'rate': 'Puanla',
    'dark_mode': 'Koyu Mod',
    'light_mode': 'Açık Mod',
    'traffic_and_environment': 'Trafik ve Çevre Bilgisi',
    'first_aid': 'İlk Yardım Bilgisi',
    'vehicle_technical': 'Araç Teknik',
    'vehicle_maintenance': 'Motor ve Araç Bakımı',
    'traffic_ethics': 'Trafik Adabı',
    'language': 'Dil',
    'select_language': 'Dil Seçin',
    'turkish': 'Türkçe',
    'english': 'English',
    'change_theme': 'Tema Değiştir',
    'announcements': 'Duyurular',
    'privacy': 'Gizlilik Şartları',
    'faq': 'Sıkça Sorulan Sorular',
    'share_app': 'Uygulamayı Paylaş',
    'rate_app': 'Uygulamayı Puanla',
    'about_app': 'Uygulama Hakkında',
    'exam_results': 'E-Sınav Sonuç Sayfası',
    'lesson_videos': 'Ders Videoları',
    'random_exam': 'Rastgele Sınav',
    'help_support': 'Yardım ve Destek',
    'privacy_security': 'Gizlilik ve Güvenlik',
    'edit_name': 'İsmi Düzenle',
    'enter_name': 'İsminizi girin',
    'cancel': 'İptal',
    'save': 'Kaydet',
    'language_set_turkish': 'Dil Türkçe olarak ayarlandı',
    'language_set_english': 'Language set to English',
    'select_year': 'Yıl Seç',
    'select_month': 'Ay Seç',
    'select_day': 'Gün Seç',
    'all': 'Hepsi',
    'clear': 'Temizle',
    'not_solved': 'Çözülmedi',
    'solved': 'Çözüldü',
    'continue_exam': 'Devam Et',
    'no_questions_found': 'Soru bulunamadı',
    'year': 'Yıl',
    'month': 'Ay',
    'day': 'Gün',
    'language_change_warning': 'Dil değiştirmek soruları da değiştirecektir.',
    'language_change_warning_title': 'Dil Değişikliği',
    'go_back': 'Geri Dön',
    'time': 'Süre',
    'score': 'Puan',
    'points_per_question': 'Her soru 2 puan',
    'total_questions': 'Toplam Soru',
    'risky': 'Riskli',
    'congratulations': 'Tebrikler',
    'exam_summary': 'Sınav Özeti',
    'your_score': 'Puanınız',
    'correct_answers': 'Doğru Cevaplar',
    'wrong_answers': 'Yanlış Cevaplar',
    'empty_answers': 'Boş Cevaplar',
  };

  // English translations
  static const Map<String, String> _en = {
    'app_name': 'Driver App',
    'home': 'Home',
    'profile': 'Profile',
    'all_questions': 'Past Exam Questions',
    'all_questions_desc': 'Prepare with real exam format questions',
    'today_exam': "Today's Exam",
    'today_exam_desc': 'Latest dated exam',
    'start': 'Start',
    'favorites': 'Favorites',
    'traffic_signs': 'Traffic Signs',
    'police_signals': 'Police Signals',
    'speed_rules': 'Speed Rules',
    'questions': 'Questions',
    'correct': 'Correct',
    'wrong': 'Wrong',
    'empty': 'Empty',
    'next': 'Next',
    'previous': 'Previous',
    'finish_exam': 'Finish Exam',
    'share': 'Share',
    'rate': 'Rate',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'traffic_and_environment': 'Traffic and Environment',
    'first_aid': 'First Aid',
    'vehicle_technical': 'Vehicle Technical',
    'vehicle_maintenance': 'Vehicle Maintenance',
    'traffic_ethics': 'Traffic Ethics',
    'language': 'Language',
    'select_language': 'Select Language',
    'turkish': 'Türkçe',
    'english': 'English',
    'change_theme': 'Change Theme',
    'announcements': 'Announcements',
    'privacy': 'Privacy Policy',
    'faq': 'FAQ',
    'share_app': 'Share App',
    'rate_app': 'Rate App',
    'about_app': 'About App',
    'exam_results': 'Exam Results Page',
    'lesson_videos': 'Lesson Videos',
    'random_exam': 'Random Exam',
    'help_support': 'Help & Support',
    'privacy_security': 'Privacy & Security',
    'edit_name': 'Edit Name',
    'enter_name': 'Enter your name',
    'cancel': 'Cancel',
    'save': 'Save',
    'language_set_turkish': 'Dil Türkçe olarak ayarlandı',
    'language_set_english': 'Language set to English',
    'select_year': 'Select Year',
    'select_month': 'Select Month',
    'select_day': 'Select Day',
    'all': 'All',
    'clear': 'Clear',
    'not_solved': 'Not Solved',
    'solved': 'Solved',
    'continue_exam': 'Continue',
    'no_questions_found': 'No questions found',
    'year': 'Year',
    'month': 'Month',
    'day': 'Day',
    'language_change_warning': 'Changing the language will also change the questions.',
    'language_change_warning_title': 'Language Change',
    'go_back': 'Go Back',
    'time': 'Time',
    'score': 'Score',
    'points_per_question': 'Each question is 2 points',
    'total_questions': 'Total Questions',
    'risky': 'Risky',
    'congratulations': 'Congratulations',
    'exam_summary': 'Exam Summary',
    'your_score': 'Your Score',
    'correct_answers': 'Correct Answers',
    'wrong_answers': 'Wrong Answers',
    'empty_answers': 'Empty Answers',
  };

  String translate(String key) {
    return _getTranslations()[key] ?? key;
  }

  Map<String, String> _getTranslations() {
    return locale.languageCode == 'tr' ? _tr : _en;
  }

  // Helper methods for easier access
  String get appName => translate('app_name');
  String get home => translate('home');
  String get profile => translate('profile');
  String get allQuestions => translate('all_questions');
  String get allQuestionsDesc => translate('all_questions_desc');
  String get todayExam => translate('today_exam');
  String get todayExamDesc => translate('today_exam_desc');
  String get start => translate('start');
  String get favorites => translate('favorites');
  String get trafficSigns => translate('traffic_signs');
  String get policeSignals => translate('police_signals');
  String get speedRules => translate('speed_rules');
  String get questions => translate('questions');
  String get correct => translate('correct');
  String get wrong => translate('wrong');
  String get empty => translate('empty');
  String get next => translate('next');
  String get previous => translate('previous');
  String get finishExam => translate('finish_exam');
  String get share => translate('share');
  String get rate => translate('rate');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get trafficAndEnvironment => translate('traffic_and_environment');
  String get firstAid => translate('first_aid');
  String get vehicleTechnical => translate('vehicle_technical');
  String get vehicleMaintenance => translate('vehicle_maintenance');
  String get trafficEthics => translate('traffic_ethics');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get turkish => translate('turkish');
  String get english => translate('english');
  String get changeTheme => translate('change_theme');
  String get announcements => translate('announcements');
  String get privacy => translate('privacy');
  String get faq => translate('faq');
  String get shareApp => translate('share_app');
  String get rateApp => translate('rate_app');
  String get aboutApp => translate('about_app');
  String get examResults => translate('exam_results');
  String get lessonVideos => translate('lesson_videos');
  String get randomExam => translate('random_exam');
  String get helpSupport => translate('help_support');
  String get privacySecurity => translate('privacy_security');
  String get editName => translate('edit_name');
  String get enterName => translate('enter_name');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get languageSetTurkish => translate('language_set_turkish');
  String get languageSetEnglish => translate('language_set_english');
  String get selectYear => translate('select_year');
  String get selectMonth => translate('select_month');
  String get selectDay => translate('select_day');
  String get all => translate('all');
  String get clear => translate('clear');
  String get notSolved => translate('not_solved');
  String get solved => translate('solved');
  String get continueExam => translate('continue_exam');
  String get noQuestionsFound => translate('no_questions_found');
  String get year => translate('year');
  String get month => translate('month');
  String get day => translate('day');
  String get languageChangeWarning => translate('language_change_warning');
  String get languageChangeWarningTitle => translate('language_change_warning_title');
  String get goBack => translate('go_back');
  String get time => translate('time');
  String get score => translate('score');
  String get pointsPerQuestion => translate('points_per_question');
  String get totalQuestions => translate('total_questions');
  String get risky => translate('risky');
  String get congratulations => translate('congratulations');
  String get examSummary => translate('exam_summary');
  String get yourScore => translate('your_score');
  String get correctAnswers => translate('correct_answers');
  String get wrongAnswers => translate('wrong_answers');
  String get emptyAnswers => translate('empty_answers');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
