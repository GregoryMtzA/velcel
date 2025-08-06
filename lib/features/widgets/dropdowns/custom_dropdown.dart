import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import '../../../core/app/snackbars.dart';
import '../../../core/app/theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final void Function(T? value)? onChanged;
  final Future<dartz.Either<String, List<T>>>? future;
  final String Function(T) getDisplayValue;
  final T? selectedValue;
  final String hint;
  // final List<T>? items;

  CustomDropdown({
    super.key,
    required this.onChanged,
    required this.getDisplayValue,
    this.selectedValue,
    // this.items,
    this.future,
    this.hint = 'Seleccionar',
  });

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {

        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }

        final response = snapshot.data!;

        return response.fold(
          (l) {
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
              SnackbarService.showIncorrect(context, "Error", l);
            });
            return Center(child: CircularProgressIndicator(),);
          },
          (r) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: IsselColors.grisClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButton<T>(
                padding: EdgeInsets.symmetric(horizontal: 10),
                value: selectedValue,
                hint: Text(
                  hint,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                isExpanded: true,
                isDense: false,
                underline: const SizedBox(),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(20),
                items: r.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      getDisplayValue(item),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            );
          },
        );

      },
    );
  }
}