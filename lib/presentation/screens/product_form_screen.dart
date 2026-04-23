import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isSaving = false;

  // Color variants state
  List<_ColorVariantEntry> _colorEntries = [];

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Food',
    'Books',
    'Home',
    'Sports',
    'Other',
  ];

  // Preset colors for quick picking
  final List<Map<String, String>> _presetColors = [
    {'name': 'Red', 'hex': '#E53935'},
    {'name': 'Blue', 'hex': '#1E88E5'},
    {'name': 'Green', 'hex': '#43A047'},
    {'name': 'Black', 'hex': '#212121'},
    {'name': 'White', 'hex': '#FAFAFA'},
    {'name': 'Yellow', 'hex': '#FDD835'},
    {'name': 'Purple', 'hex': '#8E24AA'},
    {'name': 'Orange', 'hex': '#FB8C00'},
    {'name': 'Pink', 'hex': '#D81B60'},
    {'name': 'Grey', 'hex': '#757575'},
    {'name': 'Brown', 'hex': '#6D4C41'},
    {'name': 'Teal', 'hex': '#00897B'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
        text: widget.product != null ? widget.product!.price.toString() : '');
    _categoryController =
        TextEditingController(text: widget.product?.category ?? _categories[0]);

    // Load existing color variants
    if (widget.product != null && widget.product!.colorVariants.isNotEmpty) {
      _colorEntries = widget.product!.colorVariants
          .map((v) => _ColorVariantEntry(
                colorHex: v.colorHex,
                colorName: v.colorName,
                imageUrls: List<String>.from(v.images),
              ))
          .toList();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                            AppTheme.secondaryColor.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isEditing
                            ? Icons.edit_rounded
                            : Icons.add_shopping_cart_rounded,
                        size: 36,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.isEditing
                          ? 'Update product details'
                          : 'Fill in the product details',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name
                  _buildLabel('Product Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Enter product name',
                      prefixIcon: Icon(Icons.label_outline_rounded,
                          color: AppTheme.textSecondary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter product description',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.description_outlined,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Price
                  _buildLabel('Price (\$)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money_rounded,
                          color: AppTheme.textSecondary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }
                      final price = double.tryParse(value.trim());
                      if (price == null || price < 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Category
                  _buildLabel('Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _categories.contains(_categoryController.text)
                        ? _categoryController.text
                        : _categories[0],
                    dropdownColor: AppTheme.cardColor,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 16),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined,
                          color: AppTheme.textSecondary),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _categoryController.text = value;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Color Variants Section ──
                  _buildSectionHeader(
                    'Color Variants',
                    'Add colors and images for each color',
                    Icons.palette_outlined,
                  ),
                  const SizedBox(height: 16),

                  // List of added colors
                  ..._colorEntries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final colorEntry = entry.value;
                    return _buildColorVariantCard(idx, colorEntry);
                  }),

                  // Add Color Button
                  InkWell(
                    onTap: _showAddColorDialog,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add Color Variant',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Save Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.5),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Update Product'
                                  : 'Add Product',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Header ──

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Color Variant Card ──

  Widget _buildColorVariantCard(int index, _ColorVariantEntry entry) {
    final color = _parseColor(entry.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.colorName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${entry.imageUrls.length} image${entry.imageUrls.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() => _colorEntries.removeAt(index));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.errorColor, size: 16),
                ),
              ),
            ],
          ),

          // Image Thumbnails
          if (entry.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: entry.imageUrls.length + 1,
                itemBuilder: (context, imgIdx) {
                  if (imgIdx == entry.imageUrls.length) {
                    // Add image button
                    return _buildAddImageTile(index);
                  }
                  return _buildImageThumbnail(index, imgIdx, entry.imageUrls[imgIdx]);
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [_buildAddImageTile(index)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(int colorIdx, int imgIdx, String url) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.broken_image,
                    color: AppTheme.textSecondary, size: 20),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: () {
                setState(() {
                  _colorEntries[colorIdx].imageUrls.removeAt(imgIdx);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageTile(int colorIdx) {
    return InkWell(
      onTap: () => _showAddImageDialog(colorIdx),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppTheme.primaryColor, size: 22),
            SizedBox(height: 2),
            Text('Add',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──

  void _showAddColorDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose a Color',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presetColors.map((preset) {
                  final alreadyAdded = _colorEntries
                      .any((e) => e.colorHex == preset['hex']);
                  return GestureDetector(
                    onTap: alreadyAdded
                        ? null
                        : () {
                            setState(() {
                              _colorEntries.add(_ColorVariantEntry(
                                colorHex: preset['hex']!,
                                colorName: preset['name']!,
                                imageUrls: [],
                              ));
                            });
                            Navigator.of(ctx).pop();
                          },
                    child: Opacity(
                      opacity: alreadyAdded ? 0.3 : 1.0,
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _parseColor(preset['hex']!),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _parseColor(preset['hex']!)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: alreadyAdded
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset['name']!,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddImageDialog(int colorIdx) {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Image for ${_colorEntries[colorIdx].colorName}',
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        content: TextField(
          controller: urlController,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Paste image URL here',
            prefixIcon:
                Icon(Icons.link_rounded, color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _colorEntries[colorIdx].imageUrls.add(url);
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<ProductProvider>();

    final colorVariants = _colorEntries
        .map((e) => ColorVariant(
              colorHex: e.colorHex,
              colorName: e.colorName,
              images: e.imageUrls,
            ))
        .toList();

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      colorVariants: colorVariants,
      category: _categoryController.text.trim(),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.isEditing) {
      success = await provider.updateProduct(product);
    } else {
      success = await provider.addProduct(product);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Product updated successfully!'
                : 'Product added successfully!',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

// ── Mutable helper class for form state ──

class _ColorVariantEntry {
  String colorHex;
  String colorName;
  List<String> imageUrls;

  _ColorVariantEntry({
    required this.colorHex,
    required this.colorName,
    required this.imageUrls,
  });
}
