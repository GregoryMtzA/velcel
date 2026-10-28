import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';
import 'package:velcel/features/gastos/presentation/providers/gastos_provider.dart';
import 'package:velcel/features/gastos/presentation/screens/home_gastos_screen.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class CrearGastoScreen extends StatefulWidget {
  const CrearGastoScreen({super.key});

  @override
  State<CrearGastoScreen> createState() => _CrearGastoScreenState();
}

class _CrearGastoScreenState extends State<CrearGastoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _importeController = TextEditingController();

  late Future<dartz.Either<String, List<TipoGastoEntity>>> _future;
  TipoGastoEntity? _selectedGasto;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _importeController.dispose();
    super.dispose();
  }

  void _loadTypes() {
    _future = context.read<GastosProvider>().getTiposGastos();
  }

  void _retry() {
    setState(_loadTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(selected: MenuDestination.expenses),
      appBar: AppBar(
        title: const Text('Crear gasto'),
        leading: NavigationService.appBarLeading(
          context,
          onMenu: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<dartz.Either<String, List<TipoGastoEntity>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingState(context);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _errorState(
                context,
                'No se pudieron cargar los tipos de gasto.',
              );
            }

            return snapshot.data!.fold(
              (error) => _errorState(context, error),
              (types) => _expenseForm(context, types),
            );
          },
        ),
      ),
    );
  }

  Widget _expenseForm(
    BuildContext context,
    List<TipoGastoEntity> types,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        final isWide = constraints.maxWidth >= 820;
        const verticalPadding = 24.0;
        final availableHeight = constraints.maxHeight - (verticalPadding * 2);
        final content = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: _surfaceCard(
            context,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionHeader(
                    context,
                    'Información del gasto',
                    'Completa los datos para registrarlo en la caja actual.',
                  ),
                  const SizedBox(height: 20),
                  IsselDropdown2<TipoGastoEntity>(
                    value: _selectedGasto,
                    items: types
                        .map(
                          (type) => DropdownMenuItem<TipoGastoEntity>(
                            value: type,
                            child: Text(type.tipoGasto),
                          ),
                        )
                        .toList(),
                    hintText: 'Seleccionar tipo de gasto',
                    height: 58,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    onChanged: _isSubmitting
                        ? null
                        : (value) => setState(() => _selectedGasto = value),
                    validator: (value) =>
                        value == null ? 'Selecciona un tipo de gasto' : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 14),
                  _importeField(context),
                  const SizedBox(height: 20),
                  IsselButton(
                    text: _isSubmitting
                        ? 'Registrando gasto...'
                        : 'Reportar gasto',
                    height: 58,
                    onTap: _isSubmitting ? null : () => _submit(context),
                  ),
                ],
              ),
            ),
          ),
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
    );
  }

  Widget _importeField(BuildContext context) {
    return IsselTextFormField(
      controller: _importeController,
      hintText: 'Importe',
      prefixIcon: Icons.attach_money_outlined,
      fillColor: Theme.of(context).colorScheme.surfaceContainer,
      height: 58,
      readOnly: _isSubmitting,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      inputFormatters: [TextInputFormatters().double],
      validator: (value) {
        final amount = double.tryParse(value ?? '');
        if (amount == null || amount <= 0) {
          return 'Ingresa un importe válido';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSubmitted: (_) => _submit(context),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final branch = context.read<BranchProvider>().branch;
    final user = context.read<UserProvider>().userEntity;
    final cashRegister = context.read<CashRegisterProvider>().cashRegister;

    if (branch == null || user?.usuario == null || cashRegister == null) {
      SnackbarService.showIncorrect(
        context,
        'Gasto',
        'La sucursal, el usuario o la caja actual no están disponibles.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await context.read<GastosProvider>().crearGasto(
            branch.nombre,
            cashRegister.identificador,
            user!.usuario!,
            double.parse(_importeController.text),
            _selectedGasto!.tipoGasto,
          );

      if (!mounted) return;

      await response.fold(
        (error) async {
          SnackbarService.showIncorrect(context, 'Gasto', error);
        },
        (_) async {
          await NavigationService.navigateTo(context, HomeGastosScreen());
        },
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.outline,
          ),
        ),
      ],
    );
  }

  Widget _surfaceCard(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _loadingState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IsselCircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 14),
          Text(
            'Cargando tipos de gasto...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _surfaceCard(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 32, color: colors.outline),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
