import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class ExerciseFormTipsCard extends StatefulWidget {
  const ExerciseFormTipsCard({
    super.key,
    required this.title,
    required this.tips,
    this.mistakesTitle,
    this.mistakes = const [],
  });

  final String title;
  final List<String> tips;
  final String? mistakesTitle;
  final List<String> mistakes;

  @override
  State<ExerciseFormTipsCard> createState() => _ExerciseFormTipsCardState();
}

class _ExerciseFormTipsCardState extends State<ExerciseFormTipsCard> {
  var _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(PremiumRadii.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: PremiumColors.accentBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: PremiumColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < widget.tips.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _BulletRow(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: PremiumColors.accentBlue,
                      text: widget.tips[i],
                    ),
                  ],
                  if (widget.mistakes.isNotEmpty && widget.mistakesTitle != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.mistakesTitle!,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < widget.mistakes.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _BulletRow(
                        icon: Icons.close_rounded,
                        iconColor: const Color(0xFFE57373),
                        text: widget.mistakes[i],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
