class Lunar {
  const Lunar(
    this.day,
    this.month,
    this.year,
    this.monthString,
    this.canChiDay,
    this.canChiMonth,
    this.canchiYear,
    this.hours,
  );

  final int day;
  final int month;
  final int year;
  final String? monthString;
  final String? canChiDay;
  final String? canChiMonth;
  final String? canchiYear;
  final List<String>? hours;
}
