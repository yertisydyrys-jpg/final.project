import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sampleProducts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = sampleProducts[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(
                      product.icon,
                      color: colorScheme.onSecondaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (product.description case final description?) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _CartToggleButton(product: product),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartToggleButton extends StatelessWidget {
  const _CartToggleButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isInCart = context.watch<CartProvider>().isInCart(product);

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
