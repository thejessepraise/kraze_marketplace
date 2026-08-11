import 'package:flutter/material.dart';

import '../../constants/categories.dart';
import '../../models/product.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/product_grid.dart';

/// The Search screen — reached by tapping the search bar on Home.
///
/// WHY StatefulWidget:
/// This screen needs to remember what the student has typed
/// (TextEditingController) and re-filter the product list every time
/// that text changes — both of those are things that change WHILE the
/// screen is open, which is exactly what State objects are for.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  // FocusNode lets us request the keyboard open automatically the
  // instant this screen appears, so the student can start typing right
  // away without an extra tap.
  final _focusNode = FocusNode();

  String _query = '';

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback runs this AFTER the
    // first frame has been drawn. Requesting focus any earlier (directly
    // in initState) can be unreliable, since the field isn't fully laid
    // out on screen yet at that point.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Products whose title OR category contains the search text
  /// (case-insensitive). Matching on category too means typing
  /// "laptop" finds both a title like "HP Pavilion Laptop" AND anything
  /// tagged with the "Laptops" category.
  List<Product> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return [];

    return sampleProducts.where((product) {
      final title = product.title.toLowerCase();
      final category = product.category.toLowerCase();
      return title.contains(query) || category.contains(query);
    }).toList();
  }

  /// Fills the search field with a tapped category name, as a fast way
  /// to browse by category without typing.
  void _searchCategory(String categoryName) {
    _controller.text = categoryName;
    setState(() => _query = categoryName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            if (!hasQuery)
              SliverToBoxAdapter(child: _buildCategorySuggestions(context))
            else if (_results.isEmpty)
              SliverToBoxAdapter(child: _buildNoResults(context))
            else ...[
              SliverToBoxAdapter(child: _buildResultsHeader(context)),
              ProductGridSliver(products: _results),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  /// Back arrow + text field, laid out like a single search bar row.
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: TextStyle(color: colorScheme.onSurface),
                      // onChanged fires on every keystroke — this is
                      // what makes results update live as you type,
                      // rather than needing a separate "Search" button.
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search textbooks, laptops, phones...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  // The clear ("x") button only appears once something
                  // has been typed — no point showing it on an empty
                  // field.
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shown before the student has typed anything — lets them jump
  /// straight into a category instead of staring at a blank screen.
  Widget _buildCategorySuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Categories',
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 15,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kCategories.map((category) {
              return GestureDetector(
                onTap: () => _searchCategory(category.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// "3 results for 'laptop'" — confirms to the student what they're
  /// looking at before the grid below it.
  Widget _buildResultsHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = _results.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text(
        '$count result${count == 1 ? '' : 's'} for "$_query"',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$_query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different word, or browse by category instead.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
