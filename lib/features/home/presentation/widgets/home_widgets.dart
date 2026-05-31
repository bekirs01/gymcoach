import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../core/workout_exercise_catalog.dart';
import '../../../../core/workout_exercise_l10n.dart';
import '../../../plans/domain/workout_plan.dart';

class HomeReferenceHeader extends StatelessWidget {
  const HomeReferenceHeader({
    super.key,
    required this.greeting,
    required this.displayName,
    required this.avatarUrl,
    required this.onStreakTap,
    required this.onProfileTap,
  });

  final String greeting;
  final String displayName;
  final String avatarUrl;
  final VoidCallback onStreakTap;
  final VoidCallback onProfileTap;

  static String _initials(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.length >= 2 ? p.substring(0, 2).toUpperCase() : p.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim().isEmpty ? '—' : displayName.trim();

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF8A50),
            onTap: onStreakTap,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl.trim().isEmpty
                    ? Text(
                        _initials(name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      )
                    : Image.network(
                        avatarUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          _initials(name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = PremiumColors.textSecondary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

class HomeTopTabs extends StatelessWidget {
  const HomeTopTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF141B27),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? PremiumColors.tabActive
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: i == selectedIndex
                          ? Colors.white
                          : PremiumColors.textSecondary,
                      fontSize: 13,
                      fontWeight: i == selectedIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomeSubtleBanner extends StatelessWidget {
  const HomeSubtleBanner({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF192231),
          borderRadius: BorderRadius.circular(PremiumRadii.md),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: PremiumColors.bannerOrange.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFFFB36D), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: PremiumColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeFeaturedTrainingCard extends StatelessWidget {
  const HomeFeaturedTrainingCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onShare,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 138,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/workout_categories/home_banner.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2B4564),
                      Color(0xFF1C2C42),
                      Color(0xFF101A29),
                    ],
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.46),
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -26,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 22,
              top: 20,
              child: Transform.rotate(
                angle: -0.7,
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 90,
                  color: Colors.white.withValues(alpha: 0.17),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 74, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: onShare,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PremiumColors.accentBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PremiumColors.accentBlue.withValues(alpha: 0.28),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              '$actionLabel >',
              style: const TextStyle(
                color: PremiumColors.accentBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class HomeMonthlyCalendar extends StatelessWidget {
  const HomeMonthlyCalendar({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.plannedDays,
    required this.completedDays,
    required this.onMonthChanged,
    required this.onDaySelected,
    required this.l10n,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Set<DateTime> plannedDays;
  final Set<DateTime> completedDays;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(month);
    final cells = _buildMonthCells(month);
    final weekdays = [
      l10n.calendarDow1,
      l10n.calendarDow2,
      l10n.calendarDow3,
      l10n.calendarDow4,
      l10n.calendarDow5,
      l10n.calendarDow6,
      l10n.calendarDow7,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2A),
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _MonthArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => onMonthChanged(-1),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _MonthArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => onMonthChanged(1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final w in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: TextStyle(
                        color: PremiumColors.textSecondary.withValues(alpha: 0.86),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - 12) / 7;
              return Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  for (final cell in cells)
                    SizedBox(
                      width: cellWidth,
                      height: 37,
                      child: Builder(
                        builder: (context) {
                          final key = DateTime(
                            cell.date.year,
                            cell.date.month,
                            cell.date.day,
                          );
                          return _CalendarDayCell(
                            day: cell.date.day,
                            outsideMonth: cell.outsideMonth,
                            selected: _sameDay(key, selectedDay),
                            hasPlan: plannedDays.contains(key),
                            completed: completedDays.contains(key),
                            onTap: () => onDaySelected(key),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 30,
        child: Icon(icon, size: 22, color: PremiumColors.accentBlue),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.outsideMonth,
    required this.selected,
    required this.hasPlan,
    required this.completed,
    required this.onTap,
  });

  final int day;
  final bool outsideMonth;
  final bool selected;
  final bool hasPlan;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = outsideMonth
        ? PremiumColors.textMuted.withValues(alpha: 0.48)
        : selected
            ? Colors.white
            : PremiumColors.textPrimary.withValues(alpha: 0.9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? PremiumColors.accentBlue.withValues(alpha: 0.28) : null,
          borderRadius: BorderRadius.circular(9),
          border: selected
              ? Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.75))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            if (!outsideMonth && (hasPlan || completed)) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? PremiumColors.successGreen
                      : PremiumColors.accentBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeWorkoutBuilderPanel extends StatefulWidget {
  const HomeWorkoutBuilderPanel({
    super.key,
    required this.plans,
    required this.onAddPlan,
    required this.onOpenPlan,
    required this.onStartPlan,
  });

  final List<WorkoutPlan> plans;
  final ValueChanged<WorkoutPlan> onAddPlan;
  final ValueChanged<WorkoutPlan> onOpenPlan;
  final ValueChanged<WorkoutPlan> onStartPlan;

  @override
  State<HomeWorkoutBuilderPanel> createState() => _HomeWorkoutBuilderPanelState();
}

class _HomeWorkoutBuilderPanelState extends State<HomeWorkoutBuilderPanel> {
  Future<void> _openComposer() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _WorkoutComposerSheet(onAddPlan: widget.onAddPlan),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.plans.isEmpty)
          _WorkoutEmptyState(onCreate: _openComposer),
        if (widget.plans.isNotEmpty) ...[
          for (final plan in widget.plans.take(4)) ...[
            _WorkoutPlanTile(
              plan: plan,
              l10n: l10n,
              onOpen: () => widget.onOpenPlan(plan),
              onStart: () => widget.onStartPlan(plan),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _openComposer,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.homeAddWorkout),
              style: FilledButton.styleFrom(
                backgroundColor: PremiumColors.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WorkoutComposerSheet extends StatefulWidget {
  const _WorkoutComposerSheet({required this.onAddPlan});

  final ValueChanged<WorkoutPlan> onAddPlan;

  @override
  State<_WorkoutComposerSheet> createState() => _WorkoutComposerSheetState();
}

class _WorkoutComposerSheetState extends State<_WorkoutComposerSheet> {
  final _nameController = TextEditingController();
  final Set<String> _selectedExerciseNames = {};
  final Set<String> _selectedCategoryTitles = {WorkoutExerciseCatalog.categories.first.title};
  var _step = _WorkoutBuildStep.category;

  List<WorkoutExerciseCategory> get _selectedCategories {
    return WorkoutExerciseCatalog.categories
        .where((category) => _selectedCategoryTitles.contains(category.title))
        .toList();
  }

  List<WorkoutExerciseEntry> get _selectedExercises {
    return WorkoutExerciseCatalog.allExercises
        .where((exercise) => _selectedExerciseNames.contains(exercise.name))
        .toList();
  }

  String _title(AppLocalizations l10n) {
    return switch (_step) {
      _WorkoutBuildStep.category => l10n.workoutChooseMuscleGroup,
      _WorkoutBuildStep.exercises => _selectedCategories.length == 1
          ? WorkoutExerciseL10n.categoryTitle(l10n, _selectedCategories.first.title)
          : l10n.workoutChooseExercises,
      _WorkoutBuildStep.details => l10n.workoutNameYourWorkout,
    };
  }

  void _toggleCategory(WorkoutExerciseCategory category) {
    setState(() {
      if (_selectedCategoryTitles.contains(category.title)) {
        if (_selectedCategoryTitles.length > 1) {
          _selectedCategoryTitles.remove(category.title);
        }
      } else {
        _selectedCategoryTitles.add(category.title);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleExercise(WorkoutExerciseEntry exercise) {
    setState(() {
      if (_selectedExerciseNames.contains(exercise.name)) {
        _selectedExerciseNames.remove(exercise.name);
      } else {
        _selectedExerciseNames.add(exercise.name);
      }
    });
  }

  void _saveWorkout() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedExerciseNames.isEmpty) return;

    final now = DateTime.now();
    widget.onAddPlan(
      WorkoutPlan(
        id: now.microsecondsSinceEpoch.toString(),
        name: name,
        scheduledDate: WorkoutPlan.dateOnly(now),
        scheduledTime: TimeOfDay.now(),
        durationMinutes: 45,
        difficulty: PlanDifficulty.intermediate,
        exerciseNames: _selectedExerciseNames.toList()..sort(),
        status: PlanStatus.planned,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
            child: Row(
              children: [
                if (_step != _WorkoutBuildStep.category)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _step = _step == _WorkoutBuildStep.details
                            ? _WorkoutBuildStep.exercises
                            : _WorkoutBuildStep.category;
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: PremiumColors.accentBlue,
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    _title(l10n),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: PremiumColors.textSecondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildStep(l10n),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: _buildBottomAction(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n) {
    return switch (_step) {
      _WorkoutBuildStep.category => _buildCategoryStep(l10n),
      _WorkoutBuildStep.exercises => _buildExerciseStep(l10n),
      _WorkoutBuildStep.details => _buildDetailsStep(l10n),
    };
  }

  Widget _buildBottomAction(AppLocalizations l10n) {
    return switch (_step) {
      _WorkoutBuildStep.category => FilledButton(
          onPressed: _selectedCategoryTitles.isEmpty
              ? null
              : () => setState(() => _step = _WorkoutBuildStep.exercises),
          style: _primaryButtonStyle(),
          child: Text(
            _selectedCategoryTitles.length <= 1
                ? l10n.workoutContinue
                : l10n.workoutContinueGroups(_selectedCategoryTitles.length),
          ),
        ),
      _WorkoutBuildStep.exercises => FilledButton(
          onPressed: _selectedExerciseNames.isEmpty
              ? null
              : () => setState(() => _step = _WorkoutBuildStep.details),
          style: _primaryButtonStyle(),
          child: Text(
            _selectedExerciseNames.isEmpty
                ? l10n.workoutSelectExercises
                : l10n.workoutContinueExercises(_selectedExerciseNames.length),
          ),
        ),
      _WorkoutBuildStep.details => FilledButton.icon(
          onPressed: _nameController.text.trim().isEmpty || _selectedExerciseNames.isEmpty
              ? null
              : _saveWorkout,
          icon: const Icon(Icons.check_rounded),
          label: Text(l10n.workoutSaveWorkout),
          style: _primaryButtonStyle(),
        ),
    };
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: PremiumColors.accentBlue,
      disabledBackgroundColor: PremiumColors.surfaceRaised,
      foregroundColor: Colors.white,
      disabledForegroundColor: PremiumColors.textMuted,
      minimumSize: const Size.fromHeight(54),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.md),
      ),
    );
  }

  Widget _buildCategoryStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.workoutMuscleGroupHint,
          style: const TextStyle(
            color: PremiumColors.textSecondary,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        for (final category in WorkoutExerciseCatalog.categories) ...[
          _MuscleCategoryCard(
            category: category,
            l10n: l10n,
            selected: _selectedCategoryTitles.contains(category.title),
            onTap: () => _toggleCategory(category),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildExerciseStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _selectedCategories.length == 1
              ? l10n.workoutExerciseHintSingle(
                  WorkoutExerciseL10n.categoryTitle(l10n, _selectedCategories.first.title),
                )
              : l10n.workoutExerciseHintMulti,
          style: const TextStyle(
            color: PremiumColors.textSecondary,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        for (final category in _selectedCategories) ...[
          if (_selectedCategories.length > 1) ...[
            Text(
              WorkoutExerciseL10n.categoryTitle(l10n, category.title),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (final exercise in category.exercises) ...[
            _ExercisePhotoCard(
              exercise: exercise,
              l10n: l10n,
              selected: _selectedExerciseNames.contains(exercise.name),
              onTap: () => _toggleExercise(exercise),
            ),
            const SizedBox(height: 10),
          ],
          if (_selectedCategories.length > 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: l10n.workoutNameHint,
            hintStyle: TextStyle(
              color: PremiumColors.textMuted.withValues(alpha: 0.8),
            ),
            filled: true,
            fillColor: PremiumColors.surface,
            prefixIcon: const Icon(
              Icons.edit_note_rounded,
              color: PremiumColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PremiumRadii.md),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PremiumRadii.md),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PremiumRadii.md),
              borderSide: const BorderSide(color: PremiumColors.accentBlue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final exercise in _selectedExercises) ...[
          _SelectedExerciseSummary(exercise: exercise, l10n: l10n),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

enum _WorkoutBuildStep { category, exercises, details }

class _WorkoutEmptyState extends StatelessWidget {
  const _WorkoutEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 22),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 76,
            color: PremiumColors.accentBlue.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.workoutListEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.workoutListEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.workoutAddTrainingDay),
            style: FilledButton.styleFrom(
              backgroundColor: PremiumColors.accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int _workoutProgressPercent(WorkoutPlan plan) {
  return plan.status == PlanStatus.completed ? 100 : 0;
}

class _WorkoutProgressRing extends StatelessWidget {
  const _WorkoutProgressRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final progress = percent / 100.0;
    final color = percent >= 100
        ? const Color(0xFF34C759)
        : const Color(0xFFFF453A);

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              color: color,
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanTile extends StatelessWidget {
  const _WorkoutPlanTile({
    required this.plan,
    required this.l10n,
    required this.onOpen,
    required this.onStart,
  });

  final WorkoutPlan plan;
  final AppLocalizations l10n;
  final VoidCallback onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final imageAsset = WorkoutExerciseCatalog.imageForName(plan.exerciseNames.isEmpty
        ? null
        : plan.exerciseNames.first);
    final progressPercent = _workoutProgressPercent(plan);

    return Material(
      color: PremiumColors.surface,
      borderRadius: BorderRadius.circular(PremiumRadii.md),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Row(
            children: [
              _WorkoutProgressRing(percent: progressPercent),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageAsset == null
                      ? Container(
                          color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: PremiumColors.accentBlue,
                          ),
                        )
                      : Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: PremiumColors.accentBlue,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.exercisesCount(plan.exerciseNames.length)} · ${plan.formattedTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                color: PremiumColors.accentBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExercisePhotoCard extends StatelessWidget {
  const _ExercisePhotoCard({
    required this.exercise,
    required this.l10n,
    required this.selected,
    required this.onTap,
  });

  final WorkoutExerciseEntry exercise;
  final AppLocalizations l10n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = WorkoutExerciseL10n.name(l10n, exercise.name);
    final displayDescription = WorkoutExerciseL10n.description(l10n, exercise.name, exercise.description);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: BoxConstraints(minHeight: selected ? 138 : 104),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.circular(PremiumRadii.md),
          border: Border.all(
            color: selected
                ? PremiumColors.accentBlue.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.1),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 92,
                child: Image.asset(
                  exercise.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: PremiumColors.surfaceRaised,
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: PremiumColors.textMuted,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: selected
                              ? PremiumColors.accentBlue
                              : Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? PremiumColors.accentBlue
                                : Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Icon(
                          selected ? Icons.check_rounded : Icons.add_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    displayDescription,
                    maxLines: selected ? 4 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.workoutSelected,
                      style: const TextStyle(
                        color: PremiumColors.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedExerciseSummary extends StatelessWidget {
  const _SelectedExerciseSummary({required this.exercise, required this.l10n});

  final WorkoutExerciseEntry exercise;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final displayName = WorkoutExerciseL10n.name(l10n, exercise.name);
    final displayDescription = WorkoutExerciseL10n.description(l10n, exercise.name, exercise.description);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Image.asset(
                exercise.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: PremiumColors.surfaceRaised,
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: PremiumColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleCategoryCard extends StatelessWidget {
  const _MuscleCategoryCard({
    required this.category,
    required this.l10n,
    required this.selected,
    required this.onTap,
  });

  final WorkoutExerciseCategory category;
  final AppLocalizations l10n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = WorkoutExerciseL10n.categoryTitle(l10n, category.title);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 138,
        padding: const EdgeInsets.all(14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          border: Border.all(
            color: selected
                ? PremiumColors.accentBlue.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.1),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              category.imageAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [category.startColor, category.endColor],
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.74),
                    Colors.black.withValues(alpha: 0.34),
                    Colors.black.withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(
                category.icon,
                size: 58,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (selected)
              const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthCell {
  const _MonthCell({required this.date, required this.outsideMonth});

  final DateTime date;
  final bool outsideMonth;
}

List<_MonthCell> _buildMonthCells(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final leading = first.weekday - 1;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final prevMonthDays = DateTime(month.year, month.month, 0).day;
  final total = ((leading + daysInMonth + 6) ~/ 7) * 7;

  return List.generate(total, (index) {
    if (index < leading) {
      final day = prevMonthDays - leading + index + 1;
      final m = month.month == 1 ? 12 : month.month - 1;
      final y = month.month == 1 ? month.year - 1 : month.year;
      return _MonthCell(date: DateTime(y, m, day), outsideMonth: true);
    }

    final dayIndex = index - leading;
    if (dayIndex >= daysInMonth) {
      final day = dayIndex - daysInMonth + 1;
      final m = month.month == 12 ? 1 : month.month + 1;
      final y = month.month == 12 ? month.year + 1 : month.year;
      return _MonthCell(date: DateTime(y, m, day), outsideMonth: true);
    }

    return _MonthCell(
      date: DateTime(month.year, month.month, dayIndex + 1),
      outsideMonth: false,
    );
  });
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
