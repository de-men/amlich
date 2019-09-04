import 'package:equatable/equatable.dart';

abstract class MainEvent extends Equatable {
  MainEvent([List props = const []]) : super(props);
}

class AppStarted extends MainEvent {
  @override
  String toString() => 'AppStarted';
}
