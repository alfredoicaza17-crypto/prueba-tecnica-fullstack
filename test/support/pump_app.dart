import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/app.dart';
import 'package:tienda_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:tienda_app/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:tienda_app/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:tienda_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:tienda_app/features/products/domain/usecases/get_products.dart';
import 'package:tienda_app/features/products/presentation/cubit/products_cubit.dart';

import 'fakes.dart';

Future<void> pumpTiendaApp(
  WidgetTester tester, {
  required FakeProductRepository products,
  FakeFavoriteRepository? favorites,
  bool settle = true,
}) async {
  final favoriteRepository = favorites ?? FakeFavoriteRepository();
  final productsCubit = ProductsCubit(GetProducts(products))..load();
  final favoritesCubit = FavoritesCubit(
    GetFavorites(favoriteRepository),
    ToggleFavorite(favoriteRepository),
    RemoveFavorite(favoriteRepository),
  )..load();

  addTearDown(productsCubit.close);
  addTearDown(favoritesCubit.close);

  await tester.pumpWidget(
    TiendaApp(productsCubit: productsCubit, favoritesCubit: favoritesCubit),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
