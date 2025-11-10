import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/inventory/data/models/category_inventory_model.dart';
import 'package:velcel/features/inventory/domain/entities/category_inventory_entity.dart';
import 'package:velcel/features/inventory/domain/entities/product_altas_inventory_entity.dart';
import 'package:velcel/features/inventory/domain/entities/product_inventory_entity.dart';
import 'package:velcel/features/inventory/domain/repositories/inventory_repository.dart';

import '../models/product_altas_inventory_model.dart';
import '../models/product_inventory_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {

  final Future<MySqlConnection> Function() createConnection;


  InventoryRepositoryImpl({
    required this.createConnection,
  });


  String fechaFormateada(DateTime fecha){
    return DateFormat('yyyy-MM-dd').format(fecha.toUtc());
  }

  @override
  Future<Either<Failure, List<CategoryInventoryEntity>>> getAllCategories() async {

    final mysql = await createConnection();

    try {
      print("OBTENIENDO CATEGORIAS");

      Results results = await mysql.query("SELECT categoria FROM categorias", []);

      List<CategoryInventoryEntity> categories = [];

      for (var result in results) {
        CategoryInventoryEntity category = CategoryInventoryModel.fromJson(result.fields);
        categories.add(category);
      }

      return Right(categories);

    } on MySqlException catch (e) {
      print(e);
      return Left(ServerFailure(message: 'Contacte a soporte'));
    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ProductInventoryEntity>>> getProducts(String sucursal) async {
    final mysql = await createConnection();

    try {

      final List<ProductInventoryEntity> products = [];
      int offset = 0;
      const int limit = 100;

      while (true) {

        Results results = await mysql.query(
          '''
            SELECT p.categoria, p.nombre, a.disponibles, p.descripcion
            FROM productos p
            JOIN almacenaje a ON p.nombre = a.nombre
            WHERE a.sucursal = ?
            LIMIT ?, ?
          ''',
          [sucursal, offset, limit],
        );

        if (results.isEmpty) break;

        for (var row in results) {
          final product = ProductInventoryModel.fromJson(row.fields);
          products.add(product);
        }

        // Si trajo menos que el límite, ya no hay más datos
        if (results.length < limit) {
          break;
        }

        offset += limit; // avanzar al siguiente bloque
      }

      return Right(products);

    } on MySqlException catch (e) {
      print(e);
      return Left(ServerFailure(message: "Contacte a soporte"));
    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ProductAltasInventoryEntity>>> getProductsAltasWithDate(DateTime fechaA, DateTime fechaB, String sucursal) async {
    final mysql = await createConnection();

    try {

      String fechaA_Formatted = fechaFormateada(fechaA);
      String fechaB_Formatted = fechaFormateada(fechaB);

      List<ProductAltasInventoryEntity> products = [];

      Results results = await mysql.query(
        '''SELECT nombre, sucursal, cantidad, fecha FROM altas WHERE (fecha BETWEEN ? AND ?) AND sucursal = ?''',
        [fechaA_Formatted, fechaB_Formatted, sucursal]
      );

      for (var result in results){
        ProductAltasInventoryEntity product = ProductAltasInventoryModel.fromJson(result.fields);
        products.add(product);
      }

      return Right(products);

    } on MySqlException catch (e) {

      print(e);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ProductAltasInventoryEntity>>> getProductsBajasWithDate(DateTime fechaA, DateTime fechaB, String sucursal) async {
    final mysql = await createConnection();

    try {

      String fechaA_Formatted = fechaFormateada(fechaA);
      String fechaB_Formatted = fechaFormateada(fechaB);

      List<ProductAltasInventoryEntity> products = [];

      Results results = await mysql.query(
        '''SELECT nombre, sucursal, cantidad, motivo, fecha FROM bajas WHERE (fecha BETWEEN ? AND ?) AND sucursal = ?''',
        [fechaA_Formatted, fechaB_Formatted, sucursal]
      );

      for (var result in results){
        ProductAltasInventoryEntity product = ProductAltasInventoryModel.fromJson(result.fields);
        products.add(product);
      }

      return Right(products);

    } on MySqlException catch (e) {

      print(e);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
       await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ProductInventoryEntity>>> getProductsWithCategory(String categoria, String sucursal) async {
    final mysql = await createConnection();

    try {
      print("Buscando productos por categoria");

      List<ProductInventoryEntity> products = [];

      Results results = await mysql.query(
        '''SELECT p.categoria, p.nombre, a.disponibles, p.descripcion
          FROM productos p
          JOIN almacenaje a ON p.nombre = a.nombre
          WHERE p.categoria = ? AND a.sucursal = ?
          ORDER BY p.categoria''',
        [categoria, sucursal]
      );

      for (var result in results){
        ProductInventoryEntity product = ProductInventoryModel.fromJson(result.fields);
        products.add(product);
      }

      return Right(products);

    } on MySqlException catch (e) {
      print(e);
      return Left(ServerFailure(message: "Contacte a soporte"));
    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ProductInventoryEntity>>> getProductsWithName(String nombre, String sucursal) async {
    final mysql = await createConnection();

    try {
      print("Buscando productos por nombre");

      List<ProductInventoryEntity> products = [];

      Results results = await mysql.query(
          '''SELECT p.categoria, p.nombre, a.disponibles, p.descripcion
            FROM productos p
            JOIN almacenaje a ON p.nombre = a.nombre
            WHERE p.nombre LIKE ? AND a.sucursal = ?
            ORDER BY p.categoria''',
          ["%${nombre}%", sucursal]
      );

      for (var result in results){
        ProductInventoryEntity product = ProductInventoryModel.fromJson(result.fields);
        products.add(product);
      }

      return Right(products);

    } on MySqlException catch (e) {
      print(e);
      return Left(ServerFailure(message: "Contacte a soporte"));
    } finally{
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<String>>> getImeis(String modelo) async {
    final mysql = await createConnection();

    try {

      List<String> imeis = [];

      Results results = await mysql.query('''SELECT imei FROM imeis WHERE nombre=?''', [modelo]);

      for (var result in results) {
        String imei = result["imei"];
        imeis.add(imei);
      }

      return Right(imeis);

    } on MySqlException catch(e) {
      return Left(ServerFailure(message: "Contacte a soporte"));
    } finally {
      await mysql.close();
    }

  }


}