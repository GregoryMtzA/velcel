import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/expresiones_regulares.dart';

class CartChangeWidget extends StatefulWidget {
  const CartChangeWidget({super.key});

  @override
  State<CartChangeWidget> createState() => _CartChangeWidgetState();
}

class _CartChangeWidgetState extends State<CartChangeWidget> {
  final _receivedController = TextEditingController();
  double _change = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cartState = context.read<CartState>();
    if (cartState.total == 0 && _receivedController.text.isNotEmpty) {
      _receivedController.clear();
      _change = 0;
    }
  }

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = cartState.cartPaymentType?.enumType == PaymentTypes.normal
        ? cartState.total
        : double.tryParse(cartState.creditEnchangeController.text) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IsselTextFormField(
          controller: _receivedController,
          hintText: 'Importe recibido',
          prefixIcon: Icons.attach_money,
          fillColor: colors.surfaceContainer,
          height: 52,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [TextInputFormatters().double],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) => _updateChange(value, total),
          validator: (value) {
            final parsed = double.tryParse(value?.trim() ?? '');
            if (parsed == null) return 'Ingresa una cantidad válida';
            if (parsed < total) return 'La cantidad es menor al total';
            return null;
          },
        ),
        const SizedBox(height: 12),
        IsselInfoField(
          title: 'Cambio',
          value: '\$ ${_change.toStringAsFixed(2)}',
          backColor: colors.surfaceContainer,
          valueBackColor: colors.surface,
        ),
      ],
    );
  }

  void _updateChange(String value, double total) {
    final received = double.tryParse(value.trim());
    final double nextChange = received == null ? 0.0 : received - total;

    if (nextChange != _change && mounted) {
      setState(() => _change = nextChange < 0 ? 0 : nextChange);
    }
  }
}
