import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/device_user_id.dart';
import '../../territory_map/data/territory_api_factory.dart';
import '../../territory_map/domain/leaderboard_entry.dart';
import '../../territory_map/presentation/territory_formatters.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key, required this.displayName});

  final String displayName;

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  var _loading = true;
  var _refreshing = false;
  String? _error;
  List<LeaderboardEntry> _entries = const [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() => _refreshing = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await DeviceUserId.resolve(prefs);
      final client = await createTerritoryApiClient(
        prefs: prefs,
        displayName: widget.displayName,
      );
      final entries = await client.getLeaderboard();
      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
        _entries = entries;
        _loading = false;
        _refreshing = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final bottomPad = FloatingTabBar.reservedBottomSpace(context) + AppSpacing.md;

    return PremiumBackground(
      child: RefreshIndicator(
        color: PremiumColors.accentBlue,
        backgroundColor: PremiumColors.surface,
        onRefresh: () => _load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, topPad + 8, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.navLeaderboard,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.leaderboardSubtitle,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading && !_refreshing)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: PremiumColors.accentBlue),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: PremiumColors.textMuted),
                    ),
                  ),
                ),
              )
            else if (_entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    l10n.mapLeaderboardEmpty,
                    style: const TextStyle(color: PremiumColors.textSecondary),
                  ),
                ),
              )
            else ...[
              if (_entries.length >= 3)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: _PodiumRow(
                      entries: _entries.take(3).toList(),
                      currentUserId: _currentUserId,
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, bottomPad),
                sliver: SliverList.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final isMe = entry.userId == _currentUserId;
                    return _LeaderboardRow(
                      entry: entry,
                      isCurrentUser: isMe,
                      l10n: l10n,
                    );
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

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.entries, required this.currentUserId});

  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final order = entries.length >= 3 ? [entries[1], entries[0], entries[2]] : entries;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < order.length; i++)
          Expanded(
            child: _PodiumTile(
              entry: order[i],
              height: order[i].rank == 1 ? 120 : order[i].rank == 2 ? 96 : 84,
              isCurrentUser: order[i].userId == currentUserId,
            ),
          ),
      ],
    );
  }
}

class _PodiumTile extends StatelessWidget {
  const _PodiumTile({
    required this.entry,
    required this.height,
    required this.isCurrentUser,
  });

  final LeaderboardEntry entry;
  final double height;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final medalColor = entry.rank == 1
        ? const Color(0xFFFFD54F)
        : entry.rank == 2
            ? const Color(0xFFB0BEC5)
            : const Color(0xFFCD7F32);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          _AvatarBadge(name: entry.displayName, highlight: isCurrentUser, size: 44),
          const SizedBox(height: 8),
          Text(
            entry.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCurrentUser ? PremiumColors.accentBlue : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            TerritoryFormatters.area(entry.totalAreaSquareMeters),
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  medalColor.withValues(alpha: 0.35),
                  PremiumColors.surface,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border.all(
                color: isCurrentUser ? PremiumColors.accentBlue : PremiumColors.glassBorder,
              ),
            ),
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: medalColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: PremiumColors.accentBlue.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
          _AvatarBadge(name: entry.displayName, highlight: isCurrentUser, size: 40),
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
  const _AvatarBadge({
    required this.name,
    required this.highlight,
    required this.size,
  });

  final String name;
  final bool highlight;
  final double size;

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
      width: size,
      height: size,
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
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
