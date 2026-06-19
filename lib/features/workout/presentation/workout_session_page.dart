import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../core/workout_exercise_l10n.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/session_calorie_estimator.dart';
import '../../../core/workout_exercise_catalog.dart';
import '../../plans/domain/workout_plan.dart';
import '../../profile/domain/user_profile.dart';
import '../../camera_validation/domain/exercise_tracking_mode.dart';
import '../../camera_validation/presentation/camera_tracking_page.dart';
import '../domain/completed_exercise_log.dart';
import '../domain/exercise_camera_tracking_support.dart';
import '../domain/exercise_instruction_data.dart';
import '../domain/workout_completion.dart';
import '../domain/workout_session_analytics.dart';
import 'widgets/exercise_form_tips_card.dart';
import 'widgets/exercise_hero_card.dart';
import 'widgets/exercise_info_chip.dart';
import 'widgets/exercise_metric_stepper_card.dart';
import 'widgets/exercise_session_metadata.dart';
import 'widgets/exercise_term_info_sheet.dart';
import 'widgets/workout_exercise_list_item.dart';
import 'widgets/workout_session_action_bar.dart';

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
  var _sets = 3;
  var _reps = 12;
  var _restSec = 60;
  final _saved = <int, ({int sets, int reps, int restSec})>{};
  final _logsByIndex = <int, CompletedExerciseLog>{};
  final _favorites = <String>{};
  var _showSummary = false;
  var _summaryElapsedSeconds = 0;
  late WorkoutCompletion _summary;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startedAt == null) return;
      setState(() => _elapsedSeconds = DateTime.now().difference(_startedAt!).inSeconds);
    });
    _loadMetricsForIndex(0);
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
    _timer?.cancel();
    super.dispose();
  }

  bool get _isCurrentCompleted => _logsByIndex.containsKey(_index);

  bool get _isFinalExercise => _index >= widget.plan.exerciseNames.length - 1;

  bool get _hasNextExercise => !_isFinalExercise;

  String get _elapsedLabel {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _saveCurrentMetrics() {
    _saved[_index] = (sets: _sets, reps: _reps, restSec: _restSec);
  }

  void _loadMetricsForIndex(int i) {
    final saved = _saved[i];
    if (saved != null) {
      _sets = saved.sets;
      _reps = saved.reps;
      _restSec = saved.restSec;
      return;
    }
    final exercise = widget.plan.exercises[i];
    final instruction = ExerciseInstructionData.forExercise(exercise.name);
    _sets = exercise.defaultSets.clamp(1, 10);
    _reps = exercise.defaultReps.clamp(1, 100);
    _restSec = instruction.recommendedRestSec.clamp(15, 300);
  }

  void _goToExercise(int i) {
    if (i == _index) return;
    setState(() {
      _saveCurrentMetrics();
      _index = i;
      _loadMetricsForIndex(i);
    });
    widget.analytics.onExerciseBecameActive(i, widget.plan.exerciseNames[i]);
  }

  void _goToNextExercise() {
    if (!_isCurrentCompleted || !_hasNextExercise) return;
    setState(() {
      _index++;
      _loadMetricsForIndex(_index);
    });
    widget.analytics.onExerciseBecameActive(_index, widget.plan.exerciseNames[_index]);
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
      _reps = count.clamp(1, 100);
      if (_sets < 1) _sets = 1;
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

  void _onCameraTap(String exerciseName) {
    if (!isCameraTrackingSupported(exerciseName)) return;
    unawaited(_openCameraTracking(exerciseName));
  }

  void _showTermInfo(BuildContext context, String title, String body) {
    showExerciseTermInfoSheet(context, title: title, body: body);
  }

  void _completeCurrent() {
    final l10n = AppLocalizations.of(context)!;
    if (_isCurrentCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(l10n.sessionExerciseAlreadyLogged)),
      );
      return;
    }
    if (_sets <= 0 || _reps <= 0) {
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
      heightCm: widget.profile.heightCm,
      categoryKey: cat,
      sets: _sets,
      reps: _reps,
    );
    final log = CompletedExerciseLog(
      exerciseId: id,
      exerciseName: name,
      setsCompleted: _sets,
      repsCompleted: _reps,
      estimatedCalories: kcal,
      completedAt: DateTime.now(),
      categoryKey: cat,
    );
    widget.analytics.onExerciseLogged(index: _index, sets: _sets, reps: _reps);
    setState(() {
      _saveCurrentMetrics();
      _logsByIndex[_index] = log;
    });
  }

  void _finishWorkout() {
    final l10n = AppLocalizations.of(context)!;
    if (_startedAt == null) return;
    _saveCurrentMetrics();
    final names = widget.plan.exerciseNames;
    final finishedAt = DateTime.now();
    final elapsedSeconds = finishedAt.difference(_startedAt!).inSeconds.clamp(1, 86400);
    final elapsedMinutes = (elapsedSeconds / 60).ceil().clamp(1, 999);
    final ordered = <CompletedExerciseLog>[];
    for (var i = 0; i < names.length; i++) {
      final log = _logsByIndex[i];
      if (log != null) ordered.add(log);
    }
    final totalKcal = SessionCalorieEstimator.sessionKcalFromLogs(
      weightKg: widget.profile.weightKg,
      heightCm: widget.profile.heightCm,
      difficulty: widget.plan.difficulty,
      durationMinutes: elapsedMinutes,
      exerciseCount: names.length,
      logs: ordered,
    );
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

  void _showImageFullscreen(String? imageAsset, String label) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => Dialog(
        backgroundColor: PremiumColors.surface,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PremiumRadii.lg)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: imageAsset == null
                  ? SizedBox(
                      height: 280,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center_rounded, color: PremiumColors.accentBlue, size: 56),
                            const SizedBox(height: 12),
                            Text(label, style: const TextStyle(color: PremiumColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  : Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_outlined,
                        color: PremiumColors.textMuted,
                        size: 48,
                      ),
                    ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  WorkoutSessionPrimaryAction _primaryAction() {
    if (!_isCurrentCompleted) return WorkoutSessionPrimaryAction.completeExercise;
    if (_hasNextExercise) return WorkoutSessionPrimaryAction.nextExercise;
    return WorkoutSessionPrimaryAction.finishWorkout;
  }

  String _primaryLabel(AppLocalizations l10n) {
    switch (_primaryAction()) {
      case WorkoutSessionPrimaryAction.completeExercise:
        return l10n.sessionCompleteExercise;
      case WorkoutSessionPrimaryAction.nextExercise:
        return l10n.sessionNextExercise;
      case WorkoutSessionPrimaryAction.finishWorkout:
        return l10n.sessionFinishWorkout;
    }
  }

  void _onPrimaryTap() {
    switch (_primaryAction()) {
      case WorkoutSessionPrimaryAction.completeExercise:
        _completeCurrent();
      case WorkoutSessionPrimaryAction.nextExercise:
        _goToNextExercise();
      case WorkoutSessionPrimaryAction.finishWorkout:
        _finishWorkout();
    }
  }

  String? _secondaryLabel(AppLocalizations l10n) {
    if (_isCurrentCompleted && _isFinalExercise) return null;
    if (_isCurrentCompleted && _hasNextExercise) return l10n.sessionFinishWorkout;
    return l10n.sessionEndWorkout;
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
    final instruction = ExerciseInstructionData.forExercise(current);
    final displayName = WorkoutExerciseL10n.name(l10n, current);
    final imageAsset = entry?.imageAsset;
    final description = WorkoutExerciseL10n.description(l10n, current, instruction.description);
    final muscleGroup = instruction.targetMuscle;
    final typeBadge = ExerciseSessionMetadata.typeBadgeFor(current);
    final equipment = instruction.equipment;
    final tips = instruction.formTips;
    final mistakes = instruction.commonMistakes;
    final tempo = instruction.tempo;
    final showCameraTracking = isCameraTrackingSupported(current);
    final isFavorite = _favorites.contains(current);
    final restSuffix = 's';

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _SessionTopBar(
                exerciseIndex: _index,
                exerciseCount: names.length,
                subtitle: muscleGroup,
                elapsedLabel: _elapsedLabel,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                  children: [
                    ExerciseHeroCard(
                      imageAsset: imageAsset,
                      label: displayName,
                      onExpand: () => _showImageFullscreen(imageAsset, displayName),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PremiumColors.accentBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                                  border: Border.all(
                                    color: PremiumColors.accentBlue.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  typeBadge,
                                  style: const TextStyle(
                                    color: PremiumColors.accentBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (isFavorite) {
                                _favorites.remove(current);
                              } else {
                                _favorites.add(current);
                              }
                            });
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? const Color(0xFFE57373) : PremiumColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                          color: PremiumColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ExerciseFormTipsCard(
                      title: l10n.sessionFormTips,
                      tips: tips,
                      mistakesTitle: mistakes.isNotEmpty ? l10n.sessionCommonMistakes : null,
                      mistakes: mistakes,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ExerciseMetricStepperCard(
                          label: l10n.labelSets,
                          value: '$_sets',
                          onDecrement: () {
                            if (_sets > 1) setState(() => _sets--);
                          },
                          onIncrement: () {
                            if (_sets < 10) setState(() => _sets++);
                          },
                          valueColor: PremiumColors.successGreen,
                          onInfoTap: () => _showTermInfo(context, l10n.labelSets, l10n.sessionInfoSets),
                        ),
                        const SizedBox(width: 8),
                        ExerciseMetricStepperCard(
                          label: l10n.labelReps,
                          value: '$_reps',
                          onDecrement: () {
                            if (_reps > 1) setState(() => _reps--);
                          },
                          onIncrement: () {
                            if (_reps < 100) setState(() => _reps++);
                          },
                          onInfoTap: () => _showTermInfo(context, l10n.labelReps, l10n.sessionInfoReps),
                        ),
                        const SizedBox(width: 8),
                        ExerciseMetricStepperCard(
                          label: l10n.labelRest,
                          value: '$_restSec',
                          suffix: restSuffix,
                          onDecrement: () {
                            if (_restSec > 15) setState(() => _restSec -= 15);
                          },
                          onIncrement: () {
                            if (_restSec < 300) setState(() => _restSec += 15);
                          },
                          onInfoTap: () => _showTermInfo(context, l10n.labelRest, l10n.sessionInfoRest),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ExerciseInfoChip(
                          icon: Icons.adjust_rounded,
                          label: l10n.sessionChipTarget,
                          value: muscleGroup,
                          onInfoTap: () => _showTermInfo(context, l10n.sessionChipTarget, l10n.sessionInfoTarget),
                        ),
                        const SizedBox(width: 8),
                        ExerciseInfoChip(
                          icon: Icons.speed_rounded,
                          label: l10n.sessionChipTempo,
                          value: tempo,
                          onInfoTap: () => _showTermInfo(context, l10n.sessionChipTempo, l10n.sessionInfoTempo),
                        ),
                        const SizedBox(width: 8),
                        ExerciseInfoChip(
                          icon: Icons.fitness_center_outlined,
                          label: l10n.sessionChipEquipment,
                          value: equipment,
                          onInfoTap: () => _showTermInfo(context, l10n.sessionChipEquipment, l10n.sessionInfoEquipment),
                        ),
                      ],
                    ),
                    if (showCameraTracking) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _onCameraTap(current),
                          icon: const Icon(Icons.videocam_outlined, size: 18),
                          label: Text(l10n.sessionCameraTracking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PremiumColors.accentBlue,
                            side: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.45)),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      l10n.sessionAllExercises.toUpperCase(),
                      style: const TextStyle(
                        color: PremiumColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < names.length; i++) ...[
                      WorkoutExerciseListItem(
                        orderNumber: i + 1,
                        title: WorkoutExerciseL10n.name(l10n, names[i]),
                        exerciseName: names[i],
                        done: _logsByIndex.containsKey(i),
                        active: i == _index,
                        onTap: () => _goToExercise(i),
                      ),
                      if (i < names.length - 1) const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              WorkoutSessionActionBar(
                primaryAction: _primaryAction(),
                primaryLabel: _primaryLabel(l10n),
                onPrimary: _onPrimaryTap,
                secondaryLabel: _secondaryLabel(l10n),
                onSecondary: _secondaryLabel(l10n) != null ? _finishWorkout : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTopBar extends StatelessWidget {
  const _SessionTopBar({
    required this.exerciseIndex,
    required this.exerciseCount,
    required this.subtitle,
    required this.elapsedLabel,
    required this.onBack,
  });

  final int exerciseIndex;
  final int exerciseCount;
  final String subtitle;
  final String elapsedLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.sessionExerciseOf(exerciseIndex + 1, exerciseCount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PremiumColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumColors.surfaceRaised,
              borderRadius: BorderRadius.circular(PremiumRadii.pill),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, color: PremiumColors.accentBlue, size: 14),
                const SizedBox(width: 4),
                Text(
                  elapsedLabel,
                  style: const TextStyle(
                    color: PremiumColors.accentBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
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
