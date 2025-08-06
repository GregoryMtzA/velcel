import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/screens/login/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) => orientation == Orientation.portrait
            ? _portraitWidget()
            : _landscapeWidget(context)
        ),
      ),
    );
  }

  Widget _landscapeWidget(BuildContext context) {
    return Row(
      children: [

        /// IMAGE
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.sizeOf(context).height,
                      child: PageView(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset("assets/lotties/01_artificial intelligence.json", fit: BoxFit.contain, height: 500),
                              SizedBox(height: 20),
                              Text(
                                "Gestiona las ventas y el inventario",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset("assets/lotties/05_dataanalytics.json", fit: BoxFit.contain, height: 500),
                              SizedBox(height: 20),
                              Text(
                                "Optimiza tu negocio",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset("assets/lotties/10_working.json", fit: BoxFit.contain, height: 500),
                              SizedBox(height: 20),
                              Text(
                                "Trabaja con mayor comodidad",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(child: Image.asset("assets/logos/velcel.png", height: 100,), left: 20, top: 20,)
                ],
              ),
            ),
          )
        ),

        /// Formulario
        Expanded(
          flex: 2,
          child: Container(
            color: IsselColors.grisClaro,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: LoginForm(),
              ),
            ),
          ),
        )

      ],
    );
  }

  Widget _portraitWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [

            /// IMAGE
            Image.asset("assets/logos/velcel.png", height: 350,),

            const SizedBox(height: 30,),

            /// Formulario
            LoginForm(),

          ],
        ),
      ),
    );
  }
}
