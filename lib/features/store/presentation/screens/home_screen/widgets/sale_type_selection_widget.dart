import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/snackbars.dart';
import '../../../../../../core/app/theme.dart';
import '../../../../domain/entities/cart_payment_type.dart';

class SaleTypeSelectionWidget extends StatelessWidget {

  const SaleTypeSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.read();

    return CustomDropdown<CartPaymentTypeEntity>(
      hintText: "Seleccionar tipo de venta",
      decoration: CustomDropdownDecoration(
        closedFillColor: IsselColors.azulSemiOscuro,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
        headerStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
        closedSuffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.white,),

      ),
      initialItem: cartState.cartPaymentType,
      validateOnChange: true,
      items: cartPaymentTypes,
      validator: (value) {
        if (value != null && (value as CartPaymentTypeEntity).enumType == PaymentTypes.paguitos && !cartState.applyForPaguitos()){
          return "Solo se permite un celular";
        }
      },
      onChanged: (value) {

        if (value == null) {
          cartState.cartPaymentType = null;
          return ;
        }

        if ((value as CartPaymentTypeEntity).enumType == PaymentTypes.paguitos && !cartState.applyForPaguitos()){
          SnackbarService.showIncorrect(
              context,
              "Paguitos",
              "Solo se permite un celular"
          );
          cartState.cartPaymentType = null;
        } else {
          cartState.cartPaymentType = value as CartPaymentTypeEntity;
        }


      },
    );
  }
}
