import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_view.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: mode,
          title: 'Âm Lịch',
          home: const MainView(),
        );
      },
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

// Celestial palette
const _navy = Color(0xFF0F1B2D);
const _surface = Color(0xFF162036);
const _gold = Color(0xFFF5E6CA);
const _accent = Color(0xFFE8A838);
const _red = Color(0xFFD4534B);
const _teal = Color(0xFF16A085);

ThemeData _darkTheme() {
  const colorScheme = ColorScheme.dark(
    primary: _accent,
    secondary: _red,
    surface: _surface,
    surfaceContainerHighest: _navy,
    onSurface: _gold,
    onPrimary: _navy,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _navy,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _navy,
      foregroundColor: _gold,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _navy,
      labelStyle: TextStyle(color: _gold.withValues(alpha: 0.9), fontSize: 12),
      side: BorderSide(color: _gold.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconTheme: IconThemeData(color: _gold.withValues(alpha: 0.8)),
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w200,
        color: _gold,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _gold,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _gold.withValues(alpha: 0.7),
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        color: _gold.withValues(alpha: 0.9),
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: _gold.withValues(alpha: 0.6),
      ),
    ),
  );
}

ThemeData _lightTheme() {
  const bg = Color(0xFFF5F5F7);
  const colorScheme = ColorScheme.light(
    primary: _teal,
    secondary: _red,
    surfaceContainerHighest: bg,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: Color(0xFF111827),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w200,
        color: Color(0xFF111827),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
      ),
      bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF374151)),
      bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
    ),
  );
}
