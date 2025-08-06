import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/errors/exceptions.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/screen.dart';

import '../../../../../../core/dialogs/custom_dialog.dart';
import '../../../../../widgets/input_app.dart';

class RegisterOpeningForm extends StatefulWidget {


  RegisterOpeningForm({super.key});

  @override
  State<RegisterOpeningForm> createState() => _RegisterOpeningFormState();
}

class _RegisterOpeningFormState extends State<RegisterOpeningForm> {
  TextEditingController cashController = TextEditingController();

  late final _formKey;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Cantidad de fondo en caja"),

          const SizedBox(height: 20,),

          Form(
            key: _formKey,
            child: InputApp(
              validator: (p0) {
                if (p0!.isEmpty) return "Ingresa un valor";
                try {

                  double value = double.parse(p0!);

                } catch (e) {

                  return "Ingresa un valor valido";

                }
              },
              hintText: "\$ 500.00",
              icon: Icons.attach_money_outlined,
              controller: cashController,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (value) => onFieldSubmitted(context, value),
            ),
          )
        ],
      ),
    );
  }

  void onFieldSubmitted(BuildContext context, String value) async {

    if (!_formKey.currentState!.validate()){
      return ;
    }

    BranchProvider branchProvider = context.read();
    UserProvider userProvider = context.read();
    CashRegisterProvider cashRegisterProvider = context.read();

    await CustomDialog.execute(
      context,
      CustomInfoDialog(
        title: "Iniciar con",
        content: "\$${value}",
        onTap: () async {



          try {

            await cashRegisterProvider.registerOpening(branchProvider.branch!.nombre, userProvider.userEntity!.usuario!, double.parse(value!));

            await NavigationService.navigateTo(context, HomeScreen.init(context));

          } on ServerException catch (e) {

            SnackbarService.showIncorrect(context, "Error", "Contacte a soporte");

          }

        },
      )
    );

  }
}
