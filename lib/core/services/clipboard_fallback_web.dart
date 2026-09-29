import 'package:web/web.dart' as web;

bool copyTextToClipboard(String text) {
  final body = web.document.body;
  if (body == null) return false;

  final textArea = web.HTMLTextAreaElement()
    ..value = text
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '0';

  body.append(textArea);
  try {
    textArea
      ..focus()
      ..select()
      ..setSelectionRange(0, text.length);
    return web.document.execCommand('copy');
  } catch (_) {
    return false;
  } finally {
    textArea.remove();
  }
}