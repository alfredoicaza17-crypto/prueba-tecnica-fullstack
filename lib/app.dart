import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/products/presentation/cubit/products_cubit.dart';
import 'features/products/presentation/pages/products_page.dart';

class TiendaApp extends StatelessWidget {
  const TiendaApp({
    super.key,
    required this.productsCubit,
    required this.favoritesCubit,
  });

  final ProductsCubit productsCubit;
  final FavoritesCubit favoritesCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: productsCubit),
        BlocProvider.value(value: favoritesCubit),
      ],
      child: MaterialApp(
        title: 'TiendaApp',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const ProductsPage(),
      ),
    );
  }
}
