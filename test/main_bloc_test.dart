import 'package:flutter_test/flutter_test.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_state.dart';

void main() {
  MainBloc mainBloc;

  setUp(() {
    mainBloc = MainBloc(DateTime.now());
  });

  test('initial state is correct', () {
    expect(mainBloc.initialState, MainUninitialized());
  });

  test('dispose does not emit new states', () {
    expectLater(
      mainBloc.state,
      emitsInOrder([MainUninitialized(), emitsDone]),
    );
    mainBloc.dispose();
  });
}
