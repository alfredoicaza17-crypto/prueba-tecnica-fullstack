import 'package:flutter/foundation.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../data/exceptions/product_exceptions.dart';
import '../../domain/utils/top_tags.dart';


class ProductBloc extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  ProductBloc({required this.getProductsUseCase});

  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;
  bool isNetworkError = false;
  List<String> selectedTags = []; // O una sola etiqueta si es selección individual
  List<String> availableTopTags = [];

// Cada vez que cargues los productos exitosamente:
  void _calculateTopTags() {
    List<String> allTags = [];
    for (var product in products) {
      allTags.addAll(product.tags);
    }
    availableTopTags = topTags(allTags, 5);
  }

// Método para filtrar al tocar una etiqueta
  String? selectedTagFilter;

  void toggleTagFilter(String tag) {
    if (selectedTagFilter == tag) {
      selectedTagFilter = null; // Si se toca de nuevo, se quita el filtro
    } else {
      selectedTagFilter = tag; // Aplica el filtro
    }
    notifyListeners();
  }

// Getter para obtener los productos filtrados en la UI
  List<Product> get filteredProducts {
    if (selectedTagFilter == null) return products;
    return products.where((p) => p.tags.any((t) => t.toLowerCase() == selectedTagFilter!.toLowerCase())).toList();
  }
  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    isNetworkError = false;
    notifyListeners();

    try {
      products = await getProductsUseCase();
      _calculateTopTags();
    } on NetworkException catch (e, stackTrace) {
      isNetworkError = true;
      errorMessage = e.message;

      debugPrint('Error de red: $e');
      debugPrintStack(stackTrace: stackTrace);
    } on HostResolutionException catch (e, stackTrace) {
      isNetworkError = true;
      errorMessage = e.message;

      debugPrint('Error de DNS: $e');
      debugPrintStack(stackTrace: stackTrace);
    } on ServerException catch (e, stackTrace) {
      isNetworkError = false;
      errorMessage = e.message;

      debugPrint('Error HTTP o de respuesta: $e');
      debugPrintStack(stackTrace: stackTrace);
    } on UnexpectedException catch (e, stackTrace) {
      isNetworkError = false;
      errorMessage = e.message;

      debugPrint('Error inesperado: $e');
      debugPrintStack(stackTrace: stackTrace);
    } catch (e, stackTrace) {
      isNetworkError = false;
      errorMessage =
      'Ocurrió un error al cargar los productos. Inténtalo de nuevo.';

      debugPrint('Error no clasificado: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
