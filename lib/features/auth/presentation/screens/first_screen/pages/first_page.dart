import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:lottie/lottie.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const verticalPadding = 24.0;
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        final minHeight = (constraints.maxHeight - verticalPadding * 2)
            .clamp(0.0, double.infinity)
            .toDouble();
        final isWide = constraints.maxWidth >= 780;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: isWide
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _illustration(context)),
                            const SizedBox(width: 28),
                            Expanded(child: _welcomeContent(context)),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _illustration(context),
                          const SizedBox(height: 12),
                          _welcomeContent(context),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _illustration(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 360),
        child: Lottie.asset(
          'assets/lotties/location.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _welcomeContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona la sucursal para comenzar.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        IsselButton(
          text: 'Seleccionar sucursal',
          height: 56,
          onTap: onTap,
        ),
      ],
    );
  }
}
