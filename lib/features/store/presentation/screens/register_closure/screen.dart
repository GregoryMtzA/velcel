import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/screens/splash_screen/splash_screen.dart';
import 'package:velcel/features/store/domain/entities/cash_register_data_response.dart';
import 'package:velcel/features/store/domain/entities/cash_register_closure_ticket.dart';
import 'package:velcel/features/store/domain/entities/cash_register_entity.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/screens/register_closure/state.dart';
import 'package:velcel/features/widgets/dialogs/closure_folio_dialog.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';

class RegisterClosureScreen extends StatefulWidget {
  const RegisterClosureScreen._();

  static Widget init(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RegisterClosureState(
            cashRegisterRepository: locator(),
          ),
        ),
      ],
      builder: (context, child) => const RegisterClosureScreen._(),
    );
  }

  @override
  State<RegisterClosureScreen> createState() => _RegisterClosureScreenState();
}

class _RegisterClosureScreenState extends State<RegisterClosureScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<dartz.Either<String, CashRegisterDataResponse>> _future;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCashRegister();
  }

  void _loadCashRegister() {
    final branch = context.read<BranchProvider>().branch;
    if (branch == null) {
      _future = Future.value(const dartz.Left('Sucursal no disponible'));
      return;
    }

    _future =
        context.read<CashRegisterProvider>().getCashRegisterData(branch.nombre);
  }

  void _retry() {
    setState(_loadCashRegister);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(selected: MenuDestination.closure),
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Cortes',
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
        child: FutureBuilder<dartz.Either<String, CashRegisterDataResponse>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingState(context);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _errorState(
                context,
                'No se pudo cargar el corte actual.',
              );
            }

            return snapshot.data!.fold(
              (error) => _errorState(context, error),
              (data) => _closureContent(context, data),
            );
          },
        ),
      ),
    );
  }

  Widget _closureContent(
    BuildContext context,
    CashRegisterDataResponse data,
  ) {
    final state = context.read<RegisterClosureState>();
    final cashRegisterProvider = context.read<CashRegisterProvider>();

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
          const verticalPadding = 24.0;
          final isWide = constraints.maxWidth >= 820;
          final availableHeight = constraints.maxHeight - verticalPadding * 2;

          final summary = _summaryCard(context, data);
          final closure = _closureCard(context, data, state);

          final content = ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: summary),
                        const SizedBox(width: 18),
                        Expanded(child: closure),
                      ],
                    ),
                  )
                else ...[
                  summary,
                  const SizedBox(height: 18),
                  closure,
                ],
                const SizedBox(height: 18),
                _finishButton(context, data, cashRegisterProvider),
              ],
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding,
            ),
            child: isWide
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight > 0 ? availableHeight : 0,
                    ),
                    child: Center(child: content),
                  )
                : content,
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    CashRegisterDataResponse data,
  ) {
    return _surfaceCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            context,
            'Resumen del turno',
            'Movimientos registrados en la caja.',
          ),
          const SizedBox(height: 16),
          _infoField(context, 'Efectivo', data.totalesEfectivo),
          const SizedBox(height: 12),
          _infoField(context, 'Tarjeta', data.totalesTarjeta),
          const SizedBox(height: 12),
          _infoField(context, 'Fondo', data.fondo),
          const SizedBox(height: 12),
          _infoField(context, 'Gastos', data.totalesGastos),
        ],
      ),
    );
  }

  Widget _closureCard(
    BuildContext context,
    CashRegisterDataResponse data,
    RegisterClosureState state,
  ) {
    return _surfaceCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            context,
            'Conteo y diferencia',
            'La diferencia se calcula contra el total neto.',
          ),
          const SizedBox(height: 16),
          _infoField(context, 'Total bruto', data.totalBruto),
          const SizedBox(height: 12),
          _infoField(context, 'Total neto', data.totalNeto),
          const SizedBox(height: 12),
          IsselTextFormField(
            controller: state.cantidadController,
            hintText: 'Cantidad contada',
            prefixIcon: Icons.payments_outlined,
            fillColor: Theme.of(context).colorScheme.surfaceContainer,
            height: 58,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [TextInputFormatters().double],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa una cantidad';
              }
              if (double.tryParse(value) == null) {
                return 'Ingresa una cantidad válida';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) => _updateDifference(value, data, state),
            onSubmitted: (_) => _finishClosure(context, data),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: state.diferenciaController,
            builder: (context, value, child) {
              final difference = double.tryParse(value.text);
              return IsselInfoField(
                title: 'Diferencia',
                value: difference == null ? '—' : _money(difference),
                height: 58,
                backColor: Theme.of(context).colorScheme.surfaceContainer,
                valueBackColor: Theme.of(context).colorScheme.surface,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _finishButton(
    BuildContext context,
    CashRegisterDataResponse data,
    CashRegisterProvider cashRegisterProvider,
  ) {
    return IsselButton(
      text: _isSubmitting ? 'Guardando corte...' : 'Terminar corte y sesión',
      onTap: _isSubmitting
          ? null
          : () => _finishClosure(
                context,
                data,
                cashRegisterProvider: cashRegisterProvider,
              ),
      height: 58,
    );
  }

  Future<void> _finishClosure(
    BuildContext context,
    CashRegisterDataResponse data, {
    CashRegisterProvider? cashRegisterProvider,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    final provider =
        cashRegisterProvider ?? context.read<CashRegisterProvider>();
    final cashRegister = provider.cashRegister;
    if (cashRegister == null) {
      SnackbarService.showIncorrect(
        context,
        'Corte',
        'No se encontró la caja abierta.',
      );
      return;
    }
    final branchName = cashRegister.sucursal ??
        context.read<BranchProvider>().branch?.nombre ??
        'Sucursal no disponible';

    setState(() => _isSubmitting = true);
    final state = context.read<RegisterClosureState>();
    final counted = double.parse(state.cantidadController.text);
    final difference = double.parse(state.diferenciaController.text);
    final closureTicket = _buildClosureTicket(
      data: data,
      cashRegister: cashRegister,
      branchName: branchName,
      cantidadContada: counted,
      diferencia: difference,
    );

    try {
      final response = await state.terminarCorte(data, cashRegister);
      if (!context.mounted) return;

      if (response == null) {
        await provider.loadLastClosedCut(branchName, force: true);
        final printResponse =
            await locator<PrinterRepositoryInterface>().printClosure(
          closureTicket,
        );
        String? printError;
        printResponse.fold(
          (error) => printError = error,
          (_) {},
        );
        if (!context.mounted) return;

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ClosureFolioDialog(
            folio: cashRegister.identificador,
            printError: printError,
          ),
        );
        if (!context.mounted) return;

        await NavigationService.navigateTo(
          context,
          SplashScreen.init(context),
        );
      } else {
        SnackbarService.showIncorrect(context, 'Corte', response);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  CashRegisterClosureTicket _buildClosureTicket({
    required CashRegisterDataResponse data,
    required CashRegisterEntity cashRegister,
    required String branchName,
    required double cantidadContada,
    required double diferencia,
  }) {
    return CashRegisterClosureTicket(
      folio: cashRegister.identificador,
      sucursal: branchName,
      usuario: cashRegister.usuario ?? 'Usuario no disponible',
      fechaApertura: cashRegister.fechaApertura,
      fechaCierre: DateTime.now(),
      fondo: data.fondo,
      efectivo: data.totalesEfectivo,
      tarjeta: data.totalesTarjeta,
      gastos: data.totalesGastos,
      totalBruto: data.totalBruto ?? 0,
      totalNeto: data.totalNeto ?? 0,
      cantidadContada: cantidadContada,
      diferencia: diferencia,
    );
  }

  void _updateDifference(
    String value,
    CashRegisterDataResponse data,
    RegisterClosureState state,
  ) {
    final counted = double.tryParse(value);
    if (counted == null) {
      state.diferenciaController.clear();
      return;
    }

    state.diferenciaController.text =
        (data.totalNeto! - counted).toStringAsFixed(2);
  }

  Widget _infoField(BuildContext context, String title, double? value) {
    final colors = Theme.of(context).colorScheme;
    return IsselInfoField(
      title: title,
      value: _money(value),
      height: 58,
      backColor: colors.surfaceContainer,
      valueBackColor: colors.surface,
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
      ],
    );
  }

  Widget _surfaceCard(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
            'Cargando el corte actual...',
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

  String _money(double? value) {
    if (value == null) return '—';
    return '\$${value.toStringAsFixed(2)}';
  }
}
