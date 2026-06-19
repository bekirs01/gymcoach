import '../../../core/workout_exercise_catalog.dart';
import 'exercise_camera_tracking_support.dart';

class ExerciseInstruction {
  const ExerciseInstruction({
    required this.description,
    required this.formTips,
    this.commonMistakes = const [],
    required this.targetMuscle,
    required this.equipment,
    required this.recommendedSets,
    required this.recommendedRepsLabel,
    required this.recommendedRestSec,
    this.recommendedRestSecMax,
    required this.tempo,
    this.difficulty,
  });

  final String description;
  final List<String> formTips;
  final List<String> commonMistakes;
  final String targetMuscle;
  final String equipment;
  final int recommendedSets;
  final String recommendedRepsLabel;
  final int recommendedRestSec;
  final int? recommendedRestSecMax;
  final String tempo;
  final String? difficulty;

  String get recommendedRestLabel {
    final max = recommendedRestSecMax;
    if (max != null && max != recommendedRestSec) {
      return '$recommendedRestSec–$max s';
    }
    return '$recommendedRestSec s';
  }
}

abstract final class ExerciseInstructionData {
  static ExerciseInstruction forExercise(String exerciseName) {
    final catalogEntry = WorkoutExerciseCatalog.entryForName(exerciseName);
    if (catalogEntry != null) {
      final exact = _byCatalogName[catalogEntry.name];
      if (exact != null) return exact;
    }
    final pattern = _matchByPattern(exerciseName);
    if (pattern != null) return pattern;
    return _genericFallback(exerciseName, catalogEntry?.description);
  }

  static String? muscleGroupFor(String exerciseName) {
    for (final category in WorkoutExerciseCatalog.categories) {
      for (final exercise in category.exercises) {
        if (exercise.name == exerciseName) return category.title;
      }
    }
    return null;
  }

  static String typeBadgeFor(String exerciseName) {
    final lower = normalizeExerciseName(exerciseName);
    if (lower.contains('push-up') ||
        lower.contains('pull-up') ||
        lower.contains('plank') ||
        lower.contains('burpee') ||
        lower.contains('mountain climber') ||
        lower.contains('jump rope')) {
      return 'Bodyweight';
    }
    if (lower.contains('curl') ||
        lower.contains('fly') ||
        lower.contains('raise') ||
        lower.contains('crunch')) {
      return 'Isolation';
    }
    if (lower.contains('press') ||
        lower.contains('squat') ||
        lower.contains('deadlift') ||
        lower.contains('row') ||
        lower.contains('lunge') ||
        lower.contains('thrust') ||
        lower.contains('dip')) {
      return 'Compound';
    }
    return muscleGroupFor(exerciseName) ?? 'Strength';
  }

  static ExerciseInstruction? _matchByPattern(String exerciseName) {
    final lower = normalizeExerciseName(exerciseName);
    if (lower.contains('squat')) return _byCatalogName['Squat'];
    if (lower.contains('plank')) return _byCatalogName['Plank'];
    if (lower.contains('fly')) return _byCatalogName['Chest Fly'];
    if (lower.contains('biceps curl') || lower == 'curl') return _byCatalogName['Biceps Curl'];
    if (lower.contains('pull-up') || lower.contains('pull up')) return _byCatalogName['Pull-up'];
    if (lower.contains('push-up') || lower.contains('push up')) return _byCatalogName['Push-up'];
    if (lower.contains('bench press')) return _byCatalogName['Barbell Bench Press'];
    return null;
  }

  static ExerciseInstruction _genericFallback(String exerciseName, String? catalogDescription) {
    final muscle = muscleGroupFor(exerciseName) ?? 'Full body';
    final equipment = _equipmentForName(exerciseName);
    final description = catalogDescription?.trim().isNotEmpty == true
        ? catalogDescription!.trim()
        : 'Focus on controlled movement and steady breathing throughout each rep.';
    return ExerciseInstruction(
      description: description,
      formTips: const [
        'Move with control on every rep',
        'Keep proper posture and core braced',
        'Stop if you feel sharp pain',
      ],
      targetMuscle: muscle,
      equipment: equipment,
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    );
  }

  static String _equipmentForName(String exerciseName) {
    final lower = normalizeExerciseName(exerciseName);
    if (lower.contains('push-up') ||
        lower.contains('pull-up') ||
        lower.contains('plank') ||
        lower.contains('burpee') ||
        lower.contains('mountain climber') ||
        lower.contains('jump rope') ||
        lower.contains('bridge') ||
        lower.contains('crunch') ||
        lower.contains('leg raise') ||
        lower.contains('bicycle')) {
      return 'Bodyweight';
    }
    if (lower.contains('barbell') || lower.contains('bench press') || lower.contains('deadlift')) {
      return 'Barbell';
    }
    if (lower.contains('dumbbell') || lower.contains('curl') || lower.contains('fly') || lower.contains('raise')) {
      return 'Dumbbells';
    }
    if (lower.contains('cable')) return 'Cable';
    if (lower.contains('lat pulldown') || lower.contains('seated row')) return 'Machine';
    if (lower.contains('bike') || lower.contains('stationary')) return 'Bike';
    if (lower.contains('rope')) return 'Jump rope';
    return 'Bodyweight';
  }

  static const _byCatalogName = <String, ExerciseInstruction>{
    'Squat': ExerciseInstruction(
      description:
          'Lower your body by bending your knees and hips while keeping your chest up and core tight.',
      formTips: [
        'Keep your feet about shoulder-width apart',
        'Keep your chest lifted and core braced',
        'Push knees in the same direction as your toes',
        'Lower under control and stand up strongly',
        'Keep heels on the floor',
      ],
      commonMistakes: [
        'Knees collapsing inward',
        'Rounding the lower back',
        'Lifting heels',
        'Dropping too fast without control',
      ],
      targetMuscle: 'Legs',
      equipment: 'Bodyweight or Barbell',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      recommendedRestSecMax: 90,
      tempo: '2-1-2',
      difficulty: 'Intermediate',
    ),
    'Plank': ExerciseInstruction(
      description: 'Hold a straight body line while keeping your core tight and hips stable.',
      formTips: [
        'Keep your body in one straight line',
        'Brace your core and glutes',
        'Do not let your hips drop',
        'Keep elbows under shoulders',
      ],
      commonMistakes: [
        'Hips sagging toward the floor',
        'Shoulders drifting behind elbows',
        'Holding breath instead of breathing steadily',
      ],
      targetMuscle: 'Core',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '30–60 seconds',
      recommendedRestSec: 45,
      recommendedRestSecMax: 60,
      tempo: 'Hold',
      difficulty: 'Beginner',
    ),
    'Chest Fly': ExerciseInstruction(
      description: 'Open the chest through a wide controlled arc and squeeze at the top.',
      formTips: [
        'Keep a soft bend in your elbows',
        'Move slowly and under control',
        'Do not overstretch your shoulders',
        'Squeeze your chest at the top',
      ],
      commonMistakes: [
        'Using too much weight and losing control',
        'Locking the elbows straight',
        'Shrugging shoulders toward ears',
      ],
      targetMuscle: 'Chest',
      equipment: 'Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Biceps Curl': ExerciseInstruction(
      description: 'Curl the weight without swinging while keeping elbows close to your torso.',
      formTips: [
        'Keep elbows close to your body',
        'Avoid using momentum',
        'Lower the weight with control',
        'Keep wrists neutral',
      ],
      commonMistakes: [
        'Swinging the torso to lift the weight',
        'Elbows drifting forward',
        'Incomplete range at the bottom',
      ],
      targetMuscle: 'Biceps',
      equipment: 'Barbell or Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Pull-up': ExerciseInstruction(
      description: 'Pull your body upward using your back and arms while keeping control.',
      formTips: [
        'Start from a controlled hang',
        'Pull elbows down toward your ribs',
        'Keep chest lifted',
        'Lower slowly',
      ],
      commonMistakes: [
        'Kipping or swinging for momentum',
        'Shrugging shoulders at the top',
        'Dropping quickly on the way down',
      ],
      targetMuscle: 'Back',
      equipment: 'Pull-up bar',
      recommendedSets: 3,
      recommendedRepsLabel: '6–10',
      recommendedRestSec: 90,
      tempo: '2-1-2',
      difficulty: 'Advanced',
    ),
    'Push-up': ExerciseInstruction(
      description: 'Lower and press your body while keeping a straight body line.',
      formTips: [
        'Keep body straight',
        'Lower chest under control',
        'Keep elbows at a natural angle',
        'Push the floor away strongly',
      ],
      commonMistakes: [
        'Hips sagging or piking up',
        'Partial range of motion',
        'Flaring elbows too wide',
      ],
      targetMuscle: 'Chest',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '10–15',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Barbell Bench Press': ExerciseInstruction(
      description: 'Press the weight upward from the chest while keeping shoulders stable.',
      formTips: [
        'Keep shoulder blades tight',
        'Lower the bar under control',
        'Keep feet planted',
        'Press without bouncing',
      ],
      commonMistakes: [
        'Bouncing the bar off the chest',
        'Losing shoulder blade retraction',
        'Uneven bar path',
      ],
      targetMuscle: 'Chest',
      equipment: 'Barbell',
      recommendedSets: 3,
      recommendedRepsLabel: '8–10',
      recommendedRestSec: 90,
      tempo: '2-1-1',
      difficulty: 'Intermediate',
    ),
    'Lat Pulldown': ExerciseInstruction(
      description: 'Pull the bar toward your upper chest while keeping your torso stable.',
      formTips: [
        'Pull elbows down and slightly back',
        'Keep chest lifted',
        'Avoid leaning too far back',
        'Control the return phase',
      ],
      commonMistakes: [
        'Pulling behind the neck',
        'Using momentum from the hips',
        'Shrugging at the top',
      ],
      targetMuscle: 'Back',
      equipment: 'Machine',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      tempo: '2-1-2',
    ),
    'Seated Row': ExerciseInstruction(
      description: 'Pull the handle toward your torso to build mid-back thickness.',
      formTips: [
        'Sit tall with a neutral spine',
        'Pull elbows back close to your body',
        'Squeeze shoulder blades together',
        'Return with control',
      ],
      commonMistakes: [
        'Rounding the lower back',
        'Using arms only without back engagement',
        'Jerking the weight',
      ],
      targetMuscle: 'Back',
      equipment: 'Machine',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      tempo: '2-1-2',
    ),
    'Deadlift': ExerciseInstruction(
      description: 'Lift the weight from the floor by hinging at the hips with a braced core.',
      formTips: [
        'Keep the bar close to your legs',
        'Brace your core before each rep',
        'Push the floor away with your legs',
        'Stand tall without hyperextending',
      ],
      commonMistakes: [
        'Rounding the lower back',
        'Bar drifting away from the body',
        'Jerking the weight off the floor',
      ],
      targetMuscle: 'Back',
      equipment: 'Barbell',
      recommendedSets: 3,
      recommendedRepsLabel: '5–8',
      recommendedRestSec: 90,
      recommendedRestSecMax: 120,
      tempo: '2-1-1',
      difficulty: 'Advanced',
    ),
    'Lunge': ExerciseInstruction(
      description: 'Step forward and lower until both knees bend with control.',
      formTips: [
        'Keep front knee tracking over toes',
        'Stay upright through the torso',
        'Push through the front heel to stand',
        'Use a stable, controlled step',
      ],
      commonMistakes: [
        'Front knee collapsing inward',
        'Short steps that limit depth',
        'Leaning too far forward',
      ],
      targetMuscle: 'Legs',
      equipment: 'Bodyweight or Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12 per leg',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Leg Curl': ExerciseInstruction(
      description: 'Curl your heels toward your glutes to isolate the hamstrings.',
      formTips: [
        'Keep hips pressed into the pad',
        'Curl smoothly without bouncing',
        'Pause briefly at peak contraction',
        'Lower under control',
      ],
      commonMistakes: [
        'Lifting hips off the pad',
        'Using momentum at the bottom',
        'Incomplete range of motion',
      ],
      targetMuscle: 'Legs',
      equipment: 'Machine',
      recommendedSets: 3,
      recommendedRepsLabel: '10–15',
      recommendedRestSec: 60,
      tempo: '2-1-2',
    ),
    'Hip Thrust': ExerciseInstruction(
      description: 'Drive your hips upward against resistance while keeping ribs down.',
      formTips: [
        'Place upper back on the bench',
        'Drive through your heels',
        'Squeeze glutes at the top',
        'Lower without losing tension',
      ],
      commonMistakes: [
        'Over-arching the lower back at the top',
        'Pushing through toes instead of heels',
        'Dropping hips too quickly',
      ],
      targetMuscle: 'Glutes',
      equipment: 'Barbell or Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '8–12',
      recommendedRestSec: 60,
      recommendedRestSecMax: 90,
      tempo: '2-1-2',
    ),
    'Glute Bridge': ExerciseInstruction(
      description: 'Lift your hips from the floor while squeezing your glutes at the top.',
      formTips: [
        'Feet flat and knees bent',
        'Brace your core before lifting',
        'Drive hips up without flaring ribs',
        'Pause briefly at the top',
      ],
      commonMistakes: [
        'Pushing hips too high and arching the back',
        'Letting knees fall inward',
        'Rushing reps without control',
      ],
      targetMuscle: 'Glutes',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '12–15',
      recommendedRestSec: 45,
      tempo: '2-1-2',
      difficulty: 'Beginner',
    ),
    'Romanian Deadlift': ExerciseInstruction(
      description: 'Hinge at the hips to load the hamstrings and glutes with a flat back.',
      formTips: [
        'Push hips back as you lower',
        'Keep the weight close to your legs',
        'Maintain a soft knee bend',
        'Stand by driving hips forward',
      ],
      commonMistakes: [
        'Rounding the lower back',
        'Turning it into a squat by bending knees too much',
        'Looking down and losing neutral neck',
      ],
      targetMuscle: 'Glutes',
      equipment: 'Barbell or Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '8–12',
      recommendedRestSec: 60,
      recommendedRestSecMax: 90,
      tempo: '3-1-2',
    ),
    'Step-up': ExerciseInstruction(
      description: 'Step onto a box or bench and drive through the working leg.',
      formTips: [
        'Place the whole foot on the step',
        'Keep torso upright',
        'Drive through the top leg, not the trailing leg',
        'Control the step down',
      ],
      commonMistakes: [
        'Pushing off the back foot too much',
        'Knee caving inward on the step',
        'Using a box that is too high',
      ],
      targetMuscle: 'Glutes',
      equipment: 'Box or Bench',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12 per leg',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Shoulder Press': ExerciseInstruction(
      description: 'Press weight overhead while keeping your core braced and ribs down.',
      formTips: [
        'Brace your core before pressing',
        'Press in a straight line overhead',
        'Avoid excessive lower-back arch',
        'Lower under control to shoulder level',
      ],
      commonMistakes: [
        'Arching the back to finish the rep',
        'Flaring elbows too far forward',
        'Using legs to drive the weight up',
      ],
      targetMuscle: 'Shoulders',
      equipment: 'Dumbbells or Barbell',
      recommendedSets: 3,
      recommendedRepsLabel: '8–12',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Lateral Raise': ExerciseInstruction(
      description: 'Raise your arms out to the sides to target the side delts.',
      formTips: [
        'Use a controlled tempo',
        'Lead with elbows, not hands',
        'Stop around shoulder height',
        'Keep a soft bend in elbows',
      ],
      commonMistakes: [
        'Swinging the torso for momentum',
        'Raising above shoulder height',
        'Shrugging traps at the top',
      ],
      targetMuscle: 'Shoulders',
      equipment: 'Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '12–15',
      recommendedRestSec: 45,
      tempo: '2-1-2',
    ),
    'Front Raise': ExerciseInstruction(
      description: 'Lift the weight in front of you to emphasize the front delts.',
      formTips: [
        'Keep a slight bend in elbows',
        'Lift to shoulder height only',
        'Lower slowly',
        'Keep torso still',
      ],
      commonMistakes: [
        'Rocking the body to lift heavier weight',
        'Raising above shoulder level',
        'Locking elbows straight',
      ],
      targetMuscle: 'Shoulders',
      equipment: 'Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 45,
      tempo: '2-0-2',
    ),
    'Face Pull': ExerciseInstruction(
      description: 'Pull the rope toward your face with elbows high to target rear delts.',
      formTips: [
        'Pull toward the upper face or forehead',
        'Keep elbows higher than wrists',
        'Squeeze shoulder blades together',
        'Control the return',
      ],
      commonMistakes: [
        'Using too much weight and losing form',
        'Pulling too low toward the chest',
        'Shrugging instead of retracting',
      ],
      targetMuscle: 'Shoulders',
      equipment: 'Cable',
      recommendedSets: 3,
      recommendedRepsLabel: '12–15',
      recommendedRestSec: 45,
      tempo: '2-1-2',
    ),
    'Hammer Curl': ExerciseInstruction(
      description: 'Curl with a neutral grip to train biceps and forearms together.',
      formTips: [
        'Keep palms facing each other',
        'Avoid swinging the dumbbells',
        'Curl until hands reach shoulder level',
        'Lower with control',
      ],
      commonMistakes: [
        'Using body momentum',
        'Elbows drifting away from torso',
        'Rushing the lowering phase',
      ],
      targetMuscle: 'Biceps',
      equipment: 'Dumbbells',
      recommendedSets: 3,
      recommendedRepsLabel: '10–12',
      recommendedRestSec: 60,
      tempo: '2-0-2',
    ),
    'Dips': ExerciseInstruction(
      description: 'Lower and press your body between parallel bars to target triceps and chest.',
      formTips: [
        'Keep shoulders down and stable',
        'Lower only as far as you stay in control',
        'Press up without locking elbows harshly',
        'Lean slightly for chest emphasis if needed',
      ],
      commonMistakes: [
        'Dropping too deep with rounded shoulders',
        'Shrugging at the bottom',
        'Kipping or swinging',
      ],
      targetMuscle: 'Arms',
      equipment: 'Parallel bars',
      recommendedSets: 3,
      recommendedRepsLabel: '8–12',
      recommendedRestSec: 60,
      tempo: '2-0-2',
      difficulty: 'Intermediate',
    ),
    'Cable Crunch': ExerciseInstruction(
      description: 'Crunch your ribs toward your pelvis using cable resistance.',
      formTips: [
        'Round through the upper back',
        'Pull with abs, not arms',
        'Pause briefly at peak contraction',
        'Return slowly without losing tension',
      ],
      commonMistakes: [
        'Pulling with arms instead of abs',
        'Using hips to generate movement',
        'Moving too fast',
      ],
      targetMuscle: 'Core',
      equipment: 'Cable',
      recommendedSets: 3,
      recommendedRepsLabel: '12–15',
      recommendedRestSec: 45,
      tempo: '2-1-2',
    ),
    'Leg Raise': ExerciseInstruction(
      description: 'Raise your legs under control while keeping your lower back stable.',
      formTips: [
        'Press lower back toward the floor',
        'Lift legs without swinging',
        'Lower slowly before touching down',
        'Keep core braced throughout',
      ],
      commonMistakes: [
        'Arching the lower back',
        'Using momentum to swing legs up',
        'Dropping legs quickly',
      ],
      targetMuscle: 'Core',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '10–15',
      recommendedRestSec: 45,
      tempo: '2-0-2',
    ),
    'Bicycle Crunch': ExerciseInstruction(
      description: 'Rotate through the torso while alternating knees and elbows.',
      formTips: [
        'Move slowly and deliberately',
        'Rotate from the ribs, not just elbows',
        'Keep lower back gently pressed down',
        'Exhale on each twist',
      ],
      commonMistakes: [
        'Pulling on the neck',
        'Rushing through reps',
        'Only moving elbows instead of torso',
      ],
      targetMuscle: 'Core',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '12–20',
      recommendedRestSec: 45,
      tempo: '2-0-2',
    ),
    'Burpee': ExerciseInstruction(
      description: 'Move from squat to plank to jump in one fluid conditioning sequence.',
      formTips: [
        'Land softly on the jump',
        'Keep core tight in the plank phase',
        'Use a steady rhythm',
        'Step back instead of jumping if needed',
      ],
      commonMistakes: [
        'Sagging hips in the plank',
        'Landing hard on the jump',
        'Rushing form for speed',
      ],
      targetMuscle: 'Cardio',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '8–12',
      recommendedRestSec: 60,
      tempo: 'Steady',
      difficulty: 'Intermediate',
    ),
    'Mountain Climber': ExerciseInstruction(
      description: 'Drive knees toward your chest from a strong plank position.',
      formTips: [
        'Keep shoulders stacked over wrists',
        'Maintain a flat back',
        'Drive knees under control',
        'Breathe steadily',
      ],
      commonMistakes: [
        'Hips bouncing too high',
        'Shoulders drifting behind hands',
        'Going so fast form breaks down',
      ],
      targetMuscle: 'Cardio',
      equipment: 'Bodyweight',
      recommendedSets: 3,
      recommendedRepsLabel: '20–30 seconds',
      recommendedRestSec: 45,
      tempo: 'Steady',
    ),
    'Jump Rope': ExerciseInstruction(
      description: 'Stay light on your feet and turn the rope with relaxed wrists.',
      formTips: [
        'Jump just high enough to clear the rope',
        'Keep elbows close to your sides',
        'Land softly on the balls of your feet',
        'Find a consistent rhythm',
      ],
      commonMistakes: [
        'Jumping too high',
        'Swinging arms from the shoulders',
        'Landing heavily on heels',
      ],
      targetMuscle: 'Cardio',
      equipment: 'Jump rope',
      recommendedSets: 3,
      recommendedRepsLabel: '30–60 seconds',
      recommendedRestSec: 45,
      tempo: 'Steady',
    ),
    'Stationary Bike': ExerciseInstruction(
      description: 'Pedal at a steady cadence with posture tall and core lightly braced.',
      formTips: [
        'Adjust seat height for a slight knee bend',
        'Keep shoulders relaxed',
        'Maintain smooth cadence',
        'Increase resistance gradually',
      ],
      commonMistakes: [
        'Seat too low causing knee stress',
        'Gripping handlebars too tightly',
        'Spiking resistance too quickly',
      ],
      targetMuscle: 'Cardio',
      equipment: 'Bike',
      recommendedSets: 1,
      recommendedRepsLabel: '10–20 minutes',
      recommendedRestSec: 0,
      tempo: 'Steady',
      difficulty: 'Beginner',
    ),
  };
}
