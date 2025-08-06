import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app/navigation.dart';

// InputDialog
class InputDialog extends StatelessWidget {

  // Constructor
  InputDialog({
    Key? key,
    required this.title,
    required this.icon,
    required this.hintText,
    this.inputFormatters,
    this.onSubmitted,
    this.validator,
  }) : super(key: key);

  // Variables
  final _formKey = GlobalKey<FormState>();
  String title;
  String hintText;
  List<TextInputFormatter>? inputFormatters;
  void Function(String value)? onSubmitted;
  String? Function(String? value)? validator;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    // Return
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: Text("${title}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      content: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 200
        ),
        child: Form(
          key: _formKey,
          child: TextFormField(
            validator: validator,
            autofocus: true,
            inputFormatters: inputFormatters,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).colorScheme.background
                    )
                ),
                icon: Icon(icon)
            ),
            onFieldSubmitted: (value) {
              if (_formKey.currentState!.validate()){
                onSubmitted!(value);
                NavigationService.back(context);
              }
            },
          ),
        ),
      ),
    );
  }
}