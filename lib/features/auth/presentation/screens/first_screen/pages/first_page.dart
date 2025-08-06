import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../../widgets/buton_app.dart';

class FirstPage extends StatelessWidget {

  VoidCallback onTap;

  FirstPage({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => orientation == Orientation.portrait
        ? _portraitWidget(context)
        : _landscapeWidget(context)
    );
  }

  Widget _portraitWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [

          /// Lottie
          Lottie.asset('assets/lotties/location.json', width: 500),

          /// Text
          Text("VelCel App", style: Theme.of(context).textTheme.titleLarge,),

          const SizedBox(height: 20,),

          Text("Selecciona la sucursal", style: Theme.of(context).textTheme.bodySmall,),

          const SizedBox(height: 50,),

          /// Button
          ButtonApp(
            text: "Seleccionar",
            onTap: () async {
              onTap();
            },
          )

        ],
      ),
    );
  }

  Widget _landscapeWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Row(
        children: [

          /// Lottie
          Lottie.asset('assets/lotties/location.json', width: 500),

          const SizedBox(width: 50,),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Text
                Text("VelCel App", style: Theme.of(context).textTheme.titleLarge,),

                const SizedBox(height: 20,),

                Text("Selecciona la sucursal", style: Theme.of(context).textTheme.bodySmall,),

                const SizedBox(height: 50,),

                /// Button
                ButtonApp(
                  text: "Seleccionar",
                  onTap: () async {
                    onTap();
                  },
                )
              ],
            )
          )

        ],
      ),
    );
  }

}
