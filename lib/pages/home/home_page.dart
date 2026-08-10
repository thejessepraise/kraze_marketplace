import 'package:flutter/material.dart';
import '../../constants/categories.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../product_detail/product_detail_page.dart';
import '../post_item/post_item_page.dart';

/// The Home Page: the first screen a logged-in student sees.
///
/// WHY StatefulWidget (not StatelessWidget like ProductCard):
/// This page needs to REMEMBER two things that change while the user is on
/// it: which bottom-nav tab is selected, and which category filter is
/// selected. Whenever something needs to change and have the screen
/// redraw itself, it needs to live inside a State object — that's exactly
/// what StatefulWidget gives us.
///
/// NOTE ON COLORS:
/// Colors here are read from Theme.of(context) rather than typed directly
/// as AppColors.xxx. This just means every color ultimately traces back to
/// the single darkTheme defined in theme/dark_theme.dart — so if you
/// tweak that one file, this whole page updates automatically. Because this
/// is a State class, `context` is already available as a property on
/// `this` inside any method, which is why the helper methods below don't
/// need a `context` parameter added.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0; // which bottom-nav tab is active
  String _selectedCategory = 'All'; // which category chip is active

  @override
  Widget build(BuildContext context) {
    // Filter the sample list based on the selected category.
    // WHY HERE, NOT A SEPARATE FUNCTION FILE:
    // This filtering is simple and only used by this page, so keeping it in
    // build() is easier to follow for now. If it grows more complex later,
    // we'd move it into product_service.dart.
    final List<Product> displayedProducts = _selectedCategory == 'All'
        ? sampleProducts
        : sampleProducts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      // No explicit backgroundColor here anymore — Scaffold automatically
      // uses theme.scaffoldBackgroundColor from whichever theme is active,
      // so this ONE line change (removing a hardcoded color) is what makes
      // the whole page background switch between modes correctly.
      body: SafeArea(
        // CustomScrollView + Slivers let us mix different scrolling
        // sections (a header, a horizontal category list, and a grid) into
        // ONE smooth scroll, instead of nesting separate scrollable widgets
        // inside each other (which Flutter doesn't allow without extra
        // workarounds).
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildCategoryRow()),
            SliverToBoxAdapter(child: _buildSectionTitle('Recent Listings')),
            _buildProductGrid(displayedProducts),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) {
          // Sell (index 2) isn't really a "tab" the way Home/Favorites/
          // Chat/Profile are — it's an action that opens a new screen on
          // top of whichever tab you're already on. So instead of
          // switching _navIndex to 2 (which would leave that tab looking
          // permanently "selected" afterwards), we push Post Item and
          // leave the currently-selected tab exactly as it was.
          if (index == 2) {
            _openPostItem();
            return;
          }

          // setState tells Flutter "data changed, please redraw the screen."
          // Without calling setState, changing _navIndex would update the
          // variable but the screen would NOT visually update.
          setState(() => _navIndex = index);
        },
      ),
    );
  }

  /// Opens Post Item and, if the student actually posted something
  /// (PostItemPage pops with `true`), rebuilds this screen so the new
  /// listing shows up immediately.
  ///
  /// WHY setState(() {}) IS ENOUGH HERE:
  /// sampleProducts is a single shared list (see models/product.dart) —
  /// PostItemPage adds directly to it. So by the time we're back here,
  /// the data already includes the new listing; we just need Flutter to
  /// re-run build() so `displayedProducts` picks it up on the next read.
  Future<void> _openPostItem() async {
    final posted = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PostItemPage()));

    if (posted == true && mounted) {
      setState(() {});
    }
  }

  /// App name + dark mode toggle + notification bell + profile avatar.
  Widget _buildTopBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kraze\nMarketplace',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          Row(
            children: [
              Icon(Icons.notifications_none, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.person, color: colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The search input (visual only for now — no logic yet, that's the
  /// Search page's job).
  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal scrollable row of category filter chips.
  Widget _buildCategoryRow() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // We build a list that starts with "All" followed by every real
    // category, so students can reset the filter easily.
    final allNames = ['All', ...kCategories.map((c) => c.name)];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: allNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = allNames[index];
          final bool selected = name == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = name),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? colorScheme.primary : theme.dividerColor,
                ),
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// A simple section heading, e.g. "Recent Listings".
  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  /// The 2-column grid of product cards.
  ///
  /// WHY SliverGrid (not a plain GridView):
  /// Because this grid lives inside a CustomScrollView (see build() above),
  /// it must be a "sliver" version of the grid so it can share ONE scroll
  /// position with the header and category row above it, rather than
  /// having its own separate, nested scroll area.
  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Text(
              'No items in this category yet.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.72, // controls card width-to-height ratio
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(
                    product: product,
                    onFavoriteTap: () {
                      // Will call favorites_service.dart once that exists.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to favorites')),
                      );
                    },
                  ),
                ),
              );
            },
            onFavoriteTap: () {
              // Will call favorites_service.dart once that exists.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          );
        }, childCount: products.length),
      ),
    );
  }
}
