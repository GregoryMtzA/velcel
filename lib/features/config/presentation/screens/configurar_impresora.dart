import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/config/presentation/screens/config_screen.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';
import 'package:velcel/features/gastos/presentation/providers/gastos_provider.dart';
import 'package:velcel/features/widgets/dropdowns/custom_dropdown.dart';
import '../../../../core/app/theme.dart';
import '../../../store/presentation/screens/register_closure/widgets/register_input_app.dart';
import '../../../widgets/buton_app.dart';

class ConfigurarImpresora extends StatefulWidget {
  const ConfigurarImpresora({super.key});

  @override
  State<ConfigurarImpresora> createState() => _CrearGastoScreenState();
}

class _CrearGastoScreenState extends State<ConfigurarImpresora> {
  late Future<dartz.Either<String, List<TipoGastoEntity>>> _future;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController macAddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    PrintersControllers printersControllers = context.watch();

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          width: MediaQuery.sizeOf(context).width * 0.5,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  Text("Vinculación de impresora", style: Theme.of(context).textTheme.bodyLarge,),

                  const SizedBox(height: 20,),

                  RegisterInputApp(
                    hintText: "Mac Address:",
                    fillColor: IsselColors.grisClaro,
                    // inputFormatters: [TextInputFormatters().int],
                    // keyboardType: TextInputType.number,
                    controller: macAddress,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo vacío";
                    },
                  ),

                  const SizedBox(height: 20,),

                  ButtonApp(
                    text: "Vincular",
                    onTap: () async {

                      dartz.Either<String, void> response = await printersControllers.emparejarImpresora(macAddress.text);

                      response.fold(
                        (l) {
                          SnackbarService.showIncorrect(context, "Impresora", l);
                        },
                        (r) async {
                          SnackbarService.showCorrect(context, "Impresora", "Conexión exitosa");
                        },
                      );

                    },
                  ),

                  const SizedBox(height: 20,),

                  const Divider(),

                  Text("Selección de impresora", style: Theme.of(context).textTheme.bodyLarge,),

                  const SizedBox(height: 20,),

                  CustomDropdown<BluetoothInfoEquatable>(
                    onChanged: printersControllers.selectPrinter,
                    future: printersControllers.escanearImpresoras(),
                    getDisplayValue: (value) => value.bluetoothInfo.name,
                    selectedValue: printersControllers.selectedPrinter,
                    hint: "Seleccionar impresora",
                    // items: gastosProvider.tiposGastos
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
