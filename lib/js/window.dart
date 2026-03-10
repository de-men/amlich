import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('open')
external void _open(JSString url);

void open(String url) => _open(url.toJS);

void download(String filename, String content) {
  final blob = web.Blob(
    [content.toJS].toJS,
    web.BlobPropertyBag(type: 'text/calendar;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  (web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = filename)
      .click();
  web.URL.revokeObjectURL(url);
}
