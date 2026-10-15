import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  const Favorite({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.tags,
    required this.addedAt,
  });

  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> tags;
  final DateTime addedAt;

  @override
  List<Object?> get props => [id, title, price, thumbnail, tags, addedAt];
}
