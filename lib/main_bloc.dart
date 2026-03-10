import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:licham/lunar.dart';
import 'package:licham/lunar_converter.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc(this.solarDate) : super(const MainUninitialized()) {
    on<MainEvent>((event, emit) {
      if (event is AppStarted) {
        Intl.defaultLocale = 'vi_VN';
        unawaited(
          initializeDateFormatting('vi').then((_) => _initDateFormat()),
        );
        solarDate = solarDate ?? DateTime.now();
        add(const SolarChanged());
      } else if (event is SolarChanged) {
        lunarDate = _calculate(solarDate!);
        emit(DateUpdate(solar: solarDate, lunar: lunarDate));
      } else if (event is TodaySelected) {
        solarDate = DateTime.now();
        add(const SolarChanged());
      } else if (event is PreviousSelected) {
        solarDate = solarDate!.add(const Duration(days: -1));
        add(const SolarChanged());
      } else if (event is NextSelected) {
        solarDate = solarDate!.add(const Duration(days: 1));
        add(const SolarChanged());
      } else if (event is SolarSelected) {
        solarDate = event.solar;
        add(const SolarChanged());
      } else if (event is LunarSelected) {
        final ddMMyyyy = event.lunar!.split('/');
        solarDate = LunarConverter.lunarToSolar(
          int.parse(ddMMyyyy[0]),
          int.parse(ddMMyyyy[1]),
          int.parse(ddMMyyyy[2]),
          lunarMonth!.endsWith('Nhuận') ? 1 : 0,
        );
        add(const SolarChanged());
      }
    });
  }

  late DateFormat weekFormat;
  late DateFormat monthYearFormat;
  DateFormat? ddMMyyyyFormat;

  DateTime? solarDate;
  Lunar? lunarDate;
  String? lunarMonth;

  void _initDateFormat() {
    weekFormat = DateFormat('EEEE', 'vi');
    monthYearFormat = DateFormat('MMMM, y', 'vi');
    ddMMyyyyFormat = DateFormat('dd/MM/yyyy', 'vi');
  }

  Lunar _calculate(DateTime date) {
    final jd = LunarConverter.julianDay(date.day, date.month, date.year);
    final result = LunarConverter.solarToLunar(date.day, date.month, date.year);
    final lunarMonthIndex = result[1];
    final year = result[2];
    final isLeap = result[3] != 0;

    lunarMonth = LunarConverter.getLunarMonthName(
      lunarMonthIndex,
      isLeap: isLeap,
    );

    return Lunar(
      result[0],
      result[1],
      result[2],
      lunarMonth,
      LunarConverter.getCanChiDay(jd),
      LunarConverter.getCanChiMonth(lunarMonthIndex, year),
      LunarConverter.getCanChiYear(year),
      LunarConverter.getAuspiciousHours(jd),
    );
  }
}
