import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/widgets/input_app_multi.dart';

import '../../../../../../core/app/expresiones_regulares.dart';
import '../../../../../widgets/input_app.dart';

class RegisterInputApp extends StatelessWidget {

  String hintText;
  TextEditingController? controller;
  TextInputType? keyboardType;
  bool expands;
  String? Function(String? value)? validator;
  void Function(String)? onChanged;
  String? initValue;
  bool readOnly;
  List<TextInputFormatter>? inputFormatters;
  Color fillColor;
  int? maxLines;

  RegisterInputApp({
    super.key,
    required this.hintText,
    this.controller,
    this.expands = false,
    this.maxLines,
    this.initValue,
    this.inputFormatters,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.fillColor = Colors.white,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(hintText, textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: IsselColors.azulSemiOscuro),),
        const SizedBox(height: 5),
        if (expands)
        Expanded(
          child: InputAppMulti(
            maxLines: maxLines,
            expands: expands,
            fillColor: fillColor,
            hintText: hintText,
            initValue: initValue,
            controller: controller,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onChanged: onChanged,
            validator: validator,
            keyboardType: keyboardType,
          ),
        ),
        if (!expands)
        InputApp(
          expands: expands,
          fillColor: fillColor,
          hintText: hintText,
          initValue: initValue,
          controller: controller,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
