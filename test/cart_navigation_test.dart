import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hello_yer/models/product.dart';
import 'package:flutter_hello_yer/providers/cart_provider.dart';
import 'package:flutter_hello_yer/screens/catalog_screen.dart';
import 'package:provider/provider.dart';

void main() {
  test('cart prevents duplicate products and calculates its total', () {
    final cart = CartProvider();
    final product = sampleProducts.first;
    var notifications = 0;
    cart.addListener(() => notifications++);

    cart.addItem(product);
    cart.addItem(
      Product(
        id: product.id,
        name: 'Another name',
        price: 1,
        icon: Icons.shopping_bag,
      ),
    );

    expect(cart.itemCount, 1);
    expect(cart.totalPrice, product.price);
    expect(notifications, 1);
    expect(() => cart.items.clear(), throwsUnsupportedError);
  });

  testWidgets('removing an item updates the catalog button and badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(home: CatalogScreen()),
      ),
    );

    expect(find.text('Add to Cart'), findsWidgets);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.text('Add to Cart').first);
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    expect(find.text('Insulated Travel Mug'), findsOneWidget);
    expect(find.text('Total: \$24.99'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove Insulated Travel Mug'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Clear All'), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton).first).onPressed,
      isNull,
    );

    await tester.tap(find.text('Back to catalog'));
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsNothing);
    expect(find.text('Add to Cart'), findsWidgets);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('clear all asks for confirmation before emptying the cart', (
    tester,
  ) async {
    final cart = CartProvider()..addItem(sampleProducts.first);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: const MaterialApp(home: CatalogScreen()),
      ),
    );
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    expect(find.text('Clear your cart?'), findsOneWidget);

    await tester.tap(find.text('Clear All').last);
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(cart.itemCount, 0);
  });
}
