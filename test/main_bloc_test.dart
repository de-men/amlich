import 'package:flutter_test/flutter_test.dart';
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
  });
}
