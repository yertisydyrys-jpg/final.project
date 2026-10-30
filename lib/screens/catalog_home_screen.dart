import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_item.dart';
import '../providers/catalog_provider.dart';
import 'catalog_item_detail_screen.dart';
import 'main_feed_screen.dart';

class CatalogHomeScreen extends StatelessWidget {
  const CatalogHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CatalogProvider>(
          builder: (context, catalog, _) =>
              Text(['Discover', 'Favorites', 'Profile'][catalog.selectedTab]),
        ),
        centerTitle: false,
        actions: [
          Consumer<CatalogProvider>(
            builder: (context, catalog, _) {
              if (catalog.selectedTab == 2) return const SizedBox.shrink();
              return IconButton(
                tooltip: catalog.isGridView ? 'Show list' : 'Show grid',
                onPressed: catalog.toggleViewMode,
                icon: Icon(
                  catalog.isGridView ? Icons.view_list : Icons.grid_view,
                ),
              );
            },
          ),
        ],
      ),
      body: Selector<CatalogProvider, int>(
        selector: (_, catalog) => catalog.selectedTab,
        builder: (_, selectedTab, _) => IndexedStack(
          index: selectedTab,
          children: const [
            _CatalogBrowser(),
            _CatalogBrowser(isFavoritesTab: true),
            _ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Selector<CatalogProvider, int>(
        selector: (_, catalog) => catalog.selectedTab,
        builder: (context, selectedTab, _) => NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: context.read<CatalogProvider>().selectTab,
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
      ),
    );
  }
}

class _CatalogBrowser extends StatelessWidget {
  const _CatalogBrowser({this.isFavoritesTab = false});

  final bool isFavoritesTab;

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        final items = isFavoritesTab
            ? catalog.favoriteProducts
            : catalog.products;
        if (catalog.products.isEmpty) {
          return RefreshIndicator(
            onRefresh: catalog.refreshProducts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: _EmptyCatalog(onReset: catalog.resetCatalog),
                ),
              ],
            ),
          );
        }
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: catalog.refreshProducts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 56,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No favorites yet'),
                          Text('Tap the heart on a product to save it here.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: catalog.refreshProducts,
          child: catalog.isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _dismissibleProduct(
                    context,
                    catalog,
                    items[index],
                    child: _CatalogGridCard(
                      item: items[index],
                      isFavorite: catalog.favoriteIds.contains(items[index].id),
                      onTap: () => _openItem(context, catalog, items[index]),
                      onFavoriteTap: () => catalog.toggleFavorite(items[index]),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _dismissibleProduct(
                    context,
                    catalog,
                    items[index],
                    child: _CatalogListTile(
                      item: items[index],
                      isFavorite: catalog.favoriteIds.contains(items[index].id),
                      onTap: () => _openItem(context, catalog, items[index]),
                      onFavoriteTap: () => catalog.toggleFavorite(items[index]),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

Widget _dismissibleProduct(
  BuildContext context,
  CatalogProvider catalog,
  CatalogItem item, {
  required Widget child,
}) {
  final originalIndex = catalog.indexOfProduct(item.id);
  return Dismissible(
    key: ValueKey(item.id),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (_) {
      catalog.removeProduct(originalIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => catalog.restoreProduct(item, originalIndex),
          ),
        ),
      );
    },
    child: child,
  );
}

void _openItem(
  BuildContext context,
  CatalogProvider catalog,
  CatalogItem item,
) {
  Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => CatalogItemDetailScreen(
        item: item,
        isFavorite: catalog.favoriteIds.contains(item.id),
        onToggleFavorite: () => catalog.toggleFavorite(item),
      ),
    ),
  );
}

class _CatalogListTile extends StatelessWidget {
  const _CatalogListTile({
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
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        item.category == 'Electronics'
            ? Icons.devices_other
            : Icons.shopping_bag_outlined,
      ),
    ),
    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _CategoryTag(category: item.category),
          Icon(Icons.star, size: 15, color: Colors.amber.shade700),
          Text(item.rating.toStringAsFixed(1)),
        ],
      ),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: onFavoriteTap,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ],
    ),
    onTap: onTap,
  );
}

class _CatalogGridCard extends StatelessWidget {
  const _CatalogGridCard({
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
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 104,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.blueGrey.shade50,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryTag(category: item.category),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 3),
                      Text(item.rating.toStringAsFixed(1)),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      category,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall,
    ),
  );
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'Catalog is Empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onReset, child: const Text('Reset Catalog')),
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
      const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
      const SizedBox(height: 12),
      Text(
        'Welcome, User',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall
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
                MaterialPageRoute(builder: (_) => const MainFeedScreen()),
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
