import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          TextButton(
            onPressed: cart.items.isEmpty ? null : () => _confirmClear(context),
            child: const Text('Clear All'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.items.isEmpty
          ? const _EmptyCart()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final product = cart.items[index];
                          return _CartItemTile(product: product);
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear your cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CartProvider>().clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: _CartProductImage(url: product.imageUrl),
      title: Text(product.title),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: IconButton(
        tooltip: 'Remove ${product.title}',
        onPressed: () => context.read<CartProvider>().removeItem(product),
        icon: const Icon(Icons.delete_outline),
      ),
    ),
  );
}

class _CartProductImage extends StatelessWidget {
  const _CartProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final validUrl =
        uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    final placeholder = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported_outlined),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: validUrl
          ? Image.network(
              url,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                final expected = progress.expectedTotalBytes;
                final value = expected == null
                    ? null
                    : progress.cumulativeBytesLoaded / expected;
                return SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CircularProgressIndicator(value: value)),
                );
              },
              errorBuilder: (_, _, _) => placeholder,
            )
          : placeholder,
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Back to catalog'),
          ),
        ],
      ),
    ),
  );
}
