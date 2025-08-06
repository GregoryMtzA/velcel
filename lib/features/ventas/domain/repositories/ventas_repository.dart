import 'package:dartz/dartz.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/ventas/domain/entities/clientes_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/corte_entity.dart';
import 'package:velcel/features/ventas/domain/entities/imeis_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/productos_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';

abstract class VentasRepository {

  Future<Either<Failure, List<ImeisVentaEntity>>> getIMEIS(int folio);
  Future<Either<Failure, List<ClientesVentaEntity>>> getClientes(int folio);
  Future<Either<Failure, List<ProductosVentaEntity>>> getProductos(int folio);
  Future<Either<Failure, List<SemiReporteVentaEntity>>> getReportesWithFolio(String sucursal, int folio);
  Future<Either<Failure, List<SemiReporteVentaEntity>>> getReportesWithDate(String sucursal, DateTime fechaA, DateTime fechaB);
  Future<Either<Failure, List<CorteEntity>>> getCortesWithFecha(String sucursal, DateTime fechaA, DateTime fechaB);

}