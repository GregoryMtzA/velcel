import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/credit_form_widget.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/sale_type_selection_widget.dart';

import '../../../../../../../core/app/enums/enums.dart';
import '../../../../../../../core/app/snackbars.dart';
import '../../../../../../../core/app/theme.dart';
import '../../../../../../widgets/buton_app.dart';
import '../../../../../../widgets/input_app.dart';
import '../../../../../domain/entities/cart_payment_type.dart';
import '../../states/cart_state.dart';
import '../verify_imeis_widget.dart';

class CartVerify extends StatelessWidget {
  CartVerify({super.key});

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.watch();

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.sizeOf(context).height,
              margin: const EdgeInsets.only(bottom: 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                  children: [

                    /// SELECCION DE TIPO DE VENTA
                    SaleTypeSelectionWidget(),

                    const SizedBox(height: 20,),

                    /// DATOS PARA CREDITO
                    if (cartState.cartPaymentType != null)
                      CreditFormWidget(),

                    /// VERIFICACION DE IMEIS
                    if (cartState.cartPaymentType != null)
                      VerifyImeisWidget(),

                    const SizedBox(height: 50,)

                  ],
                ),
              ),
            ),
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ButtonApp(
                text: "Verificar IMEI´s",
                borderRadius: 0,
                onTap: () async {

                  // Validación del tipo de pago
                  if (cartState.cartPaymentType == null){
                    SnackbarService.showIncorrect(context, "Tipo de Venta", "Selecciona un tipo de venta");
                    return ;
                  }

                  // Validación de formulario de credito
                  if (cartState.cartPaymentType!.enumType != PaymentTypes.normal && !cartState.creditFormKey.currentState!.validate()){
                    return ;
                  }

                  // Validación de IMEI´S
                  await cartState.verifyImei();

                  // Validación de formulario de IMEI´S - Se complementa con la validación de IMEI´S
                  if (!cartState.formKeyValidate.currentState!.validate()){
                    cartState.notifyListeners();
                    FocusScope.of(context).unfocus();
                    return;
                  }

                  cartState.cartState = CartStates.purchase;
                  FocusScope.of(context).unfocus();

                },
              )
          )
        ],
      ),
    );
  }
}
