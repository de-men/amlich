import 'package:flutter_test/flutter_test.dart';
import 'package:licham/main_bloc.dart';
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
}
