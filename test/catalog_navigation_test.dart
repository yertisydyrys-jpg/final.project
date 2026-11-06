import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hello_yer/screens/catalog_home_screen.dart';
import 'package:flutter_hello_yer/providers/cart_provider.dart';
import 'package:flutter_hello_yer/providers/catalog_provider.dart';
import 'package:provider/provider.dart';

void main() {
  test('refresh waits 1.5 seconds and prepends a product', () async {
    final catalog = CatalogProvider();
    final originalFirstProduct = catalog.products.first;
    var notified = false;
    catalog.addListener(() => notified = true);

    final refresh = catalog.refreshProducts();
    await Future<void>.delayed(const Duration(milliseconds: 1490));
    expect(catalog.products, hasLength(4));
    expect(notified, isFalse);

    await refresh;
    expect(catalog.products, hasLength(5));
    expect(catalog.products.first.title, 'Fresh Arrival');
    expect(catalog.products[1], originalFirstProduct);
    expect(notified, isTrue);
  });

  testWidgets('feed opens full item details and pops back to the same tab', (
    tester,
  ) async {
    await _pumpCatalogHome(tester);

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
    await _pumpCatalogHome(tester);

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Everyday Backpack'), findsOneWidget);
  });

  testWidgets('AppBar back button pops the detail route', (tester) async {
    await _pumpCatalogHome(tester);

    await tester.tap(find.text('Everyday Backpack').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('view toggle switches the feed to a two-column grid', (
    tester,
  ) async {
    await _pumpCatalogHome(tester);

    await tester.tap(find.byTooltip('Show grid'));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, 0.72);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty catalog can be reset to the seed products', (
    tester,
  ) async {
    final catalog = CatalogProvider();
    for (var index = 0; index < 4; index++) {
      catalog.removeProduct(0);
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: catalog),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MaterialApp(home: CatalogHomeScreen()),
      ),
    );
    expect(find.text('Catalog is Empty'), findsOneWidget);

    await tester.tap(find.text('Reset Catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Everyday Backpack'), findsOneWidget);
  });

  testWidgets('deleted products can be restored with Undo', (tester) async {
    await _pumpCatalogHome(tester);

    await tester.drag(
      find.text('Everyday Backpack').first,
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Everyday Backpack'), findsNothing);
    expect(find.text('UNDO'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(find.text('Everyday Backpack'), findsOneWidget);
  });
}

Future<void> _pumpCatalogHome(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MaterialApp(home: CatalogHomeScreen()),
    ),
  );
}
