import 'package:flutter/material.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/widgets/register_input_app.dart';

class ServiceDeviceData extends StatelessWidget {

  TextEditingController brand;
  TextEditingController model;
  TextEditingController series;
  TextEditingController shortDescription;
  TextEditingController IMEI;

  ServiceDeviceData({
    super.key,
    required this.brand,
    required this.model,
    required this.series,
    required this.shortDescription,
    required this.IMEI,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text("Datos del cliente:"),
        const SizedBox(height: 10,),

        Expanded(
            child: Row(
              children: [

                Expanded(
                  child: RegisterInputApp(
                    hintText: "Marca:",
                    controller: brand,
                    fillColor: IsselColors.grisClaro,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo Vacío";
                    },
                  ),
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: RegisterInputApp(
                    hintText: "Modelo:",
                    controller: model,
                    fillColor: IsselColors.grisClaro,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo Vacío";
                    },
                  ),
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: RegisterInputApp(
                    hintText: "Serie:",
                    controller: series,
                    fillColor: IsselColors.grisClaro,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo Vacío";
                    },
                  ),
                ),

              ],
            )
        ),

        Expanded(
            child: Row(
              children: [

                Expanded(
                  flex: 2,
                  child: RegisterInputApp(
                    hintText: "Descripción corta:",
                    controller: shortDescription,
                    fillColor: IsselColors.grisClaro,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo Vacío";
                    },
                  ),
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: RegisterInputApp(
                    hintText: "IMEI:",
                    controller: IMEI,
                    fillColor: IsselColors.grisClaro,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo Vacío";
                    },
                  ),
                ),

              ],
            )
        ),

      ],
    );
  }
}
