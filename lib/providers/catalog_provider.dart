import 'package:flutter/foundation.dart';

import '../models/catalog_item.dart';

class CatalogProvider extends ChangeNotifier {
  List<CatalogItem> _products = List.of(catalogItems);
  final Set<String> _favoriteIds = {};
  bool _isGridView = false;
  int _selectedTab = 0;

  List<CatalogItem> get products => List.unmodifiable(_products);
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isGridView => _isGridView;
  int get selectedTab => _selectedTab;

  List<CatalogItem> get favoriteProducts =>
      _products.where((product) => _favoriteIds.contains(product.id)).toList();

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void selectTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  void toggleFavorite(CatalogItem product) {
    if (!_favoriteIds.add(product.id)) {
      _favoriteIds.remove(product.id);
    }
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final now = DateTime.now();
    _products.insert(
      0,
      CatalogItem(
        id: 'arrival-${now.microsecondsSinceEpoch}',
        title: 'Fresh Arrival',
        description: 'A new pick, recently added to the catalog.',
        imageUrl: catalogItems.first.imageUrl,
        price: 49.99,
        category: 'New arrivals',
        rating: 4.7,
        publishedAt: now,
      ),
    );
    notifyListeners();
  }

  void removeProduct(int index) {
    if (index < 0 || index >= _products.length) {
      throw RangeError.index(index, _products, 'index');
    }
    _products.removeAt(index);
    notifyListeners();
  }

  void restoreProduct(CatalogItem product, int originalIndex) {
    if (_products.any((existing) => existing.id == product.id)) return;
    final insertionIndex = originalIndex.clamp(0, _products.length).toInt();
    _products.insert(insertionIndex, product);
    notifyListeners();
  }

  int indexOfProduct(String productId) =>
      _products.indexWhere((product) => product.id == productId);

  void resetCatalog() {
    _products = List.of(catalogItems);
    _favoriteIds.removeWhere(
      (favoriteId) => !_products.any((product) => product.id == favoriteId),
    );
    notifyListeners();
  }
}
