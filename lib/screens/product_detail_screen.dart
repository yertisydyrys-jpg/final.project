import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.product,
    required this.products,
    super.key,
  });

  final Product product;
  final List<Product> products;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String?> get _galleryImages {
    final ownImage = _validImageUrl(widget.product.imageUrl);
    final images = <String>[];
    if (ownImage != null) images.add(ownImage);

    for (final otherProduct in widget.products) {
      if (images.length == 3) break;
      if (otherProduct.id == widget.product.id ||
          otherProduct.category != widget.product.category) {
        continue;
      }
      final image = _validImageUrl(otherProduct.imageUrl);
      if (image != null && !images.contains(image)) images.add(image);
    }

    while (images.length < 3 && ownImage != null) {
      images.add(ownImage);
    }
    if (images.length < 3 && ownImage == null) {
      images.addAll(List<String>.filled(3 - images.length, ''));
    }
    return [...images.take(3)];
  }

  String? _validImageUrl(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return null;
    final uri = Uri.tryParse(trimmedValue);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return trimmedValue;
  }

  void _showShareSheet() {
    final deepLink = 'narxoz://store/product/${widget.product.id}';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share product',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(deepLink),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: deepLink));
                    if (!sheetContext.mounted || !mounted) return;
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePage(int offset) {
    final target = (_currentPage + offset).clamp(0, 2).toInt();
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = _galleryImages;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) => IconButton(
              tooltip: 'Open cart (${cart.itemCount} items)',
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
                    child: Badge(
                      isLabelVisible: cart.itemCount > 0,
                      label: Text('${cart.itemCount}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Share product',
            onPressed: _showShareSheet,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth < 960
                ? constraints.maxWidth
                : 960.0;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: ListView(
                  primary: false,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _buildCarousel(images),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(product.category),
                        backgroundColor: colorScheme.secondaryContainer,
                        labelStyle: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.star,
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                              Text(
                                '${product.rating.toStringAsFixed(1)}'
                                ' (${product.reviewCount} reviews)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(product.description, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final isInCart = cart.isInCart(product);
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.read<CartProvider>().toggleItem(product),
                      icon: Icon(
                        isInCart
                            ? Icons.remove_shopping_cart
                            : Icons.add_shopping_cart,
                      ),
                      label: Text(
                        isInCart ? 'Remove from Cart' : 'Add to Cart',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<String?> images) => Column(
    children: [
      SizedBox(
        height: 340,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final image = images[index] ?? '';
                final child = image.isEmpty
                    ? _imagePlaceholder(context)
                    : _networkProductImage(context, image);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: index == 0
                      ? Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: child,
                        )
                      : child,
                );
              },
            ),
            Positioned(
              left: 0,
              child: _CarouselArrow(
                icon: Icons.chevron_left,
                tooltip: 'Previous image',
                onPressed: _currentPage == 0 ? null : () => _changePage(-1),
              ),
            ),
            Positioned(
              right: 0,
              child: _CarouselArrow(
                icon: Icons.chevron_right,
                tooltip: 'Next image',
                onPressed: _currentPage == 2 ? null : () => _changePage(1),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text('${_currentPage + 1} / 3'),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(
          3,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: index == _currentPage ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == _currentPage
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ],
  );
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    shape: const CircleBorder(),
    child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon)),
  );
}

Widget _networkProductImage(BuildContext context, String url) => Image.network(
  url,
  fit: BoxFit.contain,
  width: double.infinity,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    final expected = progress.expectedTotalBytes;
    final value = expected == null
        ? null
        : progress.cumulativeBytesLoaded / expected;
    return Center(child: CircularProgressIndicator(value: value));
  },
  errorBuilder: (_, _, _) => _imagePlaceholder(context),
);

Widget _imagePlaceholder(BuildContext context) => Container(
  width: double.infinity,
  height: double.infinity,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Icon(
    Icons.image_not_supported_outlined,
    size: 56,
    color: Theme.of(context).colorScheme.outline,
  ),
);
