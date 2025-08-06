import 'package:flutter/material.dart';

class CustomDialog {

  static Future<void> execute(BuildContext context, CustomDialogType type) async {

    showDialog(
      context: context,
      builder: (context) => type.build(context)
    );
  }

}

// Clase abstracta para definir los tipos de diálogos personalizados
abstract class CustomDialogType {
  Widget build(BuildContext context);
}

// Ejemplo de un tipo de diálogo personalizado
class CustomInfoDialog extends CustomDialogType {

  final String title;
  final String content;
  final VoidCallback onTap;

  CustomInfoDialog({required this.title, required this.content, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onTap();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}