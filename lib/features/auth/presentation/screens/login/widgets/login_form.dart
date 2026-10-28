import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/auth/presentation/screens/login/widgets/login_form_users.dart';
import 'package:velcel/features/store/presentation/screens/register_opening/screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final branch = context.watch<BranchProvider>().branch;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar sesión',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tus datos para continuar.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
          ),
          const SizedBox(height: 20),
          if (branch != null)
            IsselInfoField2(
              icon: Icons.location_on_outlined,
              label: branch.displayName,
              height: 52,
              backColor: colors.surfaceContainer,
            )
          else
            Text(
              'No hay una sucursal seleccionada.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Usuario',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const LoginFormUsers(),
          const SizedBox(height: 18),
          Text(
            'Contraseña',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          IsselTextFormField(
            controller: _passwordController,
            hintText: 'Ingresa tu contraseña',
            prefixIcon: Icons.lock_outline,
            fillColor: colors.surfaceContainer,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una contraseña';
              }
              return null;
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          IsselButton(
            text: _isSubmitting ? 'Ingresando...' : 'Ingresar',
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

    final user = context.read<UserProvider>().userEntity;
    if (user == null || user.clave == null) {
      SnackbarService.showIncorrect(
        context,
        'Login',
        'Selecciona un usuario válido',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    if (user.clave == _passwordController.text) {
      SnackbarService.showCorrect(context, 'Login', 'Ingreso correcto');
      await NavigationService.navigateTo(context, RegisterOpening());
    } else {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      SnackbarService.showIncorrect(
        context,
        'Login',
        'Las credenciales no coinciden',
      );
    }
  }
}
