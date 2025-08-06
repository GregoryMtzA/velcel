import 'package:flutter/material.dart';
import '../../features/widgets/snackbars/custom_snackbar.dart';
import 'const.dart';

class SnackbarService{

  static void showCorrect(BuildContext context, String title, String message) async{
    removeCurrent(context);
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar(
        color: AppColors.light,
        title: title,
        message: message,
        icon: Icons.add_task_rounded
      )
    );
  }

  static void showCorrectWithoutRemoveCurrent(BuildContext context, String title, String message) async{
    ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(
            color: AppColors.light,
            title: title,
            message: message,
            icon: Icons.add_task_rounded
        )
    );
  }

  static void showIncorrect(BuildContext context, String title, String message) async{
    removeCurrent(context);
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar(
        color: Colors.red,
        title: title,
        message: message,
        icon: Icons.cancel_outlined
      )
    );
  }

  static removeCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

}