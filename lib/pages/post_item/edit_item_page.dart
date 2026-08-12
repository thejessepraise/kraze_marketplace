import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/categories.dart';
import '../../models/product.dart';
import '../../services/app_error.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/product_image.dart';

class EditItemPage extends StatefulWidget {
  final Product product;
  const EditItemPage({super.key, required this.product});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  String? _selectedCategory;
  XFile? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _selectedCategory = widget.product.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 60,
    );
    if (picked == null) return;
    setState(() => _pickedImage = picked);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    setState(() => _isLoading = true);

    try {
      await marketplaceStore.updateListing(
        productId: widget.product.id,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        imageFile: _pickedImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated!')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(theme, colorScheme),
                    const SizedBox(height: 24),
                    CustomTextField(
                      hint: 'Item Title',
                      controller: _titleController,
                      validator: (v) => v?.isEmpty ?? true ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Price (GH₵)',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(theme, colorScheme),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Description',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Save Changes',
                      isLoading: _isLoading,
                      onPressed: _handleUpdate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: _pickedImage == null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ProductImage(imagePath: widget.product.imageUrl),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ProductImage(imagePath: _pickedImage!.path),
              ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      children: kCategories.map((c) {
        final selected = c.name == _selectedCategory;
        return ChoiceChip(
          label: Text(c.name),
          selected: selected,
          onSelected: (_) => setState(() => _selectedCategory = c.name),
        );
      }).toList(),
    );
  }
}
