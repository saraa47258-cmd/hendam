package com.example.hindam

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import android.content.Context

/**
 * مكشاف إشارات اليد باستخدام MediaPipe Hand Landmarker
 * 
 * تقنية الكشف:
 * 1. استقبال صورة من Flutter عبر MethodChannel
 * 2. تحويل الصورة إلى Bitmap
 * 3. استخدام MediaPipe للكشف عن 21 نقطة لليد
 * 4. تحليل حالة الأصابع (مرفوعة/منخفضة)
 * 5. تصنيف الإشارة إلى حرف بناءً على القواعد
 */
class HandGestureHandler(private val context: Context) {
    
    private var handLandmarker: HandLandmarker? = null
    private val TAG = "HandGestureHandler"
    
    /**
     * تهيئة MediaPipe Hand Landmarker
     */
    fun initialize(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "🔄 Initializing HandLandmarker...")
            
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("hand_landmarker.task")
                .build()
            
            val options = HandLandmarker.HandLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)
                .setNumHands(1) // كشف يد واحدة
                .setMinHandDetectionConfidence(0.3f) // حساسية منخفضة للكشف الأفضل
                .setMinHandPresenceConfidence(0.3f)
                .setMinTrackingConfidence(0.3f)
                .build()
            
            handLandmarker = HandLandmarker.createFromOptions(context, options)
            Log.d(TAG, "✅ HandLandmarker initialized successfully!")
            result.success("initialized")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to initialize: ${e.message}", e)
            result.error("INIT_ERROR", "Failed to initialize: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * كشف اليد في الصورة وتحويلها لحرف
     */
    fun detectHand(imageBytes: ByteArray, result: MethodChannel.Result) {
        try {
            if (handLandmarker == null) {
                Log.e(TAG, "❌ HandLandmarker not initialized")
                result.error("NOT_INITIALIZED", "HandLandmarker not initialized", null)
                return
            }
            
            Log.d(TAG, "📸 Processing image of size: ${imageBytes.size} bytes")
            
            // تحويل bytes إلى Bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                Log.e(TAG, "❌ Failed to decode bitmap")
                result.success("")
                return
            }
            
            Log.d(TAG, "🖼️ Bitmap size: ${bitmap.width}x${bitmap.height}")
            
            // تحويل Bitmap إلى MPImage
            val mpImage = BitmapImageBuilder(bitmap).build()
            
            // كشف اليد
            val detectionResult = handLandmarker?.detect(mpImage)
            
            Log.d(TAG, "👋 Hands detected: ${detectionResult?.landmarks()?.size ?: 0}")
            
            if (detectionResult?.landmarks()?.isEmpty() != false) {
                result.success("")
                return
            }
            
            // تحويل النتيجة إلى حرف
            val landmarks = detectionResult.landmarks()[0]
            if (landmarks.size >= 21) {
                val letter = classifyToLetter(landmarks)
                Log.d(TAG, "✅ Detected letter: $letter")
                result.success(letter)
            } else {
                Log.w(TAG, "⚠️ Not enough landmarks: ${landmarks.size}")
                result.success("")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Detection error: ${e.message}", e)
            result.error("DETECTION_ERROR", "Detection failed: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * تحديد إذا كان الإصبع مرفوع أم لا
     * المنطق: إذا كان طرف الإصبع (tip) أعلى من المفصل (pip)، فالإصبع مرفوع
     */
    private fun fingerUp(landmarks: List<com.google.mediapipe.tasks.components.containers.NormalizedLandmark>, 
                        tip: Int, pip: Int): Boolean {
        return landmarks[tip].y() < landmarks[pip].y()
    }
    
    /**
     * تصنيف الإشارة إلى حرف بناءً على حالة الأصابع
     * 
     * نقاط MediaPipe Hand Landmarks:
     * - الإبهام: tip=4, ip=3
     * - السبابة: tip=8, pip=6
     * - الوسطى: tip=12, pip=10
     * - البنصر: tip=16, pip=14
     * - الخنصر: tip=20, pip=18
     */
    private fun classifyToLetter(landmarks: List<com.google.mediapipe.tasks.components.containers.NormalizedLandmark>): String {
        try {
            // فهرس نقاط الأصابع (MediaPipe Hands)
            val thumbTip = 4
            val thumbIp = 3
            val indexTip = 8
            val indexPip = 6
            val middleTip = 12
            val middlePip = 10
            val ringTip = 16
            val ringPip = 14
            val pinkyTip = 20
            val pinkyPip = 18
            
            // تحديد حالة كل إصبع
            val thumbUp = fingerUp(landmarks, thumbTip, thumbIp)
            val indexUp = fingerUp(landmarks, indexTip, indexPip)
            val middleUp = fingerUp(landmarks, middleTip, middlePip)
            val ringUp = fingerUp(landmarks, ringTip, ringPip)
            val pinkyUp = fingerUp(landmarks, pinkyTip, pinkyPip)
            
            Log.d(TAG, "🖐️ Fingers: thumb=$thumbUp, index=$indexUp, middle=$middleUp, ring=$ringUp, pinky=$pinkyUp")
            
            // قواعد التصنيف - يمكن تعديلها حسب لغة الإشارة المطلوبة
            val letter = when {
                // إصبع واحد (السبابة فقط)
                indexUp && !middleUp && !ringUp && !pinkyUp && !thumbUp -> "أ"
                
                // إصبعين (السبابة + الوسطى) - علامة السلام
                indexUp && middleUp && !ringUp && !pinkyUp && !thumbUp -> "ب"
                
                // 3 أصابع (السبابة + الوسطى + البنصر)
                indexUp && middleUp && ringUp && !pinkyUp && !thumbUp -> "ج"
                
                // 4 أصابع (بدون الإبهام)
                indexUp && middleUp && ringUp && pinkyUp && !thumbUp -> "د"
                
                // قبضة (كل الأصابع مغلقة)
                !thumbUp && !indexUp && !middleUp && !ringUp && !pinkyUp -> "ه"
                
                // يد مفتوحة (5 أصابع كلها مرفوعة)
                thumbUp && indexUp && middleUp && ringUp && pinkyUp -> "و"
                
                // إبهام فقط
                thumbUp && !indexUp && !middleUp && !ringUp && !pinkyUp -> "ي"
                
                // إبهام + سبابة (مسدس)
                thumbUp && indexUp && !middleUp && !ringUp && !pinkyUp -> "ل"
                
                // سبابة + خنصر (rock sign)
                indexUp && !middleUp && !ringUp && pinkyUp && !thumbUp -> "م"
                
                // إبهام + سبابة + وسطى
                thumbUp && indexUp && middleUp && !ringUp && !pinkyUp -> "ن"
                
                // إبهام + خنصر
                thumbUp && !indexUp && !middleUp && !ringUp && pinkyUp -> "ت"
                
                // إبهام + سبابة + خنصر
                thumbUp && indexUp && !middleUp && !ringUp && pinkyUp -> "س"
                
                // وسطى فقط
                !thumbUp && !indexUp && middleUp && !ringUp && !pinkyUp -> "ك"
                
                // وسطى + بنصر
                !thumbUp && !indexUp && middleUp && ringUp && !pinkyUp -> "ش"
                
                // بنصر فقط
                !thumbUp && !indexUp && !middleUp && ringUp && !pinkyUp -> "ر"
                
                // خنصر فقط
                !thumbUp && !indexUp && !middleUp && !ringUp && pinkyUp -> "ز"
                
                // إشارة غير معروفة
                else -> ""
            }
            
            Log.d(TAG, "📝 Classified as: $letter")
            return letter
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Classification error: ${e.message}", e)
            return ""
        }
    }
    
    /**
     * إغلاق المكشاف وتحرير الموارد
     */
    fun dispose() {
        handLandmarker?.close()
        handLandmarker = null
        Log.d(TAG, "🔒 HandLandmarker disposed")
    }
}
