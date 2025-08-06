import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/screens/splash_screen/splash_screen.dart';
import 'package:velcel/features/store/domain/entities/cash_register_data_response.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/state.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/widgets/register_input_app.dart';


import '../../../../../core/app/expresiones_regulares.dart';
import '../../../../../core/app/theme.dart';
import '../../../../widgets/buton_app.dart';
import '../../../../widgets/input_app.dart';
import '../../../../widgets/menu_drawer.dart';

class RegisterClosureScreen extends StatefulWidget {

  RegisterClosureScreen._();

  static Widget init(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RegisterClosureState(cashRegisterRepository: locator()),)
      ],
      builder: (context, child) => RegisterClosureScreen._(),
    );
  }

  @override
  State<RegisterClosureScreen> createState() => _RegisterClosureScreenState();
}

class _RegisterClosureScreenState extends State<RegisterClosureScreen> {
  TextEditingController cantidadCompraEfectivo = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<dartz.Either<String, CashRegisterDataResponse>> _future;

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    CashRegisterProvider cashRegisterProvider = context.read();
    BranchProvider branchProvider = context.read();
    _formKey = GlobalKey<FormState>();
    _future = cashRegisterProvider.getCashRegisterData(branchProvider.branch!.nombre);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RegisterClosureState registerClosureState = context.read();
    CashRegisterProvider crp = context.read();

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text("Cortes", style: Theme.of(context).textTheme.bodyLarge,),
        toolbarHeight: 50,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu_outlined),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {

            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting){
              return SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: const Center(child: CircularProgressIndicator(),),
              );
            }

            dartz.Either<String, CashRegisterDataResponse> response = snapshot.data!;

            return response.fold(
              (l) {
                return Center(child: Text("Contacte a soporte"),);
              },
              (cashRegisterDataResponse) {
                return Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        width: MediaQuery.sizeOf(context).width * 0.85,
                        height: 460,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Cantidad de compra efectivo: ",
                                          initValue: crp.cashRegisterDataResponse!.totalesEfectivo!.toStringAsFixed(2),
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 20,),
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Cantidad de fondo: ",
                                          initValue: crp.cashRegisterDataResponse!.fondo!.toStringAsFixed(2),
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 20,),
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Cantidad de gastos: ",
                                          initValue: crp.cashRegisterDataResponse!.totalesGastos!.toStringAsFixed(2),
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 20,),
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Cantidad contada",
                                          controller: registerClosureState.cantidadController,
                                          inputFormatters: [TextInputFormatters().double],
                                          validator: (value) {
                                            if (value!.isEmpty) return "Ingresa una cantidad";
                                            // try{
                                            //   double newValue = double.parse(value);
                                            //   if (newValue != crp.cashRegisterDataResponse!.totalNeto) return "Cantidad Incorrecta";
                                            // } catch (e){
                                            //   return "Ingresa una cantidad válida";
                                            // }
                                          },
                                          onChanged: (value) {
                                            if (value.isEmpty) registerClosureState.diferenciaController.text = "";
                                            try{
                                              double contadoValue = double.parse(value!);
                                              double diferenciaValue = crp.cashRegisterDataResponse!.totalNeto! - contadoValue;

                                              registerClosureState.diferenciaController.text = diferenciaValue.toStringAsFixed(2);
                                            } catch (e){

                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Cantidad de compra con tarjeta: ",
                                          initValue: crp.cashRegisterDataResponse!.totalesTarjeta!.toStringAsFixed(2),
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 20,),
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Total bruto (incluye fondo)",
                                          initValue: crp.cashRegisterDataResponse!.totalBruto!.toStringAsFixed(2),
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 20,),
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Total neto en caja (bruto - gastos)",
                                          initValue: crp.cashRegisterDataResponse!.totalNeto!.toStringAsFixed(2),
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 20,),
                                        RegisterInputApp(
                                          fillColor: IsselColors.grisClaro,
                                          hintText: "Diferencia: ",
                                          controller: registerClosureState.diferenciaController,
                                          inputFormatters: [TextInputFormatters().double],
                                          readOnly: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ButtonApp(
                              text: "Terminar corte y sesión",
                              onTap: () async {

                                if (!_formKey.currentState!.validate()){
                                  return ;
                                }


                                String? response = await registerClosureState.terminarCorte(cashRegisterDataResponse, crp.cashRegister!);

                                if (response == null){
                                  await NavigationService.navigateTo(context, SplashScreen.init(context));
                                } else {
                                  SnackbarService.showIncorrect(context, "Corte", response);
                                }

                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );

          },
        ),
      ),

    );
  }
}
