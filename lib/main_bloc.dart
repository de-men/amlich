import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc();

  @override
  MainState get initialState => MainUninitialized();

  @override
  Stream<MainState> mapEventToState(
    MainEvent event,
  ) async* {
    if (event is AppStarted) {
      yield MainInitialized();
    }
  }
}
