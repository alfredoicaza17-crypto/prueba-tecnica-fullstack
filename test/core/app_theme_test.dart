import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/core/theme/app_theme.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('buildAppTheme', () {
    final theme = buildAppTheme();

    test('usa #237AB0 como color principal', () {
      expect(brandPrimary, const Color(0xFF237AB0));
      expect(theme.colorScheme.primary, const Color(0xFF237AB0));
    });

    test('usa blanco como fondo y como texto sobre el color principal', () {
      expect(theme.scaffoldBackgroundColor, Colors.white);
      expect(theme.colorScheme.surface, Colors.white);
      expect(theme.colorScheme.onPrimary, Colors.white);
    });

    test('la barra superior usa el color principal con texto blanco', () {
      expect(theme.appBarTheme.backgroundColor, const Color(0xFF237AB0));
      expect(theme.appBarTheme.foregroundColor, Colors.white);
    });

    test('el texto blanco sobre el color principal cumple contraste AA', () {
      expect(
        contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
