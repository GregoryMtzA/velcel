import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/page_view.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/search_products_widget.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

import '../../../../../core/app/enums/enums.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen._();

  static Widget init(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CartState(
                productRepository: locator(),
                printerRepository: locator(),
                branchProvider: context.read()),
          )
        ],
        builder: (context, child) => const HomeScreen._(),
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

    // Impresora Liberada
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(selected: MenuDestination.store),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding =
                constraints.maxWidth >= 1200 ? 32.0 : 20.0;
            const verticalPadding = 20.0;
            const gap = 20.0;

            final products = _productsPanel(
              context,
              cartState,
            );
            final cart = _cartPanel(context);

            if (!isWide) {
              return Column(
                children: [
                  Expanded(child: products),
                  const SizedBox(height: gap),
                  Expanded(child: cart),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: products),
                  const SizedBox(width: gap),
                  Expanded(flex: 3, child: cart),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _productsPanel(BuildContext context, CartState cartState) {
    if (cartState.cartState != CartStates.cart) {
      return _surfacePanel(
        context,
        child: Center(
          child: SizedBox(
            width: 220,
            child: IsselButton(
              text: 'Volver a productos',
              height: 52,
              onTap: () => cartState.cartState = CartStates.cart,
            ),
          ),
        ),
      );
    }

    return _surfacePanel(
      context,
      child: SearchProductsWidget(
        onTapMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _cartPanel(BuildContext context) {
    return _surfacePanel(
      context,
      child: CartPageWidget(),
    );
  }

  Widget _surfacePanel(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
