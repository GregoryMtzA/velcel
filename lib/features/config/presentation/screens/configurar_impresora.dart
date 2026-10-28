import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/config/data/services/printer_service.dart';
import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class ConfigurarImpresora extends StatefulWidget {
  const ConfigurarImpresora({super.key});

  @override
  State<ConfigurarImpresora> createState() => _ConfigurarImpresoraState();
}

class _ConfigurarImpresoraState extends State<ConfigurarImpresora> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _macController = TextEditingController();
  final _macPattern = RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$');

  late Future<dartz.Either<String, List<BluetoothInfoEquatable>>> _devices;
  late Future<({Printer? printer, List<Printer> printers})> _systemPrinters;
  bool _showManualConnection = false;
  bool _isConnecting = false;
  String? _selectingMac;
  String? _selectingSystemUrl;

  bool get _isBusy =>
      _isConnecting || _selectingMac != null || _selectingSystemUrl != null;

  @override
  void initState() {
    super.initState();
    _devices = context.read<PrintersControllers>().escanearImpresoras();
    _systemPrinters = _loadSystemPrinters();
  }

  @override
  void dispose() {
    _macController.dispose();
    super.dispose();
  }

  void _refreshDevices() {
    setState(() {
      _devices = context.read<PrintersControllers>().escanearImpresoras();
      _systemPrinters = _loadSystemPrinters();
    });
  }

  Future<void> _selectPrinter(BluetoothInfoEquatable printer) async {
    if (_isBusy) return;

    setState(() => _selectingMac = printer.bluetoothInfo.macAdress);
    final result =
        await context.read<PrintersControllers>().selectPrinter(printer);
    if (!mounted) return;

    setState(() {
      _selectingMac = null;
      _systemPrinters = _loadSystemPrinters();
    });
    result.fold(
      (error) => SnackbarService.showIncorrect(context, 'Impresora', error),
      (_) => SnackbarService.showCorrect(
        context,
        'Impresora',
        'Impresora guardada',
      ),
    );
  }

  Future<void> _selectSystemPrinter(Printer printer) async {
    if (_isBusy) return;

    final service = _printerService;
    if (service == null) return;

    setState(() => _selectingSystemUrl = printer.url);
    try {
      await service.setPrinter(printer);
      if (!mounted) return;

      setState(() {
        _selectingSystemUrl = null;
        _systemPrinters = _loadSystemPrinters();
      });
      SnackbarService.showCorrect(
        context,
        'Impresora',
        'Impresora del sistema guardada para depuración',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _selectingSystemUrl = null);
      SnackbarService.showIncorrect(
        context,
        'Impresora',
        'No se pudo guardar la impresora: $error',
      );
    }
  }

  PrinterService? get _printerService {
    if (!locator.isRegistered<PrinterService>()) return null;
    return locator<PrinterService>();
  }

  Future<({Printer? printer, List<Printer> printers})> _loadSystemPrinters() {
    final service = _printerService;
    if (service == null) {
      return Future.value(
        (printer: null, printers: const <Printer>[]),
      );
    }
    return service.loadData();
  }

  Future<void> _connectByMac() async {
    if (_isBusy || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final mac = _macController.text.trim().toUpperCase().replaceAll('-', ':');
    setState(() => _isConnecting = true);

    final result =
        await context.read<PrintersControllers>().emparejarImpresora(mac);
    if (!mounted) return;

    setState(() => _isConnecting = false);
    result.fold(
      (error) => SnackbarService.showIncorrect(context, 'Impresora', error),
      (_) {
        SnackbarService.showCorrect(context, 'Impresora', 'Impresora guardada');
        _refreshDevices();
      },
    );
  }

  String? _validateMac(String? value) {
    final mac = (value ?? '').trim().toUpperCase().replaceAll('-', ':');
    if (mac.isEmpty) return 'Escribe la dirección MAC';
    if (!_macPattern.hasMatch(mac)) return 'Usa AA:BB:CC:DD:EE:FF';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(selected: MenuDestination.printer),
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Impresora',
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
            final horizontalPadding = constraints.maxWidth >= 760 ? 32.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: _printerCard(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _printerCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = context.watch<PrintersControllers>().selectedPrinter;

    return _surfaceCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<dartz.Either<String, List<BluetoothInfoEquatable>>>(
            future: _devices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loadingState(context);
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _message(
                  context,
                  title: 'No se pudo consultar Bluetooth',
                  message: 'Intenta actualizar la lista de impresoras.',
                );
              }

              return snapshot.data!.fold(
                (error) => _message(
                  context,
                  title: 'No se encontraron impresoras',
                  message: error,
                ),
                (printers) => printers.isEmpty
                    ? _message(
                        context,
                        title: 'No hay impresoras vinculadas',
                        message:
                            'Vincula una impresora o usa la conexión manual.',
                      )
                    : _connectionLayout(context, printers, selected),
              );
            },
          ),
          const SizedBox(height: 22),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 8),
          _manualConnectionToggle(context),
          if (_showManualConnection) ...[
            const SizedBox(height: 12),
            _manualConnectionForm(context),
          ],
          if (Platform.isWindows) ...[
            const SizedBox(height: 22),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: 20),
            _systemPrinterSection(context),
          ],
        ],
      ),
    );
  }

  Widget _systemPrinterSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_printerService == null) {
      return Text(
        'La lista de impresoras del sistema estará disponible al iniciar la aplicación.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.outline,
        ),
      );
    }

    return FutureBuilder<({Printer? printer, List<Printer> printers})>(
      future: _systemPrinters,
      builder: (context, snapshot) {
        final selected = snapshot.data?.printer;
        final printers = snapshot.data?.printers ?? const <Printer>[];
        final selectedPrinter = _matchingSystemPrinter(printers, selected);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Impresoras del sistema',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isBusy ? null : _refreshDevices,
                  icon: const Icon(Icons.refresh_outlined, size: 18),
                  label: const Text('Actualizar'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Incluye impresoras USB instaladas en Windows. Esta ruta se usará para depuración.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.outline,
              ),
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState == ConnectionState.waiting)
              IsselShimmer(width: double.infinity, height: 58)
            else if (snapshot.hasError)
              Text(
                'No se pudieron consultar las impresoras del sistema.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.error,
                ),
              )
            else if (printers.isEmpty)
              Text(
                'No hay impresoras del sistema disponibles.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
              )
            else ...[
              IsselDropdown<Printer>(
                value: selectedPrinter,
                hintText: 'Seleccionar impresora USB / sistema',
                color: colors.surfaceContainer,
                height: 58,
                items: printers.map((printer) {
                  final name = printer.name.trim();
                  final location = printer.location?.trim();
                  final subtitle =
                      location?.isNotEmpty == true ? '$name · $location' : name;
                  return DropdownMenuItem<Printer>(
                    value: printer,
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: _isBusy
                    ? null
                    : (printer) {
                        if (printer != null) _selectSystemPrinter(printer);
                      },
              ),
              if (selectedPrinter != null) ...[
                const SizedBox(height: 10),
                IsselInfoField2(
                  icon: Icons.usb_outlined,
                  label: 'Activa para depuración: ${selectedPrinter.name}',
                  copy: false,
                  height: 52,
                  backColor: colors.surfaceContainer,
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _connectionLayout(
    BuildContext context,
    List<BluetoothInfoEquatable> printers,
    BluetoothInfoEquatable? selected,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final active = _activePrinterSection(context, selected);
        final selector = _printerSelector(context, printers, selected);

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              active,
              const SizedBox(height: 22),
              selector,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: active),
            const SizedBox(width: 28),
            Expanded(child: selector),
          ],
        );
      },
    );
  }

  Widget _activePrinterSection(
    BuildContext context,
    BluetoothInfoEquatable? selected,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = selected?.bluetoothInfo.name.trim();
    final printerName = name?.isNotEmpty == true ? name! : 'Impresora guardada';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bluetooth seleccionado',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (selected == null) ...[
          Text(
            'Aún no has seleccionado una impresora.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Elige un dispositivo vinculado en la lista.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
          ),
        ] else ...[
          IsselInfoField(
            title: 'Nombre',
            value: printerName,
            height: 52,
            backColor: colors.surfaceContainer,
            valueBackColor: colors.surface,
          ),
          const SizedBox(height: 10),
          IsselInfoField2(
            icon: Icons.bluetooth_outlined,
            label: selected.bluetoothInfo.macAdress,
            copy: true,
            height: 52,
            backColor: colors.surfaceContainer,
          ),
        ],
      ],
    );
  }

  Widget _printerSelector(
    BuildContext context,
    List<BluetoothInfoEquatable> printers,
    BluetoothInfoEquatable? selected,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedDevice = _matchingPrinter(printers, selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Dispositivos vinculados',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _isBusy ? null : _refreshDevices,
              icon: const Icon(Icons.refresh_outlined, size: 18),
              label: const Text('Actualizar'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona el dispositivo que quieres usar.',
          style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 12),
        IsselDropdown<BluetoothInfoEquatable>(
          value: selectedDevice,
          hintText: 'Seleccionar impresora',
          color: colors.surfaceContainer,
          height: 58,
          items: printers.map((printer) {
            final name = printer.bluetoothInfo.name.trim();
            final mac = printer.bluetoothInfo.macAdress;
            return DropdownMenuItem<BluetoothInfoEquatable>(
              value: printer,
              child: Text(
                name.isEmpty ? mac : name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: _isBusy
              ? null
              : (printer) {
                  if (printer != null) _selectPrinter(printer);
                },
        ),
      ],
    );
  }

  Widget _manualConnectionToggle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: _isBusy
          ? null
          : () => setState(() {
                _showManualConnection = !_showManualConnection;
              }),
      icon: Icon(
        _showManualConnection
            ? Icons.keyboard_arrow_up_outlined
            : Icons.link_outlined,
        size: 20,
      ),
      label: Text(
        _showManualConnection
            ? 'Ocultar conexión manual'
            : '¿No aparece? Conectar por dirección MAC',
      ),
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: colors.primary,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _manualConnectionForm(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Escribe la dirección MAC de la impresora para vincularla.',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
          ),
          const SizedBox(height: 10),
          IsselTextFormField(
            controller: _macController,
            hintText: 'AA:BB:CC:DD:EE:FF',
            prefixIcon: Icons.bluetooth_outlined,
            fillColor: colors.surfaceContainer,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              TextInputFormatter.withFunction(
                (oldValue, newValue) => newValue.copyWith(
                  text: newValue.text.toUpperCase(),
                ),
              ),
            ],
            validator: _validateMac,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onSubmitted: (_) => _connectByMac(),
          ),
          const SizedBox(height: 12),
          IsselButton(
            text: _isConnecting ? 'Vinculando...' : 'Vincular y guardar',
            onTap: _isBusy ? null : _connectByMac,
            height: 56,
          ),
        ],
      ),
    );
  }

  Widget _loadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Buscando dispositivos vinculados...',
          style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 10),
        IsselShimmer(width: double.infinity, height: 58),
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

  BluetoothInfoEquatable? _matchingPrinter(
    List<BluetoothInfoEquatable> printers,
    BluetoothInfoEquatable? selected,
  ) {
    if (selected == null) return null;
    for (final printer in printers) {
      if (printer.bluetoothInfo.macAdress.toUpperCase() ==
          selected.bluetoothInfo.macAdress.toUpperCase()) {
        return printer;
      }
    }
    return null;
  }

  Printer? _matchingSystemPrinter(
    List<Printer> printers,
    Printer? selected,
  ) {
    if (selected == null) return null;
    for (final printer in printers) {
      if (printer.url == selected.url) return printer;
    }
    return null;
  }

  Widget _message(
    BuildContext context, {
    required String title,
    required String message,
  }) {
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
        const SizedBox(height: 4),
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _isBusy ? null : _refreshDevices,
          icon: const Icon(Icons.refresh_outlined, size: 18),
          label: const Text('Actualizar lista'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}
