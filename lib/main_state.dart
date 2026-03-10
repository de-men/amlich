import 'package:equatable/equatable.dart';
import 'package:licham/lunar.dart';

abstract class MainState extends Equatable {
  const MainState();

  @override
  List<Object?> get props => const [];
}

class MainUninitialized extends MainState {
  const MainUninitialized();

  @override
  String toString() => 'MainUninitialized';
}

class MainFailure extends MainState {
  const MainFailure({required this.error});

  final String error;

  @override
  String toString() => 'MainFailure { error: $error }';

  @override
  List<Object> get props => [error];
}

class DateUpdate extends MainState {
  const DateUpdate({required this.solar, required this.lunar});

  final DateTime? solar;
  final Lunar? lunar;

  @override
  String toString() => 'DateUpdate { solar: $solar, lunar: $lunar }';

  @override
  List<Object?> get props => [solar, lunar];
}
