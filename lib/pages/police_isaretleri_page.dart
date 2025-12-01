import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/app_localizations.dart';

class PoliceIsaretleriPage extends StatelessWidget {
  const PoliceIsaretleriPage({super.key});

  List<PoliceSign> _getPoliceSigns(String languageCode) {
    if (languageCode == 'en') {
      return [
        PoliceSign(
          name: 'Traffic pull signal on red phase.',
          description:
              'The traffic police uses this signal to stop all vehicles and pull traffic. This signal is shown when the red light is on.',
          imagePath: 'lib/assests/police/1.jpg',
          color: Colors.red,
        ),
        PoliceSign(
          name: 'Vehicle stop signal to the right.',
          description:
              'With this signal, the police indicates that vehicles on the right should stop, and vehicles going left can pass.',
          imagePath: 'lib/assests/police/2.jpg',
          color: Colors.blue,
        ),
        PoliceSign(
          name: 'Vehicle stop signal to the left.',
          description:
              'With this signal, the police shows that vehicles on the left should stop, and vehicles going right can pass.',
          imagePath: 'lib/assests/police/3.jpg',
          color: Colors.green,
        ),
        PoliceSign(
          name:
              'Traffic in front and behind will stop, traffic in both arm directions can move.',
          description:
              'With this signal, the police stops traffic in opposite directions while allowing vehicles in side directions to pass.',
          imagePath: 'lib/assests/police/4.jpg',
          color: Colors.orange,
        ),
        PoliceSign(
          name:
              'Traffic in front and behind will stop, traffic in both arm directions can move.',
          description:
              'Similarly, this signal also stops opposite traffic and allows passage to side directions.',
          imagePath: 'lib/assests/police/5.jpg',
          color: Colors.purple,
        ),
        PoliceSign(
          name: 'Traffic on the right can go left.',
          description:
              'With this signal, the police indicates that vehicles on the right can turn left, and other directions must stop.',
          imagePath: 'lib/assests/police/6.jpg',
          color: Colors.teal,
        ),
        PoliceSign(
          name: 'Traffic on the left can go right.',
          description:
              'With this signal, the police shows that vehicles on the left can turn right, and other directions must wait.',
          imagePath: 'lib/assests/police/7.jpg',
          color: Colors.amber,
        ),
        PoliceSign(
          name: 'Closing traffic in all directions - right arm.',
          description:
              'With this signal, the police stops traffic in all directions. They give this signal using their right arm.',
          imagePath: 'lib/assests/police/8.jpg',
          color: Colors.cyan,
        ),
        PoliceSign(
          name: 'Closing traffic in all directions - left arm.',
          description:
              'Similarly stops all traffic but this time gives the signal using the left arm.',
          imagePath: 'lib/assests/police/9.jpg',
          color: Colors.indigo,
        ),
        PoliceSign(
          name: 'Traffic acceleration movement - left arm.',
          description:
              'With this signal, the police enables vehicles to accelerate and speeds up traffic flow.',
          imagePath: 'lib/assests/police/10.jpg',
          color: Colors.teal,
        ),
        PoliceSign(
          name: 'Traffic deceleration movement - right arm.',
          description:
              'With this signal, the police enables vehicles to slow down and move more controlled.',
          imagePath: 'lib/assests/police/11.jpg',
          color: Colors.deepOrange,
        ),
        PoliceSign(
          name: 'Night turn signal.',
          description:
              'In darkness or when visibility is limited, the police indicates with this signal that vehicles can turn.',
          imagePath: 'lib/assests/police/12.jpg',
          color: Colors.deepPurple,
        ),
        PoliceSign(
          name: 'Night pass signal.',
          description:
              'At night or when visibility is low, the police shows with this signal that vehicles can pass.',
          imagePath: 'lib/assests/police/13.jpg',
          color: Colors.lime,
        ),
        PoliceSign(
          name: 'Night stop signal.',
          description:
              'In darkness or when visibility is limited, the police indicates with this signal that vehicles must stop.',
          imagePath: 'lib/assests/police/14.jpg',
          color: Colors.pink,
        ),
        PoliceSign(
          name: 'Direction indication signal to the right.',
          description:
              'With this signal, the police enables vehicles to head right and turn right.',
          imagePath: 'lib/assests/police/15.jpg',
          color: Colors.brown,
        ),
        PoliceSign(
          name: 'Direction indication signal to the left.',
          description:
              'With this signal, the police enables vehicles to head left and turn left.',
          imagePath: 'lib/assests/police/16.jpg',
          color: Colors.grey,
        ),
        PoliceSign(
          name: 'Traffic pull signal at red light.',
          description:
              'When the red light is on, the police uses this signal to pull vehicles and open traffic.',
          imagePath: 'lib/assests/police/17.jpg',
          color: Colors.blueGrey,
        ),
        PoliceSign(
          name: 'Traffic flow interruption signal.',
          description:
              'With this signal, the police interrupts traffic flow and stops vehicles. Usually used in emergencies.',
          imagePath: 'lib/assests/police/18.jpg',
          color: Colors.redAccent,
        ),
        PoliceSign(
          name: 'Signal to leave traffic flow to traffic lights.',
          description:
              'With this signal, the police returns traffic control back to traffic lights and returns to normal traffic flow.',
          imagePath: 'lib/assests/police/19.jpg',
          color: Colors.greenAccent,
        ),
      ];
    } else {
      return [
        PoliceSign(
          name: 'Bir kırmızı fazda trafiğin çekilmesi işareti.',
          description:
              'Trafik polisi bu işaretle tüm araçların durmasını ve trafiğin çekilmesini sağlar. Kırmızı ışık yanıyorken bu işaret gösterilir.',
          imagePath: 'lib/assests/police/1.jpg',
          color: Colors.red,
        ),
        PoliceSign(
          name: 'Araç durdurma işareti sağa doğru.',
          description:
              'Polis bu işaretle sağ taraftaki araçların durmasını, sola giden araçların geçebileceğini belirtir.',
          imagePath: 'lib/assests/police/2.jpg',
          color: Colors.blue,
        ),
        PoliceSign(
          name: 'Araç durdurma işareti sola doğru.',
          description:
              'Bu işaretle polis sol taraftaki araçların durmasını, sağa giden araçların geçebileceğini gösterir.',
          imagePath: 'lib/assests/police/3.jpg',
          color: Colors.green,
        ),
        PoliceSign(
          name:
              'Ön ve arka taraftaki trafik duracak, her iki kol yönündeki trafik hareket edebilir.',
          description:
              'Bu işaretle polis karşılıklı yönlerdeki trafiği durdururken, yan yönlerdeki araçların geçişine izin verir.',
          imagePath: 'lib/assests/police/4.jpg',
          color: Colors.orange,
        ),
        PoliceSign(
          name:
              'Ön ve arka taraftaki trafik duracak, her iki kol yönündeki trafik hareket edebilir.',
          description:
              'Benzer şekilde bu işaret de karşılıklı trafiği durdurur, yan yönlere geçiş izni verir.',
          imagePath: 'lib/assests/police/5.jpg',
          color: Colors.purple,
        ),
        PoliceSign(
          name: 'Sağ taraftaki trafik sola gidebilir.',
          description:
              'Bu işaretle polis sağ taraftaki araçların sola dönüş yapabileceğini, diğer yönlerin durması gerektiğini belirtir.',
          imagePath: 'lib/assests/police/6.jpg',
          color: Colors.teal,
        ),
        PoliceSign(
          name: 'Sol taraftaki trafik sağa gidebilir.',
          description:
              'Polis bu işaretle sol taraftaki araçların sağa dönüş yapabileceğini, diğer yönlerin beklemesi gerektiğini gösterir.',
          imagePath: 'lib/assests/police/7.jpg',
          color: Colors.amber,
        ),
        PoliceSign(
          name: 'Trafiğin bütün istikametlere kapatılması - sağ kol.',
          description:
              'Bu işaretle polis tüm yönlerdeki trafiği durdurur. Sağ kolunu kullanarak bu işareti verir.',
          imagePath: 'lib/assests/police/8.jpg',
          color: Colors.cyan,
        ),
        PoliceSign(
          name: 'Trafiğin bütün istikametlere kapatılması - sol kol.',
          description:
              'Benzer şekilde tüm trafiği durdurur ancak bu sefer sol kolunu kullanarak işaret verir.',
          imagePath: 'lib/assests/police/9.jpg',
          color: Colors.indigo,
        ),
        PoliceSign(
          name: 'Trafiği hızlandırma hareketi - sol kol.',
          description:
              'Polis bu işaretle araçların hızlanmasını ve trafik akışının hızlanmasını sağlar.',
          imagePath: 'lib/assests/police/10.jpg',
          color: Colors.teal,
        ),
        PoliceSign(
          name: 'Trafiği yavaşlatma hareketi - sağ kol.',
          description:
              'Bu işaretle polis araçların yavaşlamasını ve daha kontrollü hareket etmesini sağlar.',
          imagePath: 'lib/assests/police/11.jpg',
          color: Colors.deepOrange,
        ),
        PoliceSign(
          name: 'Gece dönüş işareti.',
          description:
              'Karanlıkta veya görüşün kısıtlı olduğu durumlarda polis bu işaretle araçların dönüş yapabileceğini belirtir.',
          imagePath: 'lib/assests/police/12.jpg',
          color: Colors.deepPurple,
        ),
        PoliceSign(
          name: 'Gece geç işareti.',
          description:
              'Geceleri veya görüşün az olduğu durumlarda polis bu işaretle araçların geçebileceğini gösterir.',
          imagePath: 'lib/assests/police/13.jpg',
          color: Colors.lime,
        ),
        PoliceSign(
          name: 'Gece dur işareti.',
          description:
              'Karanlıkta veya görüşün kısıtlı olduğu durumlarda polis bu işaretle araçların durması gerektiğini belirtir.',
          imagePath: 'lib/assests/police/14.jpg',
          color: Colors.pink,
        ),
        PoliceSign(
          name: 'Yön tayini sağa işareti.',
          description:
              'Polis bu işaretle araçların sağa doğru yönlenmesini ve sağa dönüş yapmasını sağlar.',
          imagePath: 'lib/assests/police/15.jpg',
          color: Colors.brown,
        ),
        PoliceSign(
          name: 'Yön tayini sola işareti.',
          description:
              'Bu işaretle polis araçların sola doğru yönlenmesini ve sola dönüş yapmasını sağlar.',
          imagePath: 'lib/assests/police/16.jpg',
          color: Colors.grey,
        ),
        PoliceSign(
          name: 'Kırmızı ışıkta trafiği çekme işareti.',
          description:
              'Kırmızı ışık yanıyorken polis bu işaretle araçların çekilmesini ve trafiğin açılmasını sağlar.',
          imagePath: 'lib/assests/police/17.jpg',
          color: Colors.blueGrey,
        ),
        PoliceSign(
          name: 'Trafik akımını kesme işareti.',
          description:
              'Bu işaretle polis trafik akışını keser ve araçların durmasını sağlar. Genellikle acil durumlarda kullanılır.',
          imagePath: 'lib/assests/police/18.jpg',
          color: Colors.redAccent,
        ),
        PoliceSign(
          name: 'Trafik akımının trafik ışıklarına bırakılması işareti.',
          description:
              'Polis bu işaretle trafik kontrolünü tekrar trafik ışıklarına bırakır ve normal trafik akışına döner.',
          imagePath: 'lib/assests/police/19.jpg',
          color: Colors.greenAccent,
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
    final policeSigns = _getPoliceSigns(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations?.policeSignals ?? 'Polis İşaretleri',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFF5F5F5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İşaretler listesi
            Text(
              localizations?.policeSignals ?? 'Polis İşaretleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: policeSigns.length,
              itemBuilder: (context, index) {
                return _buildPoliceSignCard(
                  context,
                  policeSigns[index],
                  isDark,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliceSignCard(
    BuildContext context,
    PoliceSign sign,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tek resim
            Center(
              child: Container(
                width: 200,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    sign.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: sign.color.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.local_police,
                          color: sign.color,
                          size: 80,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (sign.name.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Başlık
              Text(
                sign.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[100] : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 8),
            // Açıklama
            Text(
              sign.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[200] : Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PoliceSign {
  final String name;
  final String description;
  final String imagePath;
  final Color color;

  PoliceSign({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}
