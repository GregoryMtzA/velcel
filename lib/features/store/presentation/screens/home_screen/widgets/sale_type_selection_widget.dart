import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/snackbars.dart';
import '../../../../domain/entities/cart_payment_type.dart';

class SaleTypeSelectionWidget extends StatelessWidget {
  const SaleTypeSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tipo de venta',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona cómo se cobrará esta venta.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
          ),
          const SizedBox(height: 12),
          ...cartPaymentTypes.asMap().entries.expand((entry) {
            final type = entry.value;
            final tile = IsselRadioTile<CartPaymentTypeEntity>(
              value: type,
              groupValue: cartState.cartPaymentType,
              label: type.name,
              alignment: Alignment.centerLeft,
              height: 54,
              surfaceColor: colors.surface,
              onChanged: (value) => _selectType(context, cartState, value),
            );

            return entry.key == cartPaymentTypes.length - 1
                ? [tile]
                : [tile, const SizedBox(height: 8)];
          }),
        ],
      ),
    );
  }

  void _selectType(
    BuildContext context,
    CartState cartState,
    CartPaymentTypeEntity value,
  ) {
    if (value.enumType != PaymentTypes.normal &&
        !cartState.applyForPaguitos()) {
      SnackbarService.showIncorrect(
        context,
        'Tipo de venta',
        'Paguitos y Tarifario solo se permiten con un celular.',
      );
      cartState.cartPaymentType = null;
      return;
    }

    cartState.cartPaymentType = value;
  }
}
