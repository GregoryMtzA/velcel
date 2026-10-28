import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/features/store/presentation/screens/register_opening/widgets/register_opening_form.dart';

class RegisterOpening extends StatelessWidget {
  const RegisterOpening({super.key});

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
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(child: _cashPanel(context)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: _openingPanel(context),
                          ),
                        ),
                      ),
                    ],
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cashPanel(context, compact: true),
                        const SizedBox(height: 16),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: _openingPanel(context),
                          ),
                        ),
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

  Widget _cashPanel(BuildContext context, {bool compact = false}) {
    return SizedBox(
      height: compact ? 210 : 360,
      child: Lottie.asset(
        'assets/lotties/cash.json',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _openingPanel(BuildContext context) {
    return _surfaceCard(
      context,
      padding: const EdgeInsets.all(28),
      child: const RegisterOpeningForm(),
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
