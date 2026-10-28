import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/ventas/presentation/screens/ver_cortes_screen.dart';
import 'package:velcel/features/ventas/presentation/screens/ver_ventas_screen.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class HomeVentasScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(selected: MenuDestination.sales),
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Ventas',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NavigationService.appBarLeading(
          context,
          onMenu: () => _scaffoldKey.currentState?.openDrawer(),
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
                asset: 'assets/lotties/05_dataanalytics.json',
                title: 'Consultar ventas',
                description: 'Busca ventas por folio o rango de fechas.',
                semanticLabel: 'Consultar ventas',
                size: cardSize,
                onTap: () => NavigationService.navigate(
                  context,
                  const VerVentasScreen(),
                ),
              ),
              _actionCard(
                context,
                asset: 'assets/lotties/10_working.json',
                title: 'Consultar cortes',
                description: 'Revisa aperturas y cierres de caja por fecha.',
                semanticLabel: 'Consultar cortes',
                size: cardSize,
                onTap: () => NavigationService.navigate(
                  context,
                  const VerCortesScreen(),
                ),
              ),
            ];

            final content = isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox.square(
      dimension: size,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: colors.surface,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
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
                    style: theme.textTheme.bodySmall?.copyWith(
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
