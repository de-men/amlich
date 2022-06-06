import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MainEvent extends Equatable {
  List<Object?> get props => const [];
}

class AppStarted extends MainEvent {
  @override
  String toString() => 'AppStarted';
}

class SolarChanged extends MainEvent {
  @override
  String toString() => 'SolarChanged';
}

class LunarChanged extends MainEvent {
  @override
  String toString() => 'LunarChanged';
}

class TodaySelected extends MainEvent {
  @override
  String toString() => 'TodaySelected';
}

class PreviousSelected extends MainEvent {
  @override
  String toString() => 'PreviousSelected';
}

class NextSelected extends MainEvent {
  @override
  String toString() => 'NextSelected';
}

class SolarSelected extends MainEvent {
  final DateTime? solar;

  SolarSelected({required this.solar});

  @override
  String toString() => 'SolarSelected { solar: $solar }';

  @override
  List<Object?> get props => [solar];
}

class LunarSelected extends MainEvent {
  final String? lunar;

  LunarSelected({required this.lunar});

  @override
  String toString() => 'LunarSelected { lunar: $lunar }';

  @override
  List<Object?> get props => [lunar];
}
