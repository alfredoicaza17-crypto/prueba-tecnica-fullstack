import 'package:flutter/material.dart';

import '../domain/favorites.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesRepository repository;

  const FavoritesPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: FutureBuilder<List<Favorite>>(
        future: repository.getAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('No se pudieron cargar los favoritos'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data!;
          if (favorites.isEmpty) {
            return const Center(child: Text('Aún no tienes favoritos'));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final p = favorites[i].product;
              return ListTile(
                title: Text(p.title),
                subtitle: Text('\$${p.price.toStringAsFixed(2)}\n${p.tags.join(', ')}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
