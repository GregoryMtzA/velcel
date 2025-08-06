import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/auth/presentation/screens/login/widgets/login_form_users.dart';
import 'package:velcel/features/widgets/buton_app.dart';
import 'package:velcel/features/widgets/input_app.dart';

import '../../../../../../core/app/theme.dart';
import '../../../../../store/presentation/screens/register_opening/screen.dart';

class LoginForm extends StatefulWidget {


  LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController userController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  late final _formKey;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.read();
    BranchProvider branchProvider = context.read();

    return SafeArea(
      child: Form(
        key: _formKey,
        child: Stack(
          children: [
            // TEXTO
            Positioned(
              top: 20,
              child: Text(branchProvider.branch!.nombre, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: IsselColors.azulClaro, fontWeight: FontWeight.bold),)
            ),

            // FORMULARIO
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("Comencemos", style: Theme.of(context).textTheme.titleSmall,),

                const SizedBox(height: 50,),


                /// USUARIO
                const LoginFormUsers(),

                const SizedBox(height: 20,),

                InputApp(
                  hintText: "Contraseña",
                  icon: Icons.password,
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty) return "Ingresa una contraseña";
                  },
                  obscureText: true,
                ),

                const SizedBox(height: 30,),

                ButtonApp(
                  text: "Ingresar",
                  onTap: () async {

                    if (!_formKey.currentState!.validate()){
                      return;
                    }

                    if (userProvider.userEntity!.clave == passwordController.text){
                      SnackbarService.showCorrect(
                        context,
                        "Login",
                        "Ingreso Correcto"
                      );
                      await NavigationService.navigateTo(context, RegisterOpening());
                    } else {
                      SnackbarService.showIncorrect(
                        context,
                        "Login",
                        "Las Credenciales no coinciden"
                      );
                    }

                  },
                )

              ],
            ),
          ],
        ),
      ),
    );
  }
}
