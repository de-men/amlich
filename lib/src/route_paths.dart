import 'package:angular_components/model/date/date.dart';
import 'package:angular_router/angular_router.dart';
import 'package:intl/intl.dart';

const dateParam = 'date';

class RoutePaths {
  static final lich_am = RoutePath(path: '/:$dateParam');
}

Date getDate(Map<String, String> parameters) {
  final date = parameters[dateParam];
  try {
    return Date.parse(date, DateFormat("dd-MM-yyyy"));
  } on Exception {
    return null;
  }
}
