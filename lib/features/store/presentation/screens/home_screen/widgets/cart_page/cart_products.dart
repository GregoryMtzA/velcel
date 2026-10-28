import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page_list_products_widget.dart';

class PageCart extends StatelessWidget {
  const PageCart({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 4,
          child: CartPageListProductsWidget(),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
              ),
              const SizedBox(height: 4),
              IsselPill(
                text: '\$ ${cartState.total.toStringAsFixed(2)}',
                height: 42,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: colors.surface,
                textColor: colors.primary,
              ),
              const SizedBox(height: 12),
              IsselButton(
                text: 'Proceder a la compra',
                height: 50,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
