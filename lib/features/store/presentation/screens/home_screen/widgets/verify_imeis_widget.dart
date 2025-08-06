import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/store/domain/entities/cart_entity.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/imei_product_entity.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/input_imei_app.dart';

class VerifyImeisWidget extends StatefulWidget {

  VerifyImeisWidget({
    super.key,
  });

  @override
  State<VerifyImeisWidget> createState() => _VerifyImeisWidgetState();
}

class _VerifyImeisWidgetState extends State<VerifyImeisWidget> {


  @override
  Widget build(BuildContext context) {
    CartState cartState = context.read();

    return Form(
      key: cartState.formKeyValidate,
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(15)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Verificar Imeis", style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 15,),
              Expanded(
                child: ListView.builder(
                  itemCount: cartState.imeiProductEntitiesCart.length,
                  itemBuilder: (context, index) {

                    ImeiProductEntity imeiProductEntity = cartState.imeiProductEntitiesCart[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(imeiProductEntity.cartProductEntity.product.name, maxLines: 1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: IsselColors.azulSemiOscuro),),
                            ),
                          ),

                          const SizedBox(width: 10,),

                          Expanded(
                              flex: 4,
                              child: InputImeiApp(
                                imeiProductEntity: imeiProductEntity,
                              )
                          )

                        ],
                      ),
                    );
                
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
