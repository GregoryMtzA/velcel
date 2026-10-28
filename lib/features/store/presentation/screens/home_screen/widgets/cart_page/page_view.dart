import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/store/domain/entities/cart_method_pay.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/cart_products.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/cart_verify.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/change_widget.dart';

import '../../../../../../../core/app/enums/enums.dart';

class CartPageWidget extends StatelessWidget {
  const CartPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    CartState cartState = context.watch();

    return PageView(
      controller: cartState.cartPageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Carrito
        PageCart(
          onTap: () {
            // Si el carro no está vacío, entonces, seguir a la pagina de pago
            if (cartState.cart.isNotEmpty) {
              cartState.cartPaymentType = null;
              cartState.cartState = CartStates.pay;
              return;
            }

            /// MOSTRAR DIALOGO DE QUE NO HAY PRODUCTOS QUE PAGAR EN EL CARRITO.
            SnackbarService.showIncorrect(
              context,
              "Carrito",
              "No hay productos que cobrar",
            );
          },
        ),

        // Pago de carrito
        const CartVerify(),

        _PurchasePage(key: ValueKey(cartState.cartState)),
      ],
    );
  }
}

class _PurchasePage extends StatefulWidget {
  const _PurchasePage({super.key});

  @override
  State<_PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<_PurchasePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPurchasing = false;

  double _totalToCharge(CartState cartState) {
    if (cartState.cartPaymentType?.enumType == PaymentTypes.normal) {
      return cartState.total;
    }

    return double.tryParse(cartState.creditEnchangeController.text) ?? 0;
  }

  Future<void> _completeSale() async {
    if (_isPurchasing) return;

    final cartState = context.read<CartState>();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final branch = context.read<BranchProvider>().branch;
    final cashRegister = context.read<CashRegisterProvider>().cashRegister;
    final user = context.read<UserProvider>().userEntity;

    if (branch == null || cashRegister == null || user == null) {
      SnackbarService.showIncorrect(
        context,
        'Venta',
        'Faltan datos de sucursal, usuario o caja abierta.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isPurchasing = true);

    try {
      final printerResponse =
          await context.read<PrintersControllers>().checkStatusConnect();
      var canContinue = true;

      await printerResponse.fold(
        (_) async {
          canContinue = await DialogService.awaitConfirmDialog(
            context: context,
            title: 'No hay una impresora conectada',
            textButton: 'Continuar',
          );
        },
        (_) async {},
      );

      if (!canContinue || !mounted) {
        if (mounted && !canContinue) {
          SnackbarService.showIncorrect(
            context,
            'Venta',
            'Configura tu impresora para continuar.',
          );
        }
        return;
      }

      final response = await cartState.purchase(
        cashRegister.identificador,
        user.usuario,
        branch.nombre,
      );

      if (!mounted) return;
      response.fold(
        (error) => SnackbarService.showIncorrect(context, 'Venta', error),
        (message) => SnackbarService.showCorrect(context, 'Venta', message),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = _totalToCharge(cartState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Finaliza la venta',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confirma el método de pago y registra el importe recibido.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  const SizedBox(height: 18),
                  IsselInfoField(
                    title: 'Total a cobrar',
                    value: '\$ ${total.toStringAsFixed(2)}',
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Método de pago',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selecciona cómo recibes el dinero.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        IsselDropdown2<CartMethodPayEntity>(
                          value: cartState.cartMethodPayEntity,
                          hintText: 'Seleccionar método',
                          color: colors.surface,
                          items: cartMethodPayTypes
                              .map(
                                (method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              cartState.cartMethodPayEntity = value;
                            }
                          },
                          validator: (value) => value == null
                              ? 'Selecciona un método de pago'
                              : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pago recibido',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Captura la cantidad entregada por el cliente.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CartChangeWidget(),
                ],
              ),
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
            text: _isPurchasing ? 'Generando venta...' : 'Generar venta',
            height: 50,
            onTap: _isPurchasing ? null : _completeSale,
          ),
        ),
      ],
    );
  }
}
