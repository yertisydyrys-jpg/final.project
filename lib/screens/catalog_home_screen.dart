import 'package:flutter/material.dart';

import '../models/catalog_item.dart';
import 'catalog_item_detail_screen.dart';
import 'main_feed_screen.dart';

class CatalogHomeScreen extends StatefulWidget {
  const CatalogHomeScreen({super.key});

  @override
  State<CatalogHomeScreen> createState() => _CatalogHomeScreenState();
}

class _CatalogHomeScreenState extends State<CatalogHomeScreen> {
  int _selectedTab = 0;
  final Set<String> _favoriteIds = {};

  void _toggleFavorite(CatalogItem item) {
    setState(() {
      if (!_favoriteIds.add(item.id)) {
        _favoriteIds.remove(item.id);
      }
    });
  }

  void _openItem(CatalogItem item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogItemDetailScreen(
          item: item,
          isFavorite: _favoriteIds.contains(item.id),
          onToggleFavorite: () => _toggleFavorite(item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites =
        catalogItems.where((item) => _favoriteIds.contains(item.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(['Discover', 'Favorites', 'Profile'][_selectedTab]),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _CatalogList(
            items: catalogItems,
            favoriteIds: _favoriteIds,
            onItemTap: _openItem,
            onFavoriteTap: _toggleFavorite,
          ),
          _CatalogList(
            items: favorites,
            favoriteIds: _favoriteIds,
            onItemTap: _openItem,
            onFavoriteTap: _toggleFavorite,
            isFavoritesTab: true,
          ),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({
    required this.items,
    required this.favoriteIds,
    required this.onItemTap,
    required this.onFavoriteTap,
    this.isFavoritesTab = false,
  });

  final List<CatalogItem> items;
  final Set<String> favoriteIds;
  final ValueChanged<CatalogItem> onItemTap;
  final ValueChanged<CatalogItem> onFavoriteTap;
  final bool isFavoritesTab;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && isFavoritesTab) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text('No favorites yet'),
              Text('Tap the heart on a product to save it here.'),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        if (!isFavoritesTab) ...[
          Text(
            'Find something you love',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'A few picks for your everyday',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
        ],
        for (final item in items)
          _CatalogCard(
            item: item,
            isFavorite: favoriteIds.contains(item.id),
            onTap: () => onItemTap(item),
            onFavoriteTap: () => onFavoriteTap(item),
          ),
      ],
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final CatalogItem item;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 190,
                      width: double.infinity,
                      color: Colors.blueGrey.shade50,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined,
                          size: 42),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton.filledTonal(
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added ${item.publishedAt.month}/${item.publishedAt.day}/${item.publishedAt.year}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 42,
            child: Icon(Icons.person, size: 42),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, User',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your account and preferences',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Account type'),
                  subtitle: Text('User'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Personal Finance'),
                  subtitle: const Text('Cards, balance, and transactions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainFeedScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  trailing: Icon(Icons.toggle_on_outlined),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help and support'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      );
}
