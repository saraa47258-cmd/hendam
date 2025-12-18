import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'sign_language_detector.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class SignLanguageCameraPage extends StatefulWidget {
  const SignLanguageCameraPage({super.key});

  @override
  State<SignLanguageCameraPage> createState() => _SignLanguageCameraPageState();
}

class _SignLanguageCameraPageState extends State<SignLanguageCameraPage> {
  CameraController? _cameraController;
  final SignLanguageDetector _detector = SignLanguageDetector();
  String _detectedText = '';
  String _fullText = '';
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  int _skipFrames = 0;
  bool _autoAddEnabled = false;
  int _sameLetterCount = 0;
  String _lastDetectedLetter = '';
  DateTime? _lastDetectionTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // تهيئة المكشاف أولاً
      await _detector.initialize();
      
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('لا توجد كاميرات متاحة');
        return;
      }

      // اختيار الكاميرا الأمامية
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.low, // استخدم low للأداء الأفضل
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // للأندرويد
      );

      await _cameraController!.initialize();
      
      setState(() {
        _isCameraInitialized = true;
      });

      // بدء معالجة الصور
      _cameraController!.startImageStream(_processImage);
    } catch (e) {
      print('خطأ في تهيئة الكاميرا: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    // تخطي إطارات للأداء الأفضل
    _skipFrames++;
    if (_skipFrames % 15 != 0) return; // معالجة إطار واحد من كل 15
    
    if (_isProcessing) return;
    
    _isProcessing = true;

    try {
      // تحويل CameraImage إلى JPEG bytes
      final imageBytes = await _convertToJpeg(image);
      
      if (imageBytes != null) {
        print('📸 معالجة صورة بحجم: ${imageBytes.length} bytes');
        
        final detectedChar = await _detector.detectSignLanguage(imageBytes);
        
        print('📝 النتيجة: "$detectedChar"');
        
        if (detectedChar.isNotEmpty) {
          setState(() {
            _detectedText = detectedChar;
          });
          print('✅ تم التعرف على: $detectedChar');
          
          // الإضافة التلقائية
          if (_autoAddEnabled) {
            if (detectedChar == _lastDetectedLetter) {
              _sameLetterCount++;
              // إذا تم الكشف عن نفس الحرف 5 مرات متتالية، أضفه تلقائياً
              if (_sameLetterCount >= 5) {
                _addCharacterToText();
                _sameLetterCount = 0;
                _lastDetectedLetter = '';
              }
            } else {
              _lastDetectedLetter = detectedChar;
              _sameLetterCount = 1;
            }
          }
          
          _lastDetectionTime = DateTime.now();
        } else {
          // إذا لم يتم الكشف عن شيء لمدة ثانية، امسح
          if (_lastDetectionTime != null &&
              DateTime.now().difference(_lastDetectionTime!).inSeconds > 1) {
            setState(() {
              _detectedText = '';
              _sameLetterCount = 0;
              _lastDetectedLetter = '';
            });
          }
        }
      } else {
        print('❌ فشل تحويل الصورة');
      }
    } catch (e, stack) {
      print('❌ خطأ في معالجة الصورة: $e');
      print('Stack: $stack');
    } finally {
      _isProcessing = false;
    }
  }

  Future<Uint8List?> _convertToJpeg(CameraImage image) async {
    try {
      // تحويل YUV إلى RGB
      final int width = image.width;
      final int height = image.height;
      
      final img.Image rgbImage = img.Image(width: width, height: height);
      
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * width + x;
          
          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];
          
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        _sameLetterCount = 0;
        _lastDetectedLetter = '';
      });
      
      // تشغيل اهتزاز خفيف للتأكيد
      // يمكن إضافة مكتبة vibration في المستقبل
    }
  }

  void _addSpace() {
    setState(() {
      _fullText += ' ';
    });
  }

  void _clearText() {
    setState(() {
      _fullText = '';
      _detectedText = '';
      _sameLetterCount = 0;
      _lastDetectedLetter = '';
    });
  }
  
  void _deleteLastCharacter() {
    if (_fullText.isNotEmpty) {
      setState(() {
        _fullText = _fullText.substring(0, _fullText.length - 1);
      });
    }
  }
  
  void _toggleAutoAdd() {
    setState(() {
      _autoAddEnabled = !_autoAddEnabled;
      _sameLetterCount = 0;
      _lastDetectedLetter
  void _addCharacterToText() {
    if (_detectedText.isNotEmpty) {
      setState(() {
        _fullText += _detectedText;
        _detectedText = '';
      });
    }
  }

  void _addSpace() {
    setState(() {
      _fullText += ' ';
    })  actions: [
          // زر الإضافة التلقائية
          IconButton(
            icon: Icon(
              _autoAddEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
              color: _autoAddEnabled ? Colors.yellow : Colors.white,
            ),
            tooltip: _autoAddEnabled ? 'إيقاف الإضافة التلقائية' : 'تفعيل الإضافة التلقائية',
            onPressed: _toggleAutoAdd,
          ),
          // عداد للإضافة التلقائية
          if (_autoAddEnabled && _sameLetterCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$_sameLetterCount/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ;
  }

  void _clearText() {
    setState(() {
      _fullText = '';
      _detectedText = '';
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التعرف على لغة الإشارة'),
        backgroundColor: Colors.teal,
      ),
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // عرض الكاميرا
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      // عرض الحرف المكتشف
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _detectedText.isEmpty 
                                  ? Colors.black54 
                                  : Colors.green.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _detectedText.isEmpty 
                                    ? Colors.transparent 
                                    : Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _detectedText.isEmpty
                                      ? 'اعرض يدك للكاميرا'
                                      : _detectedText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _detectedText.isEmpty ? 24 : 56,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_detectedText.isNotEmpty)
                                  const SizedBox(height: 8),
                                if (_detectedText.isNotEmpty)
                                  const Text(
                                    '✓ تم الكشف',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // مؤشر المعالجة
                      if (_isProcessing)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'معالجة...',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),2),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // صف الأزرار الأول
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton.icon(
                                onPressed: _addCharacterToText,
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('إضافة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton.icon(
                                onPressed: _addSpace,
                                icon: const Icon(Icons.space_bar, size: 20),
                                label: const Text('مسافة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton.icon(
                                onPressed: _deleteLastCharacter,
                                icon: const Icon(Icons.backspace, size: 20),
                                label: const Text('حذف'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // صف الأزرار الثاني
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton.icon(
                                onPressed: _clearText,
                                icon: const Icon(Icons.delete_sweep, size: 20),
                                label: const Text('مسح الكل'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton.icon(
                                onPressed: _fullText.isNotEmpty
                                    ? () {
                                        // نسخ النص للحافظة
                                        // يمكن إضافة مكتبة clipboard في المستقبل
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم نسخ النص'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.copy, size: 20),
                                label: const Text('نسخ'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  disabledBackgroundColor: Colors.grey[300],
                                  disabledForegroundColor: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ]vatedButton.icon(
                        onPressed: _addCharacterToText,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addSpace,
                        icon: const Icon(Icons.space_bar),
                        label: const Text('مسافة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _clearText,
                        icon: const Icon(Icons.delete),
                        label: const Text('مسح'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
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
