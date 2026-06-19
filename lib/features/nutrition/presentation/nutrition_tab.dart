import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../core/auth_session_service.dart';
import '../../profile/domain/user_profile.dart';

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key, required this.profile});

  final UserProfile profile;

  static String tabLabel(BuildContext context) =>
      _NutritionText.of(context).tab;

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  var _loading = true;
  var _estimating = false;
  String? _message;
  bool _messageIsError = false;
  _Estimate? _estimate;
  List<_Meal> _meals = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMeals());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    final text = _NutritionText.of(context);
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await AuthSessionService.ensureSession();
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw StateError('No session');
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final rows = await _client
          .from('nutrition_meals')
          .select()
          .eq('user_id', userId)
          .gte('created_at', start.toUtc().toIso8601String())
          .lt('created_at', end.toUtc().toIso8601String())
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _meals = (rows as List<dynamic>)
            .map((row) => _Meal.fromRow(Map<String, dynamic>.from(row as Map)))
            .toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _showMessage(_cleanError(error, text, forSave: false), true);
      });
    }
  }

  Future<void> _calculate() async {
    final text = _NutritionText.of(context);
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => _showMessage(text.emptyInput, true));
      return;
    }
    if (_estimating) return;
    setState(() {
      _estimating = true;
      _estimate = null;
      _message = null;
    });
    _focusNode.unfocus();
    final locale = Localizations.localeOf(context).languageCode;
    try {
      await AuthSessionService.ensureSession();
      final response = await _client.functions.invoke(
        'estimate-nutrition',
        body: {
          'message': input,
          'userMessage': input,
          'locale': locale,
          'userProfile': {
            'weightKg': widget.profile.weightKg > 0
                ? widget.profile.weightKg
                : null,
            'heightCm': widget.profile.heightCm > 0
                ? widget.profile.heightCm
                : null,
            'goal': widget.profile.fitnessGoal.trim().isEmpty
                ? null
                : widget.profile.fitnessGoal,
            'targetWeightKg': widget.profile.targetWeightKg,
            'activityLevel': widget.profile.activityLevel.trim().isEmpty
                ? null
                : widget.profile.activityLevel,
            'weeklyWorkoutTarget': widget.profile.weeklyWorkoutTarget > 0
                ? widget.profile.weeklyWorkoutTarget
                : null,
          },
          'todaySummary': _summary().toJson(),
        },
      );
      final payload = _parseFunctionPayload(response.data);
      final estimate = _Estimate.fromJson(payload, input);
      if (estimate.status == 'estimated') {
        await _saveChat(input, estimate);
      }
      if (!mounted) return;
      setState(() {
        _estimating = false;
        switch (estimate.status) {
          case 'estimated':
            _estimate = estimate;
          case 'needs_clarification':
            _showMessage(
              estimate.clarifyingQuestion ??
                  estimate.userMessage ??
                  text.calculateFailed,
              false,
            );
          case 'rejected':
            _showMessage(
              estimate.rejectionMessage ??
                  estimate.userMessage ??
                  text.calculateFailed,
              false,
            );
          default:
            _showMessage(estimate.userMessage ?? text.calculateFailed, true);
        }
      });
    } on FunctionException catch (error) {
      debugPrint('[NutritionTab] estimate-nutrition failed: $error');
      if (!mounted) return;
      setState(() {
        _estimating = false;
        _showMessage(_cleanFunctionError(error, text), true);
      });
    } catch (error, stackTrace) {
      debugPrint('[NutritionTab] calculate failed: $error');
      debugPrint('[NutritionTab] stackTrace=$stackTrace');
      if (!mounted) return;
      setState(() {
        _estimating = false;
        _showMessage(_cleanError(error, text, forSave: false), true);
      });
    }
  }

  Future<void> _saveMeal() async {
    final text = _NutritionText.of(context);
    final estimate = _estimate;
    if (estimate == null) return;
    try {
      await AuthSessionService.ensureSession();
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw StateError('No session');
      final mealId = _uuid.v4();
      await _client.from('nutrition_meals').insert({
        'id': mealId,
        'user_id': userId,
        'meal_type': estimate.mealType,
        'title': estimate.mealName,
        'original_text': estimate.originalText,
        'total_calories': estimate.calories,
        'total_protein_g': estimate.protein,
        'total_carbs_g': estimate.carbs,
        'total_fat_g': estimate.fat,
        'ai_response': estimate.toJson(),
      });
      if (estimate.items.isNotEmpty) {
        await _client
            .from('nutrition_food_items')
            .insert(
              estimate.items.map((item) {
                return {
                  'id': _uuid.v4(),
                  'meal_id': mealId,
                  'user_id': userId,
                  'name': item.name,
                  'original_text': item.originalText,
                  'amount': item.amount,
                  'unit': item.unit,
                  'estimated_grams': item.grams,
                  'calories': item.calories,
                  'protein_g': item.protein,
                  'carbs_g': item.carbs,
                  'fat_g': item.fat,
                  'confidence': item.confidence,
                  'notes': item.notes,
                };
              }).toList(),
            );
      }
      if (!mounted) return;
      setState(() {
        _meals = [
          _Meal(
            id: mealId,
            title: estimate.mealName,
            calories: estimate.calories,
            protein: estimate.protein,
            carbs: estimate.carbs,
            fat: estimate.fat,
            createdAt: DateTime.now(),
          ),
          ..._meals,
        ];
        _estimate = null;
        _controller.clear();
        _showMessage(text.saved, false);
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _showMessage(_cleanError(error, text, forSave: true), true),
      );
    }
  }

  Future<void> _deleteMeal(String mealId) async {
    final text = _NutritionText.of(context);
    try {
      await _client.from('nutrition_meals').delete().eq('id', mealId);
      if (!mounted) return;
      setState(
        () => _meals = _meals.where((meal) => meal.id != mealId).toList(),
      );
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _showMessage(_cleanError(error, text, forSave: true), true),
      );
    }
  }

  Future<void> _saveChat(String input, _Estimate estimate) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('nutrition_chat_messages').insert([
        {'id': _uuid.v4(), 'user_id': userId, 'role': 'user', 'content': input},
        {
          'id': _uuid.v4(),
          'user_id': userId,
          'role': 'assistant',
          'content': estimate.userMessage ?? estimate.mealName,
          'payload': {'estimate': estimate.toJson()},
        },
      ]);
    } catch (_) {}
  }

  _Summary _summary() {
    final targets = _Targets.fromProfile(widget.profile);
    return _Summary(
      calories: _meals.fold(0, (sum, meal) => sum + meal.calories),
      protein: _meals.fold(0, (sum, meal) => sum + meal.protein.round()),
      carbs: _meals.fold(0, (sum, meal) => sum + meal.carbs.round()),
      fat: _meals.fold(0, (sum, meal) => sum + meal.fat.round()),
      targetCalories: targets.calories,
      targetProtein: targets.protein,
      targetCarbs: targets.carbs,
      targetFat: targets.fat,
    );
  }

  void _showMessage(String value, bool isError) {
    _message = value;
    _messageIsError = isError;
  }

  Map<String, dynamic> _parseFunctionPayload(Object? data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    throw StateError('Invalid response');
  }

  String? _readUserFacingMessage(Object? details) {
    if (details is! Map) return null;
    final map = Map<String, dynamic>.from(details);
    final direct = map['user_facing_message'] ?? map['userFacingMessage'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();
    return null;
  }

  String _cleanFunctionError(FunctionException error, _NutritionText text) {
    final message = _readUserFacingMessage(error.details);
    if (message != null) return message;
    final value = error.toString().toLowerCase();
    if (error.status == 404 ||
        value.contains('not_found') ||
        value.contains('requested function was not found')) {
      return text.functionNotReady;
    }
    return text.calculateFailed;
  }

  String _cleanError(
    Object error,
    _NutritionText text, {
    required bool forSave,
  }) {
    final value = error.toString().toLowerCase();
    if (value.contains('could not start guest session') ||
        value.contains('no session')) {
      return text.sessionNotReady;
    }
    if (value.contains('nutrition_meals') ||
        value.contains('nutrition_food_items') ||
        value.contains('nutrition_chat_messages') ||
        value.contains('relation') ||
        value.contains('schema cache')) {
      return text.databaseNotReady;
    }
    return forSave ? text.saveFailed : text.calculateFailed;
  }

  @override
  Widget build(BuildContext context) {
    final text = _NutritionText.of(context);
    final summary = _summary();
    final bottomPadding =
        FloatingTabBar.reservedBottomSpace(context) + AppSpacing.md;
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: PremiumColors.accentBlue),
      );
    }
    return RefreshIndicator(
      color: PremiumColors.accentBlue,
      onRefresh: _loadMeals,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        children: [
          _Hero(text: text),
          const SizedBox(height: AppSpacing.md),
          if (_message != null) ...[
            _Message(message: _message!, isError: _messageIsError),
            const SizedBox(height: AppSpacing.sm),
          ],
          _SummaryCard(
            summary: summary,
            text: text,
            hasMeals: _meals.isNotEmpty,
          ),
          const SizedBox(height: AppSpacing.md),
          _InputCard(
            controller: _controller,
            focusNode: _focusNode,
            text: text,
            estimating: _estimating,
            estimate: _estimate,
            onCalculate: _calculate,
            onSave: _saveMeal,
            onRecalculate: () => setState(() => _estimate = null),
            onSuggestion: (value) {
              _controller.text = value;
              _controller.selection = TextSelection.collapsed(
                offset: value.length,
              );
              _focusNode.requestFocus();
            },
          ),
          if (_meals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _RecentMeals(meals: _meals, text: text, onDelete: _deleteMeal),
          ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.text});
  final _NutritionText text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'assets/images/nutrition/nutrition_hero.jpg',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.78),
                  Colors.black.withValues(alpha: 0.46),
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Positioned(
            right: 22,
            top: 20,
            child: Transform.rotate(
              angle: -0.7,
              child: Icon(
                Icons.restaurant_menu_rounded,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumColors.accentBlue.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(PremiumRadii.pill),
                    border: Border.all(
                      color: PremiumColors.accentBlue.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  text.heroTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text.heroSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    height: 1.3,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.text,
    required this.hasMeals,
  });
  final _Summary summary;
  final _NutritionText text;
  final bool hasMeals;

  @override
  Widget build(BuildContext context) {
    final remaining = summary.targetCalories - summary.calories;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: hasMeals
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(text.todayNutrition),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${summary.calories} / ${summary.targetCalories} kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            remaining >= 0
                                ? text.remaining(remaining)
                                : text.over(remaining.abs()),
                            style: const TextStyle(
                              color: PremiumColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            text.macros(
                              summary.protein,
                              summary.carbs,
                              summary.fat,
                            ),
                            style: const TextStyle(
                              color: PremiumColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CustomPaint(
                        painter: _Ring(progress: summary.calorieProgress),
                        child: Center(
                          child: Text(
                            '${(summary.calorieProgress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _Bar(
                  label: text.protein,
                  value: summary.protein.toDouble(),
                  target: summary.targetProtein,
                  progress: summary.proteinProgress,
                  color: PremiumColors.accentBlue,
                ),
                const SizedBox(height: 8),
                _Bar(
                  label: text.carbs,
                  value: summary.carbs.toDouble(),
                  target: summary.targetCarbs,
                  progress: summary.carbsProgress,
                  color: PremiumColors.successGreen,
                ),
                const SizedBox(height: 8),
                _Bar(
                  label: text.fat,
                  value: summary.fat.toDouble(),
                  target: summary.targetFat,
                  progress: summary.fatProgress,
                  color: PremiumColors.bannerOrange,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(text.todayNutrition),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  text.emptySummary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text.dailyTarget(summary.targetCalories),
                  style: const TextStyle(
                    color: PremiumColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.focusNode,
    required this.text,
    required this.estimating,
    required this.estimate,
    required this.onCalculate,
    required this.onSave,
    required this.onRecalculate,
    required this.onSuggestion,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final _NutritionText text;
  final bool estimating;
  final _Estimate? estimate;
  final VoidCallback onCalculate;
  final VoidCallback onSave;
  final VoidCallback onRecalculate;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      text.suggestionEggs,
      text.suggestionChicken,
      text.suggestionProtein,
      text.suggestionDinner,
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text.aiTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text.aiSubtitle,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final suggestion in suggestions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(suggestion),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      backgroundColor: const Color(0xFF141B27),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      onPressed: estimating
                          ? null
                          : () => onSuggestion(suggestion),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !estimating,
            minLines: 4,
            maxLines: 6,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: text.placeholder,
              hintStyle: const TextStyle(color: PremiumColors.textMuted),
              filled: true,
              fillColor: const Color(0xFF141B27),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: _inputBorder(Colors.white.withValues(alpha: 0.08)),
              enabledBorder: _inputBorder(Colors.white.withValues(alpha: 0.08)),
              focusedBorder: _inputBorder(PremiumColors.accentBlue),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onCalculate(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: estimating ? null : onCalculate,
              style: FilledButton.styleFrom(
                backgroundColor: PremiumColors.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.md),
                ),
              ),
              child: estimating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      text.calculate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (estimate != null) ...[
            const SizedBox(height: AppSpacing.md),
            _EstimateCard(
              estimate: estimate!,
              text: text,
              onSave: onSave,
              onRecalculate: onRecalculate,
            ),
          ],
        ],
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({
    required this.estimate,
    required this.text,
    required this.onSave,
    required this.onRecalculate,
  });
  final _Estimate estimate;
  final _NutritionText text;
  final VoidCallback onSave;
  final VoidCallback onRecalculate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(
          color: PremiumColors.accentBlue.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.estimateTitle,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            estimate.mealName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${estimate.calories} kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text.macros(
              estimate.protein.round(),
              estimate.carbs.round(),
              estimate.fat.round(),
            ),
            style: const TextStyle(
              color: PremiumColors.textMuted,
              fontSize: 13,
            ),
          ),
          if (estimate.confidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              text.confidence(estimate.confidence),
              style: const TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          if (estimate.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final item in estimate.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.grams.round()}g · ${item.calories} kcal',
                      style: const TextStyle(
                        color: PremiumColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRecalculate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PremiumColors.textSecondary,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(text.recalculate),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: PremiumColors.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(text.saveMeal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentMeals extends StatelessWidget {
  const _RecentMeals({
    required this.meals,
    required this.text,
    required this.onDelete,
  });
  final List<_Meal> meals;
  final _NutritionText text;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(text.recentMeals),
          const SizedBox(height: AppSpacing.sm),
          for (final meal in meals)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF141B27),
                borderRadius: BorderRadius.circular(PremiumRadii.md),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(meal.createdAt.toLocal()),
                          style: const TextStyle(
                            color: PremiumColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          text.macros(
                            meal.protein.round(),
                            meal.carbs.round(),
                            meal.fat.round(),
                          ),
                          style: const TextStyle(
                            color: PremiumColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${meal.calories}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        text.kcal,
                        style: const TextStyle(
                          color: PremiumColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onDelete(meal.id),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: PremiumColors.textMuted,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? PremiumColors.errorRed : PremiumColors.accentBlue;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? PremiumColors.errorRed : PremiumColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.target,
    required this.progress,
    required this.color,
  });
  final String label;
  final double value;
  final double target;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: PremiumColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '${value.round()}g / ${target.round()}g',
              style: const TextStyle(
                color: PremiumColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(PremiumRadii.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Ring extends CustomPainter {
  _Ring({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 7.0;
    final rect = Offset.zero & size;
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeCap = StrokeCap.round;
    final foreground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = const SweepGradient(
        colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
      ).createShader(rect)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(rect.center, radius, background);
    canvas.drawArc(
      Rect.fromCircle(center: rect.center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _Ring oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Estimate {
  const _Estimate({
    required this.status,
    required this.mealName,
    required this.mealType,
    required this.originalText,
    required this.items,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    this.clarifyingQuestion,
    this.rejectionMessage,
    this.userMessage,
  });
  final String status;
  final String mealName;
  final String mealType;
  final String originalText;
  final List<_Item> items;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String confidence;
  final String? clarifyingQuestion;
  final String? rejectionMessage;
  final String? userMessage;

  factory _Estimate.fromJson(Map<String, dynamic> json, String originalText) {
    final totalsRaw = json['totals'];
    final totals = totalsRaw is Map
        ? Map<String, dynamic>.from(totalsRaw)
        : json;
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((item) => _Item.fromJson(Map<String, dynamic>.from(item)))
              .toList()
        : <_Item>[];
    return _Estimate(
      status: _readString(json['status']) ?? 'error',
      mealName:
          _readString(json['meal_name']) ??
          _readString(json['mealName']) ??
          'Meal estimate',
      mealType:
          _readString(json['meal_type']) ??
          _readString(json['mealType']) ??
          'unknown',
      originalText: originalText,
      items: items,
      calories: _readInt(_readField(totals, 'calories')),
      protein: _readDouble(_readField(totals, 'protein_g', 'proteinG')) ?? 0,
      carbs: _readDouble(_readField(totals, 'carbs_g', 'carbsG')) ?? 0,
      fat: _readDouble(_readField(totals, 'fat_g', 'fatG')) ?? 0,
      confidence: items.isEmpty ? '' : items.first.confidence,
      clarifyingQuestion: _readString(
        json['clarifying_question'] ?? json['clarifyingQuestion'],
      ),
      rejectionMessage: _readString(
        json['rejection_message'] ?? json['rejectionMessage'],
      ),
      userMessage: _readString(
        json['user_facing_message'] ?? json['userFacingMessage'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'meal_name': mealName,
    'meal_type': mealType,
    'items': items.map((item) => item.toJson()).toList(),
    'totals': {
      'calories': calories,
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
    },
    'user_facing_message': userMessage,
  };
}

class _Item {
  const _Item({
    required this.name,
    required this.originalText,
    required this.amount,
    required this.unit,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    this.notes,
  });
  final String name;
  final String originalText;
  final double amount;
  final String unit;
  final double grams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String confidence;
  final String? notes;
  factory _Item.fromJson(Map<String, dynamic> json) => _Item(
    name: _readString(json['name']) ?? '',
    originalText:
        _readString(json['original_text']) ??
        _readString(json['originalText']) ??
        '',
    amount: _readDouble(json['amount']) ?? 0,
    unit: _readString(json['unit']) ?? 'unknown',
    grams:
        _readDouble(json['estimated_grams']) ??
        _readDouble(json['estimatedGrams']) ??
        0,
    calories: _readInt(json['calories']),
    protein:
        _readDouble(json['protein_g']) ?? _readDouble(json['proteinG']) ?? 0,
    carbs: _readDouble(json['carbs_g']) ?? _readDouble(json['carbsG']) ?? 0,
    fat: _readDouble(json['fat_g']) ?? _readDouble(json['fatG']) ?? 0,
    confidence: _readString(json['confidence']) ?? 'medium',
    notes: _readString(json['notes']),
  );
  Map<String, dynamic> toJson() => {
    'name': name,
    'original_text': originalText,
    'amount': amount,
    'unit': unit,
    'estimated_grams': grams,
    'calories': calories,
    'protein_g': protein,
    'carbs_g': carbs,
    'fat_g': fat,
    'confidence': confidence,
    'notes': notes,
  };
}

class _Meal {
  const _Meal({
    required this.id,
    required this.title,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
  });
  final String id;
  final String title;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime createdAt;
  factory _Meal.fromRow(Map<String, dynamic> row) => _Meal(
    id: row['id'] as String,
    title: row['title'] as String? ?? row['original_text'] as String? ?? '',
    calories: _readInt(row['total_calories']),
    protein: _readDouble(row['total_protein_g']) ?? 0,
    carbs: _readDouble(row['total_carbs_g']) ?? 0,
    fat: _readDouble(row['total_fat_g']) ?? 0,
    createdAt:
        DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
  );
}

class _Summary {
  const _Summary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  double get calorieProgress =>
      targetCalories <= 0 ? 0 : (calories / targetCalories).clamp(0.0, 1.0);
  double get proteinProgress =>
      targetProtein <= 0 ? 0 : (protein / targetProtein).clamp(0.0, 1.0);
  double get carbsProgress =>
      targetCarbs <= 0 ? 0 : (carbs / targetCarbs).clamp(0.0, 1.0);
  double get fatProgress =>
      targetFat <= 0 ? 0 : (fat / targetFat).clamp(0.0, 1.0);
  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinG': protein,
    'carbsG': carbs,
    'fatG': fat,
  };
}

class _Targets {
  const _Targets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  factory _Targets.fromProfile(UserProfile profile) {
    if (profile.weightKg <= 0 || profile.heightCm <= 0) {
      return const _Targets(calories: 2200, protein: 140, carbs: 240, fat: 70);
    }
    final calories = (10 * profile.weightKg + 6.25 * profile.heightCm - 145)
        .round()
        .clamp(1600, 3500);
    final protein = (profile.weightKg * 1.8).clamp(90, 220).toDouble();
    final fat = (profile.weightKg * 0.9).clamp(55, 110).toDouble();
    final carbs = ((calories - protein * 4 - fat * 9) / 4)
        .clamp(120, 400)
        .toDouble();
    return _Targets(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}

class _NutritionText {
  const _NutritionText({
    required this.tab,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.todayNutrition,
    required this.emptySummary,
    required this.aiTitle,
    required this.aiSubtitle,
    required this.placeholder,
    required this.calculate,
    required this.emptyInput,
    required this.functionNotReady,
    required this.sessionNotReady,
    required this.databaseNotReady,
    required this.calculateFailed,
    required this.saveFailed,
    required this.saved,
    required this.recalculate,
    required this.saveMeal,
    required this.estimateTitle,
    required this.recentMeals,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.kcal,
    required this.suggestionEggs,
    required this.suggestionChicken,
    required this.suggestionProtein,
    required this.suggestionDinner,
    required this.macros,
    required this.remaining,
    required this.over,
    required this.dailyTarget,
    required this.confidence,
  });
  final String tab;
  final String heroTitle;
  final String heroSubtitle;
  final String todayNutrition;
  final String emptySummary;
  final String aiTitle;
  final String aiSubtitle;
  final String placeholder;
  final String calculate;
  final String emptyInput;
  final String functionNotReady;
  final String sessionNotReady;
  final String databaseNotReady;
  final String calculateFailed;
  final String saveFailed;
  final String saved;
  final String recalculate;
  final String saveMeal;
  final String estimateTitle;
  final String recentMeals;
  final String protein;
  final String carbs;
  final String fat;
  final String kcal;
  final String suggestionEggs;
  final String suggestionChicken;
  final String suggestionProtein;
  final String suggestionDinner;
  final String Function(int, int, int) macros;
  final String Function(int) remaining;
  final String Function(int) over;
  final String Function(int) dailyTarget;
  final String Function(String) confidence;

  static _NutritionText of(BuildContext context) =>
      switch (Localizations.localeOf(context).languageCode) {
        'tr' => tr,
        'ru' => ru,
        _ => en,
      };

  static final en = _NutritionText(
    tab: 'Calories',
    heroTitle: 'Nutrition Coach',
    heroSubtitle: 'Track meals, calories, and macros',
    todayNutrition: "Today's nutrition",
    emptySummary: "Log your first meal to see today's nutrition.",
    aiTitle: 'Nutrition AI',
    aiSubtitle: 'Tell me what you ate today',
    placeholder: 'Example: 2 eggs, 200g chicken breast, 150g rice',
    calculate: 'Calculate',
    emptyInput: 'Tell me what you ate first.',
    functionNotReady:
        'Nutrition AI is not ready yet. Please deploy the estimate-nutrition function.',
    sessionNotReady: 'Could not start a session. Please restart the app and try again.',
    databaseNotReady:
        'Nutrition database is not ready yet. Please run the nutrition migration.',
    calculateFailed: 'Could not calculate this meal. Try again.',
    saveFailed: 'Could not save this meal. Try again.',
    saved: 'Meal saved.',
    recalculate: 'Recalculate',
    saveMeal: 'Save meal',
    estimateTitle: 'Nutrition estimate',
    recentMeals: 'Recent meals',
    protein: 'Protein',
    carbs: 'Carbs',
    fat: 'Fat',
    kcal: 'kcal',
    suggestionEggs: '2 eggs and coffee',
    suggestionChicken: 'Chicken rice bowl',
    suggestionProtein: 'Protein snack',
    suggestionDinner: 'Add dinner',
    macros: (p, c, f) => 'Protein ${p}g · Carbs ${c}g · Fat ${f}g',
    remaining: (v) => '$v kcal remaining',
    over: (v) => '$v kcal over target',
    dailyTarget: (v) => 'Daily target: $v kcal',
    confidence: (v) => 'Confidence: $v',
  );
  static final tr = _NutritionText(
    tab: 'Kalori',
    heroTitle: 'Beslenme Koçu',
    heroSubtitle: 'Öğünleri, kalorileri ve makroları takip et',
    todayNutrition: 'Bugünün beslenmesi',
    emptySummary: 'Bugünün beslenmesini görmek için ilk öğününü kaydet.',
    aiTitle: 'Beslenme Yapay Zekası',
    aiSubtitle: 'Bugün ne yediğini söyle',
    placeholder: 'Örnek: 2 yumurta, 200g tavuk göğsü, 150g pilav',
    calculate: 'Hesapla',
    emptyInput: 'Önce ne yediğini yaz.',
    functionNotReady:
        'Beslenme yapay zekası henüz hazır değil. Lütfen estimate-nutrition fonksiyonunu dağıtın.',
    sessionNotReady:
        'Oturum başlatılamadı. Uygulamayı yeniden başlatıp tekrar dene.',
    databaseNotReady:
        'Beslenme veritabanı henüz hazır değil. Lütfen nutrition migration SQL dosyasını çalıştır.',
    calculateFailed: 'Bu öğün hesaplanamadı. Tekrar dene.',
    saveFailed: 'Bu öğün kaydedilemedi. Tekrar dene.',
    saved: 'Öğün kaydedildi.',
    recalculate: 'Yeniden hesapla',
    saveMeal: 'Öğünü kaydet',
    estimateTitle: 'Beslenme tahmini',
    recentMeals: 'Son öğünler',
    protein: 'Protein',
    carbs: 'Karbonhidrat',
    fat: 'Yağ',
    kcal: 'kcal',
    suggestionEggs: '2 yumurta ve kahve',
    suggestionChicken: 'Tavuklu pilav kasesi',
    suggestionProtein: 'Protein atıştırmalık',
    suggestionDinner: 'Akşam yemeği ekle',
    macros: (p, c, f) => 'Protein ${p}g · Karbonhidrat ${c}g · Yağ ${f}g',
    remaining: (v) => '$v kcal kaldı',
    over: (v) => 'Hedefin $v kcal üzerinde',
    dailyTarget: (v) => 'Günlük hedef: $v kcal',
    confidence: (v) => 'Güven: $v',
  );
  static final ru = _NutritionText(
    tab: 'Калории',
    heroTitle: 'Nutrition Coach',
    heroSubtitle: 'Отслеживайте приёмы пищи, калории и макросы',
    todayNutrition: 'Питание сегодня',
    emptySummary: 'Запишите первый приём пищи, чтобы увидеть питание за день.',
    aiTitle: 'Nutrition AI',
    aiSubtitle: 'Расскажите, что вы ели сегодня',
    placeholder: 'Пример: 2 яйца, 200 г куриной грудки, 150 г риса',
    calculate: 'Рассчитать',
    emptyInput: 'Сначала напишите, что вы ели.',
    functionNotReady:
        'Nutrition AI пока недоступен. Разверните функцию estimate-nutrition.',
    sessionNotReady:
        'Не удалось начать сессию. Перезапустите приложение и попробуйте снова.',
    databaseNotReady:
        'База питания пока не готова. Запустите nutrition migration SQL.',
    calculateFailed: 'Не удалось рассчитать этот приём пищи. Попробуйте снова.',
    saveFailed: 'Не удалось сохранить этот приём пищи. Попробуйте снова.',
    saved: 'Приём пищи сохранён.',
    recalculate: 'Пересчитать',
    saveMeal: 'Сохранить приём пищи',
    estimateTitle: 'Оценка питания',
    recentMeals: 'Приёмы пищи сегодня',
    protein: 'Белки',
    carbs: 'Углеводы',
    fat: 'Жиры',
    kcal: 'ккал',
    suggestionEggs: '2 яйца и кофе',
    suggestionChicken: 'Курица с рисом',
    suggestionProtein: 'Протеиновый перекус',
    suggestionDinner: 'Добавить ужин',
    macros: (p, c, f) => 'Белки $pг · Углеводы $cг · Жиры $fг',
    remaining: (v) => 'Осталось $v ккал',
    over: (v) => 'Превышение на $v ккал',
    dailyTarget: (v) => 'Дневная цель: $v ккал',
    confidence: (v) => 'Уверенность: $v',
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: PremiumColors.surfaceRaised,
  borderRadius: BorderRadius.circular(PremiumRadii.lg),
  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
);
OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(PremiumRadii.md),
  borderSide: BorderSide(color: color),
);
Object? _readField(Map<String, dynamic> map, String primary, [String? alt]) {
  if (map.containsKey(primary)) return map[primary];
  if (alt != null && map.containsKey(alt)) return map[alt];
  return null;
}
String? _readString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
double? _readDouble(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
int _readInt(Object? value) =>
    value is num ? value.round() : int.tryParse(value?.toString() ?? '') ?? 0;
