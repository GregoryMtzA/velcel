import 'package:dartz/dartz.dart';
import 'package:velcel/features/inventory/domain/entities/category_inventory_entity.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_altas_inventory_entity.dart';
import '../entities/product_inventory_entity.dart';

abstract class InventoryRepository {

  Future<Either<Failure, List<ProductInventoryEntity>>> getProducts(String sucursal);
  Future<Either<Failure, List<CategoryInventoryEntity>>> getAllCategories();
  Future<Either<Failure, List<ProductInventoryEntity>>> getProductsWithName(String nombre, String sucursal);
  Future<Either<Failure, List<ProductInventoryEntity>>> getProductsWithCategory(String categoria, String sucursal);
  Future<Either<Failure, List<ProductAltasInventoryEntity>>> getProductsAltasWithDate(DateTime fechaA, DateTime fechaB, String sucursal);
  Future<Either<Failure, List<ProductAltasInventoryEntity>>> getProductsBajasWithDate(DateTime fechaA, DateTime fechaB, String sucursal);
  Future<Either<Failure, List<String>>> getImeis(String modelo);

}