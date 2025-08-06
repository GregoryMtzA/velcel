import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/domain/repositories/products_repository.dart';
import 'package:velcel/features/store/domain/requests/venta_request.dart';
import 'package:velcel/features/store/domain/response/venta_response.dart';

class ProductsRepositoryImpl implements ProductsRepository{

  final Future<MySqlConnection> Function() createConnection;

  ProductsRepositoryImpl({
    required this.createConnection,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String name, String branchType) async {
    final mysql = await createConnection();
    try{

      // await mysqlConnect();

      Results results = await mysql.query('''SELECT nombre, categoria, precio, precioex, imagen, rimei, descripcion  FROM productos WHERE nombre LIKE ? ORDER BY nombre''', ["%${name}%"]);
      List<ProductEntity> productsEntity = [];

      for(var result in results){
        productsEntity.add(ProductEntity(
            name: result["nombre"],
            description: result["descripcion"],
            price: branchType == "Normal" ? result["precio"] : result["precioex"],
            image: Uint8List.fromList((result["imagen"] as Blob).toBytes()),
            rimei: result["rimei"] == 1 ? true : false,
            category: result["categoria"]
          )
        );
      }

      // await mysql.close();
      return Right(productsEntity);

    } on MySqlException catch(e){

      // await mysql.close();
      return Left(ServerFailure(message: e.message));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, int>> checkStock(String name, String sucursal) async {
    final mysql = await createConnection();
    try{

      // await mysqlConnect();

      Results results = await mysql.query('''SELECT disponibles FROM almacenaje WHERE nombre=? AND sucursal=?''', [name, sucursal]);

      if (results.isEmpty) return Left(ServerFailure(message: "No disponible en la sucursal"));

      if (results.first["disponibles"] == 0) return Left(ServerFailure(message: "No hay stock"));

      int stock = results.first["disponibles"];

      // await mysql.close();
      return Right(stock);

    } on MySqlException catch(e){

      // await mysql.close();
      return Left(ServerFailure(message: e.message));

    } finally {
      print("cerrando conexion");
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, bool>> verifyImei(String producto, String imei) async {
    final mysql = await createConnection();
    try{

      // await mysqlConnect();

      Results results = await mysql.query('''SELECT nombre FROM imeis WHERE nombre=? AND imei=?''', [producto, imei]);

      if (results.isEmpty) return const Right(false);

      // await mysql.close();

      return const Right(true);

    } on MySqlException catch(e){

      // await mysql.close();
      return Left(ServerFailure(message: e.message));

    } finally{
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, VentaResponse>> generarVenta(VentaRequest vr) async {
    final mysql = await createConnection();
    try{


      // await mysqlConnect();

      var uuid = const Uuid();

      String uuidString = uuid.v4();

      if (vr.credito == "No"){

        await mysql.transaction((transaction) async {

          await mysql.query('''CALL proCrearVenta(?,?,?,?,?,?,?,?,?,?, @foliox, @fechax);''',
              [vr.total, vr.metodo, vr.sucursal, vr.usuario, uuidString, vr.idCorte, vr.credito ,vr.nombres.join(","),
                vr.cantidades.join(","), vr.imeis?.join(",")]);

        },);

      } else {

        await mysql.transaction((transaction) async {

          await mysql.query('''CALL proCrearVentaPayjoi(?,?,?,?,?,?,?,?,?,?, @foliox, @fechax,?,?,?)''',
            [vr.total, vr.metodo, vr.sucursal, vr.usuario, uuidString, vr.idCorte, vr.credito, vr.nombres.join(","),
              vr.cantidades.join(","), vr.imeis?.join(","), vr.nombreC, vr.telefonoC, vr.domicilioC]);

        },);

      }

      Results results = await mysql.query('''SELECT @foliox, @fechax''');


      Uint8List binaria = Uint8List.fromList((results.first["@fechax"] as Blob).toBytes());
      String fechaString = utf8.decode(binaria);
      DateTime fecha = DateTime.parse(fechaString);

      int folio = results.first["@foliox"];

      // await mysql.close();

      return Right(VentaResponse(fecha: fecha, venta: folio));

    } on MySqlException catch(e){
      // await mysql.close();
      return Left(ServerFailure(message: e.message));

    } finally {
      await mysql.close();
    }

  }

}