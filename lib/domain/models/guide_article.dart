import 'package:equatable/equatable.dart';

/// Bilgi merkezi makale/rehber içeriği
class GuideArticle extends Equatable {
  const GuideArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.category,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final String? category;

  @override
  List<Object?> get props => [id];
}
