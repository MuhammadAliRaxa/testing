import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  ProductRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  Stream<List<ProductModel>> getProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromSnapshot(doc))
            .toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _productsCollection.add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}
