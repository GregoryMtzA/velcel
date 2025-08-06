import 'package:flutter/material.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/widgets/register_input_app.dart';

class ServiceOrderClientWidget extends StatelessWidget {

  TextEditingController customerName;
  TextEditingController contactNumber;

  ServiceOrderClientWidget({
    super.key,
    required this.contactNumber,
    required this.customerName
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Datos del cliente:"),
        const SizedBox(height: 10,),

        RegisterInputApp(
          hintText: "Nombre del cliente",
          controller: customerName,
          fillColor: IsselColors.grisClaro,
          validator: (value) {
            if (value!.isEmpty) return "campo vacío";
          },
        ),

        const SizedBox(height: 10,),
        RegisterInputApp(
          hintText: "Número de contacto:",
          controller: contactNumber,
          fillColor: IsselColors.grisClaro,
          validator: (value) {
            if (value!.isEmpty) return "campo vacío";
          },
          inputFormatters: [TextInputFormatters().cellPhoneNumber],
        ),
      ],
    );
  }
}
