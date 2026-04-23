import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Stream<List<Product>> call() {
    return repository.getProducts();
  }
}
