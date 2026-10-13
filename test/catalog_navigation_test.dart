import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hello_yer/screens/catalog_home_screen.dart';

void main() {
  testWidgets('feed opens full item details and pops back to the same tab', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogHomeScreen()));

    await tester.tap(find.text('Everyday Backpack').first);
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(
      find.text(
        'A lightweight, water-resistant backpack with a padded '
        'laptop sleeve and room for all your daily essentials.',
      ),
      findsOneWidget,
    );
    expect(find.text('\$59.99'), findsOneWidget);

    await tester.ensureVisible(find.text('Back to feed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to feed'));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Everyday Backpack'), findsOneWidget);
  });

  testWidgets('favorite action adds an item to the Favorites tab', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogHomeScreen()));

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Everyday Backpack'), findsOneWidget);
  });

  testWidgets('AppBar back button pops the detail route', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogHomeScreen()));

    await tester.tap(find.text('Everyday Backpack').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
  });
}
