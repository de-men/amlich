import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:licham/lunar.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  late DateFormat weekFormat;
  late DateFormat monthYearFormat;
  DateFormat? ddMMyyyyFormat;

  DateTime? solarDate;
  Lunar? lunarDate;

  static final List<String> LUNAR_MONTH = [
    "Tháng Giêng",
    "Tháng Hai",
    "Tháng Ba",
    "Tháng Tư",
    "Tháng Năm",
    "Tháng Sáu",
    "Tháng Bảy",
    "Tháng Tám",
    "Tháng Chín",
    "Tháng Mười",
    "Tháng Một",
    "Tháng Chạp"
  ];
  static final List<String> CAN = [
    "Canh",
    "Tân",
    "Nhâm",
    "Quý",
    "Giáp",
    "Ất",
    "Bính",
    "Đinh",
    "Mậu",
    "Kỷ"
  ];
  static final List<String> CHI = [
    "Thân",
    "Dậu",
    "Tuất",
    "Hợi",
    "Tí",
    "Sửu",
    "Dần",
    "Mão",
    "Thìn",
    "Tỵ",
    "Ngọ",
    "Mùi"
  ];
  static final List<bool> D = [
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
    false
  ];
  static final List<String> HOUR = [
    "Tí (23h-1h)",
    "Sửu (1h-3h)",
    "Dần (3h-5h)",
    "Mão (5h-7h)",
    "Thìn (7h-9h)",
    "Tỵ (9h-11h)",
    "Ngọ (11h-13h)",
    "Mùi (13h-15h)",
    "Thân (15h-17h)",
    "Dậu (17h-19h)",
    "Tuất (19h-21h)",
    "Hợi (21h-23h)"
  ];

  MainBloc(this.solarDate) : super(MainUninitialized()) {
    on<MainEvent>((event, emit) {
      if (event is AppStarted) {
        Intl.defaultLocale = "vi_VN";
        initializeDateFormatting("vi", null).then((_) => _initDateFormat());
        solarDate = solarDate ?? DateTime.now();
        add(SolarChanged());
      } else if (event is SolarChanged) {
        lunarDate = _calculate(solarDate!);
        emit(DateUpdate(solar: solarDate, lunar: lunarDate));
      } else if (event is TodaySelected) {
        solarDate = DateTime.now();
        add(SolarChanged());
      } else if (event is PreviousSelected) {
        solarDate = solarDate!.add(Duration(days: -1));
        add(SolarChanged());
      } else if (event is NextSelected) {
        solarDate = solarDate!.add(Duration(days: 1));
        add(SolarChanged());
      } else if (event is SolarSelected) {
        solarDate = event.solar;
        add(SolarChanged());
      } else if (event is LunarSelected) {
        List<String> ddMMyyyy = event.lunar!.split('/');
        solarDate = _convertLunar2Solar(
            int.parse(ddMMyyyy[0]),
            int.parse(ddMMyyyy[1]),
            int.parse(ddMMyyyy[2]),
            lunarMonth!.endsWith('Nhuận') ? 1 : 0,
            7);
        add(SolarChanged());
      }
    });
  }

  void _initDateFormat() {
    print('_initDateFormat');
    weekFormat = DateFormat("EEEE", "vi");
    monthYearFormat = DateFormat("MMMM, y", "vi");
    ddMMyyyyFormat = DateFormat('dd/MM/yyyy', "vi");
  }

  int _getLeapMonthOffset(int a11, double timeZone) {
    int k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
    int last; // Month 11 contains point of sun longutide 3*PI/2 (December solstice)
    int i = 1; // We start with the month following lunar month 11
    int arc = (_getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone) / 30)
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
    double T = (jdn - 2451545.0) /
        36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    double T2 = T * T;
    double dr = math.pi / 180; // degree to radian
    double M = 357.52910 +
        35999.05030 * T -
        0.0001559 * T2 -
        0.00000048 * T * T2; // mean anomaly, degree
    double L0 =
        280.46645 + 36000.76983 * T + 0.0003032 * T2; // mean longitude, degree
    double DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * math.sin(dr * M);
    DL = DL +
        (0.019993 - 0.000101 * T) * math.sin(dr * 2 * M) +
        0.000290 * math.sin(dr * 3 * M);
    double L = L0 + DL; // true longitude, degree
    L = L - 360 * (L / 360).floor(); // Normalize to (0, 360)
    return L;
  }

  double _getSunLongitude(int dayNumber, double timeZone) {
    return _sunLongitudeAA98(dayNumber - 0.5 - timeZone / 24);
  }

  int _getLunarMonth11(int yy, double timeZone) {
    double off = _jdFromDate(31, 12, yy) - 2415021.076998695;
    int k = (off / 29.530588853).floor();
    int nm = _getNewMoonDay(k, timeZone);
    int sunLong = (_getSunLongitude(nm, timeZone) / 30).floor();
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  double _newMoonAA98(int k) {
    double T = k / 1236.85; // Time in Julian centuries from 1900 January 0.5
    double T2 = T * T;
    double T3 = T2 * T;
    double dr = math.pi / 180;
    double Jd1 =
        2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
    Jd1 = Jd1 +
        0.00033 *
            math.sin(
                (166.56 + 132.87 * T - 0.009173 * T2) * dr); // Mean new moon
    double M = 359.2242 +
        29.10535608 * k -
        0.0000333 * T2 -
        0.00000347 * T3; // Sun's mean anomaly
    double Mpr = 306.0253 +
        385.81691806 * k +
        0.0107306 * T2 +
        0.00001236 * T3; // Moon's mean anomaly
    double F = 21.2964 +
        390.67050646 * k -
        0.0016528 * T2 -
        0.00000239 * T3; // Moon's argument of latitude
    double C1 = (0.1734 - 0.000393 * T) * math.sin(M * dr) +
        0.0021 * math.sin(2 * dr * M);
    C1 = C1 - 0.4068 * math.sin(Mpr * dr) + 0.0161 * math.sin(dr * 2 * Mpr);
    C1 = C1 - 0.0004 * math.sin(dr * 3 * Mpr);
    C1 = C1 + 0.0104 * math.sin(dr * 2 * F) - 0.0051 * math.sin(dr * (M + Mpr));
    C1 = C1 -
        0.0074 * math.sin(dr * (M - Mpr)) +
        0.0004 * math.sin(dr * (2 * F + M));
    C1 = C1 -
        0.0004 * math.sin(dr * (2 * F - M)) -
        0.0006 * math.sin(dr * (2 * F + Mpr));
    C1 = C1 +
        0.0010 * math.sin(dr * (2 * F - Mpr)) +
        0.0005 * math.sin(dr * (2 * Mpr + M));
    double deltat;
    if (T < -11) {
      deltat = 0.001 +
          0.000839 * T +
          0.0002261 * T2 -
          0.00000845 * T3 -
          0.000000081 * T * T3;
    } else {
      deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
    }
    ;
    double JdNew = Jd1 + C1 - deltat;
    return JdNew;
  }

  int _getNewMoonDay(int k, double timeZone) {
    double jd = _newMoonAA98(k);
    return (jd + 0.5 + timeZone / 24).floor();
  }

  int _jdFromDate(int dd, int mm, int yy) {
    int a = (14 - mm) ~/ 12;
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;
    int jd = dd +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
    if (jd < 2299161) {
      jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    //jd = jd - 1721425;
    return jd;
  }

  List<int> _convertSolar2Lunar(int dd, int mm, int yy, double timeZone) {
    int lunarDay, lunarMonth, lunarYear, lunarLeap;
    int dayNumber = _jdFromDate(dd, mm, yy);

    final chiDayIndex = (dayNumber + 5) % CHI.length;
    canChiDay = CAN[(dayNumber + 3) % CAN.length] + " " + CHI[chiDayIndex];

    hours = [];
    final shilfD = (chiDayIndex % 6) * 2;
    for (var i = 0; i < 12; i++) {
      if (D[(i - shilfD) % 12]) {
        hours!.add(HOUR[i]);
      }
    }

    int k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    int monthStart = _getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k, timeZone);
    }
    int a11 = _getLunarMonth11(yy, timeZone);
    int b11 = a11;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = _getLunarMonth11(yy - 1, timeZone);
    } else {
      lunarYear = yy + 1;
      b11 = _getLunarMonth11(yy + 1, timeZone);
    }

    lunarDay = dayNumber - monthStart + 1;
    int diff = ((monthStart - a11) / 29).floor();
    lunarLeap = 0;
    lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      int leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
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

  static late int lunarMonthIndex;
  String? lunarMonth;
  String? canChiDay;
  String? canChiMonth;
  String? canChiYear;
  List<String>? hours;

  Lunar _calculate(DateTime date) {
    List<int> result = _convertSolar2Lunar(date.day, date.month, date.year, 7);
    lunarMonthIndex = result[1];
    final year = result[2];
    lunarMonth = LUNAR_MONTH[lunarMonthIndex - 1];
    if (result[3] != 0) "$lunarMonth Nhuận";

    final canYearIndex = year % CAN.length;
    final canMonthOfset =
        canYearIndex % 5 + ((canYearIndex % 5 + 7) % CAN.length) * 2;

    canChiMonth = CAN[(canMonthOfset + lunarMonthIndex - 1) % CAN.length] +
        " " +
        CHI[(lunarMonthIndex + 5) % CHI.length];
    canChiYear = CAN[canYearIndex] + " " + CHI[year % CHI.length];

    return Lunar(result[0], result[1], result[2], lunarMonth, canChiDay,
        canChiMonth, canChiYear, hours);
  }

  /**
   * http://www.tondering.dk/claus/calendar.html
   * Section: Is there a formula for calculating the Julian day number?
   *
   * @param jd - the number of days since 1 January 4713 BC (Julian calendar)
   * @return
   */
  static DateTime _jdToDate(int jd) {
    int a, b, c;
    if (jd > 2299160) {
      // After 5/10/1582, Gregorian calendar
      a = jd + 32044;
      b = (4 * a + 3) ~/ 146097;
      c = a - (b * 146097) ~/ 4;
    } else {
      b = 0;
      c = jd + 32082;
    }
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;
    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = b * 100 + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }

  DateTime _convertLunar2Solar(int lunarDay, int lunarMonth, int lunarYear,
      int lunarLeap, double timeZone) {
    int a11, b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, timeZone);
      b11 = _getLunarMonth11(lunarYear, timeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, timeZone);
      b11 = _getLunarMonth11(lunarYear + 1, timeZone);
    }
    int k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
    int off = lunarMonth - 11;
    if (off < 0) {
      off += 12;
    }
    if (b11 - a11 > 365) {
      int leapOff = _getLeapMonthOffset(a11, timeZone);
      int leapMonth = leapOff - 2;
      if (leapMonth < 0) {
        leapMonth += 12;
      }
      if (lunarLeap != 0 && lunarMonth != leapMonth) {
        return DateTime(0, 0, 0);
      } else if (lunarLeap != 0 || off >= leapOff) {
        off += 1;
      }
    }
    int monthStart = _getNewMoonDay(k + off, timeZone);
    return _jdToDate(monthStart + lunarDay - 1);
  }
}
