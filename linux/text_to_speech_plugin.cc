#include "text_to_speech_plugin.h"
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <espeak/speak_lib.h>

#define TEXT_TO_SPEECH_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), text_to_speech_plugin_get_type(), \
                              TextToSpeechPlugin))

struct _TextToSpeechPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(TextToSpeechPlugin, text_to_speech_plugin, g_object_get_type())

static void text_to_speech_plugin_handle_method_call(
    TextToSpeechPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "speak") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    const gchar* text = fl_value_get_string(fl_value_lookup_string(args, "text"));
    if (text != nullptr) {
      espeak_Synth(text, strlen(text), 0, POS_CHARACTER, 0, espeakCHARS_AUTO, NULL, NULL);
      espeak_Synchronize();
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_TEXT", "Text is null", nullptr));
    }
  } else if (strcmp(method, "pause") == 0) {
    espeak_Cancel();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void text_to_speech_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(text_to_speech_plugin_parent_class)->dispose(object);
}

static void text_to_speech_plugin_class_init(TextToSpeechPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = text_to_speech_plugin_dispose;
}

static void text_to_speech_plugin_init(TextToSpeechPlugin* self) {}

void text_to_speech_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  TextToSpeechPlugin* plugin = TEXT_TO_SPEECH_PLUGIN(
      g_object_new(text_to_speech_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "ttschannel",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, 
                                            (FlMethodCallHandlerFunc)text_to_speech_plugin_handle_method_call,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
