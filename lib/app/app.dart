import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/favorites/presentation/cubit/favorites_state.dart';
import '../features/products/presentation/cubit/products_cubit.dart';
import '../features/products/presentation/pages/products_page.dart';

class TiendaApp extends StatelessWidget {
  const TiendaApp({
    super.key,
    required this.createProductsCubit,
    required this.createFavoritesCubit,
  });

  final ProductsCubit Function() createProductsCubit;
  final FavoritesCubit Function() createFavoritesCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => createProductsCubit()..load()),
        BlocProvider(create: (_) => createFavoritesCubit()..load()),
      ],
      child: MaterialApp(
        title: 'TiendaApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const ProductsPage(),
        // Errores al guardar/quitar favoritos se avisan en cualquier pantalla.
        builder: (context, child) =>
            BlocListener<FavoritesCubit, FavoritesState>(
              listenWhen: (prev, curr) =>
                  curr.status == FavoritesStatus.failure &&
                  prev.status != FavoritesStatus.loading,
              listener: (context, _) => ScaffoldMessenger.maybeOf(context)
                ?..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo actualizar tus favoritos.'),
                  ),
                ),
              child: child!,
            ),
      ),
    );
  }
}
