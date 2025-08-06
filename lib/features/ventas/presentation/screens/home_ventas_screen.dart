import 'package:flutter/material.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/inventory/presentation/screens/altas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/bajas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/view_inventory_screen.dart';
import 'package:velcel/features/ventas/presentation/screens/ver_cortes_screen.dart';
import 'package:velcel/features/ventas/presentation/screens/ver_ventas_screen.dart';

import '../../../services/presentation/screens/order_service_screen.dart';
import '../../../services/presentation/screens/view_services_screen.dart';
import '../../../services/presentation/widgets/rounded_button_service.dart';
import '../../../widgets/menu_drawer.dart';
import '../../domain/entities/semi_reporte_venta_entity.dart';

class HomeVentasScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeVentasScreen({super.key});

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
              text: "Ventas",
              icon: Icons.inventory_outlined,
              onTap: () async => NavigationService.navigate(context, VerVentasScreen()),
            ),

            const SizedBox(width: 25,),

            RoundedButtonService(
              text: "Cortes",
              icon: Icons.add_business_outlined,
              onTap: () async => NavigationService.navigate(context, VerCortesScreen()),
            ),

          ],
        ),
      ),
    );
  }


}


