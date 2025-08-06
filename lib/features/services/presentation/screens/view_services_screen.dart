import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/services/domain/entities/reporte_servicio_entity.dart';
import 'package:velcel/features/services/domain/entities/service_state_entity.dart';
import 'package:velcel/features/services/presentation/providers/services_provider.dart';
import 'package:velcel/features/services/presentation/screens/view_service_screen.dart';
import 'package:velcel/features/widgets/impresora/reporte_servicio.dart';
import 'package:velcel/features/widgets/input_app.dart';

import '../../domain/entities/service_entity.dart';


class ViewServicesScreen extends StatefulWidget {

  const ViewServicesScreen({super.key});

  @override
  State<ViewServicesScreen> createState() => _ViewServiceScreenState();
}

class _ViewServiceScreenState extends State<ViewServicesScreen> {

  ServiceStateEntity serviceStateEntity = serviceStatesList.first;
  late String branch;
  List<ServiceEntity> services = [];
  late Future<dartz.Either<String, List<ServiceEntity>>> _future;
  TextEditingController folioController = TextEditingController();
  bool loadServices = false;
  bool loadingServices = false;

  @override
  void initState() {
    ServicesProvider servicesProvider = context.read();
    BranchProvider branchProvider = context.read();
    branch = branchProvider.branch!.nombre;

    _future = servicesProvider.getServicesWithState(serviceStateEntity.name, branch);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: InputApp(
                hintText: "Folio",
                fillColor: IsselColors.grisClaro,
                controller: folioController,
                keyboardType: TextInputType.number,
                inputFormatters: [TextInputFormatters().int],
                onFieldSubmitted: (value) async {

                  if (value.isEmpty) {
                    SnackbarService.showIncorrect(context, "Folio", "Ingresa un folio");
                    return ;
                  }

                  ServicesProvider servicesProvider = context.read();

                  dartz.Either<String, ServiceEntity> response = await servicesProvider.getServiceWithFolio(int.parse(value), branch);

                  response.fold(
                    (l) {
                      SnackbarService.showIncorrect(context, "Servicio", l);
                    },
                    (r) {
                      services = [r];
                      setState(() {});
                    },
                  );

                  folioController.clear();

                },
              ),
            ),
            const SizedBox(width: 50,),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: IsselColors.grisClaro,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: DropdownButton(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  value: serviceStateEntity.name,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  items: List.generate(
                    serviceStatesList.length, (index) => DropdownMenuItem(
                      value: serviceStatesList[index].name,
                      child: Text(serviceStatesList[index].name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),)
                  )),
                  onChanged: (value) async {

                    loadingServices = true;
                    setState(() {});
                    serviceStateEntity = serviceStatesList.singleWhere((element) => element.name == value,);

                    ServicesProvider servicesProvider = context.read();

                    dartz.Either<String, List<ServiceEntity>> response = await servicesProvider.getServicesWithState(serviceStateEntity.name, branch);

                    response.fold(
                          (l) {
                        SnackbarService.showIncorrect(context, "Estado de servicio", l);
                      },
                          (r) {
                        services = r;
                      },
                    );

                    loadingServices = false;
                    setState(() {});

                  },
                ),
              )
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {

          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }

          dartz.Either<String, List<ServiceEntity>> response = snapshot.data!;

          return response.fold(
            (l) {
              return Center(child: CircularProgressIndicator(color: Colors.red,),);
            },
            (r) {
              if (loadServices == false){
                services = r;
                loadServices = true;
              }
              return Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text("Folio")),
                        Expanded(child: Text("Cliente")),
                        Expanded(child: Text("Teléfono")),
                        Expanded(child: Text("Marca")),
                        Expanded(child: Text("Modelo")),
                        Expanded(child: Text("Serie")),
                        Expanded(child: Text("IMEI")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        ServiceEntity service = services[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: ListTile(
                            tileColor: Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(service.folio.toString())),
                                Expanded(child: Text(service.cliente, style: textStyle(context),)),
                                Expanded(child: Text(service.telefono, style: textStyle(context))),
                                Expanded(child: Text(service.marca, style: textStyle(context))),
                                Expanded(child: Text(service.modelo, style: textStyle(context))),
                                Expanded(child: Text(service.serie, style: textStyle(context))),
                                Expanded(child: Text(service.imei, style: textStyle(context))),
                              ],
                            ),
                            onTap: () async {
                              await NavigationService.navigate(context, ViewServiceScreen(service: service,));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );


        },
      )
    );
  }
  
  TextStyle textStyle(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium!;
  }
  
}


