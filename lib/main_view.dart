import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:licham/ics_generator.dart';
import 'package:licham/js/window.dart';
import 'package:licham/lunar.dart';
import 'package:licham/lunar_converter.dart';
import 'package:licham/main.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';
import 'package:licham/widget/loading_indicator.dart';
import 'package:licham/widget/moon_phase.dart';
import 'package:licham/widget/my_flutter_app_icons.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final _formKey = GlobalKey<FormState>();
  bool _lunarFocus = true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainBloc>();
    return BlocBuilder<MainBloc, MainState>(
      buildWhen: (_, current) => current is DateUpdate,
      builder: (context, state) {
        if (state is! DateUpdate) return const LoadingIndicator();

        final solar = state.solar!;
        final lunar = state.lunar!;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(const TodaySelected());
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      _Header(
                        onSearch: () => _showSearchDialog(bloc),
                        lunarFocus: _lunarFocus,
                        onToggleFocus: () {
                          setState(() => _lunarFocus = !_lunarFocus);
                        },
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;
                          if (details.primaryVelocity! < 0) {
                            bloc.add(const NextSelected());
                          } else if (details.primaryVelocity! > 0) {
                            bloc.add(const PreviousSelected());
                          }
                        },
                        child: _TodayCard(
                          solar: solar,
                          lunar: lunar,
                          bloc: bloc,
                          lunarFocus: _lunarFocus,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;
                          final prevMonth = DateTime(
                            solar.year,
                            solar.month +
                                (details.primaryVelocity! < 0 ? 1 : -1),
                            solar.day.clamp(1, 28),
                          );
                          bloc.add(SolarSelected(solar: prevMonth));
                        },
                        child: _MonthCalendar(
                          selectedDate: solar,
                          selectedLunar: lunar,
                          lunarFocus: _lunarFocus,
                          onDateSelected: (date) {
                            bloc.add(SolarSelected(solar: date));
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoPanel(lunar: lunar),
                      const SizedBox(height: 12),
                      _Footer(selectedYear: solar.year),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSearchDialog(MainBloc bloc) {
    if (_lunarFocus) {
      return _showSolarSearchDialog(bloc);
    }
    return _showLunarSearchDialog(bloc);
  }

  Future<void> _showLunarSearchDialog(MainBloc bloc) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tìm ngày Âm'),
          content: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ngày/Tháng/Năm Âm lịch',
                hintText: '15/1/2024',
              ),
              validator: _validateLunarDate,
              onSaved: (value) {
                Navigator.pop(context);
                bloc.add(LunarSelected(lunar: value));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: _submitForm,
              child: const Text('Tìm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSolarSearchDialog(MainBloc bloc) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tìm ngày Dương'),
          content: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ngày/Tháng/Năm Dương lịch',
                hintText: '10/3/2026',
              ),
              validator: _validateSolarDate,
              onSaved: (value) {
                Navigator.pop(context);
                final parts = value!.split('/');
                bloc.add(
                  SolarSelected(
                    solar: DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: _submitForm,
              child: const Text('Tìm'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    final form = _formKey.currentState!;
    if (form.validate()) form.save();
  }

  String? _validateLunarDate(String? value) {
    if (value == null || value.isEmpty) return 'Cần nhập ngày âm';
    final parts = value.split('/');
    if (parts.length != 3) return 'Nhập theo Ngày/Tháng/Năm';
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Nhập theo Ngày/Tháng/Năm';
    }
    if (day < 1 || day > 30) return 'Ngày từ 1 đến 30';
    if (month < 1 || month > 12) return 'Tháng từ 1 đến 12';
    if (year < 1) return 'Năm không hợp lệ';
    return null;
  }

  String? _validateSolarDate(String? value) {
    if (value == null || value.isEmpty) return 'Cần nhập ngày dương';
    final parts = value.split('/');
    if (parts.length != 3) return 'Nhập theo Ngày/Tháng/Năm';
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Nhập theo Ngày/Tháng/Năm';
    }
    if (day < 1 || day > 31) return 'Ngày từ 1 đến 31';
    if (month < 1 || month > 12) return 'Tháng từ 1 đến 12';
    if (year < 1) return 'Năm không hợp lệ';
    return null;
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({
    required this.onSearch,
    required this.lunarFocus,
    required this.onToggleFocus,
  });

  final VoidCallback onSearch;
  final bool lunarFocus;
  final VoidCallback onToggleFocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          Icons.dark_mode,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 8),
        Text('Âm Lịch', style: Theme.of(context).textTheme.headlineMedium),
        const Spacer(),
        IconButton(
          tooltip: lunarFocus ? 'Dương lịch' : 'Âm lịch',
          icon: Icon(lunarFocus ? Icons.dark_mode : Icons.wb_sunny),
          onPressed: onToggleFocus,
        ),
        IconButton(
          tooltip: 'Hôm nay',
          icon: const Icon(Icons.today),
          onPressed: () => context.read<MainBloc>().add(const TodaySelected()),
        ),
        IconButton(
          tooltip: lunarFocus ? 'Tìm ngày Dương' : 'Tìm ngày Âm',
          icon: const Icon(Icons.search),
          onPressed: onSearch,
        ),
        IconButton(
          tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
          onPressed: () {
            themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Today Card
// ---------------------------------------------------------------------------
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.solar,
    required this.lunar,
    required this.bloc,
    required this.lunarFocus,
  });

  final DateTime solar;
  final Lunar lunar;
  final MainBloc bloc;
  final bool lunarFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    final moonShadow =
        isDark ? const Color(0xFF0F1B2D) : const Color(0xFFE5E7EB);
    final moonColor =
        isDark ? const Color(0xFFF5E6CA) : const Color(0xFF374151);

    final primaryTitle = lunarFocus ? '${lunar.day}' : '${solar.day}';
    final secondaryText = lunarFocus
        ? '${bloc.weekFormat.format(solar)} • '
            '${solar.day}/${solar.month}/${solar.year}'
        : 'Ngày ${lunar.day} ${lunar.monthString} • '
            'Năm ${lunar.canchiYear}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => bloc.add(const PreviousSelected()),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        lunarFocus
                            ? '${lunar.monthString}'
                            : bloc.weekFormat.format(solar),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        primaryTitle,
                        style: theme.textTheme.displayLarge,
                      ),
                      Text(
                        lunarFocus
                            ? 'Năm ${lunar.canchiYear}'
                            : bloc.monthYearFormat.format(solar).toUpperCase(),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => bloc.add(const NextSelected()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoonPhaseIcon(
                    lunarDay: lunar.day,
                    color: moonColor,
                    shadowColor: moonShadow,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      secondaryText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month Calendar
// ---------------------------------------------------------------------------
class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.selectedDate,
    required this.selectedLunar,
    required this.lunarFocus,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Lunar selectedLunar;
  final bool lunarFocus;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstOfMonth = DateTime(selectedDate.year, selectedDate.month);
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthNav(theme),
            const SizedBox(height: 8),
            _buildWeekdayHeaders(theme),
            const SizedBox(height: 4),
            ..._buildWeeks(
              context,
              today,
              firstOfMonth,
              daysInMonth,
              startWeekday,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNav(ThemeData theme) {
    final canChi = LunarConverter.getCanChiYear(selectedLunar.year);
    final title = lunarFocus
        ? '${selectedLunar.monthString} • $canChi'
        : 'Tháng ${selectedDate.month}, ${selectedDate.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: () {
            final prev = DateTime(
              selectedDate.year,
              selectedDate.month - 1,
              selectedDate.day.clamp(
                1,
                DateTime(selectedDate.year, selectedDate.month, 0).day,
              ),
            );
            onDateSelected(prev);
          },
        ),
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: () {
            final maxDay = DateTime(
              selectedDate.year,
              selectedDate.month + 2,
              0,
            ).day;
            final next = DateTime(
              selectedDate.year,
              selectedDate.month + 1,
              selectedDate.day.clamp(1, maxDay),
            );
            onDateSelected(next);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    return Row(
      children: _weekdays.map((d) {
        final isWeekend = d == 'T7' || d == 'CN';
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? theme.colorScheme.secondary.withValues(alpha: 0.7)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildWeeks(
    BuildContext context,
    DateTime today,
    DateTime firstOfMonth,
    int daysInMonth,
    int startWeekday,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    final moonShadow = isDark ? const Color(0xFF162036) : Colors.white;
    final moonColor =
        isDark ? const Color(0xFFF5E6CA) : const Color(0xFF6B7280);

    final weeks = <Widget>[];
    var dayCounter = 1 - (startWeekday - 1);

    while (dayCounter <= daysInMonth) {
      final cells = <Widget>[];
      for (var col = 0; col < 7; col++) {
        final day = dayCounter;
        dayCounter++;

        if (day < 1 || day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 60)));
          continue;
        }

        final date = DateTime(firstOfMonth.year, firstOfMonth.month, day);
        final isToday = date == today;
        final isSelected = date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
        final lunarResult = LunarConverter.solarToLunar(
          day,
          firstOfMonth.month,
          firstOfMonth.year,
        );
        final lunarDay = lunarResult[0];
        final phase = moonPhaseFromLunarDay(lunarDay);
        final isKeyPhase = phase == MoonPhaseType.newMoon ||
            phase == MoonPhaseType.fullMoon ||
            phase == MoonPhaseType.firstQuarter ||
            phase == MoonPhaseType.thirdQuarter;
        final isWeekend = col >= 5;

        cells.add(
          Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                height: 60,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isToday
                      ? primary
                      : isSelected
                          ? primary.withValues(alpha: 0.15)
                          : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Primary number: lunar day or solar day
                    Text(
                      lunarFocus ? '$lunarDay' : '$day',
                      style: TextStyle(
                        fontSize: lunarFocus ? 14 : 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? theme.colorScheme.onPrimary
                            : isWeekend
                                ? accent.withValues(alpha: 0.8)
                                : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Secondary: moon icon or the other day number
                    if (isKeyPhase && lunarFocus)
                      MoonPhaseIcon(
                        lunarDay: lunarDay,
                        size: 14,
                        color:
                            isToday ? theme.colorScheme.onPrimary : moonColor,
                        shadowColor: isToday ? primary : moonShadow,
                      )
                    else
                      Text(
                        lunarFocus ? '$day' : '$lunarDay',
                        style: TextStyle(
                          fontSize: 10,
                          color: isToday
                              ? theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.7)
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      weeks.add(Row(children: cells));
    }
    return weeks;
  }
}

// ---------------------------------------------------------------------------
// Info Panel
// ---------------------------------------------------------------------------
class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.lunar});

  final Lunar lunar;

  static const _hourEmoji = [
    '🐀',
    '🐂',
    '🐅',
    '🐇',
    '🐉',
    '🐍',
    '🐴',
    '🐐',
    '🐒',
    '🐓',
    '🐕',
    '🐖',
  ];

  static const _hourLabels = [
    'Tí',
    'Sửu',
    'Dần',
    'Mão',
    'Thìn',
    'Tỵ',
    'Ngọ',
    'Mùi',
    'Thân',
    'Dậu',
    'Tuất',
    'Hợi',
  ];

  static const _hourTimes = [
    '23-1',
    '1-3',
    '3-5',
    '5-7',
    '7-9',
    '9-11',
    '11-13',
    '13-15',
    '15-17',
    '17-19',
    '19-21',
    '21-23',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final hours = lunar.hours ?? <String>[];
    final moonColor =
        isDark ? const Color(0xFFF5E6CA) : const Color(0xFF374151);
    final moonShadow =
        isDark ? const Color(0xFF0F1B2D) : const Color(0xFFE5E7EB);

    final phase = moonPhaseFromLunarDay(lunar.day);
    final phaseLabel = moonPhaseLabel(phase);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _infoTile(
                  context,
                  icon: MoonPhaseIcon(
                    lunarDay: lunar.day,
                    size: 36,
                    color: moonColor,
                    shadowColor: moonShadow,
                  ),
                  label: phaseLabel.isNotEmpty
                      ? phaseLabel.replaceAll('\n', ' ')
                      : 'Ngày ${lunar.day}',
                  labelColor: primary,
                ),
                _infoTile(
                  context,
                  title: 'Ngày',
                  value: lunar.canChiDay ?? '',
                ),
                _infoTile(
                  context,
                  title: 'Tháng',
                  value: lunar.canChiMonth ?? '',
                ),
                _infoTile(
                  context,
                  title: 'Năm',
                  value: lunar.canchiYear ?? '',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Giờ Hoàng Đạo',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _buildHoursGrid(theme, hours, primary),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    Widget? icon,
    String? title,
    String? value,
    String? label,
    Color? labelColor,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          if (icon != null) icon,
          if (title != null)
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 6),
          if (value != null)
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          if (label != null)
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildHoursGrid(
    ThemeData theme,
    List<String> activeHours,
    Color primary,
  ) {
    return Row(
      children: List.generate(12, (i) {
        final isActive = activeHours.contains(LunarConverter.hourNames[i]);

        return Expanded(
          child: Tooltip(
            message: '${_hourLabels[i]}: ${_hourTimes[i]}h',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? primary.withValues(alpha: 0.4)
                      : theme.textTheme.bodyMedium!.color!
                          .withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _hourEmoji[i],
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hourLabels[i],
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------
class _Footer extends StatelessWidget {
  const _Footer({required this.selectedYear});

  final int selectedYear;

  @override
  Widget build(BuildContext context) {
    final decadeStart = selectedYear ~/ 10 * 10;
    final decadeEnd = decadeStart + 9;
    final label = '${decadeStart}s';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.download, size: 16),
          label: Text('Tải Âm Lịch $label'),
          onPressed: () {
            final ics = generateIcs(decadeStart, decadeEnd);
            download('amlich-$label.ics', ics);
          },
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          icon: const Icon(CustomIcons.githubCircled, size: 16),
          label: const Text('GitHub'),
          onPressed: () => open('https://github.com/de-men/amlich'),
        ),
      ],
    );
  }
}
