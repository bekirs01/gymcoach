import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../plans/domain/workout_plan.dart';

class HomeReferenceHeader extends StatelessWidget {
  const HomeReferenceHeader({
    super.key,
    required this.title,
    required this.onClockTap,
    required this.onEditTap,
    required this.onMenuTap,
  });

  final String title;
  final VoidCallback onClockTap;
  final VoidCallback onEditTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          _HeaderIconButton(icon: Icons.schedule_rounded, onTap: onClockTap),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          _HeaderIconButton(icon: Icons.edit_outlined, onTap: onEditTap),
          const SizedBox(width: 4),
          _HeaderIconButton(icon: Icons.menu_rounded, onTap: onMenuTap),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

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
          child: Icon(icon, size: 20, color: PremiumColors.textSecondary),
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
              'assets/workout_categories/chest.jpg',
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.05,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    subtitle,
                    maxLines: 1,
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
  final _nameController = TextEditingController();
  final Set<String> _selectedExercises = {};
  var _selectedCategory = _exerciseCategories.first;
  var _showComposer = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleExercise(String exercise) {
    setState(() {
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  void _saveWorkout() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedExercises.isEmpty) return;

    final now = DateTime.now();
    widget.onAddPlan(
      WorkoutPlan(
        id: now.microsecondsSinceEpoch.toString(),
        name: name,
        scheduledDate: WorkoutPlan.dateOnly(now),
        scheduledTime: TimeOfDay.now(),
        durationMinutes: 45,
        difficulty: PlanDifficulty.intermediate,
        exerciseNames: _selectedExercises.toList()..sort(),
        status: PlanStatus.planned,
      ),
    );

    setState(() {
      _nameController.clear();
      _selectedExercises.clear();
      _showComposer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        _nameController.text.trim().isNotEmpty && _selectedExercises.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Training Days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _showComposer = !_showComposer),
              icon: Icon(
                _showComposer ? Icons.close_rounded : Icons.add_rounded,
                color: PremiumColors.accentBlue,
              ),
              style: IconButton.styleFrom(
                backgroundColor: PremiumColors.surfaceRaised,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_showComposer && widget.plans.isEmpty)
          _WorkoutEmptyState(onCreate: () => setState(() => _showComposer = true)),
        if (!_showComposer && widget.plans.isNotEmpty) ...[
          for (final plan in widget.plans.take(4)) ...[
            _WorkoutPlanTile(
              plan: plan,
              onOpen: () => widget.onOpenPlan(plan),
              onStart: () => widget.onStartPlan(plan),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => setState(() => _showComposer = true),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add workout'),
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
        if (_showComposer) ...[
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
              hintText: 'Enter workout name...',
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
          const SizedBox(height: 14),
          SizedBox(
            height: 126,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _exerciseCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = _exerciseCategories[index];
                return _MuscleCategoryCard(
                  category: category,
                  selected: category == _selectedCategory,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final exercise in _selectedCategory.exercises)
                _ExerciseChoiceChip(
                  label: exercise,
                  selected: _selectedExercises.contains(exercise),
                  onTap: () => _toggleExercise(exercise),
                ),
            ],
          ),
          if (_selectedExercises.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Selected: ${_selectedExercises.length}',
              style: const TextStyle(
                color: PremiumColors.accentBlue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: canSave ? _saveWorkout : null,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save workout'),
            style: FilledButton.styleFrom(
              backgroundColor: PremiumColors.accentBlue,
              disabledBackgroundColor: PremiumColors.surfaceRaised,
              foregroundColor: Colors.white,
              disabledForegroundColor: PremiumColors.textMuted,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.md),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WorkoutEmptyState extends StatelessWidget {
  const _WorkoutEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Your workout list is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding exercises to a new training day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add training day'),
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

class _WorkoutPlanTile extends StatelessWidget {
  const _WorkoutPlanTile({
    required this.plan,
    required this.onOpen,
    required this.onStart,
  });

  final WorkoutPlan plan;
  final VoidCallback onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onOpen,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PremiumColors.accentBlue.withValues(alpha: 0.16),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: PremiumColors.accentBlue,
          ),
        ),
        title: Text(
          plan.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${plan.exerciseNames.length} exercises · ${plan.formattedTime}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: PremiumColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded),
          color: PremiumColors.accentBlue,
        ),
      ),
    );
  }
}

class _MuscleCategoryCard extends StatelessWidget {
  const _MuscleCategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _ExerciseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 158,
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.72),
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
              alignment: Alignment.bottomLeft,
              child: Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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

class _ExerciseChoiceChip extends StatelessWidget {
  const _ExerciseChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? PremiumColors.accentBlue.withValues(alpha: 0.24)
              : PremiumColors.surface,
          borderRadius: BorderRadius.circular(PremiumRadii.pill),
          border: Border.all(
            color: selected
                ? PremiumColors.accentBlue.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check_rounded,
                color: PremiumColors.accentBlue,
                size: 16,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : PremiumColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCategory {
  const _ExerciseCategory({
    required this.title,
    required this.imageAsset,
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.exercises,
  });

  final String title;
  final String imageAsset;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final List<String> exercises;
}

const _exerciseCategories = [
  _ExerciseCategory(
    title: 'Chest',
    imageAsset: 'assets/workout_categories/chest.jpg',
    icon: Icons.accessibility_new_rounded,
    startColor: Color(0xFF0B3344),
    endColor: Color(0xFF12263A),
    exercises: ['Push-ups', 'Bench Press', 'Incline Press', 'Chest Fly'],
  ),
  _ExerciseCategory(
    title: 'Back',
    imageAsset: 'assets/workout_categories/back.jpg',
    icon: Icons.self_improvement_rounded,
    startColor: Color(0xFF123A42),
    endColor: Color(0xFF13283A),
    exercises: ['Pull-ups', 'Lat Pulldown', 'Seated Row', 'Deadlift'],
  ),
  _ExerciseCategory(
    title: 'Legs',
    imageAsset: 'assets/workout_categories/legs.jpg',
    icon: Icons.directions_run_rounded,
    startColor: Color(0xFF25394F),
    endColor: Color(0xFF172338),
    exercises: ['Squats', 'Lunges', 'Leg Press', 'Leg Curl'],
  ),
  _ExerciseCategory(
    title: 'Glutes',
    imageAsset: 'assets/workout_categories/glutes.jpg',
    icon: Icons.fitness_center_rounded,
    startColor: Color(0xFF3A2B4A),
    endColor: Color(0xFF1C2438),
    exercises: ['Hip Thrust', 'Glute Bridge', 'Romanian Deadlift', 'Step-ups'],
  ),
  _ExerciseCategory(
    title: 'Shoulders',
    imageAsset: 'assets/workout_categories/shoulders.jpg',
    icon: Icons.sports_gymnastics_rounded,
    startColor: Color(0xFF3B344A),
    endColor: Color(0xFF172235),
    exercises: ['Shoulder Press', 'Lateral Raise', 'Front Raise', 'Face Pull'],
  ),
  _ExerciseCategory(
    title: 'Arms',
    imageAsset: 'assets/workout_categories/arms.jpg',
    icon: Icons.sports_martial_arts_rounded,
    startColor: Color(0xFF44302E),
    endColor: Color(0xFF1B2635),
    exercises: ['Biceps Curl', 'Triceps Pushdown', 'Hammer Curl', 'Dips'],
  ),
  _ExerciseCategory(
    title: 'Core',
    imageAsset: 'assets/workout_categories/core.jpg',
    icon: Icons.blur_circular_rounded,
    startColor: Color(0xFF2D3E34),
    endColor: Color(0xFF172337),
    exercises: ['Plank', 'Crunches', 'Leg Raises', 'Russian Twist'],
  ),
  _ExerciseCategory(
    title: 'Cardio',
    imageAsset: 'assets/workout_categories/cardio.jpg',
    icon: Icons.monitor_heart_rounded,
    startColor: Color(0xFF274458),
    endColor: Color(0xFF142236),
    exercises: ['Running', 'Jumping Jacks', 'Cycling', 'Rowing'],
  ),
];

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
