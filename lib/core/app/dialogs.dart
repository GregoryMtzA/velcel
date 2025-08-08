import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velcel/features/widgets/dialogs/await_confirm_dialog.dart';
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

  static Future<bool> awaitConfirmDialog({
    required BuildContext context,
    required String title,
    required String textButton,
  }) async {
    // 1️⃣ Lanza el diálogo y espera su resultado (true, false o null)
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AwaitConfirmDialog(
        title: title,
        textButton: textButton,
      ),
    );

    // 2️⃣ Si result es true, ejecuta onAccept y devuelve true
    if (result == true) {
      return true;
    }

    // 3️⃣ En cualquier otro caso (false o null), no hace nada y devuelve false
    return false;
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