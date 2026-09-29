import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'clipboard_fallback_stub.dart'
    if (dart.library.html) 'clipboard_fallback_web.dart' as fallback;

Future<bool> copyTextToClipboard(String text) async {
  if (kIsWeb && fallback.copyTextToClipboard(text)) return true;

  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    return false;
  }
}