import 'package:flutter/material.dart';

import 'package:kraze_student_marketplace/constants/categories.dart';
import 'package:kraze_student_marketplace/models/product.dart';
import 'package:kraze_student_marketplace/services/marketplace_store.dart';
import 'package:kraze_student_marketplace/theme/app_text_styles.dart';
import 'package:kraze_student_marketplace/widgets/bottom_nav_bar.dart';
import 'package:kraze_student_marketplace/widgets/kraze_page_route.dart';
import 'package:kraze_student_marketplace/widgets/product_grid.dart';
import 'package:kraze_student_marketplace/widgets/product_image.dart';
import 'package:kraze_student_marketplace/pages/chat/messages_page.dart';
import 'package:kraze_student_marketplace/pages/favorites/favorites_page.dart';
import 'package:kraze_student_marketplace/pages/post_item/post_item_page.dart';
import 'package:kraze_student_marketplace/pages/profile/profile_page.dart';
import 'package:kraze_student_marketplace/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: marketplaceStore,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: KeyedSubtree(
                key: ValueKey(_selectedTab),
                child: _buildCurrentTab(),
              ),
            ),
          ),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: _selectedTab,
            onTap: _onNavigationTap,
          ),
        );
      },
    );
  }

  Widget _buildCurrentTab() {
    return switch (_selectedTab) {
      1 => const FavoritesPage(),
      3 => const MessagesPage(),
      4 => const ProfilePage(),
      _ => _MarketplaceTab(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() => _selectedCategory = category);
          },
          onProfileTap: () => setState(() => _selectedTab = 4),
          onNotificationTap: () => setState(() => _selectedTab = 3),
        ),
    };
  }

  Future<void> _onNavigationTap(int index) async {
    if (index == 2) {
      await Navigator.of(context).push<bool>(
        KrazePageRoute(builder: (_) => const PostItemPage()),
      );
      return;
    }
    setState(() => _selectedTab = index);
  }
}

class _MarketplaceTab extends StatelessWidget {
  const _MarketplaceTab({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final allProducts = selectedCategory == 'All'
        ? marketplaceStore.products
        : marketplaceStore.products
              .where((product) => product.category == selectedCategory)
              .toList(growable: false);
    
    // Only show active items in the main feed
    final products = allProducts.where((p) => p.status == 'active').toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildTopBar(context)),
        SliverToBoxAdapter(child: _buildSearchShortcut(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildCategories(context)),
        SliverToBoxAdapter(child: _buildSectionHeader(context, products.length)),
        ProductGridSliver(
          products: products,
          emptyIcon: Icons.storefront_outlined,
          emptyMessage: 'No items in this category yet.',
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppGradients.brand.createShader(bounds),
                  child: const Text(
                    'K',
                    style: TextStyle(
                      fontFamily: 'Glitch',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Marketplace',
                    style: AppTextStyles.sectionTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ListenableBuilder(
                listenable: marketplaceStore,
                builder: (context, _) {
                  final count = marketplaceStore.unreadConversationCount;
                  return Badge(
                    label: Text('$count'),
                    isLabelVisible: count > 0,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: onNotificationTap,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primaryContainer,
                  child: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: _buildProfileIcon(colorScheme),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon(ColorScheme colorScheme) {
    final profile = marketplaceStore.currentProfile;
    if (profile == null || profile.photoUrl.isEmpty) {
      return Icon(Icons.person, color: colorScheme.primary);
    }
    return ProductImage(imagePath: profile.photoUrl);
  }

  Widget _buildSearchShortcut(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          KrazePageRoute(builder: (_) => const SearchPage()),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(
                'Search textbooks, laptops, phones...',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      const Category('All', Icons.apps),
      ...kCategories,
    ];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category.name == selectedCategory;
          return ChoiceChip(
            label: Text(category.name),
            selected: selected,
            onSelected: (_) => onCategorySelected(category.name),
            selectedColor: colorScheme.primary,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected ? colorScheme.primary : theme.dividerColor,
              ),
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = selectedCategory == 'All' ? 'Recent Listings' : selectedCategory;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          Text(
            '$count item${count == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
