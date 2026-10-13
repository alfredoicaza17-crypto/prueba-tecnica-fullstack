import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/core/error/result.dart';
import 'package:tienda_app/features/products/domain/usecases/get_products.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_cubit.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_state.dart';

import '../../../helpers/fixtures.dart';

class _MockGetProducts extends Mock implements GetProducts {}

void main() {
  late _MockGetProducts getProducts;

  setUp(() => getProducts = _MockGetProducts());

  blocTest<ProductsCubit, ProductsState>(
    'load exitoso emite loading y success con las etiquetas populares',
    setUp: () => when(
      () => getProducts(),
    ).thenAnswer((_) async => const Ok(sampleProducts)),
    build: () => ProductsCubit(getProducts),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProductsState(status: ProductsStatus.loading),
      const ProductsState(
        status: ProductsStatus.success,
        products: sampleProducts,
        topTags: ['beauty', 'eyeshadow', 'fruits', 'mascara'],
      ),
    ],
  );

  blocTest<ProductsCubit, ProductsState>(
    'load sin red emite failure con NetworkFailure',
    setUp: () => when(
      () => getProducts(),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => ProductsCubit(getProducts),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProductsState(status: ProductsStatus.loading),
      const ProductsState(
        status: ProductsStatus.failure,
        failure: NetworkFailure(),
      ),
    ],
  );

  blocTest<ProductsCubit, ProductsState>(
    'load con lista vacía queda en success y isEmpty',
    setUp: () =>
        when(() => getProducts()).thenAnswer((_) async => const Ok([])),
    build: () => ProductsCubit(getProducts),
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.isEmpty, isTrue),
  );

  blocTest<ProductsCubit, ProductsState>(
    'reintentar tras un error limpia el failure',
    setUp: () => when(
      () => getProducts(),
    ).thenAnswer((_) async => const Ok(sampleProducts)),
    build: () => ProductsCubit(getProducts),
    seed: () => const ProductsState(
      status: ProductsStatus.failure,
      failure: ServerFailure(),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProductsState(status: ProductsStatus.loading),
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.success)
          .having((s) => s.failure, 'failure', isNull),
    ],
  );

  group('toggleTag', () {
    const loaded = ProductsState(
      status: ProductsStatus.success,
      products: sampleProducts,
      topTags: ['beauty', 'eyeshadow', 'fruits', 'mascara'],
    );

    blocTest<ProductsCubit, ProductsState>(
      'filtra los productos que tienen la etiqueta',
      build: () => ProductsCubit(getProducts),
      seed: () => loaded,
      act: (cubit) => cubit.toggleTag('beauty'),
      verify: (cubit) {
        expect(cubit.state.selectedTag, 'beauty');
        expect(cubit.state.visibleProducts, [mascara, eyeshadow]);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'tocar la misma etiqueta quita el filtro',
      build: () => ProductsCubit(getProducts),
      seed: () => loaded,
      act: (cubit) => cubit
        ..toggleTag('beauty')
        ..toggleTag('beauty'),
      verify: (cubit) {
        expect(cubit.state.selectedTag, isNull);
        expect(cubit.state.visibleProducts, sampleProducts);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'tocar otra etiqueta cambia el filtro',
      build: () => ProductsCubit(getProducts),
      seed: () => loaded,
      act: (cubit) => cubit
        ..toggleTag('beauty')
        ..toggleTag('fruits'),
      verify: (cubit) => expect(cubit.state.visibleProducts, [apple]),
    );
  });

  group('refresh con datos visibles', () {
    const loaded = ProductsState(
      status: ProductsStatus.success,
      products: sampleProducts,
      topTags: ['beauty', 'eyeshadow', 'fruits', 'mascara'],
      selectedTag: 'beauty',
    );

    blocTest<ProductsCubit, ProductsState>(
      'un error mantiene la lista y expone el failure',
      setUp: () => when(
        () => getProducts(),
      ).thenAnswer((_) async => const Err(NetworkFailure())),
      build: () => ProductsCubit(getProducts),
      seed: () => loaded,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded.copyWith(isRefreshing: true),
        loaded.copyWith(failure: () => const NetworkFailure()),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'un refresh exitoso conserva el filtro seleccionado',
      setUp: () => when(
        () => getProducts(),
      ).thenAnswer((_) async => const Ok(sampleProducts)),
      build: () => ProductsCubit(getProducts),
      seed: () => loaded,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.selectedTag, 'beauty');
        expect(cubit.state.isRefreshing, isFalse);
      },
    );
  });

  blocTest<ProductsCubit, ProductsState>(
    'ignora un load mientras otro está en curso',
    setUp: () => when(() => getProducts()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return const Ok(sampleProducts);
    }),
    build: () => ProductsCubit(getProducts),
    act: (cubit) => Future.wait([cubit.load(), cubit.load()]),
    verify: (_) => verify(() => getProducts()).called(1),
  );
}
