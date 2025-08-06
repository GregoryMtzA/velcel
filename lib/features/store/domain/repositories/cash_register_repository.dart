import 'package:dartz/dartz.dart';
import 'package:velcel/features/store/domain/entities/cash_register_data_response.dart';
import 'package:velcel/features/store/domain/entities/cash_register_entity.dart';

import '../../../../core/errors/failures.dart';

abstract class CashRegisterRepository {

  Future<CashRegisterEntity> registerOpening(double fondo, String sucursal, String usuario);
  Future<Either<Failure, CashRegisterEntity?>> openCashRegister(String sucursal);
  Future<Either<Failure, CashRegisterDataResponse>> getCashRegisterData(String sucursal, int idCorte);
  Future<String?> terminarCorte(CashRegisterDataResponse cashRegisterDataResponse, CashRegisterEntity cashRegisterEntity, double contado, double diferencia);

}