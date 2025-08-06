import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/features/store/presentation/screens/register_opening/widgets/register_opening_form.dart';

class RegisterOpening extends StatelessWidget {

  RegisterOpening({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height,
              child: OrientationBuilder(
                builder: (context, orientation) => orientation == Orientation.portrait
                  ? _portraitWidget()
                  : _landscapeWidget(),
              ),
            ),
          ),
        ),
      )
    );
  }

  Row _landscapeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Expanded(
          flex: 3,
          child: Lottie.asset("assets/lotties/cash.json", height: 650),
        ),

        Expanded(
          flex: 2,
          child: RegisterOpeningForm(),
        )

      ],
    );
  }

  Column _portraitWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Lottie.asset("assets/lotties/cash.json", height: 500),

        RegisterOpeningForm(),


      ],
    );
  }

}
