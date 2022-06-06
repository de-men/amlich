import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_view.dart';

void main() {
  DateTime date = _getDate(Uri.base.queryParameters);
  runApp(
    BlocProvider<MainBloc>(
      create: (context) {
        return MainBloc(date)..add(AppStarted());
      },
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  Widget build(ct) {
    return MaterialApp(
      theme: _buildDarkTheme(),
      title: "Âm Lịch",
      home: MainView(),
    );
  }
}

DateTime _getDate(Map<String, String> queryParameters) {
  final date = queryParameters['date'];
  try {
    return date != null
        ? DateFormat("dd-MM-yyyy", "en_US").parse(date)
        : DateTime.now();
  } on Exception {
    return DateTime.now();
  }
}

ThemeData _buildDarkTheme() {
  const Color primaryColor = Color(0xFF0175c2);
  const Color secondaryColor = Color(0xFF13B9FD);
  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    primaryColorDark: const Color(0xFF0050a0),
    primaryColorLight: secondaryColor,
    indicatorColor: Colors.white,
    toggleableActiveColor: const Color(0xFF6997DF),
    canvasColor: const Color(0xFF202124),
    scaffoldBackgroundColor: const Color(0xFF202124),
    backgroundColor: const Color(0xFF202124),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
