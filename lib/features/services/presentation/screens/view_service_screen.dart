import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/services/domain/entities/service_entity.dart';
import 'package:velcel/features/services/presentation/providers/services_provider.dart';
import 'package:velcel/features/services/presentation/screens/home_service_screen.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/widgets/register_input_app.dart';
import 'package:velcel/features/widgets/buton_app.dart';

import '../../domain/entities/service_state_entity.dart';

class ViewServiceScreen extends StatefulWidget  {

  ServiceEntity service;

  ViewServiceScreen({
    super.key,
    required this.service
  });

  @override
  State<ViewServiceScreen> createState() => _ViewServiceScreenState();
}

class _ViewServiceScreenState extends State<ViewServiceScreen> {

  late String serviceStatus;
  TextEditingController observSal = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    serviceStatus = widget.service.estado;
    observSal.text = widget.service.observSal ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Folio: ${widget.service.folio.toString()}"),
        centerTitle: true,
      ),
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

                  Text("Datos recibidos", style: Theme.of(context).textTheme.bodyLarge,),

                  const SizedBox(height: 20,),

                  RegisterInputApp(
                    hintText: "Falla reportada",
                    fillColor: IsselColors.grisClaro,
                    controller: TextEditingController(text: widget.service.fallaRep),
                    readOnly: true,
                  ),

                  const SizedBox(height: 20,),

                  Container(
                    height: 150,
                    child: RegisterInputApp(
                      hintText: "Observaciones a la llegada:",
                      fillColor: IsselColors.grisClaro,
                      controller: TextEditingController(text: widget.service.observLleg),
                      readOnly: true,
                      expands: true,
                    ),
                  ),

                  const SizedBox(height: 20,),

                  Text("Datos de raparación", style: Theme.of(context).textTheme.bodyLarge,),

                  const SizedBox(height: 20,),

                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: IsselColors.grisClaro,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: DropdownButton(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      value: serviceStatus,
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
                        serviceStatus = value!;
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 20,),

                  Container(
                    height: 150,
                    child: RegisterInputApp(
                      hintText: "Obserbaciones en reparación",
                      fillColor: IsselColors.grisClaro,
                      controller: observSal,
                      validator: (value) {
                        if (value!.isEmpty) return "Campo Vacío";
                      },
                      expands: true,
                    ),
                  ),

                  const SizedBox(height: 20,),

                  ButtonApp(
                    text: "Actualizar Servicio",
                    onTap: () async {

                      if (!_formKey.currentState!.validate()) return;

                      ServicesProvider servicesProvider = context.read();
                      UserProvider userProvider = context.read();

                      dartz.Either<String, void> response = await servicesProvider.updateService(
                        observSal.text,
                        serviceStatus,
                        widget.service.folio,
                        userProvider.userEntity!.usuario!
                      );

                      response.fold(
                        (l) {
                          SnackbarService.showIncorrect(context, "Servicio", l);
                        },
                        (r) async {
                          await NavigationService.navigateTo(context, HomeServiceScreen());
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
