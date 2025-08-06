import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/domain/entities/cart_entity.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/imei_product_entity.dart';

import '../../../../../widgets/input_app.dart';
import '../states/cart_state.dart';

class InputImeiApp extends StatelessWidget {

  ImeiProductEntity imeiProductEntity;

  InputImeiApp({super.key, required this.imeiProductEntity});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputApp(
          hintText: "Ingresa IMEI",
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          controller: imeiProductEntity.imeiController,
          validator: (value) {
            CartState cartState = context.read();

            List<ImeiProductEntity> imeis = cartState.imeiProductEntitiesCart.where((element) => element.imeiController.text == imeiProductEntity.imeiController.text,).toList();

            if (imeis.length > 1) return "IMEI repetido";

            if (value!.isEmpty) return "Rellena el campo";
            if (imeiProductEntity.error) return "IMEI no valido";
          },
        ),

      ],
    );
  }
}
