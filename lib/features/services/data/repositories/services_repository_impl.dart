import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/features/services/data/models/service_model.dart';
import 'package:velcel/features/services/domain/entities/service_entity.dart';
import 'package:velcel/features/services/domain/repositories/services_repository.dart';
import 'package:velcel/features/services/domain/requests/service_request.dart';

import '../../../../core/errors/failures.dart';

class ServicesRepositoryImpl implements ServicesRepository {

  final Future<MySqlConnection> Function() createConnection;


  ServicesRepositoryImpl({
    required this.createConnection
  });

  String fechaFormateada(DateTime fecha){
    return DateFormat('yyyy-MM-dd').format(fecha.toUtc());
  }

  @override
  Future<Either<Failure, ServiceEntity>> createService(ServiceRequest sr) async {
    final mysql = await createConnection();
    try {
      String estado = "Pendiente";
      late DateTime fecha;

      late Results results;

      await mysql.transaction((transaction) async {

        Results _fechaResult = await mysql.query("SELECT CURRENT_TIMESTAMP() as fecha;", []);
        fecha = _fechaResult.first["fecha"];
        String fechaStringinicio = fechaFormateada(fecha);
        String fechaStringFinal = fechaFormateada(sr.fechaSal);

        Results _createService = await mysql.query('''INSERT INTO servicios
        (cliente, telefono, marca, modelo, serie, imei, desccorta, fecharec, fallarep, observlleg, sucursal, usuarioabre, estado, fechasal)
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''', [sr.cliente, sr.telefono, sr.marca, sr.modelo, sr.serie, sr.imei, sr.descCorta, fechaStringinicio,
              sr.fallaRep, sr.observLleg, sr.sucursal, sr.usuarioAbre, estado, fechaStringFinal]
        );

        results = await mysql.query('''SELECT folio from servicios where
         cliente=? AND sucursal=? AND telefono=? AND fecharec=? AND marca=? AND modelo=? AND serie=?  AND imei=?  AND desccorta=?
         AND fallarep=? AND observlleg=? AND usuarioabre=? AND estado=? AND fechasal=?''',
            [sr.cliente, sr.sucursal, sr.telefono, fechaStringinicio, sr.marca, sr.modelo, sr.serie, sr.imei, sr.descCorta,
              sr.fallaRep, sr.observLleg, sr.usuarioAbre, estado, fechaStringFinal]
        );

      },);

      ServiceEntity serviceEntity = ServiceEntity(
          folio: results.first["folio"],
          cliente: sr.cliente,
          telefono: sr.telefono,
          marca: sr.marca,
          modelo: sr.modelo,
          serie: sr.serie,
          imei: sr.imei,
          descCorta: sr.descCorta,
          fechaRec: fecha,
          fechaSal: sr.fechaSal,
          fallaRep: sr.fallaRep,
          observLleg: sr.observLleg,
          sucursal: sr.sucursal,
          usuarioAbre: sr.usuarioAbre,
          estado: estado,
      );

      return Right(serviceEntity);
    } catch (e){
      print(e);
      return Left(ServerFailure(message: "Contacte a soporte"));
    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesWithState(String estado, String sucursal) async {
    final mysql = await createConnection();
    print("obteniendo servicios");

    try {

      Results results = await mysql.query(
          '''SELECT * FROM servicios where estado=? AND sucursal=?''',
          [estado, sucursal]
      );

      List<ServiceModel> models = [];

      for (var result in results){
        ServiceModel serviceModel = ServiceModel.fromJson(result.fields);
        models.add(serviceModel);
      }

      return Right(models);

    } catch (e) {
      print(e);
      return Left(ServerFailure(message: e.toString()));
    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, void>> updateService(String observSal, String estado, int folio, String usuario) async {
    final mysql = await createConnection();
    try {

      if (estado != "Entregado") {
        Results results = await mysql.query(
            "UPDATE servicios SET observsal=?, estado=?, usuariocierra=? WHERE folio=?",
            [observSal, estado, usuario, folio]
        );
      }
      else {
        Results _fechaResult = await mysql.query("SELECT CURRENT_TIMESTAMP() as fecha;");
        DateTime fecha = _fechaResult.first["fecha"];
        String fechaStringFinal = fechaFormateada(fecha);

        Results results = await mysql.query(
            "UPDATE servicios SET observsal=?, estado=?, usuariocierra=?, fechasal=? WHERE folio=?",
            [observSal, estado, usuario, fechaStringFinal, folio]
        );
      }

      return Right(null);

    } catch (e) {
      return Left(ServerFailure(message: "Contacte a soporte"));
    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, ServiceEntity>> getServiceWithFolio(int folio, String sucursal) async {
    final mysql = await createConnection();
    print("obteniendo servicios");

    try {

      Results results = await mysql.query(
          '''SELECT * FROM servicios where folio=? AND sucursal=?''', [folio, sucursal]
      );

      List<ServiceModel> models = [];

      for (var result in results){
        ServiceModel serviceModel = ServiceModel.fromJson(result.fields);
        models.add(serviceModel);
      }

      if (models.isEmpty) return Left(ServerFailure(message: "Servicio no existente"));

      return Right(models.first);

    } on MySqlException catch (e) {
      print(e.message);
      return Left(ServerFailure(message: e.toString()));
    } finally {
      await mysql.close();
    }
  }

}