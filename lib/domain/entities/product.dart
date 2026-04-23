class ColorVariant {
  final String colorHex;
  final String colorName;
  final List<String> images;

  const ColorVariant({
    required this.colorHex,
    required this.colorName,
    this.images = const [],
  });

  ColorVariant copyWith({
    String? colorHex,
    String? colorName,
    List<String>? images,
  }) {
    return ColorVariant(
      colorHex: colorHex ?? this.colorHex,
      colorName: colorName ?? this.colorName,
      images: images ?? this.images,
    );
  }
}

class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final List<ColorVariant> colorVariants;
  final String category;
  final DateTime createdAt;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.colorVariants = const [],
    required this.category,
    required this.createdAt,
  });

  /// All images across all color variants
  List<String> get allImages =>
      colorVariants.expand((v) => v.images).toList();

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<ColorVariant>? colorVariants,
    String? category,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      colorVariants: colorVariants ?? this.colorVariants,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
