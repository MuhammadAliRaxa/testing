import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/add_product.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency injection
    final dataSource = ProductRemoteDataSource();
    final repository = ProductRepositoryImpl(remoteDataSource: dataSource);

    return ChangeNotifierProvider(
      create: (_) => ProductProvider(
        getProducts: GetProducts(repository),
        addProduct: AddProduct(repository),
        updateProduct: UpdateProduct(repository),
        deleteProduct: DeleteProduct(repository),
      ),
      child: MaterialApp(
        title: 'Product Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ProductListScreen(),
      ),
    );
  }
}
