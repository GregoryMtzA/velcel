import 'package:flutter/material.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
    );
  }
}
