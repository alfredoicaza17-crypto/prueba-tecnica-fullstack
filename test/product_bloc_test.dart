import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/data/exceptions/product_exceptions.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';
import 'package:tienda_app/features/products/domain/repositories/product_repository.dart';
import 'package:tienda_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:tienda_app/features/products/presentation/bloc/product_bloc.dart';

void main() {
  group('ProductBloc.fetchProducts', () {
    test(
      'classifies host resolution failures as connectivity errors',
      () async {
        final bloc = ProductBloc(
          getProductsUseCase: GetProductsUseCase(
            _FailingProductRepository(HostResolutionException()),
          ),
        );

        await bloc.fetchProducts();

        expect(bloc.isNetworkError, isTrue);
        expect(bloc.errorMessage, HostResolutionException().message);
        bloc.dispose();
      },
    );

    test('keeps HTTP failures separate from connectivity errors', () async {
      final bloc = ProductBloc(
        getProductsUseCase: GetProductsUseCase(
          _FailingProductRepository(ServerException()),
        ),
      );

      await bloc.fetchProducts();

      expect(bloc.isNetworkError, isFalse);
      expect(bloc.errorMessage, ServerException().message);
      bloc.dispose();
    });
  });
}

class _FailingProductRepository implements ProductRepository {
  final Exception exception;

  _FailingProductRepository(this.exception);

  @override
  Future<List<Product>> getProducts() async {
    throw exception;
  }
}
