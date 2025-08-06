import 'package:flutter/material.dart';

import '../../core/app/theme.dart';

class ButtonApp extends StatefulWidget {

  String text;
  Future Function() onTap;
  double borderRadius;

  ButtonApp({
    super.key,
    required this.text,
    required this.onTap,
    this.borderRadius = 10,
  });

  @override
  State<ButtonApp> createState() => _ButtonAppState();
}

class _ButtonAppState extends State<ButtonApp> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: !loading ? IsselColors.azulSemiOscuro : IsselColors.grisClaro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius))
        ),
        onPressed: !loading ? () async {
          loading = true;
          setState(() {});
          await widget.onTap();
          loading = false;
          setState(() {});
        } : null,
        child: Text(widget.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),),
      ),
    );
  }
}
