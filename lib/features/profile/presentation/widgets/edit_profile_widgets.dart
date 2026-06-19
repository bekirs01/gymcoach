import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: PremiumColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: PremiumColors.midnightBottom,
            borderRadius: BorderRadius.circular(PremiumRadii.lg),
            border: Border.all(color: PremiumColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withDividers(children),
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.isEmpty) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Divider(height: 1, color: PremiumColors.glassBorder, indent: 16, endIndent: 16));
      }
    }
    return result;
  }
}

class ProfileMetricTile extends StatelessWidget {
  const ProfileMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.placeholder,
    this.onTap,
  });

  final String label;
  final String value;
  final String? placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? (placeholder ?? 'Not set') : value;
    final isPlaceholder = value.trim().isEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      display,
                      style: TextStyle(
                        color: isPlaceholder ? PremiumColors.textSecondary : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: PremiumColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.helperText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? helperText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              helperText: helperText,
              helperStyle: const TextStyle(color: PremiumColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileOptionPickerSheet extends StatelessWidget {
  const ProfileOptionPickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileOptionPickerSheet(
        title: title,
        options: options,
        selected: selected,
        onSelected: (value) => Navigator.pop(context, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(PremiumRadii.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                  ),
                ],
              ),
            ),
            ...options.map((option) {
              final active = option == selected;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(option, style: const TextStyle(color: Colors.white)),
                  trailing: active ? const Icon(Icons.check_rounded, color: PremiumColors.accentBlue) : null,
                  onTap: () => onSelected(option),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

enum ProfileNumberPickerKind { weight, height }

class ProfileNumberPickerSheet extends StatefulWidget {
  const ProfileNumberPickerSheet({
    super.key,
    required this.title,
    required this.kind,
    required this.initialValue,
    this.allowClear = false,
  });

  final String title;
  final ProfileNumberPickerKind kind;
  final double? initialValue;
  final bool allowClear;

  static Future<double?> showWeight(
    BuildContext context, {
    required String title,
    required double initialValue,
    bool allowClear = false,
    double? initialNullable,
  }) {
    return showModalBottomSheet<double?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileNumberPickerSheet(
        title: title,
        kind: ProfileNumberPickerKind.weight,
        initialValue: initialNullable ?? initialValue,
        allowClear: allowClear,
      ),
    );
  }

  static Future<double?> showHeight(
    BuildContext context, {
    required String title,
    required double initialValue,
  }) {
    return showModalBottomSheet<double?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileNumberPickerSheet(
        title: title,
        kind: ProfileNumberPickerKind.height,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<ProfileNumberPickerSheet> createState() => _ProfileNumberPickerSheetState();
}

class _ProfileNumberPickerSheetState extends State<ProfileNumberPickerSheet> {
  late final List<double> _values;
  late int _index;

  @override
  void initState() {
    super.initState();
    if (widget.kind == ProfileNumberPickerKind.weight) {
      _values = List.generate(((200.0 - 35.0) / 0.5).round() + 1, (i) => 35.0 + i * 0.5);
    } else {
      _values = List.generate(230 - 120 + 1, (i) => (120 + i).toDouble());
    }
    final initial = widget.initialValue ?? _values.first;
    var closest = 0;
    var bestDiff = double.infinity;
    for (var i = 0; i < _values.length; i++) {
      final diff = (_values[i] - initial).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        closest = i;
      }
    }
    _index = closest;
  }

  String _format(double value) {
    if (widget.kind == ProfileNumberPickerKind.weight) {
      return value == value.roundToDouble() ? '${value.toStringAsFixed(1)} kg' : '${value.toStringAsFixed(1)} kg';
    }
    return '${value.round()} cm';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: PremiumColors.textSecondary)),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (widget.allowClear)
                      TextButton(
                        onPressed: () => Navigator.pop(context, -1.0),
                        child: const Text('Clear', style: TextStyle(color: PremiumColors.textMuted)),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, _values[_index]),
                      child: const Text('Done', style: TextStyle(color: PremiumColors.accentBlue, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _index),
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => _index = i,
                  children: _values
                      .map(
                        (v) => Center(
                          child: Text(
                            _format(v),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileOutlineButton extends StatelessWidget {
  const ProfileOutlineButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: PremiumColors.accentBlue),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.55)),
        backgroundColor: PremiumColors.surfaceRaised,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PremiumRadii.md)),
      ),
    );
  }
}
