import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/store/domain/entities/cart_method_pay.dart';
import 'package:velcel/features/store/domain/entities/cart_payment_type.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/cart_products.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/cart_verify.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/verify_imeis_widget.dart';
import 'package:velcel/features/widgets/buton_app.dart';
import 'package:velcel/features/widgets/input_app.dart';

import '../../../../../../../core/app/enums/enums.dart';
import '../change_widget.dart';

class CartPageWidget extends StatelessWidget {

  CartPageWidget({super.key});

  final GlobalKey<FormState> _formKeyRecibido = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.watch();

    return PageView(
      controller: cartState.cartPageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [

        // Carrito
        PageCart(
          onTap: () {
            // Si el carro no está vacío, entonces, seguir a la pagina de pago
            if (cartState.cart.isNotEmpty){
              cartState.cartPaymentType = null;
              cartState.cartState = CartStates.pay;
              return;
            }

            /// MOSTRAR DIALOGO DE QUE NO HAY PRODUCTOS QUE PAGAR EN EL CARRITO.
            SnackbarService.showIncorrect(
              context,
              "Carrito",
              "No hay productos que cobrar",
            );

          },
        ),

        // Pago de carrito
        CartVerify(),

        Container(
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Text("Datos de Venta", style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center,),
                        const SizedBox(height: 10,),

                        // Metodo de pago
                        Text("Metodo de pago: "),
                        const SizedBox(height: 5,),
                        CustomDropdown<CartMethodPayEntity>(
                          hintText: "Seleccionar tipo de pago",
                          decoration: CustomDropdownDecoration(
                            closedFillColor: IsselColors.azulSemiOscuro,
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                            headerStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                            closedSuffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.white,),

                          ),
                          initialItem: cartState.cartMethodPayEntity,
                          items: cartMethodPayTypes,
                          onChanged: (value) {

                            if (value == null) {
                              return ;
                            }

                            cartState.cartMethodPayEntity = value as CartMethodPayEntity;

                          },
                        ),

                        const SizedBox(height: 15,),

                        // TOTAL A COBRAR
                        Text("Total a cobrar: "),
                        const SizedBox(height: 5,),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: IsselColors.grisClaro,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(cartState.cartPaymentType?.enumType == PaymentTypes.normal ? cartState.total.toStringAsFixed(2) : cartState.creditEnchangeController.text, maxLines: 1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: IsselColors.azulSemiOscuro),),
                        ),

                        const SizedBox(height: 25,),

                        Text("Cambio y Recibido", style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center,),
                        const SizedBox(height: 10,),

                        Form(
                          key: _formKeyRecibido,
                          child: CartChangeWidget()
                        )

                      ],
                    ),
                  ),
                )
              ),

              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ButtonApp(
                    text: "Generar Venta",
                    borderRadius: 0,
                    onTap: () async {

                      if (!_formKeyRecibido.currentState!.validate()){
                        return ;
                      }


                      BranchProvider branchProvider = context.read();
                      if (branchProvider.branch!.nombre == "VELCEL AVENTA") {
                        PrintersControllers printersController = context.read();
                        Either<String, void> printerResponse = await printersController.checkStatusConnect();
                        bool isContinue = true;
                        await printerResponse.fold(
                              (l) async {
                            bool result = await DialogService.awaitConfirmDialog(
                              context: context,
                              title: "No hay una impresora conectada",
                              textButton: "Continuar",
                            );

                            if (!result) {
                              isContinue = false;
                            }
                          },
                              (r) {},
                        );

                        if (!isContinue) {
                          SnackbarService.showIncorrect(context, "Venta", "Configura tu impresora");
                          return;
                        }
                      }

                      CashRegisterProvider cashRegisterProvider = context.read();
                      UserProvider userProvider = context.read();

                      if (cartState.cartMethodPayEntity == null){
                        SnackbarService.showIncorrect(context, "Tipo de Pago", "Selecciona un tipo de pago");
                        return ;
                      }

                      Either<String, String> response = await cartState.purchase(
                        cashRegisterProvider.cashRegister!.identificador,
                        userProvider.userEntity!.usuario,
                        branchProvider.branch!.nombre
                      );

                      response.fold(
                        (l) {
                          SnackbarService.showIncorrect(context, "Venta", l);
                        },
                        (r) {
                          SnackbarService.showCorrect(context, "Venta", r);
                        },
                      );

                    },
                  )
              )

            ],
          ),
        ),

      ],
    );
  }
}
