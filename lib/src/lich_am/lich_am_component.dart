import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_datepicker/material_datepicker.dart';
import 'package:angular_components/material_datepicker/material_calendar_picker.dart';
import 'package:angular_components/material_datepicker/module.dart';
import 'package:angular_components/utils/browser/window/module.dart';
import 'package:angular_components/model/date/date.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math' as math;

@Component(
  selector: 'lich-am',
  styleUrls: ['lich_am_component.css'],
  templateUrl: 'lich_am_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    MaterialDatepickerComponent,
    DateInputDirective,
    MaterialCalendarPickerComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
  ],
  providers: [windowBindings, datepickerBindings],
)
class LichAmComponent implements OnInit {

  DateFormat weekFormat;
  DateFormat monthYearFormat;
  DateFormat dayMonthYearFormat;
  DateFormat ddMMyyyyFormat;

  String formatDate(Date date) => date == null ? '(null)' : date.toString();

  CalendarState singleDateModel =
      CalendarState.selected([CalendarSelection('range', Date.today(), Date.today())]);

  @override
  Future<Null> ngOnInit() async {
    Intl.defaultLocale = "vi_VN";
    initializeDateFormatting("vi", null).then((_) => initDateFormat() );
  }

  void onDateChange(Date dateChanged) {
    singleDateModel = singleDateModel.setSelection(CalendarSelection(
        'range', dateChanged, dateChanged));
  }

  void initDateFormat() {
    weekFormat = DateFormat("EEEE", "vi");
    monthYearFormat = DateFormat("MMMM, y", "vi");
    dayMonthYearFormat = DateFormat("d MMMM, y", "vi");
    ddMMyyyyFormat = DateFormat('dd/MM/yyyy', "vi");
  }

  int jdFromDate(int dd, int mm, int yy) {
    int a = (14  - mm) ~/ 12;
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;
    int jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    if (jd < 2299161) {
        jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    //jd = jd - 1721425;
    return jd;
  }
 
  double NewMoonAA98(int k) {
    double T = k / 1236.85; // Time in Julian centuries from 1900 January 0.5
    double T2 = T * T;
    double T3 = T2 * T;
    double dr = math.pi / 180;
    double Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
    Jd1 = Jd1 + 0.00033 * math.sin((166.56 + 132.87 * T - 0.009173 * T2) * dr); // Mean new moon
    double M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3; // Sun's mean anomaly
    double Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3; // Moon's mean anomaly
    double F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3; // Moon's argument of latitude
    double C1 = (0.1734 - 0.000393 * T) * math.sin(M * dr) + 0.0021 * math.sin(2 * dr * M);
    C1 = C1 - 0.4068 * math.sin(Mpr * dr) + 0.0161 * math.sin(dr * 2 * Mpr);
    C1 = C1 - 0.0004 * math.sin(dr * 3 * Mpr);
    C1 = C1 + 0.0104 * math.sin(dr * 2 * F) - 0.0051 * math.sin(dr * (M + Mpr));
    C1 = C1 - 0.0074 * math.sin(dr * (M - Mpr)) + 0.0004 * math.sin(dr * (2 * F + M));
    C1 = C1 - 0.0004 * math.sin(dr * (2 * F - M)) - 0.0006 * math.sin(dr * (2 * F + Mpr));
    C1 = C1 + 0.0010 * math.sin(dr * (2 * F - Mpr)) + 0.0005 * math.sin(dr * (2 * Mpr + M));
    double deltat;
    if (T < -11) {
        deltat= 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3;
    } else {
        deltat= -0.000278 + 0.000265 * T + 0.000262 * T2;
    };
    double JdNew = Jd1 + C1 - deltat;
    return JdNew;
  }

  int getNewMoonDay(int k, double timeZone) {
    double jd = NewMoonAA98(k);
    return (jd + 0.5 + timeZone / 24).toInt();
  }

  double SunLongitudeAA98(double jdn) {
        double T = (jdn - 2451545.0 ) / 36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
        double T2 = T * T;
        double dr = math.pi / 180; // degree to radian
        double M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2; // mean anomaly, degree
        double L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2; // mean longitude, degree
        double DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * math.sin(dr * M);
        DL = DL + (0.019993 - 0.000101 * T) * math.sin(dr * 2 * M) + 0.000290 * math.sin(dr * 3 * M);
        double L = L0 + DL; // true longitude, degree
        L = L - 360 * (L ~/ 360); // Normalize to (0, 360)
        return L;
  }

  double getSunLongitude(int dayNumber, double timeZone) {
    return SunLongitudeAA98(dayNumber - 0.5 - timeZone / 24);
  }

  int getLunarMonth11(int yy, double timeZone) {
    double off = jdFromDate(31, 12, yy) - 2415021.076998695;
    int k = off ~/ 29.530588853;
    int nm = getNewMoonDay(k, timeZone);
    int sunLong = getSunLongitude(nm, timeZone) ~/ 30;
    if (sunLong >= 9) {
        nm = getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  int getLeapMonthOffset(int a11, double timeZone) {
    int k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).toInt();
    int last; // Month 11 contains point of sun longutide 3*PI/2 (December solstice)
    int i = 1; // We start with the month following lunar month 11
    int arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone) ~/ 30;
    do {
        last = arc;
        i++;
        arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone) ~/ 30;
    } while (arc != last && i < 14);
    return i - 1;
  }

  List<int> convertSolar2Lunar(int dd, int mm, int yy, double timeZone) {
    int lunarDay, lunarMonth, lunarYear, lunarLeap;
    int dayNumber = jdFromDate(dd, mm, yy);
    int k = (dayNumber - 2415021.076998695) ~/ 29.530588853;
    int monthStart = getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) {
        monthStart = getNewMoonDay(k, timeZone);
    }
    int a11 = getLunarMonth11(yy, timeZone);
    int b11 = a11;
    if (a11 >= monthStart) {
        lunarYear = yy;
        a11 = getLunarMonth11(yy - 1, timeZone);
    } else {
        lunarYear = yy+1;
        b11 = getLunarMonth11(yy + 1, timeZone);
    }
    lunarDay = dayNumber - monthStart + 1;
    int diff = (monthStart - a11) ~/ 29;
    lunarLeap = 0;
    lunarMonth = diff+11;
    if (b11 - a11 > 365) {
        int leapMonthDiff = getLeapMonthOffset(a11, timeZone);
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

  Date calculate() {
    var date = singleDateModel.selection('range').start;
    List<int> result = convertSolar2Lunar(date.day, date.month, date.year, 7);
    return Date(result[2], result[1], result[0]);
  }
}
