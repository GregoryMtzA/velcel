import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';
import 'package:velcel/features/ventas/presentation/providers/ventas_provider.dart';
import 'package:velcel/features/ventas/presentation/screens/ver_detail_venta_screen.dart';

class VerVentasScreen extends StatefulWidget {
  const VerVentasScreen({super.key});

  @override
  State<VerVentasScreen> createState() => _VerVentasScreenState();
}

class _VerVentasScreenState extends State<VerVentasScreen> {
  final TextEditingController _folioController = TextEditingController();
  final TextEditingController _folioCorteController = TextEditingController();
  final DateTime _initialDate = DateTime.now();

  List<SemiReporteVentaEntity> _ventas = [];
  late DateTime _initDate = _initialDate;
  late DateTime _endDate = _initialDate;
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void dispose() {
    _folioController.dispose();
    _folioCorteController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final folioText = _folioController.text.trim();
    final folioCorteText = _folioCorteController.text.trim();
    final folio = int.tryParse(folioText);
    final folioCorte = int.tryParse(folioCorteText);

    if (folioText.isNotEmpty && folio == null) {
      setState(() => _errorMessage = 'Ingresa un folio válido.');
      return;
    }

    if (folioCorteText.isNotEmpty && folioCorte == null) {
      setState(() => _errorMessage = 'Ingresa un folio de corte válido.');
      return;
    }

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
      _ventas = [];
    });

    try {
      final provider = context.read<VentasProvider>();
      final response = await provider.getSemiReportsWithFilters(
        sucursal: branch.nombre,
        folio: folio,
        folioCorte: folioCorte,
        fechaA: _initDate,
        fechaB: _endDate,
      );

      if (!mounted) return;

      String? searchError;
      int? resultCount;
      response.fold(
        (error) => searchError = error,
        (ventas) {
          _ventas = ventas;
          resultCount = ventas.length;
        },
      );

      setState(() {
        _errorMessage = searchError;
        _isSearching = false;
      });

      if (searchError == null && resultCount != null && mounted) {
        await _showResultsDialog(resultCount!);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo completar la consulta.';
          _isSearching = false;
        });
      }
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

  Future<void> _showResultsDialog(int resultCount) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final resultWord =
        resultCount == 1 ? 'venta encontrada' : 'ventas encontradas';

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
    _folioController.clear();
    _folioCorteController.clear();
    setState(() {
      _initDate = _initialDate;
      _endDate = _initialDate;
      _ventas = [];
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
        title: Text(
          'Consultar ventas',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NavigationService.appBarLeading(context),
      ),
      body: SafeArea(
        child: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
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
              _filtersCard(context),
              const SizedBox(height: 20),
              Expanded(child: _resultsCard(context)),
            ],
          ),
        );
      },
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
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 4, child: _folioField(context)),
                const SizedBox(width: 14),
                Expanded(flex: 4, child: _folioCorteField(context)),
                const SizedBox(width: 14),
                Expanded(flex: 5, child: _dateField(context)),
                const SizedBox(width: 14),
                _filterActions(context),
              ],
            );
          }

          final folioFields = constraints.maxWidth >= 640
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _folioField(context)),
                    const SizedBox(width: 14),
                    Expanded(child: _folioCorteField(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _folioField(context),
                    const SizedBox(height: 14),
                    _folioCorteField(context),
                  ],
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              folioFields,
              const SizedBox(height: 14),
              _dateField(context),
              const SizedBox(height: 14),
              _filterActions(context, expanded: true),
            ],
          );
        },
      ),
    );
  }

  Widget _folioField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Folio de venta',
          style: theme.textTheme.labelMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 6),
        IsselTextFormField(
          controller: _folioController,
          hintText: 'Ej. 1024',
          prefixIcon: Icons.confirmation_number_outlined,
          fillColor: colors.surfaceContainer,
          height: 50,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          inputFormatters: [TextInputFormatters().int],
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
          onSubmitted: (_) => _search(),
        ),
      ],
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
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
          onSubmitted: (_) => _search(),
        ),
      ],
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
                        '${_date(_initDate)}  a  ${_date(_endDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
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
        title: 'Buscando ventas',
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
        message:
            'Ingresa un folio, un folio de corte o elige un rango y presiona “Buscar”.',
      );
    }

    if (_ventas.isEmpty) {
      return _messageState(
        context,
        title: 'No encontramos ventas',
        message: 'Prueba con otro folio, folio de corte o rango de fechas.',
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
          'Folio',
          'Total',
          'Método',
          'Crédito',
          'Fecha',
          'Vendedor',
        ],
        colorPills: colors.surfaceContainer,
      ),
      rows: _ventas
          .map(
            (venta) => IsselRowTable(
              cells: [
                _resultCell(context, venta.folio.toString()),
                _resultCell(context, _money(venta.total)),
                _resultCell(context, venta.metodo),
                _resultCell(context, venta.credito),
                _resultCell(
                  context,
                  _dateTime(venta.fecha),
                  tooltipMessage: _dateTime(venta.fecha),
                ),
                _resultCell(context, venta.usuario),
              ],
            ),
          )
          .toList(),
      onTapRow: (index) => _openDetail(_ventas[index]),
    );
  }

  IsselPill _resultCell(
    BuildContext context,
    String value, {
    String? tooltipMessage,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cellText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface),
    );

    return IsselPill(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      color: colors.surfaceContainer,
      widget: tooltipMessage == null
          ? cellText
          : Tooltip(message: tooltipMessage, child: cellText),
    );
  }

  Widget _compactResults(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(right: 4),
      itemCount: _ventas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final venta = _ventas[index];
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Material(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => _openDetail(venta),
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
                          'Folio ${venta.folio}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _money(venta.total),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: colors.outline),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${venta.metodo} · Crédito: ${venta.credito}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dateTime(venta.fecha)} · ${venta.usuario}',
                    maxLines: 1,
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

  Future<void> _openDetail(SemiReporteVentaEntity venta) {
    return NavigationService.navigate(
      context,
      VerDetailVentaScreen(semiReporteVentaEntity: venta),
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

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  String _date(DateTime value) => DateFormat('dd/MM/yyyy').format(value);

  String _dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm').format(value);
}
