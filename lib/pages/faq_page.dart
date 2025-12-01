import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<_FAQItem> _getFAQItems(String languageCode) {
    if (languageCode == 'en') {
      return [
        _FAQItem(
          question: "How is the driving license exam score calculated?",
          answer:
              "The calculation is made out of 100 points based on the number of correct answers given by the candidates. Wrong answers do not reduce your net score. In the central system exam, each question has equal points. Candidates who score 70 and above out of 100 are considered successful.",
        ),
        _FAQItem(
          question: "What is the distribution of driving license exam questions?",
          answer:
              "Traffic and Environment: 23 questions\nFirst Aid: 12 questions\nVehicle Technical (Engine and Vehicle Maintenance): 9 questions\nTraffic Ethics: 6 questions",
        ),
        _FAQItem(
          question: "How many questions are there in the driving license exam?",
          answer: "There are a total of 50 questions in the driving license exam.",
        ),
        _FAQItem(
          question: "How many questions are there from traffic lessons in the driving license exam?",
          answer:
              "23 of the questions in the driving license exam are asked from traffic lessons.",
        ),
        _FAQItem(
          question: "How many questions are there from first aid knowledge in the driving license exam?",
          answer:
              "12 of the questions in the driving license exam are asked from first aid knowledge lessons.",
        ),
        _FAQItem(
          question: "How many questions are there from engine in the driving license exam?",
          answer:
              "9 of the questions in the driving license exam are asked from vehicle technical (engine and vehicle maintenance) lessons.",
        ),
        _FAQItem(
          question: "Do 3 wrong answers cancel 1 correct answer in the driving license exam?",
          answer:
              "No. Wrong answers in the driving license exam do not affect your net score.",
        ),
        _FAQItem(
          question: "How many points do I need to pass the driving license exam?",
          answer: "You need to score at least 70 points from each test.",
        ),
        _FAQItem(
          question:
              "How many questions do I need to answer correctly to pass the driving license exam?",
          answer: "You need to answer at least 35 questions correctly to pass the exam.",
        ),
        _FAQItem(
          question: "How many times can I take the driving license theory (written) exam?",
          answer:
              "Candidates have the right to take a maximum of 4 written and 4 practical exams.",
        ),
        _FAQItem(
          question: "How many times can I take the driving license practical exam?",
          answer:
              "Each driver candidate has the right to take the practical exam 4 times.",
        ),
        _FAQItem(
          question: "What is the total exam duration?",
          answer: "It is 45 minutes in total.",
        ),
        _FAQItem(
          question: "How many questions are asked in total in the exam?",
          answer: "A total of 50 questions are asked in the exam.",
        ),
        _FAQItem(
          question: "What is the exam success score threshold?",
          answer: "The success threshold is 70 out of 100.",
        ),
        _FAQItem(
          question:
              "Do the wrong answers I give in the exam affect my correct answers?",
          answer: "No, wrong answers do not cancel correct answers.",
        ),
        _FAQItem(
          question: "How much absence can I have in class hours?",
          answer: "Up to 20% of total class hours without excuse.",
        ),
        _FAQItem(
          question:
              "Can I drive a vehicle with a driver's certificate without getting my driver's license?",
          answer:
              "No. You can drive a vehicle after applying to the Traffic Registration Office and getting your driver's license.",
        ),
        _FAQItem(
          question: "How many times can I take the exam if I fail?",
          answer:
              "After failing the exam, you have a total of 4 exam rights (first + 3 retakes).",
        ),
        _FAQItem(
          question: "Where can I get a driver's fitness report?",
          answer:
              "It can be obtained from hospitals and family physicians authorized to issue driver's fitness reports.",
        ),
        _FAQItem(
          question:
              "How long after I get my driver's certificate should I apply to the Traffic Registration Office? Will my certificate be cancelled if I miss the deadline?",
          answer:
              "Certificates are valid for 2 years from the date they are received. Health reports are valid for 1 year; if the period expires, a new one is added to the file.",
        ),
        _FAQItem(
          question:
              "Until what date can primary school graduates apply for a driver's license?",
          answer:
              "Primary school graduates can get a driver's license; there is currently no time restriction.",
        ),
        _FAQItem(
          question: "What is a probationary license?",
          answer:
              "If a driver reaches 75 penalty points within 2 years, their license is confiscated and they undergo a psychotechnical evaluation. After the necessary documents, they must apply to a driving school and get a new license.",
        ),
        _FAQItem(
          question:
              "I enrolled in a driving school, took the exams and failed. Can I change schools?",
          answer:
              "Yes. Driving schools have transfer procedures like schools.",
        ),
        _FAQItem(
          question:
              "How many questions are asked in total in the exam? How many correct answers do I need from each lesson?",
          answer: "A total of 50 questions are asked; 35 correct answers pass.",
        ),
        _FAQItem(
          question: "I dropped out of 6th grade, can I get a license?",
          answer:
              "Yes. Those who dropped out of 6th, 7th, and 8th grades can also get a license.",
        ),
        _FAQItem(
          question: "How often are driving license exams held?",
          answer:
              "Usually once a month (exceptions may occur) through a central exam system.",
        ),
        _FAQItem(
          question:
              "I qualified for a license, got my file but 1 year passed. Can someone else get the license for me? What should I do?",
          answer:
              "If 1 year has passed, you need to renew your health report and criminal record certificate. Application is made in person; procedures cannot be done through power of attorney or by someone else.",
        ),
        _FAQItem(
          question: "I lost my license, how is a lost license reissued?",
          answer:
              "A loss announcement in the newspaper or a police report is recommended. You can renew it by applying to the relevant Traffic Registration Office with 2 photos, original ID card, form and current fee. If you are in another city, you can apply to the Traffic Registration Office where you are.",
        ),
      ];
    } else {
      return [
        _FAQItem(
          question: "Ehliyet sınavı puanı nasıl hesaplanır?",
          answer:
              "Adayların sorulara verdikleri doğru cevap sayıları tespit edilerek 100 puan üzerinden hesaplama yapılır. Yanlış cevaplar netinizi düşürmez. Merkezi sistem sınavında her soru eşit puandadır. 100 üzerinden 70 ve üzeri puan alan adaylar başarılı sayılır.",
        ),
        _FAQItem(
          question: "Ehliyet sınav soru dağılımı nasıldır?",
          answer:
              "Trafik ve Çevre Bilgisi: 23 soru\nİlk Yardım Bilgisi: 12 soru\nAraç Tekniği (Motor ve Araç Bakımı): 9 soru\nTrafik Adabı: 6 soru",
        ),
        _FAQItem(
          question: "Ehliyet sınavında kaç soru var?",
          answer: "Ehliyet sınavında toplam 50 soru bulunmaktadır.",
        ),
        _FAQItem(
          question: "Ehliyet sınavında trafik dersinden kaç soru var?",
          answer:
              "Ehliyet sınavındaki soruların 23`si trafik dersinden sorulmaktadır.",
        ),
        _FAQItem(
          question: "Ehliyet sınavında ilk yardım bilgisinden kaç soru var?",
          answer:
              "Ehliyet sınavındaki soruların 12`ü ilk yardım bilgisi dersinden sorulmaktadır.",
        ),
        _FAQItem(
          question: "Ehliyet sınavında motordan kaç soru var?",
          answer:
              "Ehliyet sınavındaki soruların 9 tanesi araç tekniği (motor ve araç bakımı) dersinden sorulmaktadır.",
        ),
        _FAQItem(
          question: "Ehliyet sınavında 3 yanlış 1 doğruyu götürüyor mu?",
          answer:
              "Hayır. Ehliyet sınavında yanlış cevapladığınız sorular net sayınızı etkilemez.",
        ),
        _FAQItem(
          question: "Ehliyet sınavını geçebilmek için kaç puan almalıyım?",
          answer: "Her testten en az 70 puan almanız gerekir.",
        ),
        _FAQItem(
          question:
              "Ehliyet sınavını geçebilmek için kaç soruyu doğru yanıtlamalıyım?",
          answer: "Sınavı geçebilmek için en az 35 soruyu doğru yanıtlamalısınız.",
        ),
        _FAQItem(
          question: "Ehliyet teori (yazılı) sınavına kaç kez girme hakkı var?",
          answer:
              "Adaylar en fazla 4 yazılı ve 4 uygulama sınavına girme hakkına sahiptir.",
        ),
        _FAQItem(
          question: "Ehliyet direksiyon sınavına kaç kez girme hakkı var?",
          answer:
              "Direksiyon sınavına her sürücü adayının 4 kez girme hakkı vardır.",
        ),
        _FAQItem(
          question: "Sınav süresi toplam kaç saattir?",
          answer: "Toplam 45 dakikadır.",
        ),
        _FAQItem(
          question: "Sınavda toplam kaç soru sorulur?",
          answer: "Sınavda toplam 50 soru sorulur.",
        ),
        _FAQItem(
          question: "Sınav başarı puan barajı kaçtır?",
          answer: "Başarı barajı 100 üzerinden 70'dir.",
        ),
        _FAQItem(
          question:
              "Sınavda verdiğim yanlış cevaplar doğru cevaplarımı etkiler mi?",
          answer: "Etkilemez, yanlış doğruyu götürmüyor.",
        ),
        _FAQItem(
          question: "Ders saatlerinde ne kadar devamsızlık yapabilirim?",
          answer: "Mazeretsiz olarak toplam ders saatlerinin %20'si kadar.",
        ),
        _FAQItem(
          question:
              "Sürücü belgemi almadan sürücü sertifikasıyla araç kullanabilir miyim?",
          answer:
              "Hayır. Trafik Tescil Bürosuna başvurup sürücü belgenizi aldıktan sonra araç kullanabilirsiniz.",
        ),
        _FAQItem(
          question: "Sınavda başarısız olduğumda kaç defa sınava girme hakkım var?",
          answer:
              "Sınavdan başarısız olduktan sonra toplam 4 sınav hakkınız vardır (ilk + 3 tekrar).",
        ),
        _FAQItem(
          question: "Sürücü olur raporu nerelerden alınabilir?",
          answer:
              "Sürücü olur raporu vermeye yetkili hastanelerden ve aile hekimlerinden alınabilir.",
        ),
        _FAQItem(
          question:
              "Sürücü sertifikamı aldıktan sonra ne kadar süre içinde Trafik Tescil Bürosuna başvurmalıyım? Süreyi kaçırırsam sertifikam iptal olur mu?",
          answer:
              "Sertifikalar alındığı tarihten itibaren 2 yıl geçerlidir. Sağlık raporu 1 yıl geçerlidir; süresi dolarsa yenisi dosyaya eklenir.",
        ),
        _FAQItem(
          question:
              "İlkokul mezunu olanlar hangi tarihe kadar sürücü belgesi için müracaat edebilir?",
          answer:
              "İlkokul mezunları sürücü belgesi alabilir; şu an için süre kısıtlaması yoktur.",
        ),
        _FAQItem(
          question: "Stajyer ehliyet nedir?",
          answer:
              "Sürücü, 2 yıl içinde 75 ceza puanına ulaşırsa ehliyetine el konur ve psikoteknik değerlendirmeye girer. Gerekli belgeler sonrası sürücü kursuna başvurup yeniden ehliyet alması gerekir.",
        ),
        _FAQItem(
          question:
              "Ben bir sürücü kursuna kayıt oldum, sınavlara girdim başarısız oldum. Kurs değiştirebilir miyim?",
          answer:
              "Evet. Sürücü kurslarında okullardaki gibi nakil işlemi bulunmaktadır.",
        ),
        _FAQItem(
          question:
              "Sınavda toplam kaç soru sorulur? Her dersten kaç doğru bilmem gerekiyor?",
          answer: "Toplam 50 soru sorulur; 35 doğru geçer.",
        ),
        _FAQItem(
          question: "İlköğretim 6. sınıftan terk ettim ehliyet alabilir miyim?",
          answer:
              "Evet. İlköğretim 6., 7. ve 8. sınıflardan terk etmiş olanlar da ehliyet alabilmektedir.",
        ),
        _FAQItem(
          question: "Ehliyet sınavları ne kadar zamanda bir yapılmaktadır?",
          answer:
              "Genellikle ayda bir (istisnalar olabilir) merkezi sınav sistemiyle yapılır.",
        ),
        _FAQItem(
          question:
              "Ehliyet almaya hak kazandım, dosyamı aldım ama 1 sene geçti. Bir tanıdığım benim için ehliyeti alabilir mi? Ne yapmalıyım?",
          answer:
              "1 sene geçtiyse sağlık raporu ve adli sicil belgesini yenilemeniz gerekir. Başvuru şahsen yapılır; vekalet veya başkası aracılığıyla işlem yapılamaz.",
        ),
        _FAQItem(
          question: "Ehliyetimi kaybettim, kayıp ehliyet nasıl yeniden çıkarılır?",
          answer:
              "Gazeteye kayıp ilanı veya karakol tutanağı önerilir. İlgili Trafik Tescil Bürosuna 2 fotoğraf, nüfus cüzdanı aslı, form ve güncel ücretle başvurarak yenileyebilirsiniz. Başka şehirdeyseniz bulunduğunuz yerdeki Trafik Tescil'e başvurabilirsiniz.",
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final languageCode = localeProvider.locale.languageCode;
    final items = _getFAQItems(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.faq ?? 'Sıkça Sorulan Sorular'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final expanded = item.expanded;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black12.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => item.expanded = !item.expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.question,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            expanded ? Icons.remove : Icons.add,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded) ...[
                    Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  bool expanded = false;

  _FAQItem({required this.question, required this.answer});
}
