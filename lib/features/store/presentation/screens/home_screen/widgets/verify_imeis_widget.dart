import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/input_imei_app.dart';

class VerifyImeisWidget extends StatelessWidget {
  const VerifyImeisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = context.read<CartState>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: cartState.formKeyValidate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'IMEIs de los productos',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 36,
                  child: IsselPill(
                    height: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    color: colors.surface,
                    widget: Center(
                      child: Text(
                        '${cartState.imeiProductEntitiesCart.length}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Verifica cada IMEI antes de continuar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.outline,
              ),
            ),
            const SizedBox(height: 14),
            if (cartState.imeiProductEntitiesCart.isEmpty)
              Text(
                'No hay productos que requieran IMEI.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
              )
            else
              ...cartState.imeiProductEntitiesCart.map(
                (imeiProductEntity) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          imeiProductEntity
                              .cartProductEntity.product.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InputImeiApp(
                          imeiProductEntity: imeiProductEntity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
