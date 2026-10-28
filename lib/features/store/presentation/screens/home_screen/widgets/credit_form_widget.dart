import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/app/expresiones_regulares.dart';

class CreditFormWidget extends StatefulWidget {
  const CreditFormWidget({super.key});

  @override
  State<CreditFormWidget> createState() => _CreditFormWidgetState();
}

class _CreditFormWidgetState extends State<CreditFormWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (cartState.cartPaymentType?.enumType == PaymentTypes.normal) {
      return const SizedBox.shrink();
    }

    return Form(
      key: cartState.creditFormKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datos del crédito',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Nombre, teléfono, domicilio y enganche.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colors.outline,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  const SizedBox(height: 14),
                  IsselTextFormField(
                    hintText: 'Nombre completo',
                    prefixIcon: Icons.person_outline,
                    controller: cartState.creditNameController,
                    fillColor: colors.surface,
                    height: 50,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  IsselTextFormField(
                    hintText: 'Número de teléfono',
                    prefixIcon: Icons.phone_outlined,
                    controller: cartState.creditPhoneController,
                    fillColor: colors.surface,
                    height: 50,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [TextInputFormatters().cellPhoneNumber],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  IsselTextFormField(
                    hintText: 'Domicilio',
                    prefixIcon: Icons.location_on_outlined,
                    controller: cartState.creditAddressController,
                    fillColor: colors.surface,
                    height: 76,
                    maxLines: 2,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  IsselTextFormField(
                    hintText: 'Enganche',
                    prefixIcon: Icons.attach_money,
                    controller: cartState.creditEnchangeController,
                    fillColor: colors.surface,
                    height: 50,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [TextInputFormatters().double],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateDownPayment,
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Completa este campo';
    }
    return null;
  }

  String? _validateDownPayment(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;

    if (double.tryParse(value!.trim()) == null) {
      return 'Ingresa una cantidad válida';
    }
    return null;
  }
}
