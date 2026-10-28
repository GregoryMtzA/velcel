import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/inventory/domain/entities/product_altas_inventory_entity.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';

class BajasInventoryScreen extends StatefulWidget {
  const BajasInventoryScreen({super.key});

  @override
  State<BajasInventoryScreen> createState() => _BajasInventoryScreenState();
}

class _BajasInventoryScreenState extends State<BajasInventoryScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateTime _initialDate = DateTime.now();

  List<ProductAltasInventoryEntity> _products = [];
  late DateTime _initDate = _initialDate;
  late DateTime _endDate = _initialDate;
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;

  Future<void> _search() async {
    final branch = context.read<BranchProvider>().branch;
    if (branch == null) {
      setState(() => _errorMessage = 'La sucursal actual no está disponible.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
      _products = [];
    });

    try {
      final response = await context
          .read<InventoryProvider>()
          .getProductsBajasWithDate(_initDate, _endDate, branch.nombre);

      if (!mounted) return;

      response.fold(
        (error) => _errorMessage = error,
        (products) => _products = products,
      );

      setState(() => _isSearching = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo completar la consulta.';
        _isSearching = false;
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectDateRange() async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
      ),
      dialogSize: const Size(450, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (!mounted ||
        results == null ||
        results.isEmpty ||
        results.first == null) {
      return;
    }

    setState(() {
      _initDate = results.first!;
      _endDate = results.length > 1 && results[1] != null
          ? results[1]!
          : results.first!;
      _errorMessage = null;
    });
  }

  void _clearFilters() {
    setState(() {
      _initDate = _initialDate;
      _endDate = _initialDate;
      _products = [];
      _hasSearched = false;
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
        leading: NavigationService.appBarLeading(context),
        title: Text(
          'Consultar bajas',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _filtersCard(context),
                  const SizedBox(height: 20),
                  Expanded(child: _resultsCard(context)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filtersCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rowWidth =
              constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: rowWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _dateField(context)),
                  const SizedBox(width: 14),
                  _filterActions(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dateField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rango de fechas',
          style: theme.textTheme.labelMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 6),
        Material(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: _isSearching ? null : _selectDateRange,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.date_range_outlined, color: colors.outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_dateFormat.format(_initDate)}  a  ${_dateFormat.format(_endDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: colors.outline),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterActions(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 140,
          child: IsselButton(
            text: _isSearching ? 'Buscando...' : 'Buscar',
            height: 50,
            onTap: _isSearching ? null : _search,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 140,
          child: IsselButton(
            text: 'Limpiar',
            height: 50,
            color: colors.surfaceContainer,
            textColor: colors.primary,
            onTap: _isSearching ? null : _clearFilters,
          ),
        ),
      ],
    );
  }

  Widget _resultsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _resultsContent(context, constraints);
        },
      ),
    );
  }

  Widget _resultsContent(BuildContext context, BoxConstraints constraints) {
    if (_isSearching) {
      return _messageState(
        context,
        title: 'Buscando bajas',
        message: 'Estamos consultando los registros del periodo.',
        loading: true,
      );
    }

    if (_errorMessage != null) {
      return _messageState(
        context,
        title: 'No se pudo completar la consulta',
        message: _errorMessage!,
        action: IsselButton(
          text: 'Reintentar',
          height: 46,
          width: 140,
          onTap: _search,
        ),
      );
    }

    if (!_hasSearched) {
      return _messageState(
        context,
        title: 'Aún no hay una consulta',
        message: 'Elige un rango y presiona “Buscar” para consultar las bajas.',
      );
    }

    if (_products.isEmpty) {
      return _messageState(
        context,
        title: 'No hay bajas registradas',
        message: 'No encontramos movimientos en el periodo seleccionado.',
      );
    }

    return constraints.maxWidth < 700
        ? _compactResults(context)
        : _tableResults(context);
  }

  Widget _tableResults(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IsselTableWidget(
      color: colors.surface,
      header: IsselHeaderTable(
        titleHeaders: const [
          'Sucursal',
          'Producto',
          'Cantidad',
          'Motivo',
          'Fecha',
        ],
        colorPills: colors.surfaceContainer,
      ),
      rows: _products
          .map(
            (product) => IsselRowTable(
              cells: [
                _resultCell(context, product.sucursal),
                _resultCell(context, product.nombre),
                _resultCell(context, product.cantidad.toString()),
                _resultCell(context, product.motivo ?? 'Sin motivo'),
                _resultCell(context, _dateTime(product.fecha)),
              ],
            ),
          )
          .toList(),
      onTapRow: (index) => _showProductInfoDialog(context, _products[index]),
    );
  }

  IsselPill _resultCell(BuildContext context, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return IsselPill(
      height: 46,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: colors.surfaceContainer,
      widget: Tooltip(
        message: value,
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _compactResults(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.only(right: 4),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = _products[index];

        return Material(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => _showProductInfoDialog(context, product),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nombre,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IsselPill(
                        text: '${product.cantidad} unidades',
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: colors.surface,
                        textColor: colors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.sucursal,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.motivo ?? 'Sin motivo'} · ${_dateTime(product.fecha)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showProductInfoDialog(
    BuildContext context,
    ProductAltasInventoryEntity product,
  ) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Detalle de la baja',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IsselInfoField(
                    title: 'Sucursal',
                    value: product.sucursal,
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 10),
                  IsselInfoField(
                    title: 'Producto',
                    value: product.nombre,
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 10),
                  IsselInfoField(
                    title: 'Cantidad',
                    value: product.cantidad.toString(),
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 10),
                  IsselInfoField(
                    title: 'Fecha',
                    value: _dateTime(product.fecha),
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 10),
                  IsselInfoField(
                    title: 'Motivo',
                    value: product.motivo ?? 'Sin motivo',
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 20),
                  IsselButton(
                    text: 'Cerrar',
                    height: 52,
                    onTap: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _messageState(
    BuildContext context, {
    required String title,
    required String message,
    bool loading = false,
    Widget? action,
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
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  String _dateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);
}
