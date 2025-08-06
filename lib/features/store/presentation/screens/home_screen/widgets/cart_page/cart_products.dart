import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page_list_products_widget.dart';
import 'package:velcel/features/widgets/buton_app.dart';
import 'package:velcel/features/widgets/image_app.dart';

import '../../../../../../../core/app/theme.dart';

class PageCart extends StatelessWidget {

  VoidCallback onTap;

  PageCart({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.watch();

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.sizeOf(context).height-20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// Productos
            Expanded(
                flex: 4,
                child: CartPageListProductsWidget()
            ),

            /// TOTALES
            Expanded(
              // PRUEBA
              flex: 2,
              child: Container(
                color: IsselColors.grisMedio,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Row(
                  children: [

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total:", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.tertiary),),
                              Text("\$ ${cartState.total.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: IsselColors.azulClaro),)
                            ],
                          ),

                          ButtonApp(
                            text: "Proceder a la compra",
                            onTap: () async => onTap(),
                          )

                        ],
                      )
                    ),

                    const SizedBox(width: 20,),

                    ImageApp(
                      url: cartState.selectedProduct?.image
                    )

                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
