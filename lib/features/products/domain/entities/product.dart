import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.tags,
    required this.thumbnail,
  });

  final int id;
  final String title;
  final double price;
  final List<String> tags;
  final String thumbnail;

  bool hasTag(String tag) {
    final wanted = tag.toLowerCase();
    return tags.any((t) => t.toLowerCase() == wanted);
  }

  @override
  List<Object?> get props => [id, title, price, tags, thumbnail];
}
