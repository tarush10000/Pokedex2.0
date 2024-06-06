#ifndef FLUTTER_PLUGIN_TEXT_TO_SPEECH_PLUGIN_H_
#define FLUTTER_PLUGIN_TEXT_TO_SPEECH_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(TextToSpeechPlugin, text_to_speech_plugin, TEXT_TO_SPEECH, PLUGIN, GObject)

void text_to_speech_plugin_register_with_registrar(FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_TEXT_TO_SPEECH_PLUGIN_H_
