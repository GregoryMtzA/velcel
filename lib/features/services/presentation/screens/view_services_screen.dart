import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/services/domain/entities/service_entity.dart';
import 'package:velcel/features/services/domain/entities/service_state_entity.dart';
import 'package:velcel/features/services/presentation/providers/services_provider.dart';
import 'package:velcel/features/services/presentation/screens/view_service_screen.dart';

class ViewServicesScreen extends StatefulWidget {
  const ViewServicesScreen({super.key});

  @override
  State<ViewServicesScreen> createState() => _ViewServicesScreenState();
}

class _ViewServicesScreenState extends State<ViewServicesScreen> {
  final TextEditingController _folioController = TextEditingController();

  ServiceStateEntity _selectedState = serviceStatesList.first;
  List<ServiceEntity> _services = [];
  String? _branch;
  String? _errorMessage;
  bool _isLoading = true;
  bool _lastQueryWasFolio = false;

  @override
  void initState() {
    super.initState();
    _branch = context.read<BranchProvider>().branch?.nombre;

    if (_branch == null) {
      _isLoading = false;
      _errorMessage = 'La sucursal actual no está disponible.';
    } else {
      _loadByState();
    }
  }

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
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
          'Consultar servicios',
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
          final isWide = constraints.maxWidth >= 760;
          final folio = _folioField(context);
          final state = _stateField(context);
          final actions = _filterActions(context);

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                folio,
                const SizedBox(height: 14),
                state,
                const SizedBox(height: 16),
                _filterActions(context, expanded: true),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 4, child: folio),
              const SizedBox(width: 14),
              Expanded(flex: 4, child: state),
              const SizedBox(width: 14),
              actions,
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
          'Buscar por folio',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.outline,
          ),
        ),
        const SizedBox(height: 6),
        IsselTextFormField(
          controller: _folioController,
          hintText: 'Ej. 1024',
          prefixIcon: Icons.confirmation_number_outlined,
          fillColor: colors.surfaceContainer,
          height: 50,
          readOnly: _isLoading,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          inputFormatters: [TextInputFormatters().int],
          onChanged: (_) {
            if (_errorMessage != null && mounted) {
              setState(() => _errorMessage = null);
            }
          },
          onSubmitted: (_) {
            _searchByFolio();
          },
        ),
      ],
    );
  }

  Widget _stateField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Estado del servicio',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.outline,
          ),
        ),
        const SizedBox(height: 6),
        IsselDropdown<ServiceStateEntity>(
          value: _selectedState,
          items: serviceStatesList
              .map(
                (state) => DropdownMenuItem<ServiceStateEntity>(
                  value: state,
                  child: Text(state.name),
                ),
              )
              .toList(),
          hintText: 'Seleccionar estado',
          height: 50,
          color: colors.surfaceContainer,
          onChanged: _isLoading
              ? null
              : (value) {
                  if (value != null) _selectState(value);
                },
        ),
      ],
    );
  }

  Widget _filterActions(BuildContext context, {bool expanded = false}) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (expanded)
          Expanded(
            child: IsselButton(
              text: _isLoading ? 'Buscando...' : 'Buscar',
              height: 50,
              onTap: _isLoading ? null : _searchByFolio,
            ),
          )
        else
          SizedBox(
            width: 140,
            child: IsselButton(
              text: _isLoading ? 'Buscando...' : 'Buscar',
              height: 50,
              onTap: _isLoading ? null : _searchByFolio,
            ),
          ),
        const SizedBox(width: 10),
        if (expanded)
          Expanded(
            child: IsselButton(
              text: 'Limpiar',
              height: 50,
              color: colors.surfaceContainer,
              textColor: colors.primary,
              onTap: _isLoading ? null : _clearFilters,
            ),
          )
        else
          SizedBox(
            width: 140,
            child: IsselButton(
              text: 'Limpiar',
              height: 50,
              color: colors.surfaceContainer,
              textColor: colors.primary,
              onTap: _isLoading ? null : _clearFilters,
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
    if (_isLoading) {
      return _messageState(
        context,
        title: 'Buscando servicios',
        message: 'Estamos consultando las órdenes disponibles.',
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
          onTap: _retry,
        ),
      );
    }

    if (_services.isEmpty) {
      return _messageState(
        context,
        title: 'No hay servicios registrados',
        message: _lastQueryWasFolio
            ? 'No encontramos un servicio con ese folio.'
            : 'No hay órdenes con el estado seleccionado.',
      );
    }

    return constraints.maxWidth < 760
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
          'Cliente',
          'Equipo',
          'Estado',
          'Fecha',
        ],
        colorPills: colors.surfaceContainer,
      ),
      rows: _services
          .map(
            (service) => IsselRowTable(
              cells: [
                _resultCell(context, service.folio.toString()),
                _resultCell(context, service.cliente),
                _resultCell(
                  context,
                  '${service.marca} ${service.modelo}'.trim(),
                ),
                _resultCell(context, service.estado),
                _resultCell(context, _dateTime(service.fechaRec)),
              ],
            ),
          )
          .toList(),
      onTapRow: (index) => _openDetail(_services[index]),
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
      itemCount: _services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = _services[index];

        return Material(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => _openDetail(service),
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
                          'Folio ${service.folio}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IsselPill(
                        text: service.estado,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: colors.surface,
                        textColor: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: colors.outline),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.cliente,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.marca} ${service.modelo} · ${service.telefono}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateTime(service.fechaRec),
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

  Future<void> _selectState(ServiceStateEntity state) async {
    setState(() {
      _selectedState = state;
      _lastQueryWasFolio = false;
    });
    await _loadByState();
  }

  Future<void> _loadByState() async {
    final branch = _branch;
    if (branch == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _services = [];
      _lastQueryWasFolio = false;
    });

    try {
      final response = await context
          .read<ServicesProvider>()
          .getServicesWithState(_selectedState.name, branch);

      if (!mounted) return;

      response.fold(
        (error) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        },
        (services) {
          setState(() {
            _services = services;
            _isLoading = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo completar la consulta.';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByFolio() async {
    final folioText = _folioController.text.trim();
    final folio = int.tryParse(folioText);

    if (folioText.isEmpty || folio == null) {
      setState(() {
        _errorMessage = 'Ingresa un folio válido.';
        _services = [];
        _lastQueryWasFolio = true;
      });
      return;
    }

    final branch = _branch;
    if (branch == null) {
      setState(() => _errorMessage = 'La sucursal actual no está disponible.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _services = [];
      _lastQueryWasFolio = true;
    });

    try {
      final response = await context
          .read<ServicesProvider>()
          .getServiceWithFolio(folio, branch);

      if (!mounted) return;

      response.fold(
        (error) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        },
        (service) {
          setState(() {
            _services = [service];
            _isLoading = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo completar la consulta.';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearFilters() async {
    _folioController.clear();
    await _loadByState();
  }

  Future<void> _retry() {
    return _lastQueryWasFolio ? _searchByFolio() : _loadByState();
  }

  Future<void> _openDetail(ServiceEntity service) {
    return NavigationService.navigate(
      context,
      ViewServiceScreen(service: service),
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
