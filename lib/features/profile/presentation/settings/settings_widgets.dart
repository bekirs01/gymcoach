import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: PremiumColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: PremiumColors.surface,
            borderRadius: BorderRadius.circular(PremiumRadii.lg),
            border: Border.all(color: PremiumColors.glassBorder),
          ),
          child: Column(
            children: _withDividers(children),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Text(
              footer!,
              style: const TextStyle(
                color: PremiumColors.textMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.length <= 1) return items;
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(const Padding(
          padding: EdgeInsets.only(left: 56),
          child: Divider(height: 1, color: PremiumColors.glassBorder),
        ));
      }
    }
    return out;
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.enabled = true,
    this.onTap,
    this.showChevron = false,
    this.statusText,
    this.destructiveTitle = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool enabled;
  final VoidCallback? onTap;
  final bool showChevron;
  final String? statusText;
  final bool destructiveTitle;

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.45;
    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                leading ??
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: PremiumColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PremiumColors.glassBorder),
                      ),
                      child: Icon(icon, color: PremiumColors.accentBlue, size: 18),
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: destructiveTitle ? PremiumColors.errorRed : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: PremiumColors.textMuted,
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ],
                      if (statusText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          statusText!,
                          style: TextStyle(
                            color: statusText == 'Allowed' || statusText == 'Limited'
                                ? PremiumColors.successGreen
                                : PremiumColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
                if (showChevron)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: PremiumColors.textMuted,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.statusText,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? statusText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      statusText: statusText,
      enabled: enabled,
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      trailing: Transform.scale(
        scale: 0.88,
        child: CupertinoSwitch(
          value: value,
          activeTrackColor: PremiumColors.accentBlue,
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

class SettingsSheetShell extends StatelessWidget {
  const SettingsSheetShell({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.surface,
      child: SafeArea(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class SettingsPickerTile extends StatelessWidget {
  const SettingsPickerTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: PremiumColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: PremiumColors.accentBlue, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
