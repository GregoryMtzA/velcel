import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/imei_product_entity.dart';

class InputImeiApp extends StatelessWidget {
  const InputImeiApp({
    super.key,
    required this.imeiProductEntity,
  });

  final ImeiProductEntity imeiProductEntity;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IsselTextFormField(
      hintText: 'Ingresa el IMEI',
      prefixIcon: Icons.phone_android_outlined,
      controller: imeiProductEntity.imeiController,
      fillColor: colors.surfaceContainer,
      height: 50,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => imeiProductEntity.error = false,
      validator: (value) {
        final cartState = context.read<CartState>();
        final currentImei = value?.trim() ?? '';

        if (currentImei.isEmpty) return 'Completa este campo';

        final duplicateCount = cartState.imeiProductEntitiesCart
            .where(
              (element) => element.imeiController.text.trim() == currentImei,
            )
            .length;

        if (duplicateCount > 1) return 'IMEI repetido';

        if (imeiProductEntity.error) return 'IMEI no válido';

        return null;
      },
    );
  }
}
