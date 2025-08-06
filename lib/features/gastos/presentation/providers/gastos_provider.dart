import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/gastos_repository.dart';
import '../../domain/usecases/crear_gasto_usecase.dart';

class GastosProvider extends ChangeNotifier {

  GastosRepository gastosRepository;
  CrearGastoUsecase crearGastoUsecase;

  GastosProvider({
    required this.gastosRepository,
    required this.crearGastoUsecase,
  });

  List<TipoGastoEntity> tiposGastos = [];
  List<GastoEntity> gastos = [];

  Future<Either<String, List<TipoGastoEntity>>> getTiposGastos() async {

    Either<Failure, List<TipoGastoEntity>> usecase = await gastosRepository.GetAllTipoGastos();

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        tiposGastos = r;
        return Right(tiposGastos);
      },
    );

  }

  Future<Either<String, List<GastoEntity>>> getGastosPorTipo(String tipo, String sucursal) async {

    Either<Failure, List<GastoEntity>> usecase = await gastosRepository.obtenerGastosPorTipo(tipo, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        gastos = r;
        notifyListeners();
        return Right(gastos);
      },
    );

  }

  Future<Either<String, List<GastoEntity>>> getGastosPorFolio(int folio, String sucursal) async {

    Either<Failure, List<GastoEntity>> usecase = await gastosRepository.obtenerGastosPorFolio(folio, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        gastos = r;
        notifyListeners();
        return Right(gastos);
      },
    );

  }

  Future<Either<String, void>> crearGasto(int folio, String sucursal, int corte, String usuario, double importe, String tipo) async {

    final usecase = await crearGastoUsecase(folio, sucursal, corte, usuario, importe, tipo);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );

  }

}