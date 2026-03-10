import 'package:equatable/equatable.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object?> get props => const [];
}

class AppStarted extends MainEvent {
  const AppStarted();

  @override
  String toString() => 'AppStarted';
}

class SolarChanged extends MainEvent {
  const SolarChanged();

  @override
  String toString() => 'SolarChanged';
}

class LunarChanged extends MainEvent {
  const LunarChanged();

  @override
  String toString() => 'LunarChanged';
}

class TodaySelected extends MainEvent {
  const TodaySelected();

  @override
  String toString() => 'TodaySelected';
}

class PreviousSelected extends MainEvent {
  const PreviousSelected();

  @override
  String toString() => 'PreviousSelected';
}

class NextSelected extends MainEvent {
  const NextSelected();

  @override
  String toString() => 'NextSelected';
}

class SolarSelected extends MainEvent {
  const SolarSelected({required this.solar});

  final DateTime? solar;

  @override
  String toString() => 'SolarSelected { solar: $solar }';

  @override
  List<Object?> get props => [solar];
}

class LunarSelected extends MainEvent {
  const LunarSelected({required this.lunar});

  final String? lunar;

  @override
  String toString() => 'LunarSelected { lunar: $lunar }';

  @override
  List<Object?> get props => [lunar];
}
