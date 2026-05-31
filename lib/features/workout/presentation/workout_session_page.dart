import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../core/workout_exercise_l10n.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/session_calorie_estimator.dart';
import '../../../core/workout_exercise_catalog.dart';
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
    this.analytics = const NoOpWorkoutSessionAnalytics(),
  });

  final WorkoutPlan plan;
  final UserProfile profile;
  final ValueChanged<WorkoutCompletion> onFinished;
  final WorkoutSessionAnalytics analytics;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  DateTime? _startedAt;
  Timer? _timer;
  var _elapsedSeconds = 0;
  var _index = 0;
  final _saved = <int, ({int sets, int reps, int restSec})>{};
  final _logsByIndex = <int, CompletedExerciseLog>{};
  var _showSummary = false;
  var _summaryElapsedSeconds = 0;
  late WorkoutCompletion _summary;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController();
    _repsController = TextEditingController();
    _restController = TextEditingController(text: '60');
    _setsController.addListener(_refreshInputs);
    _repsController.addListener(_refreshInputs);
    _restController.addListener(_refreshInputs);
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startedAt == null) return;
      setState(() => _elapsedSeconds = DateTime.now().difference(_startedAt!).inSeconds);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final names = widget.plan.exerciseNames;
      if (names.isNotEmpty) {
        widget.analytics.onExerciseBecameActive(0, names[0]);
      }
    });
  }

  void _refreshInputs() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _setsController.removeListener(_refreshInputs);
    _repsController.removeListener(_refreshInputs);
    _restController.removeListener(_refreshInputs);
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  String get _elapsedLabel {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _flushInputsToSaved() {
    final sets = int.tryParse(_setsController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    final rest = int.tryParse(_restController.text.trim()) ?? 60;
    if (sets != null && reps != null && sets > 0 && reps > 0) {
      _saved[_index] = (sets: sets, reps: reps, restSec: rest);
    }
  }

  void _fillControllersFromSaved() {
    final e = _saved[_index];
    if (e != null) {
      _setsController.text = '${e.sets}';
      _repsController.text = '${e.reps}';
      _restController.text = '${e.restSec}';
    } else {
      _setsController.text = '';
      _repsController.text = '';
      _restController.text = '60';
    }
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
    if (_logsByIndex.containsKey(_index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionExerciseAlreadyLogged)),
      );
      return;
    }
    final s = int.tryParse(_setsController.text.trim()) ?? 0;
    final r = int.tryParse(_repsController.text.trim()) ?? 0;
    final rest = int.tryParse(_restController.text.trim()) ?? 60;
    if (s <= 0 || r <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionValidationSetsReps)),
      );
      return;
    }
    final names = widget.plan.exerciseNames;
    final name = names[_index];
    final id = '${widget.plan.id}_$_index';
    final cat = SessionCalorieEstimator.categoryKeyForName(name);
    final kcal = SessionCalorieEstimator.kcalForExercise(
      weightKg: widget.profile.weightKg,
      categoryKey: cat,
      sets: s,
      reps: r,
    );
    final log = CompletedExerciseLog(
      exerciseId: id,
      exerciseName: name,
      setsCompleted: s,
      repsCompleted: r,
      estimatedCalories: kcal,
      completedAt: DateTime.now(),
      categoryKey: cat,
    );
    widget.analytics.onExerciseLogged(index: _index, sets: s, reps: r);
    setState(() {
      _saved[_index] = (sets: s, reps: r, restSec: rest);
      _logsByIndex[_index] = log;
      if (_index < names.length - 1) {
        _index++;
        _fillControllersFromSaved();
        widget.analytics.onExerciseBecameActive(_index, names[_index]);
      }
    });
  }

  void _finishWorkout() {
    final l10n = AppLocalizations.of(context)!;
    if (_startedAt == null) return;
    _flushInputsToSaved();
    final names = widget.plan.exerciseNames;
    final finishedAt = DateTime.now();
    final elapsedSeconds = finishedAt.difference(_startedAt!).inSeconds.clamp(1, 86400);
    final elapsedMinutes = (elapsedSeconds / 60).ceil().clamp(1, 999);
    final ordered = <CompletedExerciseLog>[];
    for (var i = 0; i < names.length; i++) {
      final log = _logsByIndex[i];
      if (log != null) ordered.add(log);
    }
    final logKcal = ordered.fold<int>(0, (sum, log) => sum + log.estimatedCalories);
    final timeKcal = SessionCalorieEstimator.sessionKcalFromLogs(
      weightKg: widget.profile.weightKg,
      difficulty: widget.plan.difficulty,
      durationMinutes: elapsedMinutes,
      exerciseCount: names.length,
      logs: ordered,
    );
    final totalKcal = ordered.isEmpty
        ? timeKcal
        : ((logKcal * 0.65) + (timeKcal * 0.35)).round().clamp(logKcal, logKcal + timeKcal);
    widget.analytics.onSessionFinished(finishedAt.difference(_startedAt!));
    _summaryElapsedSeconds = elapsedSeconds;
    _summary = WorkoutCompletion(
      id: finishedAt.microsecondsSinceEpoch.toString(),
      title: widget.plan.name,
      workoutType: l10n.workoutTypePlannedSession,
      completedAt: finishedAt,
      durationMinutes: elapsedMinutes,
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
        elapsedSeconds: _summaryElapsedSeconds,
        onClose: () {
          widget.onFinished(_summary);
          Navigator.of(context).pop();
        },
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final names = widget.plan.exerciseNames;
    if (names.isEmpty) {
      return PremiumBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: Text(l10n.sessionActiveTitle),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.validationPickExercise,
                textAlign: TextAlign.center,
                style: const TextStyle(color: PremiumColors.textSecondary),
              ),
            ),
          ),
        ),
      );
    }
    final current = names[_index];
    final entry = WorkoutExerciseCatalog.entryForName(current);
    final displayName = WorkoutExerciseL10n.name(l10n, current);
    final imageAsset = entry?.imageAsset;

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(
            '${_index + 1}/${names.length}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: PremiumColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(PremiumRadii.pill),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    _elapsedLabel,
                    style: const TextStyle(
                      color: PremiumColors.accentBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    _ExercisePhotoFrame(imageAsset: imageAsset, label: displayName),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (entry != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        WorkoutExerciseL10n.description(l10n, current, entry.description),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: PremiumColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ColoredMetricField(
                            controller: _setsController,
                            label: l10n.labelSets,
                            color: PremiumColors.successGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ColoredMetricField(
                            controller: _repsController,
                            label: l10n.labelReps,
                            color: PremiumColors.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ColoredMetricField(
                            controller: _restController,
                            label: l10n.labelRest,
                            color: const Color(0xFFFF8A65),
                            suffix: l10n.localeName.startsWith('ru') ? 'с' : 's',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isCameraSupportedFor(current))
                      OutlinedButton.icon(
                        onPressed: () => _openCameraTracking(current),
                        icon: const Icon(Icons.videocam_outlined, size: 18),
                        label: Text(l10n.sessionCameraTracking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PremiumColors.accentBlue,
                          side: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PremiumRadii.md),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.sessionAllExercises,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < names.length; i++) ...[
                      _ExerciseListTile(
                        title: WorkoutExerciseL10n.name(l10n, names[i]),
                        done: _logsByIndex.containsKey(i),
                        active: i == _index,
                        onTap: () => _goToExercise(i),
                      ),
                      if (i < names.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _completeCurrent,
                          style: FilledButton.styleFrom(
                            backgroundColor: PremiumColors.accentBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                            ),
                          ),
                          child: Text(
                            _index >= names.length - 1
                                ? l10n.sessionCompleteFinal
                                : l10n.sessionCompleteExercise,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _finishWorkout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PremiumColors.textSecondary,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                            ),
                          ),
                          child: Text(
                            l10n.sessionFinishWorkout,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExercisePhotoFrame extends StatelessWidget {
  const _ExercisePhotoFrame({
    required this.imageAsset,
    required this.label,
  });

  final String? imageAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: imageAsset == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fitness_center_rounded, color: PremiumColors.accentBlue, size: 48),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: PremiumColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  imageAsset!,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}

class _ColoredMetricField extends StatelessWidget {
  const _ColoredMetricField({
    required this.controller,
    required this.label,
    required this.color,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PremiumColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({
    required this.title,
    required this.done,
    required this.active,
    required this.onTap,
  });

  final String title;
  final bool done;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageAsset = WorkoutExerciseCatalog.imageForName(title);

    return Material(
      color: active ? PremiumColors.surfaceRaised : PremiumColors.surface,
      borderRadius: BorderRadius.circular(PremiumRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            border: Border.all(
              color: active
                  ? PremiumColors.accentBlue.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.1),
              width: active ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: imageAsset == null
                      ? Container(
                          color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                          child: const Icon(Icons.fitness_center_rounded, color: PremiumColors.accentBlue, size: 18),
                        )
                      : Image.asset(imageAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? PremiumColors.successGreen : PremiumColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionSummaryView extends StatelessWidget {
  const _SessionSummaryView({
    required this.completion,
    required this.elapsedSeconds,
    required this.onClose,
  });

  final WorkoutCompletion completion;
  final int elapsedSeconds;
  final VoidCallback onClose;

  String _formatDuration(AppLocalizations l10n, int seconds) {
    if (seconds < 60) return l10n.sessionDurationSecondsOnly(seconds);
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (s == 0) return l10n.sessionDurationMinutesOnly(m);
    return l10n.sessionDurationMinutesSeconds(m, s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heroName = completion.exerciseLogs.isNotEmpty
        ? completion.exerciseLogs.first.exerciseName
        : (completion.exerciseNames.isNotEmpty ? completion.exerciseNames.first : completion.title);
    final heroImage = WorkoutExerciseCatalog.imageForName(heroName);
    final logKcal = completion.exerciseLogs.fold<int>(0, (sum, log) => sum + log.estimatedCalories);

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(l10n.sessionSummaryTitle),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PremiumColors.surface,
                          borderRadius: BorderRadius.circular(PremiumRadii.lg),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                              child: SizedBox(
                                height: 120,
                                child: heroImage == null
                                    ? Container(
                                        color: PremiumColors.surfaceRaised,
                                        child: const Icon(
                                          Icons.fitness_center_rounded,
                                          color: PremiumColors.accentBlue,
                                          size: 40,
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                          heroImage,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              completion.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryTile(
                                    label: l10n.sessionSummaryDuration,
                                    value: _formatDuration(l10n, elapsedSeconds),
                                    icon: Icons.schedule_rounded,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _SummaryTile(
                                    label: l10n.sessionSummaryCalories,
                                    value: l10n.sessionCaloriesUnit(completion.calories),
                                    icon: Icons.local_fire_department_outlined,
                                  ),
                                ),
                              ],
                            ),
                            if (logKcal > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                l10n.sessionSummaryVolumeLine(logKcal, completion.calories),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: PremiumColors.textMuted,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ],
                            if (completion.caloriesAreEstimated) ...[
                              const SizedBox(height: 6),
                              Text(
                                l10n.sessionCaloriesEstimateNote,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: PremiumColors.textMuted,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.sessionCompletedExercises,
                        style: const TextStyle(
                          color: PremiumColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildExerciseLines(l10n),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: FilledButton(
                  onPressed: onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: PremiumColors.accentBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.md),
                    ),
                  ),
                  child: Text(
                    l10n.sessionDone,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExerciseLines(AppLocalizations l10n) {
    if (completion.exerciseLogs.isEmpty) {
      return completion.exerciseNames
          .map(
            (n) => _SummaryExerciseRow(
              name: WorkoutExerciseL10n.name(l10n, n),
              detail: null,
              imageAsset: WorkoutExerciseCatalog.imageForName(n),
            ),
          )
          .toList();
    }
    return completion.exerciseLogs
        .map(
          (log) => _SummaryExerciseRow(
            name: WorkoutExerciseL10n.name(l10n, log.exerciseName),
            detail: l10n.historySetsRepsDetail(log.setsCompleted, log.repsCompleted),
            imageAsset: WorkoutExerciseCatalog.imageForName(log.exerciseName),
            kcal: log.estimatedCalories,
            l10n: l10n,
          ),
        )
        .toList();
  }
}

class _SummaryExerciseRow extends StatelessWidget {
  const _SummaryExerciseRow({
    required this.name,
    required this.imageAsset,
    this.detail,
    this.kcal,
    this.l10n,
  });

  final String name;
  final String? detail;
  final String? imageAsset;
  final int? kcal;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final loc = l10n ?? AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: imageAsset == null
                  ? Container(
                      color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                      child: const Icon(Icons.fitness_center_rounded, color: PremiumColors.accentBlue, size: 18),
                    )
                  : Image.asset(imageAsset!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                if (detail != null)
                  Text(detail!, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12)),
                if (kcal != null)
                  Text(
                    loc.sessionCaloriesUnit(kcal!),
                    style: const TextStyle(color: PremiumColors.accentBlue, fontSize: 11),
                  ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: PremiumColors.successGreen, size: 18),
        ],
      ),
    );
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PremiumColors.surfaceRaised,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: PremiumColors.accentBlue, size: 18),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
