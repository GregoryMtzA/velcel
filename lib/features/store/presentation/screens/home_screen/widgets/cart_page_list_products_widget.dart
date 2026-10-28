import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/cart_entity.dart';
import '../states/cart_state.dart';

class CartPageListProductsWidget extends StatelessWidget {
  const CartPageListProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Productos seleccionados',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: cartState.cart.isEmpty
                ? _emptyCart(context)
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 4),
                    itemCount: cartState.cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final cartProduct = cartState.cart[index];
                      return _cartItem(context, cartState, cartProduct);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(
    BuildContext context,
    CartState cartState,
    CartProductEntity cartProduct,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = cartState.selectedProduct == cartProduct.product;

    return Material(
      color: isSelected ? colors.primaryContainer : colors.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => cartState.selectedProduct = cartProduct.product,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cartProduct.product.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IsselPill(
                text: 'x${cartProduct.quantity}',
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: colors.surface,
                textColor: colors.primary,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 74,
                child: Text(
                  '\$ ${(cartProduct.product.price * cartProduct.quantity).toStringAsFixed(2)}',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Eliminar producto',
                onPressed: () => cartState.deleteProduct(cartProduct),
                icon: Icon(Icons.delete_outline, color: colors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyCart(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Text(
        'Aún no has agregado productos.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.outline,
        ),
      ),
    );
  }
}
