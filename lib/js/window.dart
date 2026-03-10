import 'dart:js_interop';

@JS('open')
external void _open(JSString url);

void open(String url) => _open(url.toJS);
