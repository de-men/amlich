import 'package:licham/lunar_converter.dart';
import 'package:licham/widget/moon_phase.dart';

String generateIcs(int startYear, int endYear) {
  final buf = StringBuffer()
    ..writeln('BEGIN:VCALENDAR')
    ..writeln('VERSION:2.0')
    ..writeln('PRODID:-//Am Lich//amlich.demen.org//VI')
    ..writeln('X-WR-CALNAME:Âm Lịch')
    ..writeln('X-WR-TIMEZONE:Asia/Ho_Chi_Minh');

  for (var year = startYear; year <= endYear; year++) {
    for (var month = 1; month <= 12; month++) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      for (var day = 1; day <= daysInMonth; day++) {
        _writeEvent(buf, year, month, day);
      }
    }
  }

  buf.writeln('END:VCALENDAR');
  return buf.toString();
}

void _writeEvent(StringBuffer buf, int year, int month, int day) {
  final lunar = LunarConverter.solarToLunar(day, month, year);
  final lunarDay = lunar[0];
  final lunarMonth = lunar[1];
  final lunarYear = lunar[2];
  final isLeap = lunar[3] != 0;

  final monthName =
      LunarConverter.getLunarMonthName(lunarMonth, isLeap: isLeap);
  final summary = _buildSummary(lunarDay, lunarMonth, lunarYear, monthName);

  final jd = LunarConverter.julianDay(day, month, year);
  final canChiDay = LunarConverter.getCanChiDay(jd);
  final phase = moonPhaseFromLunarDay(lunarDay);
  final phaseLabel = moonPhaseLabel(phase).replaceAll('\n', ' ');

  final desc = StringBuffer('Ngày $canChiDay');
  if (phaseLabel.isNotEmpty) desc.write(' ($phaseLabel)');

  final dtStart = _formatDate(year, month, day);
  final next = DateTime(year, month, day + 1);
  final dtEnd = _formatDate(next.year, next.month, next.day);

  buf
    ..writeln('BEGIN:VEVENT')
    ..writeln('DTSTART;VALUE=DATE:$dtStart')
    ..writeln('DTEND;VALUE=DATE:$dtEnd')
    ..writeln('SUMMARY:$summary')
    ..writeln('DESCRIPTION:$desc')
    ..writeln('END:VEVENT');
}

String _buildSummary(
  int lunarDay,
  int lunarMonth,
  int lunarYear,
  String monthName,
) {
  if (lunarDay == 1 && lunarMonth == 1) {
    return 'Tết Nguyên Đán ${LunarConverter.getCanChiYear(lunarYear)}'
        ' - Mùng 1 $monthName';
  }
  if (lunarDay == 1) return 'Mùng 1 $monthName';
  if (lunarDay == 15) return 'Rằm $monthName';
  return 'Ngày $lunarDay $monthName';
}

String _formatDate(int y, int m, int d) {
  final yy = y.toString().padLeft(4, '0');
  final mm = m.toString().padLeft(2, '0');
  final dd = d.toString().padLeft(2, '0');
  return '$yy$mm$dd';
}
