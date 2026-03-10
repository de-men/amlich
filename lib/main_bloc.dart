import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:licham/lunar.dart';
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
        solarDate = _convertLunar2Solar(
          int.parse(ddMMyyyy[0]),
          int.parse(ddMMyyyy[1]),
          int.parse(ddMMyyyy[2]),
          lunarMonth!.endsWith('Nhuận') ? 1 : 0,
          7,
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

  static final List<String> _lunarMonths = [
    'Tháng Giêng',
    'Tháng Hai',
    'Tháng Ba',
    'Tháng Tư',
    'Tháng Năm',
    'Tháng Sáu',
    'Tháng Bảy',
    'Tháng Tám',
    'Tháng Chín',
    'Tháng Mười',
    'Tháng Một',
    'Tháng Chạp',
  ];

  static final List<String> _can = [
    'Canh',
    'Tân',
    'Nhâm',
    'Quý',
    'Giáp',
    'Ất',
    'Bính',
    'Đinh',
    'Mậu',
    'Kỷ',
  ];

  static final List<String> _chi = [
    'Thân',
    'Dậu',
    'Tuất',
    'Hợi',
    'Tí',
    'Sửu',
    'Dần',
    'Mão',
    'Thìn',
    'Tỵ',
    'Ngọ',
    'Mùi',
  ];

  static final List<bool> _d = [
    true,
    true,
    false,
    false,
    true,
    true,
    false,
    true,
    false,
    false,
    true,
    false,
  ];

  static final List<String> _hours = [
    'Tí (23h-1h)',
    'Sửu (1h-3h)',
    'Dần (3h-5h)',
    'Mão (5h-7h)',
    'Thìn (7h-9h)',
    'Tỵ (9h-11h)',
    'Ngọ (11h-13h)',
    'Mùi (13h-15h)',
    'Thân (15h-17h)',
    'Dậu (17h-19h)',
    'Tuất (19h-21h)',
    'Hợi (21h-23h)',
  ];

  static int lunarMonthIndex = 0;
  String? lunarMonth;
  String? canChiDay;
  String? canChiMonth;
  String? canChiYear;
  List<String>? auspiciousHours;

  void _initDateFormat() {
    weekFormat = DateFormat('EEEE', 'vi');
    monthYearFormat = DateFormat('MMMM, y', 'vi');
    ddMMyyyyFormat = DateFormat('dd/MM/yyyy', 'vi');
  }

  int _getLeapMonthOffset(int a11, double timeZone) {
    final k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
    int last;
    var i = 1;
    var arc = (_getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone) / 30)
        .floor();
    do {
      last = arc;
      i++;
      arc = (_getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone) / 30)
          .floor();
    } while (arc != last && i < 14);
    return i - 1;
  }

  double _sunLongitudeAA98(double jdn) {
    final t = (jdn - 2451545.0) / 36525;
    final t2 = t * t;
    const dr = math.pi / 180;
    final m =
        357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    var dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * math.sin(dr * m);
    dl = dl +
        (0.019993 - 0.000101 * t) * math.sin(dr * 2 * m) +
        0.000290 * math.sin(dr * 3 * m);
    final l = l0 + dl;
    return l - 360 * (l / 360).floor();
  }

  double _getSunLongitude(int dayNumber, double timeZone) {
    return _sunLongitudeAA98(dayNumber - 0.5 - timeZone / 24);
  }

  int _getLunarMonth11(int yy, double timeZone) {
    final off = _jdFromDate(31, 12, yy) - 2415021.076998695;
    final k = (off / 29.530588853).floor();
    var nm = _getNewMoonDay(k, timeZone);
    final sunLong = (_getSunLongitude(nm, timeZone) / 30).floor();
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  double _newMoonAA98(int k) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    const dr = math.pi / 180;
    var jd1 =
        2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    jd1 = jd1 + 0.00033 * math.sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);
    final m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;
    var c1 = (0.1734 - 0.000393 * t) * math.sin(m * dr) +
        0.0021 * math.sin(2 * dr * m);
    c1 = c1 - 0.4068 * math.sin(mpr * dr) + 0.0161 * math.sin(dr * 2 * mpr);
    c1 = c1 - 0.0004 * math.sin(dr * 3 * mpr);
    c1 = c1 + 0.0104 * math.sin(dr * 2 * f) - 0.0051 * math.sin(dr * (m + mpr));
    c1 = c1 -
        0.0074 * math.sin(dr * (m - mpr)) +
        0.0004 * math.sin(dr * (2 * f + m));
    c1 = c1 -
        0.0004 * math.sin(dr * (2 * f - m)) -
        0.0006 * math.sin(dr * (2 * f + mpr));
    c1 = c1 +
        0.0010 * math.sin(dr * (2 * f - mpr)) +
        0.0005 * math.sin(dr * (2 * mpr + m));
    double deltat;
    if (t < -11) {
      deltat = 0.001 +
          0.000839 * t +
          0.0002261 * t2 -
          0.00000845 * t3 -
          0.000000081 * t * t3;
    } else {
      deltat = -0.000278 + 0.000265 * t + 0.000262 * t2;
    }
    final jdNew = jd1 + c1 - deltat;
    return jdNew;
  }

  int _getNewMoonDay(int k, double timeZone) {
    final jd = _newMoonAA98(k);
    return (jd + 0.5 + timeZone / 24).floor();
  }

  int _jdFromDate(int dd, int mm, int yy) {
    final a = (14 - mm) ~/ 12;
    final y = yy + 4800 - a;
    final m = mm + 12 * a - 3;
    var jd = dd +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
    if (jd < 2299161) {
      jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    return jd;
  }

  List<int> _convertSolar2Lunar(int dd, int mm, int yy, double timeZone) {
    int lunarDay;
    int lunarMonth;
    int lunarYear;
    int lunarLeap;
    final dayNumber = _jdFromDate(dd, mm, yy);

    final chiDayIndex = (dayNumber + 5) % _chi.length;
    canChiDay = '${_can[(dayNumber + 3) % _can.length]} ${_chi[chiDayIndex]}';

    auspiciousHours = [];
    final shiftD = (chiDayIndex % 6) * 2;
    for (var i = 0; i < 12; i++) {
      if (_d[(i - shiftD) % 12]) {
        auspiciousHours!.add(_hours[i]);
      }
    }

    final k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    var monthStart = _getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k, timeZone);
    }
    var a11 = _getLunarMonth11(yy, timeZone);
    var b11 = a11;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = _getLunarMonth11(yy - 1, timeZone);
    } else {
      lunarYear = yy + 1;
      b11 = _getLunarMonth11(yy + 1, timeZone);
    }

    lunarDay = dayNumber - monthStart + 1;
    final diff = ((monthStart - a11) / 29).floor();
    lunarLeap = 0;
    lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      final leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) {
          lunarLeap = 1;
        }
      }
    }
    if (lunarMonth > 12) {
      lunarMonth = lunarMonth - 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }
    return [lunarDay, lunarMonth, lunarYear, lunarLeap];
  }

  Lunar _calculate(DateTime date) {
    final result = _convertSolar2Lunar(date.day, date.month, date.year, 7);
    lunarMonthIndex = result[1];
    final year = result[2];
    lunarMonth = _lunarMonths[lunarMonthIndex - 1];
    if (result[3] != 0) lunarMonth = '$lunarMonth Nhuận';

    final canYearIndex = year % _can.length;
    final canMonthOffset =
        canYearIndex % 5 + ((canYearIndex % 5 + 7) % _can.length) * 2;

    canChiMonth =
        '${_can[(canMonthOffset + lunarMonthIndex - 1) % _can.length]} '
        '${_chi[(lunarMonthIndex + 5) % _chi.length]}';
    canChiYear = '${_can[canYearIndex]} ${_chi[year % _chi.length]}';

    return Lunar(
      result[0],
      result[1],
      result[2],
      lunarMonth,
      canChiDay,
      canChiMonth,
      canChiYear,
      auspiciousHours,
    );
  }

  /// http://www.tondering.dk/claus/calendar.html
  /// Section: Is there a formula for calculating the Julian day number?
  static DateTime _jdToDate(int jd) {
    int b;
    int c;
    if (jd > 2299160) {
      final a = jd + 32044;
      b = (4 * a + 3) ~/ 146097;
      c = a - (b * 146097) ~/ 4;
    } else {
      b = 0;
      c = jd + 32082;
    }
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = b * 100 + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }

  DateTime _convertLunar2Solar(
    int lunarDay,
    int lunarMonth,
    int lunarYear,
    int lunarLeap,
    double timeZone,
  ) {
    int a11;
    int b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, timeZone);
      b11 = _getLunarMonth11(lunarYear, timeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, timeZone);
      b11 = _getLunarMonth11(lunarYear + 1, timeZone);
    }
    final k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
    var off = lunarMonth - 11;
    if (off < 0) {
      off += 12;
    }
    if (b11 - a11 > 365) {
      final leapOff = _getLeapMonthOffset(a11, timeZone);
      var leapMonth = leapOff - 2;
      if (leapMonth < 0) {
        leapMonth += 12;
      }
      if (lunarLeap != 0 && lunarMonth != leapMonth) {
        return DateTime(0);
      } else if (lunarLeap != 0 || off >= leapOff) {
        off += 1;
      }
    }
    final monthStart = _getNewMoonDay(k + off, timeZone);
    return _jdToDate(monthStart + lunarDay - 1);
  }
}
