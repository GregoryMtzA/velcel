import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/widgets/buton_app.dart';

// InfoDialog
class InfoDialog extends StatelessWidget {

  // Constructor
  InfoDialog({
    Key? key,
    required this.title,
    required this.text,
    required this.backButtonText,
    required this.onTap,
  }) : super(key: key);

  // Variables
  String title;
  String text;
  String backButtonText;
  Future Function() onTap;

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
        Container(
          height: 90,
          child: Column(
            children: [
              Text("${text}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20,),
              Expanded(
                child: ButtonApp(
                  text: backButtonText,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}