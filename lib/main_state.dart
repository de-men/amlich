import 'package:equatable/equatable.dart';
import 'package:licham/lunar.dart';

abstract class MainState extends Equatable {
  @override
  List<Object?> get props => const [];
}

class MainUninitialized extends MainState {
  @override
  String toString() => 'MainUninitialized';
}

class MainFailure extends MainState {
  final String error;

  MainFailure({required this.error});

  @override
  String toString() => 'LoginFailure { error: $error }';

  @override
  List<Object> get props => [error];
}

class DateUpdate extends MainState {
  final DateTime? solar;
  final Lunar? lunar;

  DateUpdate({required this.solar, required this.lunar});

  @override
  String toString() => 'DateUpdate { solar: $solar, lunar: $lunar }';

  @override
  List<Object?> get props => [solar, lunar];
}
