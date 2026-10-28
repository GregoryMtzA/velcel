import 'package:flutter/material.dart';

class NavigationService {
  static Future<void> navigate(BuildContext context, Widget screen) async {
    Navigator.push(context, _materialPageRoute(context, screen));
  }

  static Future<void> navigateTo(BuildContext context, Widget screen) async {
    Navigator.pushReplacement(context, _materialPageRoute(context, screen));
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }

  static Widget appBarLeading(
    BuildContext context, {
    VoidCallback? onMenu,
  }) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      return IconButton(
        tooltip: 'Regresar',
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: () => navigator.maybePop(),
      );
    }

    return Builder(
      builder: (scaffoldContext) => IconButton(
        tooltip: 'Abrir menú',
        icon: const Icon(Icons.menu_outlined),
        onPressed: onMenu ?? () => Scaffold.of(scaffoldContext).openDrawer(),
      ),
    );
  }

  static MaterialPageRoute _materialPageRoute(
      BuildContext context, Widget screen) {
    return MaterialPageRoute(
      builder: (context) => screen,
    );
  }
}
