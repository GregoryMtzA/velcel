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

  int? _lastClosedCutFolio;
  String? _lastClosedCutBranch;
  bool _isLoadingLastClosedCut = false;
  bool _lastClosedCutLoaded = false;
  String? _lastClosedCutError;

  int? get lastClosedCutFolio => _lastClosedCutFolio;
  String? get lastClosedCutBranch => _lastClosedCutBranch;
  bool get isLoadingLastClosedCut => _isLoadingLastClosedCut;
  String? get lastClosedCutError => _lastClosedCutError;

  Future<void> loadLastClosedCut(
    String sucursal, {
    bool force = false,
  }) async {
    if (sucursal.isEmpty ||
        (!force &&
            (_lastClosedCutBranch == sucursal &&
                (_isLoadingLastClosedCut ||
                    _lastClosedCutFolio != null ||
                    _lastClosedCutError != null ||
                    _lastClosedCutLoaded)))) {
      return;
    }

    _lastClosedCutBranch = sucursal;
    _lastClosedCutFolio = null;
    _lastClosedCutError = null;
    _lastClosedCutLoaded = false;
    _isLoadingLastClosedCut = true;
    notifyListeners();

    final response =
        await cashRegisterRepository.getLastClosedCutFolio(sucursal);
    if (_lastClosedCutBranch != sucursal) return;

    response.fold(
      (failure) => _lastClosedCutError = failure is ServerFailure
          ? failure.message
          : 'No se pudo consultar el último corte',
      (folio) => _lastClosedCutFolio = folio,
    );
    _lastClosedCutLoaded = true;
    _isLoadingLastClosedCut = false;
    notifyListeners();
  }

  Future<void> registerOpening(
      String sucursal, String usuario, double fondo) async {
    cashRegister =
        await cashRegisterRepository.registerOpening(fondo, sucursal, usuario);
  }

  Future<Either<String, CashRegisterEntity?>> openCashRegister(
      String sucursal) async {
    Either<Failure, CashRegisterEntity?> usecase =
        await cashRegisterRepository.openCashRegister(sucursal);

    return usecase.fold(
      (l) => Left((l as ServerFailure).message),
      (r) {
        cashRegister = r;
        return Right(cashRegister);
      },
    );
  }

  Future<Either<String, CashRegisterDataResponse>> getCashRegisterData(
      String sucursal) async {
    Either<Failure, CashRegisterDataResponse> usecase =
        await cashRegisterRepository.getCashRegisterData(
            sucursal, cashRegister!.identificador);

    return usecase.fold(
      (l) {
        return Left((l as ServerFailure).message);
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
