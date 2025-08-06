import 'package:flutter/material.dart';
import 'package:velcel/features/store/domain/entities/cash_register_data_response.dart';
import 'package:velcel/features/store/domain/entities/cash_register_entity.dart';

import '../../../domain/repositories/cash_register_repository.dart';

class RegisterClosureState extends ChangeNotifier {

  CashRegisterRepository cashRegisterRepository;

  RegisterClosureState({
    required this.cashRegisterRepository
  });

  TextEditingController cantidadController = TextEditingController();
  TextEditingController diferenciaController = TextEditingController();

  Future<String?> terminarCorte(CashRegisterDataResponse cashRegisterDataResponse, CashRegisterEntity cashRegisterEntity) async {

    double cantidad = double.parse(cantidadController.text);
    double diferencia = double.parse(diferenciaController.text);

    String? usecase = await cashRegisterRepository.terminarCorte(cashRegisterDataResponse, cashRegisterEntity, cantidad, diferencia);

    return usecase;

  }

}