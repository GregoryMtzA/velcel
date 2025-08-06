import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/inventory/domain/entities/category_inventory_entity.dart';
import 'package:velcel/features/inventory/domain/entities/product_inventory_entity.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_altas_inventory_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {

  InventoryRepository inventoryRepository;


  InventoryProvider({
    required this.inventoryRepository,
  });

  List<CategoryInventoryEntity> categories = [];
  List<ProductInventoryEntity> products = [];
  List<String> imeis = [];

  /// Categoría Seleccionada
  CategoryInventoryEntity? _selectedCategory;
  CategoryInventoryEntity? get selectedCategory => _selectedCategory;
  set selectedCategory(CategoryInventoryEntity? value) {
    _selectedCategory = value;
  }

  Future<Either<String, List<CategoryInventoryEntity>>> getCategories() async {

    Either<Failure, List<CategoryInventoryEntity>> usecase = await inventoryRepository.getAllCategories();

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        categories = r;
        notifyListeners();
        return Right(categories);
      },
    );

  }

  Future<Either<String, List<ProductInventoryEntity>>> getProducts(String sucursal) async {

    Either<Failure, List<ProductInventoryEntity>> usecase = await inventoryRepository.getProducts(sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        products = r;
        notifyListeners();
        return Right(products);
      },
    );

  }

  Future<Either<String, void>> getProductsWithCategory(String sucursal, String categoria) async {

    Either<Failure, List<ProductInventoryEntity>> usecase = await inventoryRepository.getProductsWithCategory(categoria, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        products = r;
        notifyListeners();
        return Right(null);
      },
    );

  }

  Future<Either<String, void>> getProductsWithName(String nombre, String sucursal) async {

    Either<Failure, List<ProductInventoryEntity>> usecase = await inventoryRepository.getProductsWithName(nombre, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        products = r;
        notifyListeners();
        return Right(null);
      },
    );

  }

  Future<void> getImeis(String nombre) async {

    final usecase = await inventoryRepository.getImeis(nombre);

    usecase.fold(
      (l) {

      },
      (r) {
        imeis = r;
        notifyListeners();
      },
    );

  }

  Future<Either<String, List<ProductAltasInventoryEntity>>> getProductsAltasWithDate(DateTime fechaA, DateTime fechaB, String sucursal) async {

    Either<Failure, List<ProductAltasInventoryEntity>> usecase = await inventoryRepository.getProductsAltasWithDate(fechaA, fechaB, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        return Right(r);
      },
    );

  }

  Future<Either<String, List<ProductAltasInventoryEntity>>> getProductsBajasWithDate(DateTime fechaA, DateTime fechaB, String sucursal) async {

    Either<Failure, List<ProductAltasInventoryEntity>> usecase = await inventoryRepository.getProductsBajasWithDate(fechaA, fechaB, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        return Right(r);
      },
    );

  }

}