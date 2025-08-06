import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/services/domain/entities/service_entity.dart';
import 'package:velcel/features/services/presentation/providers/services_provider.dart';
import 'package:velcel/features/services/presentation/screens/home_service_screen.dart';

import '../../../widgets/impresora/reporte_servicio.dart';
import '../../domain/entities/reporte_servicio_entity.dart';
import '../widgets/service_device_data.dart';
import '../widgets/service_order_client_widget.dart';
import '../widgets/service_service_data.dart';

class OrderServiceScreen extends StatefulWidget {


  OrderServiceScreen({super.key});

  @override
  State<OrderServiceScreen> createState() => _OrderServiceScreenState();
}

class _OrderServiceScreenState extends State<OrderServiceScreen> {

  TextEditingController contactNumber = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController brand = TextEditingController();
  TextEditingController IMEI = TextEditingController();
  TextEditingController model = TextEditingController();
  TextEditingController series = TextEditingController();
  TextEditingController shortDescription = TextEditingController();
  TextEditingController reportedFault = TextEditingController();
  TextEditingController observations = TextEditingController();
  DateTime collectionDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: !loading ? () async => await _onAddService(context) : null,
        child: Icon(Icons.add_outlined, color: !loading ? IsselColors.azulSemiOscuro : IsselColors.grisClaro,),
      ),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  /// CLIENTE Y EQUIPO
                  Container(
                    height: MediaQuery.sizeOf(context).height * (error ? 0.35 : 0.30),
                    child: Row(
                      children: [
                        /// DATOS DEL CLIENTE
                        Expanded(
                          flex: 2,
                          child: _Decoration(ServiceOrderClientWidget(
                            contactNumber: contactNumber,
                            customerName: customerName
                          )),
                        ),

                        const SizedBox(width: 20,),

                        /// DATOS DEL EQUIPO
                        Expanded(
                          flex: 3,
                          child: _Decoration(ServiceDeviceData(
                            brand: brand,
                            IMEI: IMEI,
                            model: model,
                            series: series,
                            shortDescription: shortDescription,
                          )),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20,),

                  /// SERVICIO
                  Container(
                    height: MediaQuery.sizeOf(context).height * (error ? 0.48 : 0.40),
                    child: Row(
                      children: [
                        /// DATOS DEL SERVICIO
                        Expanded(
                          child: _Decoration(ServiceServiceData(
                            collectionDate: collectionDate,
                            observations: observations,
                            reportedFault: reportedFault,
                          )),
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Future<void> _onAddService(BuildContext context) async {

    loading = true;
    setState(() {});

    if (!_formKey.currentState!.validate()) {
      loading = false;
      error = true;
      setState(() {});
      return ;
    };

    error = false;

    ServicesProvider servicesProvider = context.read();
    BranchProvider branchProvider = context.read();
    UserProvider userProvider = context.read();

    dartz.Either<String, ServiceEntity> response = await servicesProvider.createService(
      branchProvider.branch!.nombre,
      userProvider.userEntity!.usuario,
      customerName.text,
      contactNumber.text,
      brand.text,
      model.text,
      series.text,
      shortDescription.text,
      IMEI.text,
      collectionDate,
      reportedFault.text,
      observations.text
    );

    response.fold(
      (l) {
        SnackbarService.showIncorrect(context, "Servicio", l);
      },
      (r) async {

        // Generar entidad de ticket
        ReporteServicioEntity ticketEntity = ReporteServicioEntity(
            sucursal: branchProvider.branch!.nombre,
            fecha: r.fechaRec,
            cliente: r.cliente,
            descripcionCorta: r.descCorta,
            fallaReportada: r.fallaRep,
            fechaEstimada: r.fechaSal,
            folio: r.folio,
            imei: r.imei,
            marca: r.marca,
            modelo: r.modelo,
            observacionLlega: r.observLleg,
            serie: r.serie
        );
        // Guardar Ticket
        await generarReporteServicio(ticketEntity);
        SnackbarService.showCorrectWithoutRemoveCurrent(context, "servicio", "Generado exitosamente");

        DialogService.infoDialog(
          context: context,
          barrierDismissible: false,
          title: "Numero de fólio",
          text: r.folio.toString(),
          backButtonText: "Copiar",
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: r.folio.toString()));
            SnackbarService.showCorrectWithoutRemoveCurrent(context, "servicio", "Folio copiado");
            await NavigationService.navigateTo(context, HomeServiceScreen());
          },
        );

      },
    );

  }

  Container _Decoration(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25)
      ),
      padding: EdgeInsets.all(10),
      child: child,
    );
  }
}
