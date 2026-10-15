import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/core/error/failures.dart';
import 'package:tienda_app/features/products/domain/entities/product.dart';

import '../../../support/fakes.dart';
import '../../../support/fixtures.dart';
import '../../../support/pump_app.dart';

const serverMessage =
    'El servidor tuvo un problema. Inténtalo de nuevo en unos minutos.';
const networkMessage =
    'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.';

void main() {
  group('RF-01 listado', () {
    testWidgets('muestra miniatura, titulo y precio de cada producto', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('Beef Steak'), findsOneWidget);
      expect(find.text('\$12.50'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });
  });

  group('RF-02 estados', () {
    testWidgets('muestra el indicador de carga mientras espera', (
      tester,
    ) async {
      final completer = Completer<List<Product>>();
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() => completer.future),
        settle: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(sampleProducts);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Beef Steak'), findsOneWidget);
    });

    testWidgets('muestra mensaje y boton Reintentar ante error del servidor', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => throw const ServerFailure()),
      );

      expect(find.text(serverMessage), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text(networkMessage), findsNothing);
    });

    testWidgets('el mensaje sin conexion es distinto al error del servidor', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => throw const NetworkFailure()),
      );

      expect(find.text(networkMessage), findsOneWidget);
      expect(find.text(serverMessage), findsNothing);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('Reintentar vuelve a cargar y muestra el listado', (
      tester,
    ) async {
      var attempts = 0;
      final repository = FakeProductRepository(() async {
        attempts++;
        if (attempts == 1) throw const ServerFailure();
        return sampleProducts;
      });
      await pumpTiendaApp(tester, products: repository);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(repository.calls, 2);
      expect(find.text(serverMessage), findsNothing);
      expect(find.text('Beef Steak'), findsOneWidget);
    });

    testWidgets('muestra mensaje cuando la lista esta vacia', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => <Product>[]),
      );

      expect(find.text('No hay productos disponibles.'), findsOneWidget);
    });
  });

  group('RF-03 etiquetas populares', () {
    testWidgets('muestra como chips las 5 etiquetas mas frecuentes', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      expect(find.byType(FilterChip), findsNWidgets(5));
      for (final tag in sampleTopTags) {
        expect(find.byKey(ValueKey('tag-$tag')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('tag-mascara')), findsNothing);
    });

    testWidgets('al tocar una etiqueta muestra solo los productos que la tienen', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await tester.tap(find.byKey(const ValueKey('tag-meat')));
      await tester.pumpAndSettle();

      expect(find.text('Beef Steak'), findsOneWidget);
      expect(find.text('Chicken Meat'), findsOneWidget);
      expect(find.text('Eyeliner'), findsNothing);
      expect(find.text('Essence Mascara Lash Princess'), findsNothing);
    });

    testWidgets('al tocar la etiqueta de nuevo se quita el filtro', (
      tester,
    ) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await tester.tap(find.byKey(const ValueKey('tag-meat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tag-meat')));
      await tester.pumpAndSettle();

      expect(find.text('Eyeliner'), findsOneWidget);
      expect(find.text('Beef Steak'), findsOneWidget);
      expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
    });

    testWidgets('los chips se mantienen al filtrar', (tester) async {
      await pumpTiendaApp(
        tester,
        products: FakeProductRepository(() async => sampleProducts),
      );

      await tester.tap(find.byKey(const ValueKey('tag-beauty')));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNWidgets(5));
    });
  });
}
