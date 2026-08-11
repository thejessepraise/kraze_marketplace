import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/categories.dart';
import '../../models/product.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/product_image.dart';

/// The Post Item ("Sell") screen — a student fills this out to list
/// something for sale.
///
/// WHY StatefulWidget:
/// Same reasoning as Login/Signup — this screen owns TextEditingControllers,
/// a loading flag, PLUS two more pieces of state that change while the
/// screen is open: which category chip is selected, and which photo (if
/// any) has been picked from the device.
///
/// WHERE THE NEW LISTING GOES (NO BACKEND YET):
/// There's no database yet, so "posting" an item means adding a new
/// Product straight onto the in-memory `sampleProducts` list from
/// models/product.dart — the exact same list Home already reads from.
/// Home just needs to rebuild after this page closes to pick it up (see
/// home_page.dart's Sell tab handling). Once Firebase is wired in, this is
/// the one spot that changes: instead of `sampleProducts.insert(...)`,
/// _handlePost() will call something like
/// `productService.createListing(...)` and let the real database be the
/// single source of truth.
class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Starts unselected on purpose — forcing a student to actively choose a
  // category (rather than defaulting to the first one) avoids a pile of
  // miscategorized listings from people who just tap "Post" too quickly.
  String? _selectedCategory;

  // Holds the path to the photo the student picked, or null if they
  // haven't picked one yet. XFile (from image_picker) wraps a file on
  // the device — .path is what ProductImage/Image.file need to read it.
  XFile? _pickedImage;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // ImageSource.gallery opens the device's photo library rather than
    // the camera — most listing photos are of an item the student
    // already has, not something they want to photograph right now.
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      // Caps the resolution so a listing photo doesn't balloon into a
      // multi-megabyte file for no visual benefit at the sizes this app
      // actually displays it.
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (picked == null) return; // student backed out of the picker

    setState(() => _pickedImage = picked);
  }

  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;

    // The category selector isn't a Form field, so it needs its own
    // check here rather than a `validator` callback like the text fields.
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // WHERE REAL POSTING GOES:
    // await productService.createListing(...); once a backend exists.
    // For now we just simulate "it worked" after a short pause, the same
    // pattern login_page.dart and signup_page.dart use.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final newProduct = Product(
      // A real id would come from the database. For now, the current
      // timestamp is good enough to be unique among sample data.
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _selectedCategory!,
      // No logged-in user/profile system yet — see auth_service.dart's
      // note about where AuthService.currentUser plugs in once that
      // exists. Hardcoding "You" keeps this page honest about what it
      // actually knows right now.
      sellerName: 'You',
      postedAt: DateTime.now(),
      imageUrl: _pickedImage?.path ?? '',
      description: _descriptionController.text.trim(),
    );

    // Newest listing first, matching how Home's "Recent Listings" title
    // reads.
    marketplaceStore.addProduct(newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing posted!')),
    );

    // Hands `true` back to whoever pushed this page (Home) so it knows a
    // new listing was added and should rebuild its grid.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: const Text('Post an Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          // Same width cap used by Login/Signup, so this form doesn't
          // stretch edge-to-edge on a wide desktop/web window.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildImagePicker(theme, colorScheme),
                    const SizedBox(height: 24),

                    Text(
                      'Item Title',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'e.g. Casio FX-991 Calculator',
                      controller: _titleController,
                      prefixIcon: Icons.sell_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a title for your item';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Price (GH₵)',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'e.g. 45.00',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: '₵ ',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a price';
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null) {
                          return 'Enter a valid number';
                        }
                        if (parsed <= 0) {
                          return 'Price must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Category',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategorySelector(theme, colorScheme),
                    const SizedBox(height: 20),

                    Text(
                      'Description',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint:
                          'Condition, why you\'re selling, pickup details...',
                      controller: _descriptionController,
                      maxLines: 4,
                      borderRadius: 16, // less "pill"-like at this height
                      // Optional on purpose — see Product's description
                      // field comment in models/product.dart. No
                      // validator here means an empty description is
                      // allowed.
                    ),
                    const SizedBox(height: 28),

                    CustomButton(
                      label: 'Post Item',
                      isLoading: _isLoading,
                      onPressed: _handlePost,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The photo picker: a tappable box that shows either "Add Photo" or a
  /// preview of the chosen image, plus a small button to remove it.
  Widget _buildImagePicker(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: _pickedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 36,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add a Photo',
                    style: AppTextStyles.fieldLabel.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ProductImage(imagePath: _pickedImage!.path),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// A horizontally-wrapping row of category choice chips — visually the
  /// same idea as Home's filter chips, but for CHOOSING one value instead
  /// of filtering by one.
  Widget _buildCategorySelector(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kCategories.map((category) {
        final bool selected = category.name == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category.name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? colorScheme.primary : theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? colorScheme.primary : theme.dividerColor,
              ),
            ),
            child: Text(
              category.name,
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
      }).toList(),
    );
  }
}
