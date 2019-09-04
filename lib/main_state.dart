import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class MainState extends Equatable {
  MainState([List props = const []]) : super(props);
}

class MainUninitialized extends MainState {
  @override
  String toString() => 'MainUninitialized';
}

class MainInitialized extends MainState {
  @override
  String toString() => 'MainInitialized';
}

class MainFailure extends MainState {
  final String error;

  MainFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'LoginFailure { error: $error }';
}
