import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sign_language_camera_page.dart';

class SignLanguageHomePage extends StatelessWidget {
  const SignLanguageHomePage({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    // طلب إذن الكاميرا
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      // الانتقال لصفحة الكاميرا
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignLanguageCameraPage(),
          ),
        );
      }
    } else if (status.isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى السماح باستخدام الكاميرا'),
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // فتح إعدادات التطبيق
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لغة الإشارة'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sign_language,
              size: 120,
              color: Colors.teal[300],
            ),
            const SizedBox(height: 30),
            const Text(
              'التعرف على لغة الإشارة',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'استخدم الكاميرا لتحويل إشارات اليد إلى نص',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () => _requestPermissions(context),
              icon: const Icon(Icons.camera_alt, size: 28),
              label: const Text(
                'ابدأ الآن',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كيفية الاستخدام:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('1️⃣ اسمح للتطبيق باستخدام الكاميرا'),
                      SizedBox(height: 5),
                      Text('2️⃣ قف أمام الكاميرا وابدأ بالإشارات'),
                      SizedBox(height: 5),
                      Text('3️⃣ اضغط "إضافة" لإضافة الحرف للنص'),
                      SizedBox(height: 5),
                      Text('4️⃣ استخدم "مسافة" للفصل بين الكلمات'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
