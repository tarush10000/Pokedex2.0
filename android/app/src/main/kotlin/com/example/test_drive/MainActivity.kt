package com.example.test_drive

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import java.util.*

class MainActivity: FlutterActivity(), OnInitListener {
    private lateinit var tts: TextToSpeech
    private val CHANNEL = "ttschannel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(this, this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "speak") {
                val text = call.argument<String>("text")
                if (text != null) {
                    speak(text)
                    result.success(null)
                } else {
                    result.error("INVALID_TEXT", "Text is null", null)
                }
            }
            else if (call.method == "pause") {
                pauseSpeaking()
                result.success(null)
            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts.language = Locale.US
        }
    }

    private fun speak(text: String) {
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    private fun pauseSpeaking() {
        tts.stop()
    }

    override fun onDestroy() {
        // Shutdown TTS when the activity is destroyed
        if (tts != null) {
            tts.stop()
            tts.shutdown()
        }
        super.onDestroy()
    }
}
