String formatPrice(double price) => '\$${price.toStringAsFixed(2)}';

/// `13/10/2026` (sin depender de `intl` para un formato fijo).
String formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
