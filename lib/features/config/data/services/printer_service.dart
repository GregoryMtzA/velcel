import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _systemPrinterKey = 'PRINTER';
const _printerTransportKey = 'printer_transport';
const _systemTransport = 'system';
const _bluetoothTransport = 'bluetooth';

/// Persiste la impresora del sistema usada únicamente por la ruta de
/// depuración con [printing]. El flujo Bluetooth conserva su propio MAC.
class PrinterService {
  PrinterService({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
  Printer? selectedPrinter;

  Future<Printer?> getSelectedPrinter() async {
    if (selectedPrinter != null) return selectedPrinter;
    return getPrinter();
  }

  Future<({Printer? printer, List<Printer> printers})> loadData() async {
    final printer = await getPrinter();
    final printers = await listPrinters();
    return (printer: printer, printers: printers);
  }

  Future<List<Printer>> listPrinters() async {
    if (!await _canListPrinters()) return const <Printer>[];

    final printers = List<Printer>.from(await Printing.listPrinters());
    final selected = selectedPrinter;

    if (selected == null) return printers;

    final index = printers.indexWhere((printer) => printer.url == selected.url);
    if (index >= 0) {
      printers[index] = selected;
    }
    return printers;
  }

  Future<Printer?> getPrinter() async {
    final savedUrl = sharedPreferences.getString(_systemPrinterKey);
    if (savedUrl == null) return null;

    final printers = await listPrinters();
    for (final printer in printers) {
      if (printer.url == savedUrl) {
        selectedPrinter = printer;
        return printer;
      }
    }

    return null;
  }

  Future<bool> _canListPrinters() async {
    try {
      return (await Printing.info()).canListPrinters;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPrinter(Printer printer) async {
    final saved = await sharedPreferences.setString(
      _systemPrinterKey,
      printer.url,
    );
    if (!saved) {
      throw StateError('No se pudo guardar la impresora del sistema');
    }

    final transportSaved = await sharedPreferences.setString(
      _printerTransportKey,
      _systemTransport,
    );
    if (!transportSaved) {
      throw StateError('No se pudo guardar el tipo de impresora');
    }

    selectedPrinter = printer;
  }

  Future<void> selectBluetooth() async {
    await sharedPreferences.remove(_systemPrinterKey);
    final saved = await sharedPreferences.setString(
      _printerTransportKey,
      _bluetoothTransport,
    );
    if (!saved) {
      throw StateError('No se pudo guardar el tipo de impresora');
    }

    selectedPrinter = null;
  }

  bool isSystemPrinterSelected() {
    return sharedPreferences.getString(_printerTransportKey) ==
        _systemTransport;
  }
}
