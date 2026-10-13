import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.tags,
  });

  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> tags;

  /// Comparación sin distinguir mayúsculas, igual que en [topTags].
  bool hasTag(String tag) {
    final needle = tag.toLowerCase();
    return tags.any((t) => t.toLowerCase() == needle);
  }

  @override
  List<Object?> get props => [id, title, price, thumbnail, tags];
}
