import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/ventas/domain/entities/clientes_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/productos_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/reporte_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';
import 'package:velcel/features/ventas/presentation/providers/ventas_provider.dart';

class VerDetailVentaScreen extends StatefulWidget {
  const VerDetailVentaScreen({
    super.key,
    required this.semiReporteVentaEntity,
  });

  final SemiReporteVentaEntity semiReporteVentaEntity;

  @override
  State<VerDetailVentaScreen> createState() => _VerDetailVentaScreenState();
}

class _VerDetailVentaScreenState extends State<VerDetailVentaScreen> {
  late Future<dartz.Either<String, ReporteVentaEntity>> _future;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    final provider = context.read<VentasProvider>();
    _future = provider.getDetailReportWithFolio(
      widget.semiReporteVentaEntity.folio,
      widget.semiReporteVentaEntity.credito,
    );
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
          'Detalle de venta',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NavigationService.appBarLeading(context),
      ),
      body: SafeArea(
        child: FutureBuilder<dartz.Either<String, ReporteVentaEntity>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingState(context);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _errorState(
                context,
                'No se pudo cargar el detalle de la venta.',
              );
            }

            return snapshot.data!.fold(
              (error) => _errorState(context, error),
              (report) => _detailContent(context, report),
            );
          },
        ),
      ),
    );
  }

  Widget _detailContent(BuildContext context, ReporteVentaEntity report) {
    final cliente =
        report.clienteCredito != null && report.clienteCredito!.isNotEmpty
            ? report.clienteCredito!.first
            : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _saleSummary(context, cliente),
              const SizedBox(height: 20),
              _detailSections(context, report),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saleSummary(
    BuildContext context,
    ClientesVentaEntity? client,
  ) {
    final colors = Theme.of(context).colorScheme;
    final sale = widget.semiReporteVentaEntity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 560
                  ? 2
                  : 1;
          const spacing = 12.0;
          final itemWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - spacing * (columns - 1)) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              _summaryField(
                width: itemWidth,
                title: 'Folio',
                value: sale.folio.toString(),
              ),
              _summaryField(
                width: itemWidth,
                title: 'Total',
                value: _money(sale.total),
              ),
              _summaryField(
                width: itemWidth,
                title: 'Método',
                value: sale.metodo,
              ),
              _summaryField(
                width: itemWidth,
                title: 'Crédito',
                value: sale.credito,
              ),
              _summaryField(
                width: itemWidth,
                title: 'Fecha',
                value: _dateTime(sale.fecha),
              ),
              _summaryField(
                width: itemWidth,
                title: 'Vendedor',
                value: sale.usuario,
              ),
              if (sale.credito != 'No' && client != null) ...[
                _summaryField(
                  width: itemWidth,
                  title: 'Nombre',
                  value: client.nombre,
                ),
                _summaryField(
                  width: itemWidth,
                  title: 'Domicilio',
                  value: client.domicilio,
                ),
                _summaryField(
                  width: itemWidth,
                  title: 'Teléfono',
                  value: client.telefono,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _summaryField({
    required double width,
    required String title,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: IsselInfoField(
        title: title,
        value: value,
        backColor: colors.surfaceContainer,
        valueBackColor: colors.surface,
      ),
    );
  }

  Widget _detailSections(
    BuildContext context,
    ReporteVentaEntity report,
  ) {
    final productsSection = _productsSection(context, report.productos);
    final imeisSection = _imeisSection(context, report);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: productsSection),
                const SizedBox(width: 20),
                Expanded(child: imeisSection),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            productsSection,
            const SizedBox(height: 20),
            imeisSection,
          ],
        );
      },
    );
  }

  Widget _productsSection(
    BuildContext context,
    List<ProductosVentaEntity> products,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _sectionCard(
      context,
      title: 'Productos',
      count: products.length,
      child: products.isEmpty
          ? _emptyText(context, 'No hay productos registrados.')
          : Column(
              children: [
                _listHeader(
                  context,
                  left: 'Nombre',
                  right: 'Cantidad',
                ),
                const SizedBox(height: 8),
                ...products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: IsselPill(
                      height: 46,
                      color: colors.surfaceContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      widget: Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 76,
                            child: Text(
                              '${product.cantidad} uds.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _imeisSection(
    BuildContext context,
    ReporteVentaEntity report,
  ) {
    final colors = Theme.of(context).colorScheme;

    return _sectionCard(
      context,
      title: 'IMEIs',
      count: report.imeisVentaEntity.length,
      child: report.imeisVentaEntity.isEmpty
          ? _emptyText(context, 'No hay IMEIs asociados a esta venta.')
          : Column(
              children: [
                _listHeader(context, left: 'IMEI'),
                const SizedBox(height: 8),
                ...report.imeisVentaEntity.map(
                  (imei) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: IsselInfoField2(
                      icon: Icons.phone_android_outlined,
                      label: imei.imei,
                      copy: true,
                      backColor: colors.surfaceContainer,
                      copied: () => SnackbarService.showCorrect(
                        context,
                        'IMEI',
                        'El IMEI se copió al portapapeles.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _listHeader(
    BuildContext context, {
    required String left,
    String? right,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (right != null)
            SizedBox(
              width: 76,
              child: Text(
                right,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
    int? count,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 30,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 12),
                  IsselPill(
                    text: '$count',
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    color: colors.surfaceContainer,
                    textColor: colors.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _emptyText(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.outline,
          ),
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
            'Cargando detalle de la venta',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No se pudo mostrar la venta',
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
              const SizedBox(height: 18),
              IsselButton(
                text: 'Reintentar',
                height: 50,
                width: 140,
                onTap: () {
                  setState(_loadDetail);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  String _dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm').format(value);
}
