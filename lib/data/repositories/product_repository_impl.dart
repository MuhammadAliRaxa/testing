import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Product>> getProducts() {
    return remoteDataSource.getProducts();
  }

  @override
  Future<void> addProduct(Product product) {
    final model = ProductModel.fromEntity(product);
    return remoteDataSource.addProduct(model);
  }

  @override
  Future<void> updateProduct(Product product) {
    final model = ProductModel.fromEntity(product);
    return remoteDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) {
    return remoteDataSource.deleteProduct(id);
  }
}
