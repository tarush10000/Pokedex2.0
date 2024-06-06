import Flutter
import UIKit
import AVFoundation

public class TextToSpeechHandler: NSObject, FlutterPlugin {
    private var synthesizer = AVSpeechSynthesizer()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ttschannel", binaryMessenger: registrar.messenger())
        let instance = TextToSpeechHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "speak":
            if let args = call.arguments as? [String: Any],
                let text = args["text"] as? String {
                speak(text: text)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_TEXT", message: "Text is null", details: nil))
            }
        case "pause":
            pauseSpeaking()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    private func pauseSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
