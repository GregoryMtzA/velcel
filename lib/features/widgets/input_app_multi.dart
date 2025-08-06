import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputAppMulti extends StatefulWidget {

  String hintText;
  TextEditingController? controller;
  IconData? icon;
  bool obscureText;
  bool expands;
  TextInputType? keyboardType;
  String? Function(String? value)? validator;
  void Function(String)? onChanged;
  String? initValue;
  bool readOnly;
  List<TextInputFormatter>? inputFormatters;
  EdgeInsetsGeometry? contentPadding;
  Color fillColor;
  int? maxLines;
  void Function(String value)? onFieldSubmitted;


  InputAppMulti({
    super.key,
    required this.hintText,
    this.icon,
    this.maxLines,
    this.controller,
    this.expands = false,
    this.initValue,
    this.obscureText = false,
    this.inputFormatters,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.fillColor = Colors.white,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.keyboardType,
    this.onFieldSubmitted
  });

  @override
  State<InputAppMulti> createState() => _InputAppState();
}

class _InputAppState extends State<InputAppMulti> {

  late bool obscureText;

  @override
  void initState() {
    obscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initValue,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscureText,
      maxLines: widget.maxLines,
      expands: widget.expands,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffixIcon: widget.obscureText ? _iconButton() : null,
          contentPadding: widget.contentPadding,
          filled: true,
          fillColor: widget.fillColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none
          )
      ),
    );
  }

  IconButton _iconButton(){
    return IconButton(
      icon: const Icon(Icons.remove_red_eye_outlined),
      onPressed: () {
        obscureText = !obscureText;
        setState(() {});
      },
    );
  }

}
