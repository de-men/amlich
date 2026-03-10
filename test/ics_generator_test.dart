import 'package:flutter_test/flutter_test.dart';
import 'package:licham/ics_generator.dart';

void main() {
  group('generateIcs', () {
    late String ics;

    setUpAll(() {
      ics = generateIcs(2024, 2024);
    });

    test('produces valid iCalendar wrapper', () {
      expect(ics, startsWith('BEGIN:VCALENDAR'));
      expect(ics, contains('VERSION:2.0'));
      expect(ics, contains('PRODID:-//Am Lich//amlich.demen.org//VI'));
      expect(ics, contains('X-WR-CALNAME:Âm Lịch'));
      expect(ics.trimRight(), endsWith('END:VCALENDAR'));
    });

    test('contains one event per day for a full year', () {
      final eventCount = 'BEGIN:VEVENT'.allMatches(ics).length;
      expect(eventCount, 366); // 2024 is a leap year
    });

    test('events have required fields', () {
      expect(ics, contains('DTSTART;VALUE=DATE:'));
      expect(ics, contains('DTEND;VALUE=DATE:'));
      expect(ics, contains('SUMMARY:'));
      expect(ics, contains('DESCRIPTION:'));
    });

    test('Tết 2024 event has correct summary', () {
      expect(
        ics,
        contains(
          'SUMMARY:Tết Nguyên Đán Giáp Thìn - Mùng 1 Tháng Giêng',
        ),
      );
    });

    test('Tết 2024 is on Feb 10', () {
      final lines = ics.split('\n');
      final tetIndex = lines.indexWhere(
        (l) => l.contains('Tết Nguyên Đán Giáp Thìn'),
      );
      final dtStart = lines[tetIndex - 2];
      expect(dtStart, contains('20240210'));
    });

    test('Rằm Trung Thu 2024 event exists', () {
      expect(ics, contains('SUMMARY:Rằm Tháng Tám'));
    });

    test('Rằm Trung Thu 2024 is on Sep 17', () {
      final lines = ics.split('\n');
      final ramIndex = lines.indexWhere(
        (l) => l.contains('Rằm Tháng Tám'),
      );
      final dtStart = lines[ramIndex - 2];
      expect(dtStart, contains('20240917'));
    });

    test('Mùng 1 events for each lunar month', () {
      final mung1Count = 'SUMMARY:Mùng 1'.allMatches(ics).length;
      // 12 or 13 months (leap year may have extra), minus the Tết one
      expect(mung1Count, greaterThanOrEqualTo(11));
    });

    test('description includes Can Chi', () {
      expect(ics, contains('DESCRIPTION:Ngày'));
    });

    test('description includes moon phase for key days', () {
      expect(ics, contains('(Sóc)'));
      expect(ics, contains('(Vọng)'));
    });

    test('date format is YYYYMMDD', () {
      expect(ics, contains('DTSTART;VALUE=DATE:20240101'));
      expect(ics, contains('DTEND;VALUE=DATE:20240102'));
      expect(ics, contains('DTSTART;VALUE=DATE:20241231'));
      expect(ics, contains('DTEND;VALUE=DATE:20250101'));
    });
  });

  group('multi-year generation', () {
    test('decade covers all years', () {
      final ics = generateIcs(2020, 2029);
      for (var year = 2020; year <= 2029; year++) {
        expect(
          ics,
          contains('DTSTART;VALUE=DATE:${year}0101'),
          reason: 'Missing Jan 1 of $year',
        );
      }
    });

    test('decade event count matches total days', () {
      final ics = generateIcs(2020, 2029);
      final eventCount = 'BEGIN:VEVENT'.allMatches(ics).length;
      var totalDays = 0;
      for (var y = 2020; y <= 2029; y++) {
        totalDays += DateTime(y + 1).difference(DateTime(y)).inDays;
      }
      expect(eventCount, totalDays);
    });
  });
}
