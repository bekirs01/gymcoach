import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';

class SocialAvatar extends StatefulWidget {
  const SocialAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.fallbackImageUrl,
    this.size = 44,
  });

  final String name;
  final String imageUrl;
  final String? fallbackImageUrl;
  final double size;

  static String initials(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.length >= 2 ? p.substring(0, 2).toUpperCase() : p.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  State<SocialAvatar> createState() => _SocialAvatarState();
}

class _SocialAvatarState extends State<SocialAvatar> {
  var _primaryFailed = false;
  var _fallbackFailed = false;

  @override
  void didUpdateWidget(covariant SocialAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) _primaryFailed = false;
    if (oldWidget.fallbackImageUrl != widget.fallbackImageUrl) _fallbackFailed = false;
  }

  String? get _activeUrl {
    final primary = widget.imageUrl.trim();
    final fallback = widget.fallbackImageUrl?.trim() ?? '';
    if (!_primaryFailed && primary.isNotEmpty) return primary;
    if (!_fallbackFailed && fallback.isNotEmpty) return fallback;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _activeUrl;
    if (url == null) {
      return _Fallback(name: widget.name, size: widget.size);
    }

    final isFallback = widget.imageUrl.trim().isEmpty || _primaryFailed;
    return ClipOval(
      child: Image.network(
        url,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (!isFallback && !_primaryFailed) {
            _primaryFailed = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          } else if (isFallback && !_fallbackFailed) {
            _fallbackFailed = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
          return _Fallback(name: widget.name, size: widget.size);
        },
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
        ),
      ),
      child: Text(
        SocialAvatar.initials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.33,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
