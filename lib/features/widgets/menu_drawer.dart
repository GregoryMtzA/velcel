import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/presentation/screens/config_screen.dart';
import 'package:velcel/features/gastos/presentation/screens/home_gastos_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/home_inventory_screen.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/screen.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/screen.dart';
import 'package:velcel/features/ventas/presentation/screens/home_ventas_screen.dart';

import '../services/presentation/screens/home_service_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    UserProvider userProvider = context.read();
    BranchProvider branchProvider = context.read();

    return Drawer(
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                children: [
                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.store_outlined),
                        const SizedBox(width: 10,),
                        Text("Tienda")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, HomeScreen.init(context)),
                  ),

                  const SizedBox(height: 10,),

                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.home_repair_service_outlined),
                        const SizedBox(width: 10,),
                        Text("Servicio")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, HomeServiceScreen()),
                  ),

                  const SizedBox(height: 10,),

                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined),
                        const SizedBox(width: 10,),
                        Text("Inventario")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, HomeInventoryScreen()),
                  ),

                  const SizedBox(height: 10,),


                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.sell_outlined),
                        const SizedBox(width: 10,),
                        Text("Ventas")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, HomeVentasScreen()),
                  ),

                  const SizedBox(height: 10,),

                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.payment_outlined),
                        const SizedBox(width: 10,),
                        Text("Gastos")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, HomeGastosScreen()),
                  ),

                  const SizedBox(height: 10,),

                  if (branchProvider.branch!.nombre == "VELCEL AVENTA")
                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.payment_outlined),
                        const SizedBox(width: 10,),
                        Text("Configuración")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, ConfigScreen()),
                  ),

                ],
              ),
            ),
            /// Corte, Sucursal y Usuario
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    tileColor: IsselColors.grisClaro,
                    title: Row(
                      children: [
                        Icon(Icons.money_outlined),
                        const SizedBox(width: 10,),
                        Text("Corte")
                      ],
                    ),
                    onTap: () => NavigationService.navigateTo(context, RegisterClosureScreen.init(context)),
                  ),
                  const SizedBox(height: 10,),
                  Text(branchProvider.branch!.nombre!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: IsselColors.azulSemiOscuro),),
                  Text(userProvider.userEntity!.usuario!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: IsselColors.azulSemiOscuro),)
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
