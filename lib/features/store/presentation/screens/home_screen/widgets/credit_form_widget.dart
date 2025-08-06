import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/expresiones_regulares.dart';
import '../../../../../widgets/input_app.dart';

class CreditFormWidget extends StatelessWidget {
  const CreditFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.read();

    return Form(
      key: cartState.creditFormKey,
      child: Column(
        children: [
          if (cartState.cartPaymentType!.enumType == PaymentTypes.paguitos)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Datos para credito:", style: Theme.of(context).textTheme.bodyLarge,),
                  const SizedBox(height: 15,),
                  InputApp(
                    hintText: "Nombre completo",
                    icon: Icons.person_outlined, controller: cartState.creditNameController,
                    validator: (value) {
                      if (value!.isEmpty) return "llena el campo";
                    },
                  ),
                  const SizedBox(height: 10,),
                  InputApp(
                    validator: (value) {
                      if (value!.isEmpty) return "llena el campo";
                    },
                    inputFormatters: [TextInputFormatters().cellPhoneNumber],
                    hintText: "Número de telefono",
                    icon: Icons.phone_enabled_outlined,
                    controller: cartState.creditPhoneController,
                    keyboardType: TextInputType.number,


                  ),
                  const SizedBox(height: 10,),
                  InputApp(
                    hintText: "Domicilio",
                    icon: Icons.location_on_outlined,
                    controller: cartState.creditAddressController,
                    validator: (value) {
                      if (value!.isEmpty) return "llena el campo";
                    },
                  ),
                  const SizedBox(height: 10,),
                  InputApp(
                    hintText: "Engance",
                    icon: Icons.money_outlined,
                    controller: cartState.creditEnchangeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return "llena el campo";
                    },
                  ),
                ],
              ),
            ),

          if (cartState.cartPaymentType!.enumType == PaymentTypes.paguitos)
            const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
