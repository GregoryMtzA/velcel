import 'package:flutter/material.dart';

import '../buton_app.dart';

class AwaitConfirmDialog extends StatelessWidget {
  final String title;
  final String textButton;

  const AwaitConfirmDialog({
    Key? key,
    required this.title,
    required this.textButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ButtonApp(
                text: "Cancelar",
                onTap: () async {
                  Navigator.of(context).pop(false); // Devuelve false
                },
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: ButtonApp(
                text: textButton,
                onTap: () async {
                  Navigator.of(context).pop(true); // Devuelve true
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
