import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/ventas/data/models/clientes_venta_model.dart';
import 'package:velcel/features/ventas/data/models/corte_model.dart';
import 'package:velcel/features/ventas/data/models/imeis_venta_model.dart';
import 'package:velcel/features/ventas/data/models/productos_venta_model.dart';
import 'package:velcel/features/ventas/data/models/semi_reporte_venta_model.dart';
import 'package:velcel/features/ventas/domain/entities/clientes_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/corte_entity.dart';
import 'package:velcel/features/ventas/domain/entities/imeis_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/productos_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';
import 'package:velcel/features/ventas/domain/repositories/ventas_repository.dart';

class VentasRepositoryImpl implements VentasRepository {

  final Future<MySqlConnection> Function() createConnection;

  VentasRepositoryImpl({
    required this.createConnection,
  });


  String fechaFormateada(DateTime fecha){
    return DateFormat('yyyy-MM-dd').format(fecha.toUtc());
  }

  @override
  Future<Either<Failure, List<ImeisVentaEntity>>> getIMEIS(int folio) async {
    final mysql = await createConnection();
    try {
      List<ImeisVentaEntity> imeis = [];
      
      Results results = await mysql.query('''SELECT imei FROM imeisventas WHERE folio=?''', [folio]);

      for (var result in results) {
        ImeisVentaEntity imeisVentaEntity = ImeisVentaModel.fromJson(result.fields);
        imeis.add(imeisVentaEntity);
      }

      return Right(imeis);

    } on MySqlConnection catch(e) {

      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }


  }

  @override
  Future<Either<Failure, List<ClientesVentaEntity>>> getClientes(int folio) async {
    final mysql = await createConnection();
    try {

      List<ClientesVentaEntity> clientes = [] ;

      Results results = await mysql.query('''SELECT nombre, domicilio, telefono FROM registropayjoy WHERE folio=?''', [folio]);

      for (var result in results) {
        ClientesVentaEntity cliente = ClientesVentaModel.fromJson(result.fields);
        clientes.add(cliente);
      }

      return Right(clientes);

    } on MySqlException catch (e) {

      print(e.message);
      return Left(ServerFailure(message: "ERROR AL OBTENER EL CLIENTE"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<ProductosVentaEntity>>> getProductos(int folio) async {
    final mysql = await createConnection();
    try {

      List<ProductosVentaEntity> productos = [];
      
      Results results = await mysql.query(
        '''SELECT productos.nombre, salidasventas.cantidad FROM productos join salidasventas ON productos.nombre = salidasventas.nombre WHERE salidasventas.folio=?''',
        [folio]
      );

      for (var result in results) {
        ProductosVentaEntity producto = ProductosVentaModel.fromJson(result.fields);
        productos.add(producto);
      }

      return Right(productos);
      
    } on MySqlException catch(e) {
      
      return Left(ServerFailure(message: "Contacte a soporte"));
      
    } finally {
      await mysql.close();
    }
    
  }

  @override
  Future<Either<Failure, List<SemiReporteVentaEntity>>> getReportesWithDate(String sucursal, DateTime fechaA, DateTime fechaB) async {
    final mysql = await createConnection();
    try {

      String fechaAFormatted = fechaFormateada(fechaA);
      String fechaBFormatted = fechaFormateada(fechaB);

      List<SemiReporteVentaEntity> semiReportes = [];

      Results results = await mysql.query(
        '''SELECT folio, total, metodo, credito, fecha, usuario FROM reportesventas WHERE (fecha BETWEEN ? AND ?) AND sucursal=?''',
        [fechaAFormatted, fechaBFormatted, sucursal]
      );

      for (var result in results){
        SemiReporteVentaEntity semiReporte = SemiReporteVentaModel.fromJson(result.fields);
        semiReportes.add(semiReporte);
      }

      return Right(semiReportes);

    } on MySqlException catch(e) {

      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<SemiReporteVentaEntity>>> getReportesWithFolio(String sucursal, int folio) async {
    final mysql = await createConnection();
    try {

      List<SemiReporteVentaEntity> semiReportes = [];

      Results results = await mysql.query(
          '''SELECT folio, total, metodo, credito, fecha, usuario FROM reportesventas where sucursal=? AND folio=?''',
          [sucursal, folio]
      );

      for (var result in results){
        SemiReporteVentaEntity semiReporte = SemiReporteVentaModel.fromJson(result.fields);
        semiReportes.add(semiReporte);
      }

      return Right(semiReportes);

    } on MySqlException catch(e) {

      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally{
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, List<CorteEntity>>> getCortesWithFecha(String sucursal, DateTime fechaA, DateTime fechaB) async {
    final mysql = await createConnection();
    try {

      String fechaAFormatted = fechaFormateada(fechaA);
      String fechaBFormatted = fechaFormateada(fechaB);

      List<CorteEntity> cortes = [];

      Results results = await mysql.query(
          '''SELECT usuario, fechaapertura, fechacierre, cantidadefectivo, cantidadtarjeta, fondo, gastos, total, totalconteo, diferencia FROM cortes WHERE (fechaapertura BETWEEN ? AND ?) AND sucursal=? AND estado=?''',
          [fechaAFormatted, fechaBFormatted, sucursal, "Cerrado"]
      );

      for (var result in results){
        CorteEntity corte = CorteModel.fromJson(result.fields);
        cortes.add(corte);
      }

      return Right(cortes);

    } on MySqlException catch(e) {

      return Left(ServerFailure(message: "Contacte a soporte"));

    } finally{
      await mysql.close();
    }

  }

}