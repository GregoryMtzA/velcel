import 'package:dartz/dartz.dart';
import 'package:velcel/features/gastos/domain/repositories/gastos_repository.dart';

import '../../../../core/errors/failures.dart';

class CrearGastoUsecase {

  GastosRepository gastosRepository;

  CrearGastoUsecase({
    required this.gastosRepository,
  });

  Future<Either<Failure, void>> call(int folio, String sucursal, int corte, String usuario, double importe, String tipo) async {

    final folioResponse = await gastosRepository.verificarFolio(folio, sucursal);

    return folioResponse.fold(
      (l) => Left(l),
      (r) async {

        final gastoResponse = await gastosRepository.crearSolGasto(tipo, importe, sucursal, usuario, corte, folio);

        return gastoResponse.fold(
          (lGasto) => Left(lGasto),
          (rGasto) => Right(rGasto),
        );

      },
    );

  }

}