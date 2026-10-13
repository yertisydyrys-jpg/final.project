class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final DateTime publishedAt;
}

final catalogItems = <CatalogItem>[
  CatalogItem(
    id: 'backpack',
    title: 'Everyday Backpack',
    description:
        'A lightweight, water-resistant backpack with a padded laptop sleeve '
        'and room for all your daily essentials.',
    imageUrl:
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=900',
    price: 59.99,
    category: 'Accessories',
    publishedAt: DateTime(2026, 10, 12),
  ),
  CatalogItem(
    id: 'headphones',
    title: 'Studio Headphones',
    description:
        'Comfortable over-ear headphones with rich sound and a foldable '
        'design for listening at home or on the go.',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=900',
    price: 89.50,
    category: 'Electronics',
    publishedAt: DateTime(2026, 10, 10),
  ),
  CatalogItem(
    id: 'watch',
    title: 'Classic Wristwatch',
    description:
        'A minimal everyday watch with a clean dial, stainless steel case, '
        'and a comfortable adjustable strap.',
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=900',
    price: 124.00,
    category: 'Accessories',
    publishedAt: DateTime(2026, 10, 8),
  ),
  CatalogItem(
    id: 'camera',
    title: 'Instant Camera',
    description:
        'Capture spontaneous moments and turn them into prints with this '
        'easy-to-use instant camera.',
    imageUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=900',
    price: 74.95,
    category: 'Electronics',
    publishedAt: DateTime(2026, 10, 5),
  ),
];
