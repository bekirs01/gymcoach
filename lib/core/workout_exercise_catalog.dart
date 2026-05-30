import 'package:flutter/material.dart';

class WorkoutExerciseEntry {
  const WorkoutExerciseEntry({
    required this.name,
    required this.imageAsset,
    required this.description,
  });

  final String name;
  final String imageAsset;
  final String description;
}

class WorkoutExerciseCategory {
  const WorkoutExerciseCategory({
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
  final List<WorkoutExerciseEntry> exercises;
}

abstract final class WorkoutExerciseCatalog {
  static const categories = <WorkoutExerciseCategory>[
    WorkoutExerciseCategory(
      title: 'Chest',
      imageAsset: 'assets/workout_categories/chest.jpg',
      icon: Icons.accessibility_new_rounded,
      startColor: Color(0xFF0B3344),
      endColor: Color(0xFF12263A),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Barbell Bench Press',
          imageAsset: 'assets/workout_exercises/chest_bench_press.jpg',
          description:
              'A classic chest press focused on the pectorals, front delts, and triceps. Keep shoulder blades stable and control the bar path.',
        ),
        WorkoutExerciseEntry(
          name: 'Chest Fly',
          imageAsset: 'assets/workout_exercises/chest_fly.jpg',
          description:
              'Opens the chest through a wide arc. Use lighter weight, soft elbows, and squeeze the chest at the top.',
        ),
        WorkoutExerciseEntry(
          name: 'Push-up',
          imageAsset: 'assets/workout_exercises/chest_pushup.jpg',
          description:
              'Bodyweight chest movement. Keep the body straight, lower under control, and press away from the floor.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Back',
      imageAsset: 'assets/workout_categories/back.jpg',
      icon: Icons.self_improvement_rounded,
      startColor: Color(0xFF123A42),
      endColor: Color(0xFF13283A),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Pull-up',
          imageAsset: 'assets/workout_exercises/back_pullup.jpg',
          description:
              'Vertical pull for lats and upper back. Start from a controlled hang and pull the chest toward the bar.',
        ),
        WorkoutExerciseEntry(
          name: 'Lat Pulldown',
          imageAsset: 'assets/workout_exercises/back_lat_pulldown.jpg',
          description:
              'Targets the lats with a stable seated position. Pull elbows down and avoid shrugging the shoulders.',
        ),
        WorkoutExerciseEntry(
          name: 'Seated Row',
          imageAsset: 'assets/workout_exercises/back_seated_row.jpg',
          description:
              'Horizontal row for mid-back thickness. Keep the spine tall and pull the handle toward the torso.',
        ),
        WorkoutExerciseEntry(
          name: 'Deadlift',
          imageAsset: 'assets/workout_exercises/back_deadlift.jpg',
          description:
              'Full posterior-chain lift. Brace the core, keep the bar close, and drive through the floor.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Legs',
      imageAsset: 'assets/workout_categories/legs.jpg',
      icon: Icons.directions_run_rounded,
      startColor: Color(0xFF25394F),
      endColor: Color(0xFF172338),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Squat',
          imageAsset: 'assets/workout_exercises/legs_squat.jpg',
          description:
              'Main lower-body strength movement. Sit between the hips, keep knees tracking over toes, and stand tall.',
        ),
        WorkoutExerciseEntry(
          name: 'Lunge',
          imageAsset: 'assets/workout_exercises/legs_lunge.jpg',
          description:
              'Single-leg movement for quads and glutes. Step with control and keep the front foot planted.',
        ),
        WorkoutExerciseEntry(
          name: 'Leg Curl',
          imageAsset: 'assets/workout_exercises/legs_curl.jpg',
          description:
              'Hamstring isolation exercise. Curl smoothly and avoid lifting the hips off the pad.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Glutes',
      imageAsset: 'assets/workout_categories/glutes.jpg',
      icon: Icons.fitness_center_rounded,
      startColor: Color(0xFF3A2B4A),
      endColor: Color(0xFF1C2438),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Hip Thrust',
          imageAsset: 'assets/workout_exercises/glutes_hip_thrust.jpg',
          description:
              'Heavy glute movement. Tuck the ribs, drive through the heels, and squeeze at full hip extension.',
        ),
        WorkoutExerciseEntry(
          name: 'Glute Bridge',
          imageAsset: 'assets/workout_exercises/glutes_bridge.jpg',
          description:
              'Beginner-friendly glute exercise. Lift the hips with control and pause briefly at the top.',
        ),
        WorkoutExerciseEntry(
          name: 'Romanian Deadlift',
          imageAsset: 'assets/workout_exercises/glutes_rdl.jpg',
          description:
              'Hip-hinge movement for glutes and hamstrings. Push hips back and keep the weight close.',
        ),
        WorkoutExerciseEntry(
          name: 'Step-up',
          imageAsset: 'assets/workout_exercises/glutes_stepup.jpg',
          description:
              'Single-leg glute and quad builder. Step up through the full foot without bouncing off the rear leg.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Shoulders',
      imageAsset: 'assets/workout_categories/shoulders.jpg',
      icon: Icons.sports_gymnastics_rounded,
      startColor: Color(0xFF3B344A),
      endColor: Color(0xFF172235),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Shoulder Press',
          imageAsset: 'assets/workout_exercises/shoulders_press.jpg',
          description:
              'Overhead press for delts and triceps. Brace the core and press without over-arching the back.',
        ),
        WorkoutExerciseEntry(
          name: 'Lateral Raise',
          imageAsset: 'assets/workout_exercises/shoulders_lateral_raise.jpg',
          description:
              'Side-delt isolation. Raise to shoulder height with soft elbows and controlled tempo.',
        ),
        WorkoutExerciseEntry(
          name: 'Front Raise',
          imageAsset: 'assets/workout_exercises/shoulders_front_raise.jpg',
          description: 'Targets the front delts. Lift smoothly and avoid swinging the body.',
        ),
        WorkoutExerciseEntry(
          name: 'Face Pull',
          imageAsset: 'assets/workout_exercises/shoulders_face_pull.jpg',
          description:
              'Rear-delt and upper-back movement. Pull toward the face while keeping elbows high.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Arms',
      imageAsset: 'assets/workout_categories/arms.jpg',
      icon: Icons.sports_martial_arts_rounded,
      startColor: Color(0xFF44302E),
      endColor: Color(0xFF1B2635),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Biceps Curl',
          imageAsset: 'assets/workout_exercises/arms_biceps_curl.jpg',
          description:
              'Classic biceps isolation. Keep elbows near the torso and curl without swinging.',
        ),
        WorkoutExerciseEntry(
          name: 'Hammer Curl',
          imageAsset: 'assets/workout_exercises/arms_hammer_curl.jpg',
          description:
              'Neutral-grip curl for biceps and forearms. Control both the lift and the lowering phase.',
        ),
        WorkoutExerciseEntry(
          name: 'Dips',
          imageAsset: 'assets/workout_exercises/arms_dips.jpg',
          description:
              'Triceps-focused press. Keep shoulders stable and lower only as far as comfortable.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Core',
      imageAsset: 'assets/workout_categories/core.jpg',
      icon: Icons.blur_circular_rounded,
      startColor: Color(0xFF2D3E34),
      endColor: Color(0xFF172337),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Plank',
          imageAsset: 'assets/workout_exercises/core_plank.jpg',
          description:
              'Core stability hold. Keep ribs down, glutes active, and body in one straight line.',
        ),
        WorkoutExerciseEntry(
          name: 'Cable Crunch',
          imageAsset: 'assets/workout_exercises/core_crunch.jpg',
          description:
              'Weighted ab flexion. Curl the ribs toward the pelvis instead of pulling with the arms.',
        ),
        WorkoutExerciseEntry(
          name: 'Leg Raise',
          imageAsset: 'assets/workout_exercises/core_leg_raise.jpg',
          description:
              'Lower-ab focused movement. Lift the legs under control and avoid arching the lower back.',
        ),
        WorkoutExerciseEntry(
          name: 'Bicycle Crunch',
          imageAsset: 'assets/workout_exercises/core_twist.jpg',
          description:
              'Rotational core exercise. Move slowly and rotate through the torso, not just the elbows.',
        ),
      ],
    ),
    WorkoutExerciseCategory(
      title: 'Cardio',
      imageAsset: 'assets/workout_categories/cardio.jpg',
      icon: Icons.monitor_heart_rounded,
      startColor: Color(0xFF274458),
      endColor: Color(0xFF142236),
      exercises: [
        WorkoutExerciseEntry(
          name: 'Burpee',
          imageAsset: 'assets/workout_exercises/cardio_burpee.jpg',
          description:
              'Full-body conditioning drill. Move from squat to plank to jump with steady rhythm.',
        ),
        WorkoutExerciseEntry(
          name: 'Mountain Climber',
          imageAsset: 'assets/workout_exercises/cardio_mountain_climber.jpg',
          description:
              'Fast core and cardio movement. Keep shoulders stacked and drive knees forward.',
        ),
        WorkoutExerciseEntry(
          name: 'Jump Rope',
          imageAsset: 'assets/workout_exercises/cardio_jump_rope.jpg',
          description: 'Low-space cardio drill. Stay light on the feet and keep wrists relaxed.',
        ),
        WorkoutExerciseEntry(
          name: 'Stationary Bike',
          imageAsset: 'assets/workout_exercises/cardio_bike.jpg',
          description:
              'Joint-friendly cardio option. Maintain cadence and gradually increase resistance.',
        ),
      ],
    ),
  ];

  static List<WorkoutExerciseEntry> get allExercises =>
      categories.expand((category) => category.exercises).toList();

  static String? imageForName(String? name) {
    if (name == null) return null;
    for (final exercise in allExercises) {
      if (exercise.name == name) return exercise.imageAsset;
    }
    return null;
  }

  static WorkoutExerciseEntry? entryForName(String? name) {
    if (name == null) return null;
    for (final exercise in allExercises) {
      if (exercise.name == name) return exercise;
    }
    return null;
  }
}
