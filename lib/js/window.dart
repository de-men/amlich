@JS() // sets the context, in this case being `window`
library main; // required library declaration

import 'package:js/js.dart'; // Pull in our dependency

@JS('open') // annotates `open` function to call `open`
external void open(dynamic str);
