import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/presentation/providers/products_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_product_widget.dart';
import '../../../../../../utils/productos.dart';
import '../../../../../widgets/input_app.dart';

class SearchProductsWidget extends StatelessWidget {

  VoidCallback onTapMenu;

  SearchProductsWidget({super.key, required this.onTapMenu});

  TextEditingController searchProductController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    CartState cartState = context.read();
    BranchProvider branchProvider = context.read();
    ProductsProvider productsProvider = context.watch();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10, top: 10),
      child: Column(
        children: [

          Row(
            children: [
              IconButton(
                onPressed: onTapMenu,
                icon: Icon(Icons.menu_outlined)
              ),
              Expanded(
                child: InputApp(
                  hintText: "Buscar",
                  icon: Icons.search_outlined,
                  onFieldSubmitted: (value) => productsProvider.searchProductWithName(value, branchProvider.branch!.tipo!),
                  controller: TextEditingController(),
                ),
              )
            ],
          ),

          const SizedBox(height: 20,),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
              ),
              itemCount: productsProvider.products.length,
              itemBuilder: (context, index) {

                ProductEntity producto = productsProvider.products[index];

                return CartProductWidget(
                  producto: producto,
                  onTap: () async {

                    Either<String, String> response = await cartState.addProduct(producto, branchProvider.branch!.nombre);

                    response.fold(
                      (l) => SnackbarService.showIncorrect(context, "Stock", l),
                      (r) => SnackbarService.showCorrect(context, "Stock", r),
                    );

                  }
                );

              },
            ),
          )

        ],
      ),
    );
  }
}
