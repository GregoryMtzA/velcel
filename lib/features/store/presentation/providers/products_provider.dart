import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/store/domain/repositories/products_repository.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';

class ProductsProvider extends ChangeNotifier {

  ProductsRepository productsRepository;

  ProductsProvider({
    required this.productsRepository
  });

  List<ProductEntity> products = [];

  Future<Either<String, List<ProductEntity>>> searchProductWithName(String name, String branchType) async {

    Either<Failure, List<ProductEntity>> usecase = await productsRepository.searchProducts(name, branchType);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (newProducts) {
        products = newProducts;
        notifyListeners();
        return Right(products);
      },
    );

  }

}