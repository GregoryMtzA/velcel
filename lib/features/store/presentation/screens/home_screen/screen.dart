import 'package:flutter/material.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/page_view.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/search_products_widget.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/widgets/buton_app.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

import '../../../../../core/app/enums/enums.dart';

class HomeScreen extends StatelessWidget {

  HomeScreen._();

  static Widget init(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CartState(productRepository: locator()),)
    ],
    builder: (context, child) => HomeScreen._(),
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.watch();

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuDrawer(),
      body: SafeArea(
        child: Row(
          children: [

            /// Productos
            Expanded(
              flex: 5,
              child: cartState.cartState == CartStates.cart
                ? SearchProductsWidget(
                    onTapMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  )
                : Center(
                  child: SizedBox(
                    width: 300,
                    child: ButtonApp(
                      onTap: () async {
                        cartState.cartState = CartStates.cart;
                      },
                      text: "Regresar",
                    ),
                  ),
                )
            ),

            /// Carrito
            Expanded(
              flex: 3,
              child: CartPageWidget()
            )

          ],
        ),
      ),
    );
  }
}
