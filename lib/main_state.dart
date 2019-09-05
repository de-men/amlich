import 'package:licham/lunar.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class MainState extends Equatable {
  MainState([List props = const []]) : super(props);
}

class MainUninitialized extends MainState {
  @override
  String toString() => 'MainUninitialized';
}

class MainFailure extends MainState {
  final String error;

  MainFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'LoginFailure { error: $error }';
}

class DateUpdate extends MainState {
  final DateTime solar;
  final Lunar lunar;

  DateUpdate({@required this.solar, @required this.lunar})
      : super([solar, lunar]);

  @override
  String toString() => 'DateUpdate { solar: $solar, lunar: $lunar }';
}
