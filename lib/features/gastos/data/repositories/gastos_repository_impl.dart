import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/features/gastos/data/models/gasto_model.dart';
import 'package:velcel/features/gastos/data/models/tipo_gasto_model.dart';
import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';
import 'package:velcel/features/gastos/domain/repositories/gastos_repository.dart';

import '../../../../core/errors/failures.dart';

class GastosRepositoryImpl implements GastosRepository {

  final Future<MySqlConnection> Function() createConnection;

  GastosRepositoryImpl({
    required this.createConnection
  });


  @override
  Future<Either<Failure, List<TipoGastoEntity>>> GetAllTipoGastos() async {
    final mysql = await createConnection();
    print("Obteniendo GASTOS");

    try {
      List<TipoGastoEntity> tiposGastos = [];

      Results results = await mysql.query(
        "SELECT tipogasto FROM tiposgastos", []
      );

      for (var result in results) {
        TipoGastoEntity gasto = TipoGastoModel.fromJson(result.fields);
        tiposGastos.add(gasto);
      }

      return Right(tiposGastos);


    } on MySqlException catch(e){

      print(e.message);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, bool>> verificarFolio(int folio, String sucursal) async {
    final mysql = await createConnection();
    try {

      Results results = await mysql.query(
        "SELECT folio FROM reportesventas WHERE folio=? AND sucursal=?",
        [folio, sucursal]
      );

      bool valid = results.isNotEmpty;

      return Right(valid);

    } on MySqlException catch (e) {

      print(e.message);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, void>> crearSolGasto(String tipo, double importe, String sucursal, String usuario, int corte, int folioVenta) async {
    final mysql = await createConnection();
    try {

      Results results = await mysql.query(
        "INSERT INTO gastos (fecha, tipogasto, importe, sucursal, usuario, corte, folioventas) VALUES(CURRENT_TIMESTAMP(), ?, ?, ?, ?, ?, ?)",
        [tipo, importe, sucursal, usuario, corte, folioVenta]
      );

      return Right(null);

    } on MySqlException catch (e) {

      print(e.message);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<GastoEntity>>> obtenerGastosPorFolio(int folio, String sucursal) async {
    final mysql = await createConnection();
    try {

      List<GastoEntity> gastos = [];

      Results results = await mysql.query(
        "SELECT tipogasto, importe, fecha, folioventas FROM gastos WHERE folioventas=? AND sucursal=?",
        [folio, sucursal]
      );

      for (var result in results) {
        GastoEntity gasto = GastoModel.fromJson(result.fields);
        gastos.add(gasto);
      }

      return Right(gastos);

    } on MySqlException catch (e) {

      print(e.message);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<GastoEntity>>> obtenerGastosPorTipo(String tipo, String sucursal) async {
    final mysql = await createConnection();
    try {

      List<GastoEntity> gastos = [];

      Results results = await mysql.query(
          "SELECT tipogasto, importe, fecha, folioventas FROM gastos WHERE tipogasto=? AND sucursal=?",
          [tipo, sucursal]
      );

      for (var result in results) {
        GastoEntity gasto = GastoModel.fromJson(result.fields);
        gastos.add(gasto);
      }

      return Right(gastos);

    } on MySqlException catch (e) {

      print(e.message);
      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }





}