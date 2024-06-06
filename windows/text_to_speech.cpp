#include "text_to_speech.h"
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>
#include <sapi.h>
#include <string>
#include <memory>
#include <sstream>

class TextToSpeechHandler {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "ttschannel",
        &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<TextToSpeechHandler>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto& call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  TextToSpeechHandler() {
    // Initialize COM library
    if (FAILED(::CoInitialize(nullptr))) {
      // Handle the error
    }

    // Create a SAPI voice
    if (FAILED(::CoCreateInstance(CLSID_SpVoice, nullptr, CLSCTX_ALL, IID_ISpVoice, (void**)&voice_))) {
      // Handle the error
    }
  }

  ~TextToSpeechHandler() {
    if (voice_) {
      voice_->Release();
    }
    ::CoUninitialize();
  }

 private:
  void HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& call,
                        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (call.method_name().compare("speak") == 0) {
      const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
      auto text = std::get_if<std::string>(&arguments->at(flutter::EncodableValue("text")));
      if (text) {
        Speak(*text);
        result->Success();
      } else {
        result->Error("INVALID_TEXT", "Text is null");
      }
    } else if (call.method_name().compare("pause") == 0) {
      Pause();
      result->Success();
    } else {
      result->NotImplemented();
    }
  }

  void Speak(const std::string& text) {
    if (voice_) {
      std::wstring wtext(text.begin(), text.end());
      voice_->Speak(wtext.c_str(), SPF_DEFAULT, nullptr);
    }
  }

  void Pause() {
    if (voice_) {
      voice_->Pause();
    }
  }

  ISpVoice* voice_ = nullptr;
};

void TextToSpeechRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  TextToSpeechHandler::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
