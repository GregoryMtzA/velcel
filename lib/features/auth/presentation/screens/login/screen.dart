import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/features/auth/presentation/screens/login/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final PageController _benefitsController;

  @override
  void initState() {
    super.initState();
    _benefitsController = PageController();
  }

  @override
  void dispose() {
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const verticalPadding = 24.0;
            final isWide = constraints.maxWidth >= 820;
            final horizontalPadding = isWide ? 32.0 : 20.0;
            final minHeight = (constraints.maxHeight - verticalPadding * 2)
                .clamp(0.0, double.infinity)
                .toDouble();

            final content = isWide
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _brandPanel(context)),
                        const SizedBox(width: 20),
                        Expanded(child: _loginPanel(context)),
                      ],
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _brandPanel(context, compact: true),
                        const SizedBox(height: 16),
                        _loginPanel(context),
                      ],
                    ),
                  );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight,
                  maxWidth: 1120,
                ),
                child: isWide
                    ? Center(child: content)
                    : Align(
                        alignment: Alignment.topCenter,
                        child: content,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _brandPanel(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _surfaceCard(
      context,
      padding: EdgeInsets.all(compact ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: compact ? 4 : 8),
          Text(
            'Controla tu negocio desde un solo lugar.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra tus ventas, inventario y caja con la información que necesitas para trabajar mejor.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.outline,
            ),
          ),
          SizedBox(height: compact ? 16 : 20),
          SizedBox(
            height: compact ? 170 : 270,
            child: PageView(
              controller: _benefitsController,
              children: [
                _benefitPage(
                  context,
                  asset: 'assets/lotties/01_artificial intelligence.json',
                  text: 'Gestiona las ventas y el inventario.',
                ),
                _benefitPage(
                  context,
                  asset: 'assets/lotties/05_dataanalytics.json',
                  text: 'Consulta la información de tu negocio.',
                ),
                _benefitPage(
                  context,
                  asset: 'assets/lotties/10_working.json',
                  text: 'Trabaja con mayor comodidad.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitPage(
    BuildContext context, {
    required String asset,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Lottie.asset(
            asset,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _loginPanel(BuildContext context) {
    return _surfaceCard(
      context,
      padding: const EdgeInsets.all(28),
      child: const LoginForm(),
    );
  }

  Widget _surfaceCard(
    BuildContext context, {
    required Widget child,
    required EdgeInsets padding,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
