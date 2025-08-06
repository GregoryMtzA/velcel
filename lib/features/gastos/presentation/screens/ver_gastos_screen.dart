import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';

import '../../../../core/app/snackbars.dart';
import '../../../../core/app/theme.dart';
import '../../../widgets/dropdowns/custom_dropdown.dart';
import '../../../widgets/input_app.dart';
import '../../domain/entities/tipo_gasto_entity.dart';
import '../providers/gastos_provider.dart';

class VerGastosScreen extends StatefulWidget {
  const VerGastosScreen({super.key});

  @override
  State<VerGastosScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<VerGastosScreen> {

  late Future<dartz.Either<String, List<TipoGastoEntity>>> _futureTipoGasto;
  TextEditingController folioController = TextEditingController();
  TipoGastoEntity? _selectedGasto;

  @override
  void initState() {
    GastosProvider gastosProvider = context.read();
    _futureTipoGasto = gastosProvider.getTiposGastos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GastosProvider gastosProvider = context.watch();
    BranchProvider branchProvider = context.read();

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: InputApp(
                  hintText: "Folio",
                  fillColor: IsselColors.grisClaro,
                  controller: folioController,
                  onFieldSubmitted: (value) async {

                    if (value.isEmpty) {
                      SnackbarService.showIncorrect(context, "Folio", "Ingresa un folio");
                      return ;
                    }


                    final response = await gastosProvider.getGastosPorFolio(int.parse(value), branchProvider.branch!.nombre);

                    response.fold(
                      (l) {
                        SnackbarService.showIncorrect(context, "Gastos", l);
                      },
                      (r) {
                        folioController.clear();
                        _selectedGasto = null;
                        setState(() {});
                      },
                    );

                  },
                ),
              ),
              const SizedBox(width: 50,),
              /// Seleccion de categoría
              Expanded(
                child: CustomDropdown<TipoGastoEntity>(
                  onChanged: (TipoGastoEntity? value) async {
                    _selectedGasto = value!;

                    final response = await gastosProvider.getGastosPorTipo(_selectedGasto!.tipoGasto, branchProvider.branch!.nombre);

                    response.fold(
                      (l) {
                        SnackbarService.showIncorrect(context, "Gastos", l);
                      },
                      (r) {

                      },
                    );

                  },
                  future: _futureTipoGasto,
                  getDisplayValue: (value) => value.tipoGasto,
                  selectedValue: _selectedGasto,
                  hint: "Seleccionar Gasto",
                  // items: gastosProvider.tiposGastos
                ),
              ),

            ],
          ),
        ),
        body: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text("Folio")),
                  Expanded(child: Text("Tipo")),
                  Expanded(child: Text("Importe")),
                  Expanded(child: Text("Fecha")),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Material(
                child: ListView.builder(
                  itemCount: gastosProvider.gastos.length,
                  itemBuilder: (context, index) {
                    GastoEntity gasto = gastosProvider.gastos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(gasto.folioVentas != null ? gasto.folioVentas.toString() : "")),
                            Expanded(child: Text(gasto.tipoGasto, style: textStyle(context),)),
                            Expanded(child: Text(gasto.importe.toString(), style: textStyle(context))),
                            Expanded(child: Text(DateFormat("yyyy:MM:dd").format(gasto.fecha), style: textStyle(context))),
                          ],
                        ),
                        onTap: () async {
                          // await NavigationService.navigate(context, ViewServiceScreen(service: service,));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        )
      );
  }

  TextStyle textStyle(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium!;
  }

}
