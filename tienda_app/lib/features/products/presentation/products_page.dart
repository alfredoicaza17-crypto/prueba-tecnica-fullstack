import 'package:flutter/material.dart';
import 'package:http/http.dart' show ClientException;
import 'package:tienda_app/top_tags.dart';

import '../data/models/product_dto.dart';
import '../data/services/product_service.dart';
import '../data/utils/product_api_utils.dart';
import 'widgets/api_error_view.dart';
import 'widgets/products_layout.dart';

const _pageSize = 20;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, this.service});

  final ProductService? service;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductService _service;
  List<ProductDto> _products = const [];
  List<String> _popularTags = const [];
  String? _selectedTag;
  int _currentPage = 0;
  int _requestedPage = 0;
  int _totalProducts = 0;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ProductService();
    _loadPage(0);
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _requestedPage = page;
    });

    try {
      final response = await _service.fetchProducts(
        limit: _pageSize,
        skip: page * _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _products = response.products;
        _popularTags = topTags(
          response.products.expand((product) => product.tags).toList(),
          5,
        );
        if (page != _currentPage) {
          _selectedTag = null;
        }
        _currentPage = page;
        _totalProducts = response.total;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProductsLayout(
      isRefreshing: _isLoading,
      onRefresh: () => _loadPage(_currentPage),
      currentPage: _currentPage,
      totalPages: (_totalProducts / _pageSize).ceil(),
      onPreviousPage: () => _loadPage(_currentPage - 1),
      onNextPage: () => _loadPage(_currentPage + 1),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Cargando productos'),
      );
    }

    if (_error != null) {
      final statusCode = switch (_error) {
        ProductServiceException(:final statusCode) => statusCode,
        _ => null,
      };
      return ApiErrorView(
        statusCode: statusCode,
        isOffline: _error is ClientException,
        onRetry: () => _loadPage(_requestedPage),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700 ? 3 : 2;
        final visibleProducts = _selectedTag == null
            ? _products
            : _products
                  .where(
                    (product) => product.tags.any(
                      (tag) => tag.toLowerCase() == _selectedTag,
                    ),
                  )
                  .toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_popularTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tag in _popularTags)
                      ChoiceChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTag = selected ? tag : null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            Expanded(
              child: visibleProducts.isEmpty
                  ? const Center(
                      child: Text('No hay productos con esta etiqueta.'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: visibleProducts.length,
                      itemBuilder: (context, index) =>
                          _ProductCard(product: visibleProducts[index]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductDto product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 40),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: colors.tertiary),
                        const SizedBox(width: 2),
                        Text(product.rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
