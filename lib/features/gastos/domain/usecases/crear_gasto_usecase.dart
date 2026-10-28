import 'package:dartz/dartz.dart';
import 'package:velcel/features/gastos/domain/repositories/gastos_repository.dart';

import '../../../../core/errors/failures.dart';

class CrearGastoUsecase {
  GastosRepository gastosRepository;

  CrearGastoUsecase({
    required this.gastosRepository,
  });

  Future<Either<Failure, void>> call(String sucursal, int corte, String usuario,
      double importe, String tipo) async {
    return gastosRepository.crearSolGasto(
      tipo,
      importe,
      sucursal,
      usuario,
      corte,
    );
  }
}
