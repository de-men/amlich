# Âm Lịch

[![CI](https://github.com/de-men/amlich/actions/workflows/ci.yml/badge.svg)](https://github.com/de-men/amlich/actions/workflows/ci.yml)
[![codecov](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/thaihuynhxyz/750c80dac4c020472e8510f5ca8c8b7a/raw/coverage.json)](https://github.com/de-men/amlich/actions/workflows/ci.yml)

A Vietnamese lunar calendar ([Âm Lịch](https://amlich.demen.org)) web app built with [Flutter](https://flutter.dev/web).

## Features

- Solar (Gregorian) and Lunar date conversion
- Moon phase visualization for each day
- Can Chi (Heavenly Stems & Earthly Branches) for day, month, and year
- Auspicious hours (Giờ Hoàng Đạo) with zodiac icons
- Month calendar view with lunar day numbers
- Solar/Lunar focus toggle
- Dark (celestial) and Light theme
- Swipe gestures for day and month navigation
- Download .ics calendar file for any decade

## Download Lunar Calendar (.ics)

You can download the Vietnamese lunar calendar as an `.ics` file and import it into Google Calendar, Apple Calendar, Outlook, or any calendar app:

1. Open [amlich.demen.org](https://amlich.demen.org)
2. Navigate to the year/decade you want
3. Click **"Tải Âm Lịch 2020s"** (or whichever decade is shown) at the bottom
4. Import the downloaded `.ics` file into your calendar app

The file is generated client-side from the app's lunar conversion algorithm and covers a full decade (e.g. 2020-2029). Each day includes the lunar date, Can Chi, and moon phase info.

## URL Parameters

You can open the app with a specific date using the `date` query parameter:

```
https://amlich.demen.org/?date=10-02-2024
```

Format: `dd-MM-yyyy` (day-month-year)

## Getting Started

```bash
flutter pub get
flutter run -d chrome
```

## Deployment

Deployment is automated via GitHub Actions. Every push to `master` builds and deploys to [amlich.demen.org](https://amlich.demen.org).

To build manually:

```bash
flutter build web
```

## License

[BSD](LICENSE)
