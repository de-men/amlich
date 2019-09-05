import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  DateFormat weekFormat;
  DateFormat monthYearFormat;
  DateFormat ddMMyyyyFormat;
  DateTime solarDate;

  MainBloc();

  @override
  MainState get initialState => MainUninitialized();

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    if (event is AppStarted) {
      Intl.defaultLocale = "vi_VN";
      initializeDateFormatting("vi", null).then((_) => _initDateFormat());
      solarDate = DateTime.now();
      yield MainDateChange(date: solarDate);
      // yield MainInitialized();
    }
  }

  void _initDateFormat() {
    print('_initDateFormat');
    weekFormat = DateFormat("EEEE", "vi");
    monthYearFormat = DateFormat("MMMM y", "vi");
    ddMMyyyyFormat = DateFormat('dd/MM/yyyy', "vi");
  }
}
