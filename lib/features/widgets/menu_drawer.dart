import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/presentation/screens/configuracion_screen.dart';
import 'package:velcel/features/config/presentation/screens/configurar_impresora.dart';
import 'package:velcel/features/gastos/presentation/screens/home_gastos_screen.dart';
import 'package:velcel/features/inventory/presentation/screens/home_inventory_screen.dart';
import 'package:velcel/features/services/presentation/screens/home_service_screen.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/screen.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/screen.dart';
import 'package:velcel/features/ventas/presentation/screens/home_ventas_screen.dart';

enum MenuDestination {
  store,
  services,
  inventory,
  sales,
  expenses,
  closure,
  printer,
  settings,
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key, required this.selected});

  final MenuDestination selected;

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String? _requestedBranch;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final branch = context.read<BranchProvider>().branch;
    final cashRegister = context.read<CashRegisterProvider?>();
    if (branch == null ||
        cashRegister == null ||
        _requestedBranch == branch.nombre) {
      return;
    }

    _requestedBranch = branch.nombre;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cashRegister.loadLastClosedCut(branch.nombre);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final branch = context.watch<BranchProvider>().branch;
    final user = context.watch<UserProvider>().userEntity;
    final cashRegister = context.watch<CashRegisterProvider?>();
    final activeCut = cashRegister?.cashRegister?.identificador;
    final activeCutLabel = activeCut == null
        ? 'Corte activo: No disponible'
        : 'Corte activo: $activeCut';
    final lastClosedCut = cashRegister?.lastClosedCutBranch == branch?.nombre
        ? cashRegister?.lastClosedCutFolio
        : null;
    final lastClosedCutLabel = cashRegister == null
        ? 'Ultimo corte: No disponible'
        : cashRegister.isLoadingLastClosedCut
            ? 'Último corte: Cargando...'
            : cashRegister.lastClosedCutError != null
                ? 'Último corte: No disponible'
                : lastClosedCut == null
                    ? 'Último corte: Sin registros'
                    : 'Último corte: $lastClosedCut';

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: 22),
              _sectionLabel(context, 'Módulos'),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _item(
                        context,
                        MenuDestination.store,
                        Icons.storefront_outlined,
                        'Tienda',
                        () => HomeScreen.init(context),
                      ),
                      _item(
                        context,
                        MenuDestination.services,
                        Icons.handyman_outlined,
                        'Servicio',
                        () => HomeServiceScreen(),
                      ),
                      _item(
                        context,
                        MenuDestination.inventory,
                        Icons.inventory_2_outlined,
                        'Inventario',
                        () => HomeInventoryScreen(),
                      ),
                      _item(
                        context,
                        MenuDestination.sales,
                        Icons.point_of_sale_outlined,
                        'Ventas',
                        () => HomeVentasScreen(),
                      ),
                      _item(
                        context,
                        MenuDestination.expenses,
                        Icons.receipt_long_outlined,
                        'Gastos',
                        () => HomeGastosScreen(),
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel(context, 'Administración'),
                      const SizedBox(height: 4),
                      _item(
                        context,
                        MenuDestination.closure,
                        Icons.account_balance_wallet_outlined,
                        'Corte',
                        () => RegisterClosureScreen.init(context),
                      ),
                      _item(
                        context,
                        MenuDestination.printer,
                        Icons.print_outlined,
                        'Impresora',
                        () => const ConfigurarImpresora(),
                      ),
                      _item(
                        context,
                        MenuDestination.settings,
                        Icons.settings_outlined,
                        'Configuración',
                        () => const ConfiguracionScreen(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: colors.outlineVariant, height: 1),
              const SizedBox(height: 12),
              _accountInfo(
                context,
                Icons.storefront_outlined,
                branch?.displayName ?? 'Sin sucursal',
              ),
              const SizedBox(height: 8),
              _accountInfo(
                context,
                Icons.point_of_sale_outlined,
                activeCutLabel,
              ),
              const SizedBox(height: 8),
              _accountInfo(
                context,
                Icons.receipt_long_outlined,
                lastClosedCutLabel,
              ),
              const SizedBox(height: 8),
              _accountInfo(
                context,
                Icons.person_outline,
                user?.usuario ?? 'Sin usuario',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: Image.asset('assets/logos/velcel.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Velcel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Menú principal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.outline,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _accountInfo(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.outline),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    MenuDestination destination,
    IconData icon,
    String title,
    Widget Function() screen,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = widget.selected == destination;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IsselPill(
        height: 46,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: isSelected ? colors.surfaceContainer : Colors.transparent,
        onTap: () {
          if (isSelected) {
            Navigator.pop(context);
          } else {
            NavigationService.navigateTo(context, screen());
          }
        },
        widget: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primary : colors.onSurface,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? colors.primary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
