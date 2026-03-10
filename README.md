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

## Add Vietnamese Lunar Calendar to Google Calendar

You can subscribe to the Vietnamese lunar calendar to see lunar dates directly in your Google Calendar:

1. Open [Google Calendar](https://calendar.google.com)
2. Click **+** next to "Other calendars" in the left sidebar
3. Select **From URL**
4. Paste this URL:

```
https://calendar.google.com/calendar/ical/demen.org_4jc7p02lkoire319rabglmfifo%40group.calendar.google.com/public/basic.ics
```

5. Click **Add calendar**

Or click this link to add it directly:

[Add to Google Calendar](https://calendar.google.com/calendar/r?cid=demen.org_4jc7p02lkoire319rabglmfifo@group.calendar.google.com)

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
