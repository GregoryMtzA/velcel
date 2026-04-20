import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/expresiones_regulares.dart';
import '../../../../../widgets/input_app.dart';

class CreditFormWidget extends StatefulWidget {
  const CreditFormWidget({super.key});

  @override
  State<CreditFormWidget> createState() => _CreditFormWidgetState();
}

class _CreditFormWidgetState extends State<CreditFormWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.read();

    return Form(
      key: cartState.creditFormKey,
      child: Column(
        children: [
          if (cartState.cartPaymentType!.enumType != PaymentTypes.normal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _expanded = !_expanded);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Datos para credito",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: Column(
                      children: [
                        const SizedBox(height: 15),
                        InputApp(
                          hintText: "Nombre completo",
                          icon: Icons.person_outlined,
                          controller: cartState.creditNameController,
                          validator: (value) {
                            if (value!.isEmpty) return "llena el campo";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        InputApp(
                          validator: (value) {
                            if (value!.isEmpty) return "llena el campo";
                            return null;
                          },
                          inputFormatters: [
                            TextInputFormatters().cellPhoneNumber,
                          ],
                          hintText: "Numero de telefono",
                          icon: Icons.phone_enabled_outlined,
                          controller: cartState.creditPhoneController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        InputApp(
                          hintText: "Domicilio",
                          icon: Icons.location_on_outlined,
                          controller: cartState.creditAddressController,
                          validator: (value) {
                            if (value!.isEmpty) return "llena el campo";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        InputApp(
                          hintText: "Enganche",
                          icon: Icons.money_outlined,
                          controller: cartState.creditEnchangeController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) return "llena el campo";
                            return null;
                          },
                        ),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _expanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          if (cartState.cartPaymentType!.enumType != PaymentTypes.normal)
            const SizedBox(height: 20),
        ],
      ),
    );
  }
}
