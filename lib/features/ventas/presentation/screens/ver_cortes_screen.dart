import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';

import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:velcel/features/ventas/domain/entities/corte_entity.dart';
import 'package:velcel/features/ventas/presentation/providers/ventas_provider.dart';
import 'package:velcel/features/widgets/date_picker/multi_date_picker.dart';


class VerCortesScreen extends StatefulWidget {

  const VerCortesScreen({super.key});

  @override
  State<VerCortesScreen> createState() => _AltasInventoryScreenState();
}

class _AltasInventoryScreenState extends State<VerCortesScreen> {

  List<CorteEntity> cortes = [];
  DateTime initDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Seleccionar Fecha:", style: Theme.of(context).textTheme.bodyLarge,),

              const SizedBox(width: 20,),

              MultiDatePicker(
                onChange: (date) async {

                  VentasProvider ventasProvider = context.read();
                  BranchProvider branchProvider = context.read();
                  String branch = branchProvider.branch!.nombre;

                  initDate = date[0];
                  endDate = date[1];

                  dartz.Either<String, List<CorteEntity>> response = await ventasProvider.getCortesWithDate(initDate, endDate, branch);

                  response.fold(
                    (l) {
                      SnackbarService.showIncorrect(context, "Cortes", l);
                    },
                    (r) {
                      cortes = r;
                      setState(() {});
                    },
                  );

                },
                dates: [initDate, endDate],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text("Usuario")),
                  Expanded(child: Text("Apertura")),
                  Expanded(child: Text("Cierre")),
                  Expanded(child: Text("Cant. Efectivo")),
                  Expanded(child: Text("Cant. Tarjeta")),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Material(
                child: ListView.builder(
                  itemCount: cortes.length,
                  itemBuilder: (context, index) {
                    CorteEntity corte = cortes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(corte.usuario)),
                            Expanded(child: Text(DateFormat("yyyy:MM:dd").format(corte.fechaapertura), style: textStyle(context),)),
                            Expanded(child: Text(DateFormat("yyyy:MM:dd").format(corte.fechacierre), style: textStyle(context))),
                            Expanded(child: Text(corte.cantidadefectivo.toStringAsFixed(2), style: textStyle(context))),
                            Expanded(child: Text(corte.cantidadtarjeta.toStringAsFixed(2), style: textStyle(context))),
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
