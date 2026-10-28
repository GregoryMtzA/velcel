import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/errors/exceptions.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/screen.dart';

class RegisterOpeningForm extends StatefulWidget {
  const RegisterOpeningForm({super.key});

  @override
  State<RegisterOpeningForm> createState() => _RegisterOpeningFormState();
}

class _RegisterOpeningFormState extends State<RegisterOpeningForm> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cantidad inicial',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          IsselTextFormField(
            controller: _cashController,
            hintText: '\$ 500.00',
            prefixIcon: Icons.payments_outlined,
            fillColor: colors.surfaceContainer,
            height: 58,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [TextInputFormatters().double],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa un valor';
              }
              if (double.tryParse(value) == null) {
                return 'Ingresa un valor válido';
              }
              return null;
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 18),
          IsselButton(
            text: _isSubmitting ? 'Abriendo caja...' : 'Abrir caja',
            height: 56,
            onTap: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final branch = context.read<BranchProvider>().branch;
    final username = context.read<UserProvider>().userEntity?.usuario;
    final amount = double.tryParse(_cashController.text.trim());

    if (branch == null || username == null || amount == null) {
      SnackbarService.showIncorrect(
        context,
        'Fondo de caja',
        'Faltan datos para abrir la caja.',
      );
      return;
    }

    final confirmed = await _showConfirmation(context, amount);
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<CashRegisterProvider>().registerOpening(
            branch.nombre,
            username,
            amount,
          );

      if (!mounted) return;
      await NavigationService.navigateTo(context, HomeScreen.init(context));
    } on ServerException {
      if (!mounted) return;
      SnackbarService.showIncorrect(
        context,
        'Fondo de caja',
        'No se pudo abrir la caja. Contacta a soporte.',
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarService.showIncorrect(
        context,
        'Fondo de caja',
        'Ocurrió un error al abrir la caja.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool?> _showConfirmation(BuildContext context, double amount) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Confirmar apertura',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifica el efectivo inicial antes de comenzar la jornada.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.outline,
                  ),
                ),
                const SizedBox(height: 20),
                IsselInfoField(
                  title: 'Fondo inicial',
                  value: _money(amount),
                  height: 58,
                  backColor: colors.surfaceContainer,
                  valueBackColor: colors.surface,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: IsselButton(
                        text: 'Cancelar',
                        height: 52,
                        color: colors.surfaceContainer,
                        textColor: colors.onSurface,
                        onTap: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IsselButton(
                        text: 'Confirmar',
                        height: 52,
                        onTap: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}
