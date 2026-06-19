import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../feed/presentation/widgets/network_image_with_fallback.dart';
import '../../data/fitness_articles_data.dart';
import '../../domain/fitness_article.dart';
import 'home_widgets.dart';

class ArticlesSection extends StatelessWidget {
  const ArticlesSection({super.key});

  static const _cardWidth = 268.0;
  static const _carouselHeight = 292.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final articles = FitnessArticlesData.articles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        HomeSectionHeader(
          title: l10n.homeArticles,
          actionLabel: l10n.homeViewAll,
          onAction: () => showAllArticlesSheet(context: context),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: _carouselHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleCard(
                width: _cardWidth,
                article: article,
                content: article.contentFor(locale),
                onTap: () => showArticleDetailSheet(
                  context: context,
                  article: article,
                  content: article.contentFor(locale),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.width,
    required this.article,
    required this.content,
    required this.onTap,
  });

  final double width;
  final FitnessArticle article;
  final ArticleContent content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          child: Ink(
            decoration: BoxDecoration(
              color: PremiumColors.surface,
              borderRadius: BorderRadius.circular(PremiumRadii.lg),
              border: Border.all(color: PremiumColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: PremiumColors.accentBlue.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.lg)),
                  child: SizedBox(
                    height: 132,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkImageWithFallback(
                          url: article.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.62),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: _CategoryChip(label: content.category),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PremiumColors.textSecondary,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          content.readTime,
                          style: const TextStyle(
                            color: PremiumColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PremiumColors.accentBlue.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> showArticleDetailSheet({
  required BuildContext context,
  required FitnessArticle article,
  required ArticleContent content,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ArticleDetailSheet(
      article: article,
      content: content,
    ),
  );
}

Future<void> showAllArticlesSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AllArticlesSheet(),
  );
}

class _ArticleDetailSheet extends StatelessWidget {
  const _ArticleDetailSheet({
    required this.article,
    required this.content,
  });

  final FitnessArticle article;
  final ArticleContent content;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Material(
            color: PremiumColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkImageWithFallback(
                        url: article.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryChip(label: content.category),
                      const SizedBox(height: 10),
                      Text(
                        content.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content.readTime,
                        style: const TextStyle(
                          color: PremiumColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content.body,
                        style: const TextStyle(
                          color: PremiumColors.textSecondary,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AllArticlesSheet extends StatelessWidget {
  const _AllArticlesSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final articles = FitnessArticlesData.articles;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Material(
          color: PremiumColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumColors.glassBorder,
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.homeArticles,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: articles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final content = article.contentFor(locale);
                    return Material(
                      color: PremiumColors.midnightBottom,
                      borderRadius: BorderRadius.circular(PremiumRadii.lg),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showArticleDetailSheet(
                            context: context,
                            article: article,
                            content: content,
                          );
                        },
                        borderRadius: BorderRadius.circular(PremiumRadii.lg),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(PremiumRadii.lg),
                            border: Border.all(color: PremiumColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(PremiumRadii.md),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: NetworkImageWithFallback(
                                    url: article.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      content.readTime,
                                      style: const TextStyle(
                                        color: PremiumColors.textMuted,
                                        fontSize: 11,
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
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
