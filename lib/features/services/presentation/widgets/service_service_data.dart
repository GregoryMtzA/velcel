import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/widgets/register_input_app.dart';
import 'package:velcel/features/widgets/input_date_picker.dart';

class ServiceServiceData extends StatelessWidget {

  TextEditingController reportedFault;
  TextEditingController observations;
  DateTime collectionDate;

  ServiceServiceData({
    super.key,
    required this.reportedFault,
    required this.observations,
    required this.collectionDate
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        Text("Datos del cliente:"),
        const SizedBox(height: 10,),

        Expanded(
            child: Row(
              children: [

                Expanded(
                  child: InputDatePicker(
                    hintText: "Fecha de recibo:",
                    onChange: (date) {},
                    readOnly: true,
                  )
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: InputDatePicker(
                    hintText: "Fecha de entrega:",
                    onChange: (date) => collectionDate = date,
                  )
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: RegisterInputApp(
                    hintText: "Falla reportada:",
                    controller: reportedFault,
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
          flex: 2,
          child: RegisterInputApp(
            hintText: "Observaciones:",
            controller: observations,
            fillColor: IsselColors.grisClaro,
            expands: true,
            validator: (value) {
              if (value!.isEmpty) return "Campo Vacío";
            },
          ),
        ),

      ],
    );
  }
}
