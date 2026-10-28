import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/gastos/presentation/screens/crear_gasto_screen.dart';
import 'package:velcel/features/gastos/presentation/screens/ver_gastos_screen.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class HomeGastosScreen extends StatelessWidget {
  const HomeGastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const MenuDrawer(selected: MenuDestination.expenses),
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Gastos',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NavigationService.appBarLeading(
          context,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
            const verticalPadding = 24.0;
            final availableHeight = constraints.maxHeight - verticalPadding * 2;
            final availableWidth = constraints.maxWidth - horizontalPadding * 2;
            final double cardSize = (isWide
                    ? ((availableWidth - 24) / 2).clamp(0.0, 420.0)
                    : availableWidth.clamp(0.0, 340.0))
                .toDouble();

            final actions = [
              _actionCard(
                context,
                asset: 'assets/lotties/cash.json',
                title: 'Registrar gasto',
                description: 'Registra una salida en la caja actual.',
                semanticLabel: 'Registrar gasto',
                size: cardSize,
                onTap: () => NavigationService.navigate(
                  context,
                  const CrearGastoScreen(),
                ),
              ),
              _actionCard(
                context,
                asset: 'assets/lotties/05_dataanalytics.json',
                title: 'Consultar gastos',
                description: 'Consulta los gastos por folio de corte o tipo.',
                semanticLabel: 'Consultar gastos',
                size: cardSize,
                onTap: () => NavigationService.navigate(
                  context,
                  const VerGastosScreen(),
                ),
              ),
            ];

            final content = isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      actions[0],
                      const SizedBox(width: 24),
                      actions[1],
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      actions[0],
                      const SizedBox(height: 16),
                      actions[1],
                    ],
                  );

            final scrollContent = isWide
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight > 0 ? availableHeight : 0,
                    ),
                    child: Center(child: content),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: content,
                  );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: scrollContent,
            );
          },
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String asset,
    required String title,
    required String description,
    required String semanticLabel,
    required double size,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: size,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      height: size * 0.44,
                      child: Lottie.asset(
                        asset,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.outline,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
