import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/session_calorie_estimator.dart';
import '../../plans/domain/workout_plan.dart';
import '../../profile/domain/user_profile.dart';
import '../../camera_validation/data/exercise_name_resolver.dart';
import '../../camera_validation/exercise_tracker_registry.dart';
import '../../camera_validation/domain/exercise_tracking_mode.dart';
import '../../camera_validation/presentation/camera_tracking_page.dart';
import '../domain/completed_exercise_log.dart';
import '../domain/workout_completion.dart';
import '../domain/workout_session_analytics.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({
    super.key,
    required this.plan,
    required this.profile,
    required this.onFinished,
    this.autoStart = false,
    this.lastWeightKgByExercise = const {},
    this.analytics = const NoOpWorkoutSessionAnalytics(),
  });

  final WorkoutPlan plan;
  final UserProfile profile;
  final ValueChanged<WorkoutCompletion> onFinished;
  final bool autoStart;
  final Map<String, double> lastWeightKgByExercise;
  final WorkoutSessionAnalytics analytics;

  static const int defaultRestSeconds = 90;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  DateTime? _startedAt;
  var _index = 0;
  final _saved = <int, ({int sets, int reps, double? weightKg})>{};
  final _logsByIndex = <int, CompletedExerciseLog>{};
  var _isStarted = false;
  var _showSummary = false;
  late WorkoutCompletion _summary;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  Timer? _restTimer;
  var _restSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    if (widget.autoStart) {
      _startedAt = DateTime.now();
      _isStarted = true;
    }
    _fillControllersFromSaved();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final names = widget.plan.exerciseNames;
      if (names.isNotEmpty) {
        widget.analytics.onExerciseBecameActive(0, names[0]);
      }
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _flushInputsToSaved() {
    final s = int.tryParse(_setsController.text.trim());
    final r = int.tryParse(_repsController.text.trim());
    final w = _parseWeight(_weightController.text);
    if (s != null && r != null && s > 0 && r > 0) {
      _saved[_index] = (sets: s, reps: r, weightKg: w);
    }
  }

  double? _parseWeight(String raw) {
    final n = raw.trim().replaceAll(',', '.');
    if (n.isEmpty) return null;
    final v = double.tryParse(n);
    if (v == null || v <= 0 || !v.isFinite) return null;
    return v;
  }

  void _fillControllersFromSaved() {
    final e = _saved[_index];
    if (e != null) {
      _setsController.text = '${e.sets}';
      _repsController.text = '${e.reps}';
      _weightController.text = e.weightKg != null ? '${e.weightKg}' : '';
    } else {
      _setsController.text = '';
      _repsController.text = '';
      final name = widget.plan.exerciseNames[_index];
      final last = widget.lastWeightKgByExercise[name];
      _weightController.text = last != null ? '$last' : '';
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsLeft = WorkoutSessionPage.defaultRestSeconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_restSecondsLeft <= 1) {
        t.cancel();
        setState(() => _restSecondsLeft = 0);
      } else {
        setState(() => _restSecondsLeft -= 1);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _restSecondsLeft = 0);
  }

  void _goToExercise(int i) {
    if (i == _index) return;
    setState(() {
      _flushInputsToSaved();
      _index = i;
      _fillControllersFromSaved();
    });
    widget.analytics.onExerciseBecameActive(i, widget.plan.exerciseNames[i]);
  }

  bool _isCameraSupportedFor(String exerciseName) {
    final l10n = AppLocalizations.of(context)!;
    final canonical = ExerciseNameResolver.canonicalIdForName(exerciseName, l10n);
    if (canonical == null) return false;
    return ExerciseTrackerRegistry.isCameraSupported(canonical);
  }

  Future<void> _openCameraTracking(String exerciseName) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionStartFirst)),
      );
      return;
    }
    final result = await Navigator.of(context).push<CameraTrackingResult>(
      MaterialPageRoute(
        builder: (_) => CameraTrackingPage(exerciseName: exerciseName),
      ),
    );
    if (!mounted || result == null || !result.usedCamera) return;
    final count = result.primaryCount;
    if (count <= 0) return;
    setState(() {
      _repsController.text = '$count';
      if (_setsController.text.trim().isEmpty) {
        _setsController.text = '1';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          result.mode == ExerciseTrackingMode.holdBased
              ? l10n.cameraAppliedHold(count)
              : l10n.cameraAppliedReps(count),
        ),
      ),
    );
  }

  void _completeCurrent() {
    final l10n = AppLocalizations.of(context)!;
    if (!_isStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionStartFirst)),
      );
      return;
    }
    final names = widget.plan.exerciseNames;
    if (_logsByIndex.containsKey(_index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionExerciseAlreadyLogged)),
      );
      return;
    }
    final s = int.tryParse(_setsController.text.trim()) ?? 0;
    final r = int.tryParse(_repsController.text.trim()) ?? 0;
    if (s <= 0 || r <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionValidationSetsReps)),
      );
      return;
    }
    final name = names[_index];
    final id = '${widget.plan.id}_$_index';
    final cat = SessionCalorieEstimator.categoryKeyForName(name);
    final kcal = SessionCalorieEstimator.kcalForExercise(
      weightKg: widget.profile.weightKg,
      categoryKey: cat,
      sets: s,
      reps: r,
    );
    final weight = _parseWeight(_weightController.text);
    final log = CompletedExerciseLog(
      exerciseId: id,
      exerciseName: name,
      setsCompleted: s,
      repsCompleted: r,
      estimatedCalories: kcal,
      completedAt: DateTime.now(),
      categoryKey: cat,
      weightKg: weight,
    );
    widget.analytics.onExerciseLogged(index: _index, sets: s, reps: r);
    setState(() {
      _saved[_index] = (sets: s, reps: r, weightKg: weight);
      _logsByIndex[_index] = log;
      if (_index < names.length - 1) {
        _index++;
        _fillControllersFromSaved();
        widget.analytics.onExerciseBecameActive(_index, names[_index]);
        _startRestTimer();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _finishWorkout();
        });
      }
    });
  }

  void _finishWorkout() {
    final l10n = AppLocalizations.of(context)!;
    if (!_isStarted || _startedAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionStartFirst)),
      );
      return;
    }
    _flushInputsToSaved();
    final names = widget.plan.exerciseNames;
    final finishedAt = DateTime.now();
    final elapsed = finishedAt.difference(_startedAt!).inMinutes.clamp(1, 999);
    final ordered = <CompletedExerciseLog>[];
    for (var i = 0; i < names.length; i++) {
      final log = _logsByIndex[i];
      if (log != null) ordered.add(log);
    }
    final totalKcal = SessionCalorieEstimator.sessionKcalFromLogs(
      weightKg: widget.profile.weightKg,
      difficulty: widget.plan.difficulty,
      durationMinutes: elapsed,
      exerciseCount: names.length,
      logs: ordered,
    );
    widget.analytics.onSessionFinished(finishedAt.difference(_startedAt!));
    _summary = WorkoutCompletion(
      id: finishedAt.microsecondsSinceEpoch.toString(),
      title: widget.plan.name,
      workoutType: l10n.workoutTypePlannedSession,
      completedAt: finishedAt,
      durationMinutes: elapsed,
      calories: totalKcal,
      exerciseNames: List<String>.from(names),
      exerciseLogs: ordered,
      caloriesAreEstimated: true,
    );
    setState(() => _showSummary = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSummary) {
      return _SessionSummaryView(
        completion: _summary,
        onClose: () {
          widget.onFinished(_summary);
          Navigator.of(context).pop();
        },
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final names = widget.plan.exerciseNames;
    final current = names[_index];

    final progressLabel = l10n.sessionExerciseProgress(_index + 1, names.length);
    final logged = _logsByIndex.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.sessionExitTitle),
            content: Text(l10n.sessionExitBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.sessionExitConfirm)),
            ],
          ),
        );
        if (leave == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(progressLabel, style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                widget.plan.name,
                style: theme.bodySmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.sessionLoggedCount(logged, names.length),
                  style: theme.labelMedium?.copyWith(color: AppColors.textMuted),
                ),
                if (_restSecondsLeft > 0) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.sessionRestRemaining(_restSecondsLeft),
                              style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton(onPressed: _skipRest, child: Text(l10n.sessionRestSkip)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Text(
                        current,
                        style: theme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              decoration: InputDecoration(
                                labelText: l10n.labelLoadKg,
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _setsController,
                              decoration: InputDecoration(
                                labelText: l10n.labelSets,
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _repsController,
                              decoration: InputDecoration(
                                labelText: l10n.labelReps,
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isCameraSupportedFor(current))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton.filledTonal(
                            onPressed: _isStarted ? () => _openCameraTracking(current) : null,
                            icon: const Icon(Icons.videocam_outlined),
                            tooltip: l10n.sessionCameraTracking,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (var i = 0; i < names.length; i++)
                            FilterChip(
                              label: Text('${i + 1}'),
                              selected: i == _index,
                              onSelected: (_) => _goToExercise(i),
                              showCheckmark: false,
                              avatar: Icon(
                                _logsByIndex.containsKey(i)
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 18,
                                color: _logsByIndex.containsKey(i) ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _completeCurrent,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _index >= names.length - 1 ? l10n.sessionCompleteFinal : l10n.sessionCompleteExercise,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionSummaryView extends StatelessWidget {
  const _SessionSummaryView({
    required this.completion,
    required this.onClose,
  });

  final WorkoutCompletion completion;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.sessionSummaryTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completion.title,
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.sessionSummaryDuration,
                              value: l10n.minutesShort(completion.durationMinutes),
                              icon: Icons.schedule_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.sessionSummaryCalories,
                              value: l10n.sessionCaloriesUnit(completion.calories),
                              icon: Icons.local_fire_department_outlined,
                            ),
                          ),
                        ],
                      ),
                      if (completion.caloriesAreEstimated) ...[
                        const SizedBox(height: 10),
                        Text(
                          l10n.sessionCaloriesEstimateNote,
                          style: theme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.35),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        l10n.sessionCompletedExercises,
                        style: theme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._buildExerciseLines(context, l10n),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.sessionDone,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExerciseLines(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context).textTheme;
    if (completion.exerciseLogs.isEmpty) {
      return completion.exerciseNames
          .map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      n,
                      style: theme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList();
    }
    return completion.exerciseLogs
        .map(
          (log) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exerciseName,
                        style: theme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        log.weightKg != null
                            ? l10n.historySetsRepsWeight(
                                log.setsCompleted,
                                log.repsCompleted,
                                log.weightKg!,
                              )
                            : l10n.historySetsRepsDetail(log.setsCompleted, log.repsCompleted),
                        style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: theme.labelSmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
