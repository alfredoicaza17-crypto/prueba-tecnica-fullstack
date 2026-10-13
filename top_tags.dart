/// Ruta original del enunciado. La implementación vive en la feature
/// `products` (Feature-First); este archivo la reexporta para que
/// `import 'top_tags.dart'` siga funcionando.
library;

export 'lib/features/products/domain/usecases/top_tags.dart';
