import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'app.dart';
import 'core/presentation/app_theme.dart';
import 'core/presentation/catalog_skeleton.dart';
import 'core/presentation/status_message.dart';
import 'features/catalog/data/api_product_repository.dart';
import 'features/catalog/domain/get_products.dart';
import 'features/catalog/presentation/catalog_controller.dart';
import 'features/favorites/data/sqlite_favorites_repository.dart';
import 'features/favorites/domain/manage_favorites.dart';
import 'features/favorites/presentation/favorites_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  Database? db;
  http.Client? client;
  CatalogController? catalog;
  FavoritesController? favorites;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() => failed = false);
    try {
      final database = await openDatabase(
        path.join(await getDatabasesPath(), 'tienda_app.db'),
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: SqliteFavoritesRepository.createSchema,
      );
      if (!mounted) {
        await database.close();
        return;
      }
      db = database;
      client = http.Client();
      catalog = CatalogController(GetProducts(ApiProductRepository(client!)));
      favorites = FavoritesController(
        ManageFavorites(SqliteFavoritesRepository(database)),
      );
      await favorites!.load();
      if (!mounted) return;
      setState(() {});
      await catalog!.load();
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    catalog?.dispose();
    favorites?.dispose();
    client?.close();
    db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (failed || catalog == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('TiendaApp')),
          body: failed
              ? StatusMessage(
                  message: 'No se pudo abrir la base de datos local.',
                  icon: Icons.storage,
                  retry: initialize,
                )
              : const SafeArea(child: CatalogSkeleton()),
        ),
      );
    }
    return TiendaApp(catalog: catalog!, favorites: favorites!);
  }
}
