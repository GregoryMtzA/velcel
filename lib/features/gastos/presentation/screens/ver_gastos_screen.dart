import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';
import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';
import 'package:velcel/features/gastos/presentation/providers/gastos_provider.dart';

class VerGastosScreen extends StatefulWidget {
  const VerGastosScreen({super.key});

  @override
  State<VerGastosScreen> createState() => _VerGastosScreenState();
}

class _VerGastosScreenState extends State<VerGastosScreen> {
  final TextEditingController _folioCorteController = TextEditingController();

  late Future<dartz.Either<String, List<TipoGastoEntity>>> _futureTipoGasto;
  TipoGastoEntity? _selectedGasto;
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _futureTipoGasto = context.read<GastosProvider>().getTiposGastos();
  }

  @override
  void dispose() {
    _folioCorteController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final folioCorteText = _folioCorteController.text.trim();
    final selectedType = _selectedGasto?.tipoGasto;

    if (folioCorteText.isEmpty && selectedType == null) {
      setState(() {
        _errorMessage =
            'Ingresa un folio de corte o selecciona un tipo de gasto.';
      });
      return;
    }

    final branch = context.read<BranchProvider>().branch;
    if (branch == null) {
      setState(() {
        _errorMessage = 'La sucursal actual no está disponible.';
      });
      return;
    }

    final folioCorte = int.tryParse(folioCorteText);
    if (folioCorteText.isNotEmpty && folioCorte == null) {
      setState(() {
        _errorMessage = 'Ingresa un folio de corte válido.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<GastosProvider>();
      final response = folioCorte != null
          ? await provider.getGastosPorFolioCorte(folioCorte, branch.nombre)
          : await provider.getGastosPorTipo(selectedType!, branch.nombre);

      if (!mounted) return;

      String? searchError;
      int? resultCount;
      response.fold(
        (error) => searchError = error,
        (_) => resultCount = provider.gastos.length,
      );

      setState(() {
        _errorMessage = searchError;
        _isSearching = false;
      });

      if (searchError == null && resultCount != null && mounted) {
        await _showResultsDialog(resultCount!);
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _showResultsDialog(int resultCount) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final resultWord = resultCount == 1 ? 'resultado' : 'resultados';

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Consulta completada',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: IsselPill(
                    text: '$resultCount $resultWord',
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: colors.surfaceContainer,
                    textColor: colors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                IsselButton(
                  text: 'Aceptar',
                  height: 52,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    _folioCorteController.clear();
    setState(() {
      _selectedGasto = null;
      _hasSearched = false;
      _errorMessage = null;
    });
  }

  void _onFolioCorteChanged(String value) {
    if (value.isEmpty || (_selectedGasto == null && _errorMessage == null)) {
      return;
    }
    setState(() {
      _selectedGasto = null;
      _errorMessage = null;
    });
  }

  void _onTypeChanged(TipoGastoEntity? value) {
    if (value != null) _folioCorteController.clear();
    setState(() {
      _selectedGasto = value;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Consultar gastos',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NavigationService.appBarLeading(context),
      ),
      body: SafeArea(
        child: FutureBuilder<dartz.Either<String, List<TipoGastoEntity>>>(
          future: _futureTipoGasto,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingState(context);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _typesError(
                context,
                'No se pudieron cargar los tipos de gasto.',
              );
            }

            return snapshot.data!.fold(
              (error) => _typesError(context, error),
              (types) => _content(context, types),
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<TipoGastoEntity> types) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const verticalPadding = 24.0;
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _filtersCard(context, types),
              const SizedBox(height: 20),
              Expanded(child: _resultsCard(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _filtersCard(BuildContext context, List<TipoGastoEntity> types) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 4, child: _folioCorteField(context)),
                const SizedBox(width: 14),
                Expanded(flex: 5, child: _typeField(context, types)),
                const SizedBox(width: 14),
                _filterActions(context),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _folioCorteField(context),
              const SizedBox(height: 14),
              _typeField(context, types),
              const SizedBox(height: 14),
              _filterActions(context, expanded: true),
            ],
          );
        },
      ),
    );
  }

  Widget _folioCorteField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Folio de corte',
          style: theme.textTheme.labelMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 6),
        IsselTextFormField(
          controller: _folioCorteController,
          hintText: 'Ej. 25',
          prefixIcon: Icons.point_of_sale_outlined,
          fillColor: colors.surfaceContainer,
          height: 50,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          inputFormatters: [TextInputFormatters().int],
          onChanged: _onFolioCorteChanged,
          onSubmitted: (_) => _search(),
        ),
      ],
    );
  }

  Widget _typeField(BuildContext context, List<TipoGastoEntity> types) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tipo de gasto',
          style: theme.textTheme.labelMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 6),
        IsselDropdown<TipoGastoEntity>(
          value: _selectedGasto,
          items: types
              .map(
                (type) => DropdownMenuItem<TipoGastoEntity>(
                  value: type,
                  child: Text(type.tipoGasto),
                ),
              )
              .toList(),
          hintText: 'Seleccionar tipo',
          height: 50,
          color: colors.surfaceContainer,
          onChanged: _onTypeChanged,
        ),
      ],
    );
  }

  Widget _filterActions(BuildContext context, {bool expanded = false}) {
    final colors = Theme.of(context).colorScheme;
    final searchButton = IsselButton(
      text: _isSearching ? 'Buscando...' : 'Buscar',
      height: 50,
      onTap: _isSearching ? null : _search,
    );
    final clearButton = IsselButton(
      text: 'Limpiar',
      height: 50,
      color: colors.surfaceContainer,
      textColor: colors.primary,
      onTap: _isSearching ? null : _clearFilters,
    );

    return Row(
      children: [
        if (expanded)
          Expanded(child: searchButton)
        else
          SizedBox(width: 140, child: searchButton),
        const SizedBox(width: 10),
        if (expanded)
          Expanded(child: clearButton)
        else
          SizedBox(width: 140, child: clearButton),
      ],
    );
  }

  Widget _resultsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gastos = context.watch<GastosProvider>().gastos;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _resultsContent(context, constraints, gastos);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsContent(
    BuildContext context,
    BoxConstraints constraints,
    List<GastoEntity> gastos,
  ) {
    if (_isSearching) {
      return _messageState(
        context,
        title: 'Buscando gastos',
        message: 'Estamos consultando la información disponible.',
        loading: true,
      );
    }

    if (_errorMessage != null) {
      return _messageState(
        context,
        title: 'No se pudo completar la consulta',
        message: _errorMessage!,
      );
    }

    if (!_hasSearched) {
      return _messageState(
        context,
        title: 'Aún no hay una consulta',
        message: 'Selecciona un filtro y presiona “Buscar gastos”.',
      );
    }

    if (gastos.isEmpty) {
      return _messageState(
        context,
        title: 'No encontramos gastos',
        message: 'Prueba con otro folio o tipo de gasto.',
      );
    }

    return constraints.maxWidth < 700
        ? _compactResults(context, gastos)
        : _tableResults(context, gastos);
  }

  Widget _tableResults(BuildContext context, List<GastoEntity> gastos) {
    final colors = Theme.of(context).colorScheme;

    return IsselTableWidget(
      color: colors.surface,
      header: IsselHeaderTable(
        titleHeaders: const ['Folio del gasto', 'Tipo', 'Importe', 'Fecha'],
        colorPills: colors.surfaceContainer,
      ),
      rows: gastos
          .map(
            (gasto) => IsselRowTable(
              cells: [
                _resultCell(context, gasto.folio.toString()),
                _resultCell(context, gasto.tipoGasto),
                _resultCell(context, _money(gasto.importe)),
                _resultCell(context, _date(gasto.fecha)),
              ],
            ),
          )
          .toList(),
    );
  }

  IsselPill _resultCell(BuildContext context, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return IsselPill(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      color: colors.surfaceContainer,
      widget: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface),
      ),
    );
  }

  Widget _compactResults(BuildContext context, List<GastoEntity> gastos) {
    return ListView.separated(
      padding: const EdgeInsets.only(right: 4),
      itemCount: gastos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final gasto = gastos[index];
        final colors = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gasto.tipoGasto,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _money(gasto.importe),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Folio del gasto ${gasto.folio} · ${_date(gasto.fecha)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _messageState(
    BuildContext context, {
    required String title,
    required String message,
    bool loading = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            IsselCircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 14),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState(BuildContext context) {
    return _messageState(
      context,
      title: 'Cargando tipos de gasto',
      message: 'Estamos preparando los filtros disponibles.',
      loading: true,
    );
  }

  Widget _typesError(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No se pudieron cargar los filtros',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => setState(
                  () => _futureTipoGasto =
                      context.read<GastosProvider>().getTiposGastos(),
                ),
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  String _date(DateTime value) => DateFormat('dd/MM/yyyy HH:mm').format(value);
}
