import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.name,
    required super.description,
    required super.price,
    super.colorVariants,
    required super.category,
    required super.createdAt,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawVariants = data['colorVariants'] as List<dynamic>? ?? [];
    final colorVariants = rawVariants.map((v) {
      final map = v as Map<String, dynamic>;
      return ColorVariant(
        colorHex: map['colorHex'] ?? '#FFFFFF',
        colorName: map['colorName'] ?? 'Default',
        images: List<String>.from(map['images'] ?? []),
      );
    }).toList();

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      colorVariants: colorVariants,
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      colorVariants: product.colorVariants,
      category: product.category,
      createdAt: product.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'colorVariants': colorVariants
          .map((v) => {
                'colorHex': v.colorHex,
                'colorName': v.colorName,
                'images': v.images,
              })
          .toList(),
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
