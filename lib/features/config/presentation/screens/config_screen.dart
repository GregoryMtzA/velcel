import 'package:flutter/material.dart';
import 'package:velcel/features/config/presentation/screens/configurar_impresora.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

import '../../../../core/app/navigation.dart';
import '../../../services/presentation/widgets/rounded_button_service.dart';

class ConfigScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ConfigScreen({super.key});

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
              text: "Impresora",
              icon: Icons.print,
              onTap: () async => NavigationService.navigate(context, ConfigurarImpresora()),
            ),
          ],
        ),
      ),
    );
  }
}
