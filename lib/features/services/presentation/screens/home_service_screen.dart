import 'package:flutter/material.dart';
import 'package:velcel/core/app/navigation.dart';

import '../../../widgets/menu_drawer.dart';
import '../widgets/rounded_button_service.dart';
import 'order_service_screen.dart';
import 'view_services_screen.dart';

class HomeServiceScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeServiceScreen({super.key});

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
              text: "Crear Orden",
              icon: Icons.design_services_outlined,
              onTap: () async => NavigationService.navigate(context, OrderServiceScreen()),
            ),

            const SizedBox(width: 25,),

            RoundedButtonService(
              text: "Ver Servicios",
              icon: Icons.home_repair_service_outlined,
              onTap: () async => NavigationService.navigate(context, ViewServicesScreen()),
            ),

          ],
        ),
      ),
    );
  }
}


