package com.example.hindam

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hindam/hand_gesture"
    private var handGestureHandler: HandGestureHandler? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        handGestureHandler = HandGestureHandler(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    handGestureHandler?.initialize(result)
                }
                "detectHand" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    if (imageBytes != null) {
                        handGestureHandler?.detectHand(imageBytes, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image bytes are null", null)
                    }
                }
                "dispose" -> {
                    handGestureHandler?.dispose()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
