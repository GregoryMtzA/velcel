import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/page_view.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/search_products_widget.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/widgets/buton_app.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

import '../../../../../core/app/enums/enums.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen._();

  static Widget init(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CartState(productRepository: locator(), printerRepository: locator()),)
    ],
    builder: (context, child) => HomeScreen._(),
  );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    PrintersControllers printersControllers = context.read();
    BranchProvider branchProvider = context.read();

    if (branchProvider.branch!.nombre == "VELCEL AVENTA") {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      printersControllers.checkStatusConnect().then((value) {
        value.fold(
              (l) {
            SnackbarService.showIncorrect(context, "Impresora", l);
          },
              (r) {
            SnackbarService.showCorrect(context, "Impresora", "¡Conectada!");
          },
        );
      },);
    },);
    }
  }

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
