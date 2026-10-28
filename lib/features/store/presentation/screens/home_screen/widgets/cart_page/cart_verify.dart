import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/credit_form_widget.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/sale_type_selection_widget.dart';

import '../../../../../../../core/app/enums/enums.dart';
import '../../states/cart_state.dart';
import '../verify_imeis_widget.dart';

class CartVerify extends StatefulWidget {
  const CartVerify({super.key});

  @override
  State<CartVerify> createState() => _CartVerifyState();
}

class _CartVerifyState extends State<CartVerify> {
  bool _isValidating = false;

  Future<void> _validateAndContinue() async {
    if (_isValidating) return;

    final cartState = context.read<CartState>();
    final paymentType = cartState.cartPaymentType;

    if (paymentType == null) {
      SnackbarService.showIncorrect(
        context,
        'Tipo de venta',
        'Selecciona un tipo de venta',
      );
      return;
    }

    if (paymentType.enumType != PaymentTypes.normal &&
        !(cartState.creditFormKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isValidating = true);

    try {
      await cartState.verifyImei();

      if (!mounted) return;

      final imeisAreValid =
          cartState.formKeyValidate.currentState?.validate() ?? true;
      if (!imeisAreValid) {
        return;
      }

      cartState.cartState = CartStates.purchase;
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SaleTypeSelectionWidget(),
                if (cartState.cartPaymentType != null) ...[
                  if (cartState.cartPaymentType!.enumType !=
                      PaymentTypes.normal) ...[
                    const SizedBox(height: 16),
                    const CreditFormWidget(),
                  ],
                  const SizedBox(height: 16),
                  const VerifyImeisWidget(),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: IsselButton(
            text: _isValidating ? 'Validando...' : 'Verificar IMEIs',
            height: 50,
            onTap: _isValidating ? null : _validateAndContinue,
          ),
        ),
      ],
    );
  }
}
