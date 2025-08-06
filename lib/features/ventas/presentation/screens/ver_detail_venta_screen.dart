import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/widgets/register_input_app.dart';
import 'package:velcel/features/ventas/domain/entities/imeis_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/productos_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/reporte_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';
import 'package:velcel/features/ventas/presentation/providers/ventas_provider.dart';

class VerDetailVentaScreen extends StatefulWidget {

  SemiReporteVentaEntity semiReporteVentaEntity;
  VerDetailVentaScreen({
    super.key,
    required this.semiReporteVentaEntity,
  });

  @override
  State<VerDetailVentaScreen> createState() => _VerDetailVentaScreenState();
}

class _VerDetailVentaScreenState extends State<VerDetailVentaScreen> {

  late Future<dartz.Either<String, ReporteVentaEntity>> _future;

  @override
  void initState() {
    VentasProvider ventasProvider = context.read();
    _future = ventasProvider.getDetailReportWithFolio(widget.semiReporteVentaEntity.folio, widget.semiReporteVentaEntity.credito);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {

          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }

          final response = snapshot.data!;

          return response.fold(
            (l) {
              WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
                SnackbarService.showIncorrect(context, "Reporte", l);
              },);
              return Center(child: CircularProgressIndicator(),);
            },
            (r) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Productos", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Nombre"),
                                Text("Cantidad"),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Expanded(
                              child: ListView.builder(
                                itemCount: r.productos.length,
                                itemBuilder: (context, index) {
                                  ProductosVentaEntity producto = r.productos[index];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(producto.nombre),
                                      Text(producto.cantidad.toString()),
                                    ],
                                  );
                                },
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("IMEIS", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Imei"),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Expanded(
                                child: ListView.builder(
                                  itemCount: r.imeisVentaEntity.length,
                                  itemBuilder: (context, index) {
                                    ImeisVentaEntity imei = r.imeisVentaEntity[index];
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(imei.imei),
                                      ],
                                    );
                                  },
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Datos de credito (si aplica)", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
                            const SizedBox(height: 10,),
                            RegisterInputApp(
                              hintText: "Nombre:",
                              fillColor: IsselColors.grisClaro,
                              readOnly: true,
                              controller: TextEditingController(text: r.clienteCredito?.first.nombre ?? ""),
                            ),
                            const SizedBox(height: 10,),
                            RegisterInputApp(
                              hintText: "Domicilio:",
                              fillColor: IsselColors.grisClaro,
                              readOnly: true,
                              controller: TextEditingController(text: r.clienteCredito?.first.domicilio ?? ""),
                            ),
                            const SizedBox(height: 10,),
                            RegisterInputApp(
                              hintText: "Telefono:",
                              fillColor: IsselColors.grisClaro,
                              readOnly: true,
                              controller: TextEditingController(text: r.clienteCredito?.first.telefono ?? ""),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

        },
      ),
    );

  }
}
