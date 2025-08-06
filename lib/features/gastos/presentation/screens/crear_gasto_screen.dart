import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';
import 'package:velcel/features/gastos/presentation/providers/gastos_provider.dart';
import 'package:velcel/features/gastos/presentation/screens/home_gastos_screen.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/widgets/dropdowns/custom_dropdown.dart';
import '../../../../core/app/navigation.dart';
import '../../../../core/app/theme.dart';
import '../../../store/presentation/screens/register_closure/widgets/register_input_app.dart';
import '../../../widgets/buton_app.dart';

class CrearGastoScreen extends StatefulWidget {
  const CrearGastoScreen({super.key});

  @override
  State<CrearGastoScreen> createState() => _CrearGastoScreenState();
}

class _CrearGastoScreenState extends State<CrearGastoScreen> {
  late Future<dartz.Either<String, List<TipoGastoEntity>>> _future;

  @override
  void initState() {
    GastosProvider gastosProvider = context.read();
    _future = gastosProvider.getTiposGastos();
    super.initState();
  }

  TipoGastoEntity? _selectedGasto;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController folioController = TextEditingController();
  TextEditingController importeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    GastosProvider gastosProvider = context.watch();

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

                  Text("Datos del gasto", style: Theme.of(context).textTheme.bodyLarge,),

                  const SizedBox(height: 20,),

                  CustomDropdown<TipoGastoEntity>(
                    onChanged: (TipoGastoEntity? value) {
                      _selectedGasto = value!;
                      setState(() {});
                    },
                    future: _future,
                    getDisplayValue: (value) => value.tipoGasto,
                    selectedValue: _selectedGasto,
                    hint: "Seleccionar Gasto",
                    // items: gastosProvider.tiposGastos
                  ),

                  const SizedBox(height: 20,),

                  RegisterInputApp(
                    hintText: "Folio:",
                    fillColor: IsselColors.grisClaro,
                    inputFormatters: [TextInputFormatters().int],
                    keyboardType: TextInputType.number,
                    controller: folioController,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo vacío";
                    },
                  ),

                  const SizedBox(height: 20,),

                  RegisterInputApp(
                    hintText: "Importe",
                    fillColor: IsselColors.grisClaro,
                    keyboardType: TextInputType.number,
                    inputFormatters: [TextInputFormatters().double],
                    controller: importeController,
                    validator: (value) {
                      if (value!.isEmpty) return "Campo vacío";
                    },
                  ),

                  const SizedBox(height: 20,),

                  ButtonApp(
                    text: "Reportar",
                    onTap: () async {

                      if (_selectedGasto == null) {
                        SnackbarService.showIncorrect(context, "Tipo de gasto", "Selecciona un tipo");
                        return ;
                      }

                      if (!_formKey.currentState!.validate()) return;


                      BranchProvider branchProvider = context.read();
                      CashRegisterProvider cashRegisterProvider = context.read();
                      UserProvider userProvider = context.read();

                      final response = await gastosProvider.crearGasto(
                          int.parse(folioController.text),
                          branchProvider.branch!.nombre,
                          cashRegisterProvider.cashRegister!.identificador,
                          userProvider.userEntity!.usuario!,
                          double.parse(importeController.text),
                          _selectedGasto!.tipoGasto
                      );

                      response.fold(
                        (l) {
                          SnackbarService.showIncorrect(context, "Servicio", l);
                        },
                        (r) async {
                          await NavigationService.navigateTo(context, HomeGastosScreen());
                        },
                      );

                    },
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
