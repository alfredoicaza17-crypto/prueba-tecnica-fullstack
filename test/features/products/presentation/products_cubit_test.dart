import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/products/domain/usecases/get_products.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_cubit.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_state.dart';

import '../../../support/fixtures.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late MockGetProducts getProducts;

  setUp(() {
    getProducts = MockGetProducts();
  });

  const loadedState = ProductsState(
    status: ProductsStatus.success,
    products: sampleProducts,
    topTags: sampleTopTags,
  );

  group('load', () {
    blocTest<ProductsCubit, ProductsState>(
      'emite cargando y luego exito con las 5 etiquetas mas frecuentes',
      build: () {
        when(() => getProducts()).thenAnswer((_) async => sampleProducts);
        return ProductsCubit(getProducts);
      },
      act: (cubit) => cubit.load(),
      expect: () => [const ProductsState(), loadedState],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emite exito con lista vacia cuando no hay productos',
      build: () {
        when(() => getProducts()).thenAnswer((_) async => []);
        return ProductsCubit(getProducts);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductsState(),
        const ProductsState(status: ProductsStatus.success),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emite fallo de red cuando no hay conexion',
      build: () {
        when(() => getProducts()).thenThrow(const NetworkFailure());
        return ProductsCubit(getProducts);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductsState(),
        const ProductsState(
          status: ProductsStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emite fallo de servidor cuando la API falla',
      build: () {
        when(() => getProducts()).thenThrow(const ServerFailure());
        return ProductsCubit(getProducts);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductsState(),
        const ProductsState(
          status: ProductsStatus.failure,
          failure: ServerFailure(),
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'trata un error inesperado como fallo de servidor',
      build: () {
        when(() => getProducts()).thenThrow(StateError('inesperado'));
        return ProductsCubit(getProducts);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductsState(),
        const ProductsState(
          status: ProductsStatus.failure,
          failure: ServerFailure(),
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'reintentar tras un error vuelve a cargar y termina en exito',
      build: () {
        var attempts = 0;
        when(() => getProducts()).thenAnswer((_) async {
          attempts++;
          if (attempts == 1) throw const NetworkFailure();
          return sampleProducts;
        });
        return ProductsCubit(getProducts);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.load();
      },
      expect: () => [
        const ProductsState(),
        const ProductsState(
          status: ProductsStatus.failure,
          failure: NetworkFailure(),
        ),
        const ProductsState(),
        loadedState,
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'respeta la cantidad configurada de etiquetas populares',
      build: () {
        when(() => getProducts()).thenAnswer((_) async => sampleProducts);
        return ProductsCubit(getProducts, popularTagsCount: 2);
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.topTags, ['beauty', 'groceries']),
    );
  });

  group('toggleTag', () {
    blocTest<ProductsCubit, ProductsState>(
      'selecciona una etiqueta',
      build: () => ProductsCubit(getProducts),
      seed: () => loadedState,
      act: (cubit) => cubit.toggleTag('meat'),
      expect: () => [loadedState.withSelectedTag('meat')],
    );

    blocTest<ProductsCubit, ProductsState>(
      'al tocar la misma etiqueta de nuevo quita el filtro',
      build: () => ProductsCubit(getProducts),
      seed: () => loadedState,
      act: (cubit) {
        cubit.toggleTag('meat');
        cubit.toggleTag('meat');
      },
      expect: () => [loadedState.withSelectedTag('meat'), loadedState],
    );

    blocTest<ProductsCubit, ProductsState>(
      'cambiar de etiqueta reemplaza el filtro',
      build: () => ProductsCubit(getProducts),
      seed: () => loadedState,
      act: (cubit) {
        cubit.toggleTag('meat');
        cubit.toggleTag('beauty');
      },
      expect: () => [
        loadedState.withSelectedTag('meat'),
        loadedState.withSelectedTag('beauty'),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'no hace nada si los productos no estan cargados',
      build: () => ProductsCubit(getProducts),
      act: (cubit) => cubit.toggleTag('meat'),
      expect: () => <ProductsState>[],
    );
  });

  group('ProductsState.visibleProducts', () {
    test('sin etiqueta seleccionada retorna todos', () {
      expect(loadedState.visibleProducts, sampleProducts);
    });

    test('con etiqueta retorna solo los productos que la tienen', () {
      final state = loadedState.withSelectedTag('meat');

      expect(state.visibleProducts, [beef, chicken]);
    });

    test('la comparacion de etiquetas ignora mayusculas', () {
      final state = loadedState.withSelectedTag('BEAUTY');

      expect(state.visibleProducts, [mascara, eyeliner]);
    });
  });
}
