import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velcel/features/widgets/dialogs/info_dialog.dart';

import '../../features/widgets/dialogs/confirm_dialog.dart';
import '../../features/widgets/dialogs/input_dialog.dart';

class DialogService {

  static void confirmDialog({required BuildContext context, required String title, required String textButton, required Function() onAccept}) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        textButton: textButton,
        onAccept: onAccept,
      ),
    );
  }

  static void infoDialog({required BuildContext context, required String title, required String text, bool barrierDismissible = true, required String backButtonText,
    required Future Function() onTap}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => InfoDialog(
        title: title,
        text: text,
        backButtonText: backButtonText,
        onTap: onTap,
      ),
    );
  }

  static inputDialog({required BuildContext context, required String title,
    required IconData icon, required String hintText, required List<TextInputFormatter>? inputFormatters,
    required Function(String)? onSubmitted, required String? Function(String?)? validator,
  }) async {

    showDialog(
      context: context,
      builder: (context) => InputDialog(
        title: title,
        icon: icon,
        hintText: hintText,
        inputFormatters: inputFormatters,
        onSubmitted: onSubmitted,
        validator: validator,
      ),
    );

  }

}