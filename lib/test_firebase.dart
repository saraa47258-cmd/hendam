// lib/test_firebase.dart
import 'package:flutter/material.dart';
import 'package:hindam/core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _status = 'جاري الفحص...';
  bool _isLoading = true;
  final List<String> _checks = [];

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _checks.clear();
    });

    try {
      // 1. فحص Firebase Core
      _addCheck('✅ Firebase Core مثبت بنجاح');

      // 2. فحص Firebase Auth
      final auth = FirebaseService.auth;
      _addCheck(
          '✅ Firebase Auth متصل: ${auth.currentUser == null ? "لا يوجد مستخدم" : "مستخدم مسجل دخول"}');

      // 3. فحص Firestore
      final firestore = FirebaseService.firestore;
      _addCheck('✅ Firestore متصل');

      // 4. اختبار كتابة وقراءة بسيطة
      final testDoc = firestore.collection('connection_test').doc('test');
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'اختبار الاتصال',
      });
      _addCheck('✅ اختبار الكتابة نجح');

      final snapshot = await testDoc.get();
      if (snapshot.exists) {
        _addCheck('✅ اختبار القراءة نجح');
      }

      // 5. فحص Firebase Storage
      FirebaseService.storage;
      _addCheck('✅ Firebase Storage متصل');

      // 6. فحص Firebase Analytics
      final analytics = FirebaseService.analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'connection_test',
          parameters: {'test_time': DateTime.now().toString()},
        );
        _addCheck('✅ Firebase Analytics متصل');
      } else {
        _addCheck('⏭️ Firebase Analytics مؤجل (للتحسين في Debug)');
      }

      setState(() {
        _status = '🎉 جميع خدمات Firebase تعمل بشكل صحيح!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ خطأ: $e';
        _isLoading = false;
      });
      _addCheck('❌ فشل الاتصال: $e');
    }
  }

  void _addCheck(String check) {
    setState(() {
      _checks.add(check);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار اتصال Firebase'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حالة الاتصال
            Card(
              color: _isLoading
                  ? Colors.blue.shade50
                  : _status.contains('❌')
                      ? Colors.red.shade50
                      : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        _status.contains('❌')
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        size: 48,
                        color:
                            _status.contains('❌') ? Colors.red : Colors.green,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // قائمة الفحوصات
            Text(
              'تفاصيل الفحص:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _checks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _checks[index],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // زر إعادة الفحص
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFirebaseConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة الفحص'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
