import 'package:flutter_web_ui/ui.dart' as ui;

// TODO: change `my_app` to refer to your app package name.
import 'package:licham/main.dart' as app;

Future main() async {
  await ui.webOnlyInitializePlatform();
  app.main();
}
