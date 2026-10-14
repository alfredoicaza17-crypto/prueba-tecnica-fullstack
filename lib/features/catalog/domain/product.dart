class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> tags;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required List<String> tags,
  }) : tags = List.unmodifiable(tags);
}
