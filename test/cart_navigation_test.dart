import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hello_yer/models/product.dart';
import 'package:flutter_hello_yer/providers/cart_provider.dart';
import 'package:flutter_hello_yer/screens/catalog_screen.dart';
import 'package:flutter_hello_yer/services/product_service.dart';
import 'package:provider/provider.dart';

void main() {
  test('cart prevents duplicate products and calculates its total', () {
    final cart = CartProvider();
    final product = _testProduct();
    var notifications = 0;
    cart.addListener(() => notifications++);

    cart.addItem(product);
    cart.addItem(
      Product(
        id: product.id,
        title: 'Another name',
        price: 1,
        description: '',
        category: '',
        imageUrl: '',
        rating: 0,
        reviewCount: 0,
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
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(
          home: CatalogScreen(productService: _TestProductService()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add to Cart'), findsNWidgets(6));
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
    expect(find.text('Add to Cart'), findsNWidgets(6));
    expect(find.text('1'), findsNothing);
  });

  testWidgets('clear all asks for confirmation before emptying the cart', (
    tester,
  ) async {
    final cart = CartProvider()..addItem(_testProduct());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: const MaterialApp(
          home: CatalogScreen(productService: _TestProductService()),
        ),
      ),
    );
    await tester.pumpAndSettle();
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

Product _testProduct() => const Product(
  id: 1,
  title: 'Insulated Travel Mug',
  price: 24.99,
  description: '',
  category: 'Test',
  imageUrl: '',
  rating: 4.5,
  reviewCount: 12,
);

class _TestProductService extends ProductService {
  const _TestProductService();

  @override
  Future<List<Product>> fetchProducts() async => List<Product>.generate(
    6,
    (index) => Product(
      id: index + 1,
      title: index == 0 ? 'Insulated Travel Mug' : 'Test Product ${index + 1}',
      price: index == 0 ? 24.99 : 10,
      description: '',
      category: 'Test',
      imageUrl: '',
      rating: 4.5,
      reviewCount: 12,
    ),
  );
}
