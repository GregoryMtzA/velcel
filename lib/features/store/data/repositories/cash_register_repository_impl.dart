import 'package:dartz/dartz.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/core/errors/exceptions.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/store/domain/entities/cash_register_data_response.dart';
import 'package:velcel/features/store/domain/entities/cash_register_entity.dart';
import 'package:velcel/features/store/domain/repositories/cash_register_repository.dart';

class CashRegisterRepositoryImpl implements CashRegisterRepository {

  final Future<MySqlConnection> Function() createConnection;


  CashRegisterRepositoryImpl({
    required this.createConnection,
  });

  @override
  Future<CashRegisterEntity> registerOpening(double fondo, String sucursal, String usuario) async {
    final mysql = await createConnection();
    try {

      await mysql.transaction((transaction) async {

        await mysql.query('''CALL proCorteInicio(?, ?, ?, @identificadorx);''',
            [sucursal, usuario, fondo]);

      },);

      Results results = await mysql.query('''SELECT @identificadorx''');

      int resultado = results.first["@identificadorx"];

      CashRegisterEntity cashRegisterEntity = CashRegisterEntity(
        identificador: resultado,
      );

      return cashRegisterEntity;

    } catch (e) {

      print(e);

      throw ServerException(message: "Error: Contacte a soporte");

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, CashRegisterEntity?>> openCashRegister(String sucursal) async {
    final mysql = await createConnection();

    try {

      Results results = await mysql.query('''SELECT * FROM cortes where sucursal = ? AND estado= ? ''', [sucursal, "Abierto"]);

      if (results.isEmpty) return const Right(null);

      var resultado = results.first;

      CashRegisterEntity cashRegisterEntity = CashRegisterEntity(
        identificador: resultado["identificador"],
        sucursal: resultado["sucursal"],
        usuario: resultado["usuario"],
        fechaApertura: resultado["fechaapertura"],
        fondo: resultado["fondo"],
        estado: resultado["estado"]
      );

      return Right(cashRegisterEntity);

    } catch (e) {

      print(e);

      throw ServerException(message: "Error: Contacte a soporte");

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, CashRegisterDataResponse>> getCashRegisterData(String sucursal, int idCorte) async {
    final mysql = await createConnection();

    try {
      Results queryFondo = await mysql.query('''SELECT fondo FROM cortes WHERE sucursal=? AND identificador=?''', [sucursal, idCorte]);
      Results queryTotalesEfectivo = await mysql.query('''SELECT SUM(total) as total FROM reportesventas WHERE sucursal=? AND folioCorte=? AND metodo=?''', [sucursal, idCorte, "Efectivo"]);
      Results queryTotalesTarjeta = await mysql.query('''SELECT SUM(total) as total FROM reportesventas WHERE sucursal=? AND folioCorte=? AND metodo=?''', [sucursal, idCorte, "Tarjeta"]);
      Results queryTotalesGastos = await mysql.query('''SELECT SUM(importe) as importe FROM gastos WHERE sucursal = ? AND corte = ?''', [sucursal, idCorte]);

      double fondo = queryFondo.first["fondo"] ?? 0.0;
      double totalesEfectivo = queryTotalesEfectivo.first["total"] ?? 0.0;
      double totalesTarjeta = queryTotalesTarjeta.first["total"] ?? 0.0;
      double importe = queryTotalesGastos.first["importe"] ?? 0.0;

      CashRegisterDataResponse cashRegisterDataResponse = CashRegisterDataResponse(
        fondo: fondo,
        totalesEfectivo: totalesEfectivo,
        totalesTarjeta: totalesTarjeta,
        totalesGastos: importe
      );

      return Right(cashRegisterDataResponse);

    } catch (e) {

      print(e);

      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally{
      await mysql.close();
    }

  }

  @override
  Future<String?> terminarCorte(CashRegisterDataResponse crdp, CashRegisterEntity cre, double contado, double diferencia) async {
    final mysql = await createConnection();

    try {

      await mysql.transaction((transaction) async {

        await mysql.query('''UPDATE cortes SET
         cantidadefectivo=?,
         cantidadtarjeta=?,
         total=?, 
         diferencia=?, 
         totalconteo=?, 
         fechacierre=CURRENT_TIMESTAMP(), 
         estado=?, 
         gastos=? 
         WHERE identificador=?''',
         [crdp.totalesEfectivo, crdp.totalesTarjeta, crdp.totalNeto, diferencia, contado, "Cerrado", crdp.totalesGastos, cre.identificador]
        );

      },);

      return null;

    } on MySqlException catch (e) {

      return e.message;

    } finally {
      await mysql.close();
    }

  }

}