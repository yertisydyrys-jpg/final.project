import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    this.productService = const ProductService(),
  });

  final ProductService productService;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product>? _products;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await widget.productService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } on ProductServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _products = null;
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop catalog'),
        actions: [
          IconButton(
            tooltip: 'Open cart',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) => Badge(
                      isLabelVisible: cart.itemCount > 0,
                      label: Text('${cart.itemCount}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading && _products == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _products == null
            ? _ErrorState(message: _errorMessage!, onRetry: _fetchProducts)
            : _buildProductList(_products ?? const []),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) => RefreshIndicator(
    onRefresh: _fetchProducts,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductTile(
              product: product,
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ProductDetailScreen(product: product, products: products),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'product_image_${product.id}',
          child: _ProductImage(url: product.imageUrl, size: 72),
        ),
        title: Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${product.rating.toStringAsFixed(1)}'
                    ' (${product.reviewCount})',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('\$${product.price.toStringAsFixed(2)}'),
              if (product.category.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        trailing: _CartToggleButton(product: product),
      ),
    );
  }
}

class _CartToggleButton extends StatelessWidget {
  const _CartToggleButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isInCart = cart.isInCart(product);

    return isInCart
        ? OutlinedButton.icon(
            onPressed: () => context.read<CartProvider>().toggleItem(product),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Added'),
          )
        : FilledButton.icon(
            onPressed: () => context.read<CartProvider>().toggleItem(product),
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Add to Cart'),
          );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return _imagePlaceholder(context, size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          final expected = progress.expectedTotalBytes;
          final value = expected == null
              ? null
              : progress.cumulativeBytesLoaded / expected;
          return Center(child: CircularProgressIndicator(value: value));
        },
        errorBuilder: (_, _, _) => _imagePlaceholder(context, size),
      ),
    );
  }
}

Widget _imagePlaceholder(BuildContext context, double size) => Container(
  width: size,
  height: size,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
    Icons.image_not_supported_outlined,
    color: Theme.of(context).colorScheme.outline,
  ),
);

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    ),
  );
}
