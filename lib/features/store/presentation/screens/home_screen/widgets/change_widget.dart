import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/widgets/input_app.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/theme.dart';

class CartChangeWidget extends StatefulWidget {

  const CartChangeWidget({super.key});

  @override
  State<CartChangeWidget> createState() => _CartChangeWidgetState();
}

class _CartChangeWidgetState extends State<CartChangeWidget> {

  double change = 0;

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.read();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Metodo de pago
        Text("Recibido: "),
        const SizedBox(height: 5,),
        InputApp(
          hintText: "Ingresar Recibido",
          fillColor: IsselColors.grisClaro,
          keyboardType: TextInputType.number,
          validator: (value) {

            try{

              double newValue = double.parse(value!);

              double cartTotal = cartState.cartPaymentType?.enumType == PaymentTypes.normal ? cartState.total : double.parse(cartState.creditEnchangeController.text);

              if (newValue < cartTotal) {
                return "Cantidad ingresada menor al total";
              }

            } catch (e){

              return "Cantidad no válida";

            }

          },
          onChanged: (value) {

            try{

              if (value.isEmpty) return;

              double newValue = double.parse(value);

              double cartDouble = cartState.cartPaymentType?.enumType == PaymentTypes.normal ? cartState.total : double.parse(cartState.creditEnchangeController.text);

              change = newValue - cartDouble;

              setState(() {});

            } catch (e){
              SnackbarService.showIncorrect(context, "Cantidad", "Cantidad no valida");
            }

          },
        ),

        const SizedBox(height: 15,),

        // TOTAL A COBRAR
        Text("Cambio: "),
        const SizedBox(height: 5,),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: IsselColors.grisClaro,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(change.toStringAsFixed(2), maxLines: 1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: IsselColors.azulSemiOscuro),),
        ),
      ],
    );
  }
}
