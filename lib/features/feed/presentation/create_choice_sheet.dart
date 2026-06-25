import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';

enum CreateChoice {
  post,
  story,
}

Future<CreateChoice?> showCreateChoiceSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<CreateChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateChoiceSheet(),
  );
}

class _CreateChoiceSheet extends StatelessWidget {
  const _CreateChoiceSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: PremiumColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PremiumColors.glassBorder,
                    borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.feedCreateTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.feedCreateSubtitle,
                style: const TextStyle(color: PremiumColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _CreateChoiceTile(
                icon: Icons.grid_on_rounded,
                title: l10n.feedNewPost,
                subtitle: l10n.feedNewPostSubtitle,
                onTap: () => Navigator.pop(context, CreateChoice.post),
              ),
              const SizedBox(height: 10),
              _CreateChoiceTile(
                icon: Icons.auto_stories_rounded,
                title: l10n.feedNewStory,
                subtitle: l10n.feedNewStorySubtitle,
                onTap: () => Navigator.pop(context, CreateChoice.story),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateChoiceTile extends StatelessWidget {
  const _CreateChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.midnightBottom,
      borderRadius: BorderRadius.circular(PremiumRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumRadii.lg),
            border: Border.all(color: PremiumColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumColors.accentBlue.withValues(alpha: 0.18),
                  border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: PremiumColors.accentBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: PremiumColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: PremiumColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
