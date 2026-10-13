import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tienda_app/app/app.dart';
import 'package:tienda_app/app/injection.dart';
import 'package:tienda_app/core/database/app_database.dart';

/// Flujo completo con las implementaciones reales (cubits, casos de uso,
/// repositorios, sqflite) y solo la red simulada.
void main() {
  late Database db;
  late Directory tempDir;
  late String dbPath;

  final apiResponse = jsonEncode({
    'products': [
      {
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'price': 9.99,
        'tags': ['beauty', 'mascara'],
        'thumbnail': '',
      },
      {
        'id': 2,
        'title': 'Eyeshadow Palette',
        'price': 19.99,
        'tags': ['Beauty', 'eyeshadow'],
        'thumbnail': '',
      },
      {
        'id': 3,
        'title': 'Apple',
        'price': 1.99,
        'tags': ['fruits'],
        'thumbnail': '',
      },
    ],
    'total': 3,
    'skip': 0,
    'limit': 20,
  });

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tienda_app_test');
    dbPath = '${tempDir.path}/test.db';
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpApp(WidgetTester tester, http.Client client) async {
    await tester.runAsync(() async {
      db = await AppDatabase.open(factory: databaseFactoryFfi, path: dbPath);
    });
    final deps = AppDependencies(client: client, database: db);
    await tester.pumpWidget(
      TiendaApp(
        createProductsCubit: deps.productsCubit,
        createFavoritesCubit: deps.favoritesCubit,
      ),
    );
    await settle(tester);
  }

  testWidgets('listar, filtrar, marcar favorito y verlo sin conexión', (
    tester,
  ) async {
    await pumpApp(
      tester,
      MockClient((_) async => http.Response(apiResponse, 200)),
    );

    // RF-01: listado.
    expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    // RF-03: chips y filtro ('Beauty' y 'beauty' cuentan juntas).
    expect(find.byType(FilterChip), findsNWidgets(4));
    await tester.tap(find.byKey(const ValueKey('tag-beauty')));
    await tester.pump();
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Eyeshadow Palette'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tag-beauty')));
    await tester.pump();
    expect(find.text('Apple'), findsOneWidget);

    // RF-04: marcar favorito.
    await tester.tap(find.byKey(const ValueKey('fav-2')));
    await settle(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('fav-2')),
        matching: find.byIcon(Icons.favorite),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('open-favorites')));
    await settle(tester);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Eyeshadow Palette'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'eyeshadow'), findsOneWidget);

    // Se "cierra" la app y se abre de nuevo sin conexión.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
    await pumpApp(
      tester,
      MockClient((_) async => throw const SocketException('offline')),
    );

    // RF-02: mensaje de sin conexión.
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    // RF-04: los favoritos siguen disponibles sin red.
    await tester.tap(find.byKey(const ValueKey('open-favorites')));
    await settle(tester);
    expect(find.text('Eyeshadow Palette'), findsOneWidget);
    expect(find.text('\$19.99'), findsOneWidget);
  });
}

/// sqflite_ffi corre en un isolate aparte: hay que dejar correr el tiempo real
/// para que respondan las consultas antes de volver a pintar.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }
}
