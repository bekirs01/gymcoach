import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../core/supabase_operation_error.dart';
import '../../plans/domain/workout_plan.dart';
import '../../profile/domain/user_profile.dart';
import '../../social/data/social_api_client.dart';
import '../data/workout_share_repository.dart';
import '../domain/shared_workout_snapshot.dart';
import 'widgets/shared_workout_preview_card.dart';

Future<bool?> showShareWorkoutSheet({
  required BuildContext context,
  required WorkoutPlan plan,
  required UserProfile profile,
  WorkoutShareRepository? repository,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (_) => _ShareWorkoutSheet(
      plan: plan,
      profile: profile,
      repository: repository,
    ),
  );
}

class _ShareWorkoutSheet extends StatefulWidget {
  const _ShareWorkoutSheet({
    required this.plan,
    required this.profile,
    this.repository,
  });

  final WorkoutPlan plan;
  final UserProfile profile;
  final WorkoutShareRepository? repository;

  @override
  State<_ShareWorkoutSheet> createState() => _ShareWorkoutSheetState();
}

class _ShareWorkoutSheetState extends State<_ShareWorkoutSheet> {
  final _caption = TextEditingController();
  WorkoutShareRepository? _repository;
  SharedWorkoutSnapshot? _snapshot;
  var _loadingRepo = true;
  var _sharing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_initRepository());
  }

  Future<void> _initRepository() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final repo = widget.repository ?? WorkoutShareRepository(prefs: prefs);
      final uid = await repo.currentUserId();
      if (!mounted) return;
      setState(() {
        _repository = repo;
        _snapshot = SharedWorkoutSnapshot.fromWorkoutPlan(
          widget.plan,
          createdByUserId: uid,
        );
        _loadingRepo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRepo = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final repo = _repository;
    if (repo == null) return;

    if (widget.plan.exercises.isEmpty) {
      setState(() => _error = 'Add at least one exercise before sharing.');
      return;
    }

    setState(() {
      _sharing = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final client = SocialApiClient(prefs: prefs);
      await client.ensureProfile(widget.profile);
      final author = await client.getCurrentProfile();
      if (author == null) {
        throw WorkoutShareException('Profile unavailable. Try again.');
      }

      await repo.shareWorkout(
        plan: widget.plan,
        caption: _caption.text,
        author: author,
        profile: widget.profile,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on WorkoutShareException catch (e) {
      if (!mounted) return;
      setState(() {
        _sharing = false;
        _error = e.message;
      });
    } on SupabaseOperationError catch (e) {
      if (!mounted) return;
      setState(() {
        _sharing = false;
        _error = e.userMessage;
      });
    } catch (error, stackTrace) {
      final mapped = SupabaseOperationError.classify(
        operation: 'workout_share',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'Could not share workout',
      );
      if (!mounted) return;
      setState(() {
        _sharing = false;
        _error = mapped.userMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Material(
        color: PremiumColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Share workout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sharing ? null : () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                    ),
                  ],
                ),
                if (_loadingRepo)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else ...[
                  if (_snapshot != null) SharedWorkoutPreviewCard(snapshot: _snapshot!),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _caption,
                    maxLines: 3,
                    minLines: 2,
                    enabled: !_sharing,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a caption...',
                      hintStyle: const TextStyle(color: PremiumColors.textMuted),
                      filled: true,
                      fillColor: PremiumColors.midnightBottom,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.lg),
                        borderSide: const BorderSide(color: PremiumColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.lg),
                        borderSide: const BorderSide(color: PremiumColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _sharing ? null : _share,
                    style: FilledButton.styleFrom(
                      backgroundColor: PremiumColors.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.pill),
                      ),
                    ),
                    child: _sharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Share to Feed',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
