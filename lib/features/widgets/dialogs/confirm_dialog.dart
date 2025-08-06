import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/widgets/buton_app.dart';

// ConfirmDialog
class ConfirmDialog extends StatelessWidget {

  // Constructor
  ConfirmDialog({
    Key? key,
    required this.title,
    required this.textButton,
    required this.onAccept
  }) : super(key: key);

  // Variables
  String title;
  String textButton;
  VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    // Return
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: Text("${title}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      actions: [
        Row(
          children: [
            Expanded(
              child: ButtonApp(
                text: "Cancelar",
                onTap: () async {
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(width: 5,),
            Expanded(
              child: ButtonApp(
                text: textButton,
                onTap: () async {
                  onAccept();
                },
              ),
            )
          ],
        )
      ],
    );
  }
}