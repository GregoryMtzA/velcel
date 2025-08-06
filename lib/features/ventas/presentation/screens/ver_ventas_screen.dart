import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:velcel/features/ventas/data/models/semi_reporte_venta_model.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';
import 'package:velcel/features/ventas/presentation/providers/ventas_provider.dart';
import 'package:velcel/features/ventas/presentation/screens/ver_detail_venta_screen.dart';

import '../../../../core/app/navigation.dart';
import '../../../../core/app/snackbars.dart';
import '../../../../core/app/theme.dart';
import '../../../widgets/date_picker/multi_date_picker.dart';
import '../../../widgets/input_app.dart';


class VerVentasScreen extends StatefulWidget {
  const VerVentasScreen({super.key});

  @override
  State<VerVentasScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<VerVentasScreen> {

  late TextEditingController folioController = TextEditingController();
  List<SemiReporteVentaEntity> semiReportes = [];
  DateTime initDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    VentasProvider ventasProvider = context.read();
    BranchProvider branchProvider = context.read();

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              /// BUSQUEDA POR FOLIO
              Expanded(
                child: InputApp(
                  hintText: "Folio",
                  fillColor: IsselColors.grisClaro,
                  keyboardType: TextInputType.number,
                  inputFormatters: [TextInputFormatters().int],
                  controller: folioController,
                  onFieldSubmitted: (value) async {

                    if (value.isEmpty) {
                      SnackbarService.showIncorrect(context, "Folio", "Ingresa un folio");
                      return ;
                    }

                    final response = await ventasProvider.getSemiReportsWithFolio(branchProvider.branch!.nombre, int.parse(value));

                    response.fold(
                      (l) {
                        SnackbarService.showIncorrect(context, "Inventario", l);
                      },
                      (r) {
                        folioController.clear();
                        semiReportes = r;
                        setState(() {});
                      },
                    );

                  },
                ),
              ),

              const SizedBox(width: 50,),

              /// Seleccion de FECHA
              Expanded(
                child: MultiDatePicker(
                  onChange: (date) async {
                
                    VentasProvider ventasProvider = context.read();
                    BranchProvider branchProvider = context.read();
                    String branch = branchProvider.branch!.nombre;
                
                    initDate = date[0];
                    endDate = date[1];
                
                    dartz.Either<String, List<SemiReporteVentaEntity>> response = await ventasProvider.getSemiReportsWithDate(branch, initDate, endDate);
                
                    response.fold(
                      (l) {
                        SnackbarService.showIncorrect(context, "Cortes", l);
                      },
                      (r) {
                        semiReportes = r;
                        setState(() {});
                      },
                    );
                
                  },
                  dates: [initDate, endDate],
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
                  Expanded(child: Text("Total")),
                  Expanded(child: Text("Método")),
                  Expanded(child: Text("Credito")),
                  Expanded(child: Text("Fecha")),
                  Expanded(child: Text("Vendedor")),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Material(
                child: ListView.builder(
                  itemCount: semiReportes.length,
                  itemBuilder: (context, index) {
                    SemiReporteVentaEntity semiReporte = semiReportes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(semiReporte.folio.toString())),
                            Expanded(child: Text(semiReporte.total.toStringAsFixed(2), style: textStyle(context),)),
                            Expanded(child: Text(semiReporte.metodo, style: textStyle(context))),
                            Expanded(child: Text(semiReporte.credito, style: textStyle(context))),
                            Expanded(child: Text(DateFormat("yyyy:MM:dd").format(semiReporte.fecha), style: textStyle(context))),
                            Expanded(child: Text(semiReporte.usuario, style: textStyle(context))),
                          ],
                        ),
                        onTap: () async {

                          final response = await ventasProvider.getDetailReportWithFolio(semiReporte.folio, semiReporte.credito);

                          response.fold(
                            (l) {
                              print(l);
                            },
                            (r) {
                              print(r);
                              print(r.productos);
                            },
                          );

                          await NavigationService.navigate(context, VerDetailVentaScreen(semiReporteVentaEntity: semiReporte,));
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
