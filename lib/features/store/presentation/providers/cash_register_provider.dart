import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/store/domain/entities/cash_register_entity.dart';
import 'package:velcel/features/store/domain/repositories/cash_register_repository.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cash_register_data_response.dart';

class CashRegisterProvider extends ChangeNotifier {

  CashRegisterRepository cashRegisterRepository;

  CashRegisterProvider({
    required this.cashRegisterRepository,
  });

  CashRegisterEntity? cashRegister;
  CashRegisterDataResponse? cashRegisterDataResponse;

  Future<void> registerOpening(String sucursal, String usuario, double fondo) async {

    cashRegister = await cashRegisterRepository.registerOpening(fondo, sucursal, usuario);

  }

  Future<Either<String, CashRegisterEntity?>> openCashRegister(String sucursal) async{

    Either<Failure, CashRegisterEntity?> usecase = await cashRegisterRepository.openCashRegister(sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) {
        cashRegister = r;
        return Right(cashRegister);
      },
    );

  }

  Future<Either<String, CashRegisterDataResponse>> getCashRegisterData(String sucursal) async {

    Either<Failure, CashRegisterDataResponse> usecase = await cashRegisterRepository.getCashRegisterData(sucursal, cashRegister!.identificador);

    return usecase.fold(
      (l) {
        return Left( (l as ServerFailure).message );
      },
      (r) {
        r.totalBruto = r.totalesEfectivo + r.totalesTarjeta + r.fondo;
        r.totalNeto = r.totalBruto! - r.totalesGastos;
        cashRegisterDataResponse = r;
        return Right(cashRegisterDataResponse!);
      },
    );

  }

}