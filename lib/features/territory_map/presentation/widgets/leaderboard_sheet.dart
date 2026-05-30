import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../domain/leaderboard_entry.dart';
import '../territory_formatters.dart';

Future<void> showTerritoryLeaderboardSheet({
  required BuildContext context,
  required List<LeaderboardEntry> entries,
  required String? currentUserId,
  required Future<List<LeaderboardEntry>> Function() onRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (context) => _LeaderboardSheet(
      initialEntries: entries,
      currentUserId: currentUserId,
      onRefresh: onRefresh,
    ),
  );
}

class _LeaderboardSheet extends StatefulWidget {
  const _LeaderboardSheet({
    required this.initialEntries,
    required this.currentUserId,
    required this.onRefresh,
  });

  final List<LeaderboardEntry> initialEntries;
  final String? currentUserId;
  final Future<List<LeaderboardEntry>> Function() onRefresh;

  @override
  State<_LeaderboardSheet> createState() => _LeaderboardSheetState();
}

class _LeaderboardSheetState extends State<_LeaderboardSheet> {
  late List<LeaderboardEntry> _entries = widget.initialEntries;
  var _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final entries = await widget.onRefresh();
      if (!mounted) return;
      setState(() => _entries = entries);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.78),
        decoration: BoxDecoration(
          color: PremiumColors.midnightMid,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: PremiumColors.glassBorder),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.navLeaderboard,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.leaderboardSubtitle,
                          style: const TextStyle(
                            color: PremiumColors.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _refresh,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: PremiumColors.accentBlue),
                          )
                        : const Icon(Icons.refresh_rounded, color: PremiumColors.textSecondary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Text(
                        l10n.mapLeaderboardEmpty,
                        style: const TextStyle(color: PremiumColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        final isMe = entry.userId == widget.currentUserId;
                        return _LeaderboardRow(entry: entry, isCurrentUser: isMe, l10n: l10n);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    required this.l10n,
  });

  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(
          color: isCurrentUser ? PremiumColors.accentBlue : PremiumColors.glassBorder,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: entry.rank <= 3 ? PremiumColors.successGreen : PremiumColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          _AvatarBadge(name: entry.displayName, highlight: isCurrentUser),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PremiumColors.accentBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(PremiumRadii.pill),
                        ),
                        child: Text(
                          l10n.leaderboardYou,
                          style: const TextStyle(
                            color: PremiumColors.accentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.mapLeaderboardMeta(
                    TerritoryFormatters.area(entry.totalAreaSquareMeters),
                    entry.territoryCount,
                  ),
                  style: const TextStyle(color: PremiumColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.name, required this.highlight});

  final String name;
  final bool highlight;

  static String _initials(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.length >= 2 ? p.substring(0, 2).toUpperCase() : p.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [PremiumColors.accentBlue, PremiumColors.accentBlueSoft]
              : [const Color(0xFF2A3548), const Color(0xFF1E2836)],
        ),
        border: Border.all(
          color: highlight ? PremiumColors.accentBlue : Colors.white.withValues(alpha: 0.12),
          width: highlight ? 2 : 1,
        ),
      ),
      child: Text(
        _initials(name),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}
