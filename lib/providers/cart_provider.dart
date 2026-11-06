import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get totalPrice =>
      _items.fold<double>(0, (sum, product) => sum + product.price);

  bool isInCart(Product product) => _items.contains(product);

  void addItem(Product product) {
    if (_items.contains(product)) return;
    _items.add(product);
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void toggleItem(Product product) {
    if (!_items.remove(product)) {
      _items.add(product);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
