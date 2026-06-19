import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../domain/workout_plan.dart';

const Color _destructiveRed = Color(0xFFFF453A);

Future<bool?> showDeleteWorkoutConfirmation({
  required BuildContext context,
  required String workoutName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(sheetContext).bottom,
        ),
        child: _DeleteWorkoutSheet(workoutName: workoutName),
      );
    },
  );
}

Future<bool> confirmDeleteWorkout({
  required BuildContext context,
  required WorkoutPlan plan,
  required Future<void> Function() onDelete,
  bool popOnSuccess = false,
}) async {
  final confirmed = await showDeleteWorkoutConfirmation(
    context: context,
    workoutName: plan.name,
  );
  if (confirmed != true || !context.mounted) return false;

  try {
    await onDelete();
    if (!context.mounted) return true;
    if (popOnSuccess) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(AppLocalizations.of(context)!.snackbarWorkoutDeleted),
      ),
    );
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(AppLocalizations.of(context)!.snackbarWorkoutDeleteFailed),
        ),
      );
    }
    return false;
  }
}

class WorkoutDeleteIconButton extends StatelessWidget {
  const WorkoutDeleteIconButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumColors.surfaceRaised,
              border: Border.all(color: _destructiveRed.withValues(alpha: 0.32)),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: _destructiveRed,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteWorkoutSheet extends StatelessWidget {
  const _DeleteWorkoutSheet({required this.workoutName});

  final String workoutName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(PremiumRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _destructiveRed.withValues(alpha: 0.14),
                border: Border.all(color: _destructiveRed.withValues(alpha: 0.28)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: _destructiveRed,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.deleteWorkoutTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.deleteWorkoutSubtitle(workoutName),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.deleteWorkoutWarning,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PremiumColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: _destructiveRed,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.md),
              ),
            ),
            child: Text(
              l10n.deleteWorkoutConfirm,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: PremiumColors.textSecondary,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.md),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
