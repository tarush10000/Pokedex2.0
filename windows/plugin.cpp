#include "generated_plugin_registrant.h"
#include "text_to_speech.h"

void RegisterPlugins(flutter::PluginRegistry* registry) {
    TextToSpeechRegisterWithRegistrar(
    registry->GetRegistrarForPlugin("TextToSpeechHandler"));
}
