import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_view.dart';

void main() {
  final date = _getDate(Uri.base.queryParameters);
  runApp(
    BlocProvider<MainBloc>(
      create: (context) {
        return MainBloc(date)..add(const AppStarted());
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildDarkTheme(),
      title: 'Âm Lịch',
      home: const MainView(),
    );
  }
}

DateTime _getDate(Map<String, String> queryParameters) {
  final date = queryParameters['date'];
  try {
    return date != null
        ? DateFormat('dd-MM-yyyy', 'en_US').parse(date)
        : DateTime.now();
  } on Exception {
    return DateTime.now();
  }
}

ThemeData _buildDarkTheme() {
  const primaryColor = Color(0xFF0175c2);
  const secondaryColor = Color(0xFF13B9FD);
  const colorScheme = ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    error: Color(0xFFB00020),
    surface: Color(0xFF202124),
  );
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    primaryColor: primaryColor,
    canvasColor: const Color(0xFF202124),
    scaffoldBackgroundColor: const Color(0xFF202124),
  );
}
