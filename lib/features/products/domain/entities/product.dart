class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnailUrl,
    required this.tags,
  });

  final int id;
  final String title;
  final double price;
  final String thumbnailUrl;
  final List<String> tags;
}
