import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/inventory/presentation/screens/altas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/bajas_inventory_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/view_inventory_screen.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class HomeInventoryScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(selected: MenuDestination.inventory),
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Inventario',
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
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;
            final availableWidth = constraints.maxWidth -
                (constraints.maxWidth >= 900 ? 64.0 : 40.0);
            final columns = isLandscape
                ? 3
                : constraints.maxWidth >= 1100
                    ? 3
                    : constraints.maxWidth >= 700
                        ? 2
                        : 1;
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
            const verticalPadding = 24.0;
            const gap = 24.0;
            final cardWidth = ((availableWidth - gap * (columns - 1)) / columns)
                .clamp(0.0, columns == 1 ? 340.0 : 420.0)
                .toDouble();
            final availableHeight = constraints.maxHeight - verticalPadding * 2;
            final isLarge = constraints.maxWidth >= 820;

            final actions = [
              _actionCard(
                context,
                asset: 'assets/lotties/05_dataanalytics.json',
                title: 'Consultar inventario',
                description: 'Revisa existencias y productos disponibles.',
                semanticLabel: 'Consultar inventario',
                size: cardWidth,
                onTap: () => NavigationService.navigate(
                  context,
                  const ViewInventoryScreen(),
                ),
              ),
              _actionCard(
                context,
                asset: 'assets/lotties/cash.json',
                title: 'Consultar altas',
                description: 'Consulta las entradas de productos registradas.',
                semanticLabel: 'Consultar altas de inventario',
                size: cardWidth,
                onTap: () => NavigationService.navigate(
                  context,
                  const AltasInventoryScreen(),
                ),
              ),
              _actionCard(
                context,
                asset: 'assets/lotties/10_working.json',
                title: 'Consultar bajas',
                description: 'Consulta las salidas y motivos registrados.',
                semanticLabel: 'Consultar bajas de inventario',
                size: cardWidth,
                onTap: () => NavigationService.navigate(
                  context,
                  const BajasInventoryScreen(),
                ),
              ),
            ];

            final content = isLandscape
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      actions[0],
                      const SizedBox(width: gap),
                      actions[1],
                      const SizedBox(width: gap),
                      actions[2],
                    ],
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: gap,
                    runSpacing: 16,
                    children: actions,
                  );

            final scrollContent = isLarge
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
