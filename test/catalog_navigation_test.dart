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

  testWidgets('profile display name can be edited', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogHomeScreen()));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit display name'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Alex');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Alex'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('help and support opens billing topics without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: CatalogHomeScreen()));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Help and support'));
    await tester.tap(find.text('Help and support'));
    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Need help? Start here'), findsOneWidget);
    await tester.tap(find.text('Billing and Subscriptions'));
    await tester.pumpAndSettle();

    for (final topic in [
      'Request a refund',
      'View your purchase history',
      'Manage your payment information',
      "If you're unable to make purchases",
      "If you don't recognize a charge",
      'Access purchases across all your devices',
    ]) {
      expect(find.text(topic), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
  }
