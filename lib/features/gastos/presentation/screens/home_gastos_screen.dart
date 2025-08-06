import 'package:flutter/material.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/gastos/presentation/screens/crear_gasto_screen.dart';
import 'package:velcel/features/gastos/presentation/screens/ver_gastos_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/altas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/bajas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/view_inventory_screen.dart';

import '../../../services/presentation/screens/order_service_screen.dart';
import '../../../services/presentation/screens/view_services_screen.dart';
import '../../../services/presentation/widgets/rounded_button_service.dart';
import '../../../widgets/menu_drawer.dart';

class HomeGastosScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuDrawer(),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Icon(Icons.menu_outlined),
        ),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedButtonService(
              text: "Crear Gasto",
              icon: Icons.inventory_outlined,
              onTap: () async => NavigationService.navigate(context, CrearGastoScreen()),
            ),

            const SizedBox(width: 25,),

            RoundedButtonService(
              text: "Ver Gastos",
              icon: Icons.add_business_outlined,
              onTap: () async => NavigationService.navigate(context, VerGastosScreen()),
            ),

          ],
        ),
      ),
    );
  }


}


