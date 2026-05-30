import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/exercise_catalog.dart';
import '../../plans/domain/plan_exercise.dart';

Future<List<PlanExercise>?> showSessionExercisesSheet({
  required BuildContext context,
  required List<PlanExercise> exercises,
}) {
  return showModalBottomSheet<List<PlanExercise>>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _SessionExercisesSheet(initial: exercises),
  );
}

class _SessionExercisesSheet extends StatefulWidget {
  const _SessionExercisesSheet({required this.initial});

  final List<PlanExercise> initial;

  @override
  State<_SessionExercisesSheet> createState() => _SessionExercisesSheetState();
}

class _SessionExercisesSheetState extends State<_SessionExercisesSheet> {
  late List<PlanExercise> _items;

  @override
  void initState() {
    super.initState();
    _items = List<PlanExercise>.from(widget.initial);
  }

  void _addFromCatalog(String canonical) {
    final l10n = AppLocalizations.of(context)!;
    final name = ExerciseCatalog.label(l10n, canonical);
    if (_items.any((e) => e.name == name)) return;
    setState(() => _items.add(PlanExercise(name: name)));
  }

  Future<void> _addCustom() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sessionAddExercise),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: Text(l10n.add)),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (_items.any((e) => e.name == name)) return;
    setState(() => _items.add(PlanExercise(name: name)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxH = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  l10n.sessionManageExercises,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: _items.length <= 1
                            ? null
                            : () => setState(() => _items.removeAt(i)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  children: ExerciseCatalog.canonicalNames
                      .map((c) => ActionChip(
                            label: Text(ExerciseCatalog.label(l10n, c)),
                            onPressed: () => _addFromCatalog(c),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _addCustom,
                        child: Text(l10n.sessionAddExercise),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _items.isEmpty ? null : () => Navigator.pop(context, _items),
                        child: Text(l10n.sessionDone),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
