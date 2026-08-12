import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/categories.dart';
import '../../services/app_error.dart';
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
/// WHERE THE NEW LISTING GOES:
/// _handlePost() calls marketplaceStore.createListing(), which uploads
/// the photo to Firebase Storage (if one was picked), then writes the
/// listing to the `products` collection in Firestore. Home's live
/// Firestore listener picks up the new document automatically — no
/// manual refresh needed.
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

  String? _selectedCategory;
  String _selectedCondition = 'Good';

  // Holds the path to the photo the student picked, or null if they
  // haven't picked one yet. XFile (from image_picker) wraps a file on
  // the device — .path is what ProductImage/Image.file need to read it.
  XFile? _pickedImage;

  bool _isLoading = false;

  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair'];

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
      // Optimized for high quality while ensuring the Base64 string 
      // stays well within Firestore's 1MB document limit.
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 60,
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

    try {
      final cleanPrice = _priceController.text.trim().replaceAll(',', '');
      await marketplaceStore.createListing(
        title: _titleController.text.trim(),
        price: double.parse(cleanPrice),
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        condition: _selectedCondition,
        imageFile: _pickedImage,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(error))));
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

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
                        signed: false,
                      ),
                      prefixText: '₵ ',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a price';
                        }
                        final cleanValue = value.trim().replaceAll(',', '');
                        final parsed = double.tryParse(cleanValue);
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
                      'Condition',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildConditionSelector(theme, colorScheme),
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
                      keyboardType: TextInputType.multiline,
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

  Widget _buildConditionSelector(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      children: _conditions.map((condition) {
        final selected = _selectedCondition == condition;
        return ChoiceChip(
          label: Text(condition),
          selected: selected,
          onSelected: (_) => setState(() => _selectedCondition = condition),
          selectedColor: colorScheme.primary,
          labelStyle: TextStyle(
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        );
      }).toList(),
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
