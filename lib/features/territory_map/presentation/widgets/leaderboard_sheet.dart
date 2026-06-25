import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../feed/presentation/widgets/network_image_with_fallback.dart';
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
    final topThree = _entries.take(3).toList();
    final rest = _entries.length > 3 ? _entries.sublist(3) : const <LeaderboardEntry>[];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
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
            if (_entries.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    l10n.mapLeaderboardEmpty,
                    style: const TextStyle(color: PremiumColors.textSecondary),
                  ),
                ),
              )
            else ...[
              if (topThree.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _LeaderboardPodium(
                    entries: topThree,
                    currentUserId: widget.currentUserId,
                    l10n: l10n,
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: rest.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = rest[index];
                    final isMe = entry.userId == widget.currentUserId;
                    return _LeaderboardRow(entry: entry, isCurrentUser: isMe, l10n: l10n);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({
    required this.entries,
    required this.currentUserId,
    required this.l10n,
  });

  final List<LeaderboardEntry> entries;
  final String? currentUserId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final first = entries.isNotEmpty ? entries[0] : null;
    final second = entries.length > 1 ? entries[1] : null;
    final third = entries.length > 2 ? entries[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumColors.surface.withValues(alpha: 0.95),
            PremiumColors.midnightMid.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadii.xl),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumSlot(entry: second, rank: 2, currentUserId: currentUserId, l10n: l10n, height: 92)),
          Expanded(child: _PodiumSlot(entry: first, rank: 1, currentUserId: currentUserId, l10n: l10n, height: 118)),
          Expanded(child: _PodiumSlot(entry: third, rank: 3, currentUserId: currentUserId, l10n: l10n, height: 78)),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.rank,
    required this.currentUserId,
    required this.l10n,
    required this.height,
  });

  final LeaderboardEntry? entry;
  final int rank;
  final String? currentUserId;
  final AppLocalizations l10n;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (entry == null) return SizedBox(height: height);

    final isMe = entry!.userId == currentUserId;
    final medalColor = switch (rank) {
      1 => const Color(0xFFFFD54F),
      2 => const Color(0xFFB0BEC5),
      _ => const Color(0xFFCD7F32),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LeaderboardAvatar(
          entry: entry!,
          size: rank == 1 ? 58 : 48,
          highlight: isMe,
          medalColor: medalColor,
        ),
        const SizedBox(height: 8),
        Text(
          entry!.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isMe ? PremiumColors.accentBlue : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: rank == 1 ? 13 : 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          TerritoryFormatters.area(entry!.totalAreaSquareMeters),
          style: const TextStyle(color: PremiumColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withValues(alpha: 0.35),
                PremiumColors.surface.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border.all(color: medalColor.withValues(alpha: 0.45)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '#$rank',
            style: TextStyle(
              color: medalColor,
              fontWeight: FontWeight.w900,
              fontSize: rank == 1 ? 22 : 18,
            ),
          ),
        ),
      ],
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
          _LeaderboardAvatar(entry: entry, size: 42, highlight: isCurrentUser),
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

class _LeaderboardAvatar extends StatelessWidget {
  const _LeaderboardAvatar({
    required this.entry,
    required this.size,
    required this.highlight,
    this.medalColor,
  });

  final LeaderboardEntry entry;
  final double size;
  final bool highlight;
  final Color? medalColor;

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
    final borderColor = medalColor ?? (highlight ? PremiumColors.accentBlue : Colors.white.withValues(alpha: 0.12));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: highlight || medalColor != null ? 2.2 : 1),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: PremiumColors.accentBlue.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: entry.avatarUrl.trim().isNotEmpty
            ? NetworkImageWithFallback(
                url: entry.avatarUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholderIcon: Icons.person_outline_rounded,
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: highlight
                        ? [PremiumColors.accentBlue, PremiumColors.accentBlueSoft]
                        : [const Color(0xFF2A3548), const Color(0xFF1E2836)],
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(entry.displayName),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: size * 0.32,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
