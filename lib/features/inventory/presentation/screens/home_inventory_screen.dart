import 'package:flutter/material.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/inventory/presentation/screens/altas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/bajas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/view_inventory_screen.dart';

import '../../../services/presentation/screens/order_service_screen.dart';
import '../../../services/presentation/screens/view_services_screen.dart';
import '../../../services/presentation/widgets/rounded_button_service.dart';
import '../../../widgets/menu_drawer.dart';

class HomeInventoryScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeInventoryScreen({super.key});

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
              text: "Inventario",
              icon: Icons.inventory_outlined,
              onTap: () async => NavigationService.navigate(context, ViewInventoryScreen()),
            ),

            const SizedBox(width: 25,),

            RoundedButtonService(
              text: "Altas",
              icon: Icons.add_business_outlined,
              onTap: () async => NavigationService.navigate(context, AltasInventoryScreen()),
            ),

            const SizedBox(width: 25,),

            RoundedButtonService(
              text: "Bajas",
              icon: Icons.add_business_outlined,
              onTap: () async => NavigationService.navigate(context, BajasInventoryScreen()),
            ),

          ],
        ),
      ),
    );
  }


}


