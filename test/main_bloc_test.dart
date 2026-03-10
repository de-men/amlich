import 'package:flutter_test/flutter_test.dart';
import 'package:licham/lunar.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';

void main() {
  late MainBloc mainBloc;

  setUp(() {
    mainBloc = MainBloc(DateTime.now());
  });

  tearDown(() async {
    await mainBloc.close();
  });

  test('initial state is correct', () {
    expect(mainBloc.state, const MainUninitialized());
  });

  test('close does not emit new states', () async {
    final future = expectLater(
      mainBloc.stream,
      emitsInOrder(<dynamic>[emitsDone]),
    );
    await mainBloc.close();
    await future;
  });

  group('solar to lunar conversion', () {
    Future<DateUpdate> convertDate(DateTime solar) async {
      final bloc = MainBloc(solar)..add(const AppStarted());
      final state = await bloc.stream.firstWhere((s) => s is DateUpdate);
      await bloc.close();
      return state as DateUpdate;
    }

    group('Tết Nguyên Đán (Lunar New Year = 1/1)', () {
      test('2024-02-10 is Mùng 1 Tết Giáp Thìn', () async {
        final state = await convertDate(DateTime(2024, 2, 10));
        expect(state.lunar!.day, 1);
        expect(state.lunar!.month, 1);
        expect(state.lunar!.year, 2024);
        expect(state.lunar!.canchiYear, 'Giáp Thìn');
      });

      test('2025-01-29 is Mùng 1 Tết Ất Tỵ', () async {
        final state = await convertDate(DateTime(2025, 1, 29));
        expect(state.lunar!.day, 1);
        expect(state.lunar!.month, 1);
        expect(state.lunar!.year, 2025);
        expect(state.lunar!.canchiYear, 'Ất Tỵ');
      });

      test('2026-02-17 is Mùng 1 Tết Bính Ngọ', () async {
        final state = await convertDate(DateTime(2026, 2, 17));
        expect(state.lunar!.day, 1);
        expect(state.lunar!.month, 1);
        expect(state.lunar!.year, 2026);
        expect(state.lunar!.canchiYear, 'Bính Ngọ');
      });

      test('2023-01-22 is Mùng 1 Tết Quý Mão', () async {
        final state = await convertDate(DateTime(2023, 1, 22));
        expect(state.lunar!.day, 1);
        expect(state.lunar!.month, 1);
        expect(state.lunar!.year, 2023);
        expect(state.lunar!.canchiYear, 'Quý Mão');
      });
    });

    group('Rằm Trung Thu (Mid-Autumn = 15/8)', () {
      test('2024-09-17 is Rằm tháng Tám', () async {
        final state = await convertDate(DateTime(2024, 9, 17));
        expect(state.lunar!.day, 15);
        expect(state.lunar!.month, 8);
      });

      test('2025-10-06 is Rằm tháng Tám', () async {
        final state = await convertDate(DateTime(2025, 10, 6));
        expect(state.lunar!.day, 15);
        expect(state.lunar!.month, 8);
      });
    });

    test('emits auspicious hours', () async {
      final state = await convertDate(DateTime(2024, 2, 10));
      expect(state.lunar!.hours, isNotNull);
      expect(state.lunar!.hours, isNotEmpty);
    });

    test('emits Can Chi for day and month', () async {
      final state = await convertDate(DateTime(2024, 2, 10));
      expect(state.lunar!.canChiDay, isNotNull);
      expect(state.lunar!.canChiMonth, isNotNull);
    });
  });

  group('date navigation', () {
    test('today selection uses current date', () async {
      final bloc = MainBloc(DateTime(2020))..add(const AppStarted());

      final states = <DateUpdate>[];
      final sub = bloc.stream
          .where((s) => s is DateUpdate)
          .cast<DateUpdate>()
          .listen(states.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const TodaySelected());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final now = DateTime.now();
      expect(states.last.solar!.day, now.day);
      expect(states.last.solar!.month, now.month);
      expect(states.last.solar!.year, now.year);

      await sub.cancel();
      await bloc.close();
    });

    test('next day advances solar date', () async {
      final bloc = MainBloc(DateTime(2024, 2, 10))..add(const AppStarted());

      final states = <DateUpdate>[];
      final sub = bloc.stream
          .where((s) => s is DateUpdate)
          .cast<DateUpdate>()
          .listen(states.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const NextSelected());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.last.solar!.day, 11);
      expect(states.last.solar!.month, 2);

      await sub.cancel();
      await bloc.close();
    });

    test('previous day goes back', () async {
      final bloc = MainBloc(DateTime(2024, 2, 10))..add(const AppStarted());

      final states = <DateUpdate>[];
      final sub = bloc.stream
          .where((s) => s is DateUpdate)
          .cast<DateUpdate>()
          .listen(states.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const PreviousSelected());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.last.solar!.day, 9);
      expect(states.last.solar!.month, 2);

      await sub.cancel();
      await bloc.close();
    });

    test('solar date selection updates lunar', () async {
      final bloc = MainBloc(DateTime(2024))..add(const AppStarted());

      final states = <DateUpdate>[];
      final sub = bloc.stream
          .where((s) => s is DateUpdate)
          .cast<DateUpdate>()
          .listen(states.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(SolarSelected(solar: DateTime(2024, 2, 10)));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.last.lunar!.day, 1);
      expect(states.last.lunar!.month, 1);
      expect(states.last.lunar!.year, 2024);

      await sub.cancel();
      await bloc.close();
    });

    test('lunar date selection converts back to solar', () async {
      final bloc = MainBloc(DateTime(2024, 2, 10))..add(const AppStarted());

      final states = <DateUpdate>[];
      final sub = bloc.stream
          .where((s) => s is DateUpdate)
          .cast<DateUpdate>()
          .listen(states.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const LunarSelected(lunar: '1/1/2025'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.last.solar!.year, 2025);
      expect(states.last.solar!.month, 1);
      expect(states.last.solar!.day, 29);

      await sub.cancel();
      await bloc.close();
    });

    test('lunar date in month >= 11 converts correctly', () async {
      final bloc = MainBloc(DateTime(2024, 2, 10))..add(const AppStarted());

      final states = <DateUpdate>[];
      final sub = bloc.stream
          .where((s) => s is DateUpdate)
          .cast<DateUpdate>()
          .listen(states.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const LunarSelected(lunar: '1/11/2024'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.last.solar, isNotNull);
      expect(states.last.lunar!.month, 11);

      await sub.cancel();
      await bloc.close();
    });
  });

  group('event toString', () {
    test('AppStarted', () {
      expect(const AppStarted().toString(), 'AppStarted');
    });

    test('SolarChanged', () {
      expect(const SolarChanged().toString(), 'SolarChanged');
    });

    test('LunarChanged', () {
      expect(const LunarChanged().toString(), 'LunarChanged');
    });

    test('TodaySelected', () {
      expect(const TodaySelected().toString(), 'TodaySelected');
    });

    test('PreviousSelected', () {
      expect(const PreviousSelected().toString(), 'PreviousSelected');
    });

    test('NextSelected', () {
      expect(const NextSelected().toString(), 'NextSelected');
    });

    test('SolarSelected', () {
      final event = SolarSelected(solar: DateTime(2024));
      expect(event.toString(), contains('SolarSelected'));
      expect(event.props, [DateTime(2024)]);
    });

    test('LunarSelected', () {
      const event = LunarSelected(lunar: '1/1/2024');
      expect(event.toString(), contains('LunarSelected'));
      expect(event.props, ['1/1/2024']);
    });
  });

  group('state toString', () {
    test('MainUninitialized', () {
      expect(const MainUninitialized().toString(), 'MainUninitialized');
    });

    test('MainFailure', () {
      const state = MainFailure(error: 'test error');
      expect(state.toString(), contains('MainFailure'));
      expect(state.props, ['test error']);
    });

    test('DateUpdate', () {
      final state = DateUpdate(
        solar: DateTime(2024),
        lunar: const Lunar(1, 1, 2024, null, null, null, null, null),
      );
      expect(state.toString(), contains('DateUpdate'));
      expect(state.props, hasLength(2));
    });
  });
}
