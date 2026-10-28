import 'package:dartz/dartz.dart';
import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';

import '../../../../core/errors/failures.dart';

abstract class GastosRepository {
  Future<Either<Failure, List<TipoGastoEntity>>> GetAllTipoGastos();
  Future<Either<Failure, void>> crearSolGasto(
      String tipo, double importe, String sucursal, String usuario, int corte);
  Future<Either<Failure, List<GastoEntity>>> obtenerGastosPorTipo(
      String tipo, String sucursal);
  Future<Either<Failure, List<GastoEntity>>> obtenerGastosPorFolioCorte(
      int folioCorte, String sucursal);
}
