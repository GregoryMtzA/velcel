import 'package:dartz/dartz.dart';
import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';

import '../../../../core/errors/failures.dart';

abstract class GastosRepository {

  Future<Either<Failure, List<TipoGastoEntity>>> GetAllTipoGastos();
  Future<Either<Failure, bool>> verificarFolio(int folio, String sucursal);
  Future<Either<Failure, void>> crearSolGasto(String tipo, double importe, String sucursal, String usuario, int corte, int folioVenta);
  Future<Either<Failure, List<GastoEntity>>> obtenerGastosPorTipo(String tipo, String sucursal);
  Future<Either<Failure, List<GastoEntity>>> obtenerGastosPorFolio(int folio, String sucursal);

}