import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  const ProductService();

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw const ProductServiceException('Products not found (404).');
      }
      if (response.statusCode >= 500) {
        throw const ProductServiceException(
          'Server error, please try again later',
        );
      }
      if (response.statusCode != 200) {
        throw ProductServiceException(
          'Could not load products (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Expected a product list.');
      }

      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('A product response was invalid.');
        }
        return Product.fromJson(item);
      }).toList();
    } on ProductServiceException {
      rethrow;
    } on TimeoutException {
      throw const ProductServiceException(
        'Request timed out. Check your connection.',
      );
    } catch (_) {
      throw const ProductServiceException('No internet connection');
    }
  }
}

class ProductServiceException implements Exception {
  const ProductServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
