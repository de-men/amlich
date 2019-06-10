import 'package:angular_router/angular_router.dart';
import 'package:licham/src/route_paths.dart';

import 'lich_am_component.template.dart' as lich_am_template;

export 'route_paths.dart';

class Routes {

  static final lich_am = RouteDefinition(
    routePath: RoutePaths.lich_am,
    component: lich_am_template.LichAmComponentNgFactory,
    useAsDefault: true
  );

  static final all = <RouteDefinition>[
    lich_am
  ];
}
