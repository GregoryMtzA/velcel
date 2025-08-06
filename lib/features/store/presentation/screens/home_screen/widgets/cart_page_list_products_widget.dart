import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/cart_entity.dart';
import '../states/cart_state.dart';

class CartPageListProductsWidget extends StatelessWidget {

  CartPageListProductsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.read();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [

          // Columnas
          _columns(context),

          const SizedBox(height: 10,),

          // Lista de productos
          Expanded(
              child: ListView.builder(
                itemCount: cartState.cart.length,
                itemBuilder: (context, index) {

                  CartProductEntity cartProductEntity = cartState.cart[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: cartState.selectedProduct == cartProductEntity.product ? Theme.of(context).colorScheme.background : null,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: 80,
                    child: InkWell(
                      onTap: () => cartState.selectedProduct = cartProductEntity.product,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${cartProductEntity.product.name}", style: Theme.of(context).textTheme.bodySmall, maxLines: 3,)
                          ),

                          const SizedBox(width: 5,),

                          Expanded(
                              child: Text("${cartProductEntity.quantity}", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center,)
                          ),

                          const SizedBox(width: 5,),

                          Expanded(
                              child: Text("${cartProductEntity.product.price * cartProductEntity.quantity}", style: Theme.of(context).textTheme.bodySmall,)
                          ),

                          const SizedBox(width: 5,),

                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () => cartState.deleteProduct(cartProductEntity),
                              icon: Icon(Icons.delete_outline, color: Colors.red,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
          )

        ],
      ),
    );
  }

  Container _columns(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text("Productos", style: Theme.of(context).textTheme.bodyLarge,)
                ),

                const SizedBox(width: 5,),

                Expanded(
                    child: Text("Cant.", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,)
                ),

                const SizedBox(width: 5,),

                Expanded(
                    child: Text("Precio", style: Theme.of(context).textTheme.bodyLarge)
                ),

                const SizedBox(width: 5,),

                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
    );
  }
}
