import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../feed/presentation/widgets/network_image_with_fallback.dart';
import '../../data/fitness_articles_data.dart';
import '../../domain/fitness_article.dart';
import 'home_widgets.dart';

class ArticlesSection extends StatelessWidget {
  const ArticlesSection({super.key});

  static const _cardWidth = 180.0;
  static const _carouselHeight = 176.0;

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
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _ArticleCoverImage(
                          url: article.imageUrl,
                          category: content.category,
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
                          left: 8,
                          bottom: 8,
                          child: _CategoryChip(label: content.category),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          content.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PremiumColors.textSecondary,
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          content.readTime,
                          style: const TextStyle(
                            color: PremiumColors.textMuted,
                            fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: PremiumColors.accentBlue.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
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
                  height: 190,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ArticleCoverImage(
                        url: article.imageUrl,
                        category: content.category,
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
                        content.intro,
                        style: const TextStyle(
                          color: PremiumColors.textSecondary,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                      ...content.sections.map((section) => _DetailSection(section: section)),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PremiumColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(PremiumRadii.md),
                          border: Border.all(
                            color: PremiumColors.accentBlue.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content.takeawayHeading,
                              style: TextStyle(
                                color: PremiumColors.accentBlue.withValues(alpha: 0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              content.takeaway,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.section});

  final ArticleSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          if (section.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              section.body,
              style: const TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 15,
                height: 1.55,
              ),
            ),
          ],
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.bullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7, right: 10),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: PremiumColors.accentBlue,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          color: PremiumColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
                                  width: 52,
                                  height: 52,
                                  child: _ArticleCoverImage(
                                    url: article.imageUrl,
                                    category: content.category,
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

class _ArticleCoverImage extends StatelessWidget {
  const _ArticleCoverImage({
    required this.url,
    required this.category,
  });

  final String url;
  final String category;

  IconData get _placeholderIcon {
    final normalized = category.toLowerCase();
    if (normalized.contains('nutrition') ||
        normalized.contains('питание') ||
        normalized.contains('diet') ||
        normalized.contains('диета')) {
      return Icons.restaurant_rounded;
    }
    if (normalized.contains('training') || normalized.contains('тренировки')) {
      return Icons.fitness_center_rounded;
    }
    if (normalized.contains('recovery') || normalized.contains('восстановление')) {
      return Icons.self_improvement_rounded;
    }
    if (normalized.contains('habit') || normalized.contains('привычки')) {
      return Icons.event_repeat_rounded;
    }
    if (normalized.contains('guide') || normalized.contains('гид')) {
      return Icons.menu_book_rounded;
    }
    return Icons.article_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: NetworkImageWithFallback(
        url: url,
        fit: BoxFit.cover,
        placeholderIcon: _placeholderIcon,
      ),
    );
  }
}
