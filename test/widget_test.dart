// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/features/products/domain/entities/favorite_product.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';
import 'package:tienda_app/features/products/domain/repositories/favorite_repository.dart';
import 'package:tienda_app/features/products/presentation/bloc/favorite_bloc.dart';
import 'package:tienda_app/features/products/presentation/pages/favorites_page.dart';

void main() {
  testWidgets('shows and removes locally stored favorites', (tester) async {
    final newest = _product(1, 'Producto reciente', ['hogar', 'decoración']);
    final older = _product(2, 'Producto anterior', ['tecnología']);
    final repository = _MemoryFavoriteRepository([
      FavoriteProduct(product: newest, addedAt: DateTime.utc(2026, 10, 2)),
      FavoriteProduct(product: older, addedAt: DateTime.utc(2026, 10, 1)),
    ]);
    final bloc = FavoriteBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(home: FavoritesPage(favoriteBloc: bloc)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Producto reciente'), findsOneWidget);
    expect(find.text('Producto anterior'), findsOneWidget);
    expect(find.text('\$25.50'), findsNWidgets(2));
    expect(find.text('hogar, decoración'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Producto reciente')).dy,
      lessThan(tester.getTopLeft(find.text('Producto anterior')).dy),
    );

    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();

    expect(find.text('Producto reciente'), findsNothing);
    expect(find.text('Producto anterior'), findsOneWidget);
    bloc.dispose();
  });
}

Product _product(int id, String title, List<String> tags) => Product(
  id: id,
  title: title,
  price: 25.5,
  thumbnail: 'https://example.com/$id.png',
  tags: tags,
);

class _MemoryFavoriteRepository implements FavoriteRepository {
  final List<FavoriteProduct> favorites;

  _MemoryFavoriteRepository(this.favorites);

  @override
  Future<List<FavoriteProduct>> getFavorites() async => [...favorites];

  @override
  Future<bool> isFavorite(int productId) async =>
      favorites.any((favorite) => favorite.product.id == productId);

  @override
  Future<void> addFavorite(Product product) async {
    favorites.add(FavoriteProduct(product: product, addedAt: DateTime.now()));
  }

  @override
  Future<void> removeFavorite(int productId) async {
    favorites.removeWhere((favorite) => favorite.product.id == productId);
  }
}
