import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/favorites/presentation/pages/favorites_page.dart';

import '../../../support/fakes.dart';
import '../../../support/fixtures.dart';
import '../../../support/pump_app.dart';

Future<void> openFavorites(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('open-favorites')));
  await tester.pumpAndSettle();
}

Future<void> toggleHeart(WidgetTester tester, int productId) async {
  await tester.tap(find.byKey(ValueKey('favorite-$productId')));
  await tester.pumpAndSettle();
}

Icon heartOf(WidgetTester tester, int productId) {
  return tester.widget<Icon>(
    find.descendant(
      of: find.byKey(ValueKey('favorite-$productId')),
      matching: find.byType(Icon),
    ),
  );
}

void main() {
  group('RF-04 favoritos', () {
    testWidgets('el AppBar del listado abre la pantalla Favoritos', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await openFavorites(tester);

      expect(find.byType(FavoritesPage), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('muestra mensaje si no hay favoritos', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await openFavorites(tester);

      expect(find.text('Aún no tienes productos favoritos.'), findsOneWidget);
    });

    testWidgets('el icono marca y desmarca un producto', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      expect(heartOf(tester, mascara.id).icon, Icons.favorite_border);

      await toggleHeart(tester, mascara.id);
      expect(heartOf(tester, mascara.id).icon, Icons.favorite);

      await toggleHeart(tester, mascara.id);
      expect(heartOf(tester, mascara.id).icon, Icons.favorite_border);
    });

    testWidgets('muestra titulo, precio y etiquetas del favorito', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await openFavorites(tester);

      expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'beauty'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'mascara'), findsOneWidget);
      expect(find.text('Aún no tienes productos favoritos.'), findsNothing);
    });

    testWidgets('lista del mas reciente al mas antiguo', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await toggleHeart(tester, beef.id);
      await toggleHeart(tester, eyeliner.id);
      await openFavorites(tester);

      final tiles = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('favorite-tile-'),
      );
      final keys = tester
          .widgetList(tiles)
          .map((widget) => (widget.key! as ValueKey<String>).value)
          .toList();

      expect(keys, [
        'favorite-tile-${eyeliner.id}',
        'favorite-tile-${beef.id}',
        'favorite-tile-${mascara.id}',
      ]);
    });

    testWidgets('desmarcar saca al producto de Favoritos', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await toggleHeart(tester, mascara.id);
      await openFavorites(tester);

      expect(find.text('Aún no tienes productos favoritos.'), findsOneWidget);
    });

    testWidgets('Favoritos funciona aunque el listado no cargue', (
      tester,
    ) async {
      final favorites = FakeFavoriteRepository();
      await favorites.addFavorite(beef);

      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => throw Exception('offline')),
        favorites: favorites,
      );

      await openFavorites(tester);

      expect(find.text('Beef Steak'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'groceries'), findsOneWidget);
    });

    testWidgets('cada favorito tiene un corazon para quitarlo', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await toggleHeart(tester, beef.id);
      await openFavorites(tester);

      expect(find.byKey(ValueKey('remove-favorite-${mascara.id}')), findsOneWidget);
      expect(find.byKey(ValueKey('remove-favorite-${beef.id}')), findsOneWidget);
    });

    testWidgets('el corazon en Favoritos quita solo ese producto', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await toggleHeart(tester, beef.id);
      await openFavorites(tester);

      await tester.tap(find.byKey(ValueKey('remove-favorite-${mascara.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('favorite-tile-${mascara.id}')), findsNothing);
      expect(find.byKey(ValueKey('favorite-tile-${beef.id}')), findsOneWidget);
      expect(find.text('Beef Steak'), findsOneWidget);
    });

    testWidgets('quitar el ultimo favorito muestra el mensaje de lista vacia', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await openFavorites(tester);

      await tester.tap(find.byKey(ValueKey('remove-favorite-${mascara.id}')));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Aún no tienes productos favoritos.'), findsOneWidget);
    });

    testWidgets('al quitar desde Favoritos el listado queda sin marcar', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      expect(heartOf(tester, mascara.id).icon, Icons.favorite);
      await openFavorites(tester);

      await tester.tap(find.byKey(ValueKey('remove-favorite-${mascara.id}')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(heartOf(tester, mascara.id).icon, Icons.favorite_border);
    });

    testWidgets('lo quitado se puede volver a marcar desde el listado', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await toggleHeart(tester, mascara.id);
      await openFavorites(tester);
      await tester.tap(find.byKey(ValueKey('remove-favorite-${mascara.id}')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await toggleHeart(tester, mascara.id);
      await openFavorites(tester);

      expect(find.byKey(ValueKey('favorite-tile-${mascara.id}')), findsOneWidget);
    });
  });
}
