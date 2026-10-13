import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:tienda_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_cubit.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_state.dart';
import 'package:tienda_app/features/products/presentation/pages/products_page.dart';

import '../helpers/fixtures.dart';

class _MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class _MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

void main() {
  late _MockProductsCubit products;
  late _MockFavoritesCubit favorites;

  setUp(() {
    products = _MockProductsCubit();
    favorites = _MockFavoritesCubit();
    when(() => products.load()).thenAnswer((_) async {});
    when(() => favorites.load()).thenAnswer((_) async {});
    when(
      () => favorites.state,
    ).thenReturn(const FavoritesState(status: FavoritesStatus.success));
  });

  Future<void> pump(WidgetTester tester, Widget home) => tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ProductsCubit>.value(value: products),
        BlocProvider<FavoritesCubit>.value(value: favorites),
      ],
      child: MaterialApp(home: home),
    ),
  );

  group('ProductsPage (RF-01, RF-02, RF-03)', () {
    testWidgets('muestra cargando', (tester) async {
      when(
        () => products.state,
      ).thenReturn(const ProductsState(status: ProductsStatus.loading));
      await pump(tester, const ProductsPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('sin conexión muestra mensaje propio y reintenta', (
      tester,
    ) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.failure,
          failure: NetworkFailure(),
        ),
      );
      await pump(tester, const ProductsPage());

      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      verify(() => products.load()).called(1);
    });

    testWidgets('error del servidor muestra un mensaje distinto', (
      tester,
    ) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.failure,
          failure: ServerFailure(),
        ),
      );
      await pump(tester, const ProductsPage());

      expect(find.text('No pudimos cargar los productos'), findsOneWidget);
      expect(find.text('Sin conexión'), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('lista vacía muestra mensaje', (tester) async {
      when(
        () => products.state,
      ).thenReturn(const ProductsState(status: ProductsStatus.success));
      await pump(tester, const ProductsPage());

      expect(find.text('No hay productos para mostrar.'), findsOneWidget);
    });

    testWidgets('muestra título, precio y chips de etiquetas', (tester) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.success,
          products: sampleProducts,
          topTags: ['beauty', 'eyeshadow', 'fruits', 'mascara'],
        ),
      );
      await pump(tester, const ProductsPage());

      expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(4));
    });

    testWidgets('tocar un chip llama a toggleTag', (tester) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.success,
          products: sampleProducts,
          topTags: ['beauty'],
        ),
      );
      await pump(tester, const ProductsPage());

      await tester.tap(find.byKey(const ValueKey('tag-beauty')));
      verify(() => products.toggleTag('beauty')).called(1);
    });

    testWidgets('con un filtro activo solo muestra los productos que aplican', (
      tester,
    ) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.success,
          products: sampleProducts,
          topTags: ['beauty', 'fruits'],
          selectedTag: 'fruits',
        ),
      );
      await pump(tester, const ProductsPage());

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Essence Mascara Lash Princess'), findsNothing);
    });

    testWidgets('el corazón marca un favorito', (tester) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.success,
          products: [mascara],
        ),
      );
      when(
        () => favorites.toggle(
          id: any(named: 'id'),
          title: any(named: 'title'),
          price: any(named: 'price'),
          thumbnail: any(named: 'thumbnail'),
          tags: any(named: 'tags'),
        ),
      ).thenAnswer((_) async {});
      await pump(tester, const ProductsPage());

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('fav-1')));

      verify(
        () => favorites.toggle(
          id: 1,
          title: mascara.title,
          price: mascara.price,
          thumbnail: mascara.thumbnail,
          tags: mascara.tags,
        ),
      ).called(1);
    });

    testWidgets('un producto favorito muestra el corazón lleno', (
      tester,
    ) async {
      when(() => products.state).thenReturn(
        const ProductsState(
          status: ProductsStatus.success,
          products: [mascara],
        ),
      );
      when(() => favorites.state).thenReturn(
        FavoritesState(
          status: FavoritesStatus.success,
          favorites: [favoriteFrom(mascara, DateTime(2026))],
        ),
      );
      await pump(tester, const ProductsPage());

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('fav-1')),
          matching: find.byIcon(Icons.favorite),
        ),
        findsOneWidget,
      );
    });

    testWidgets('un refresh fallido mantiene la lista y avisa', (tester) async {
      const loaded = ProductsState(
        status: ProductsStatus.success,
        products: sampleProducts,
      );
      whenListen(
        products,
        Stream.value(loaded.copyWith(failure: () => const NetworkFailure())),
        initialState: loaded,
      );
      await pump(tester, const ProductsPage());
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      expect(
        find.text('Sin conexión. Mostrando los últimos productos cargados.'),
        findsOneWidget,
      );
    });

    testWidgets('el AppBar abre la pantalla de favoritos', (tester) async {
      when(
        () => products.state,
      ).thenReturn(const ProductsState(status: ProductsStatus.success));
      await pump(tester, const ProductsPage());

      await tester.tap(find.byKey(const ValueKey('open-favorites')));
      await tester.pumpAndSettle();

      expect(find.byType(FavoritesPage), findsOneWidget);
    });
  });

  group('FavoritesPage (RF-04)', () {
    testWidgets('vacía muestra mensaje', (tester) async {
      await pump(tester, const FavoritesPage());

      expect(find.text('Aún no tienes favoritos.'), findsOneWidget);
    });

    testWidgets('muestra título, precio y etiquetas en el orden recibido', (
      tester,
    ) async {
      when(() => favorites.state).thenReturn(
        FavoritesState(
          status: FavoritesStatus.success,
          favorites: [
            favoriteFrom(eyeshadow, DateTime(2026, 2)),
            favoriteFrom(mascara, DateTime(2026, 1)),
          ],
        ),
      );
      await pump(tester, const FavoritesPage());

      expect(find.text(eyeshadow.title), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
      expect(find.text('Agregado el 01/02/2026'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'mascara'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'beauty'), findsNWidgets(2));

      final first = tester.getTopLeft(find.text(eyeshadow.title)).dy;
      final second = tester.getTopLeft(find.text(mascara.title)).dy;
      expect(first, lessThan(second));
    });
  });
}
