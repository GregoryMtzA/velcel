import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/data/services/cash_register_closure_pdf.dart';
import 'package:velcel/features/config/data/services/printer_service.dart';
import 'package:velcel/features/store/domain/entities/cash_register_closure_ticket.dart';
import 'package:velcel/features/store/domain/entities/cart_entity.dart';

import '../../../store/domain/entities/ticket_entity.dart';
import '../services/sale_ticket_pdf.dart';
import '../../domain/repositories/printer_repository_interface.dart';

const _printerMacKey = 'printer_mac';

class PrinterRepositoryImpl implements PrinterRepositoryInterface {
  final SharedPreferences sharedPreferences;
  final PrinterService printerService;

  PrinterRepositoryImpl({
    required this.sharedPreferences,
    PrinterService? printerService,
  }) : printerService = printerService ??
            PrinterService(sharedPreferences: sharedPreferences);

  /// Guarda el MAC de la impresora.
  @override
  Future<Either<String, Unit>> savePrinter(String macAddress) async {
    try {
      final success =
          await sharedPreferences.setString(_printerMacKey, macAddress);
      if (success) {
        await printerService.selectBluetooth();
        return Right(unit);
      } else {
        return Left('Error al guardar el MAC de la impresora');
      }
    } catch (e) {
      return Left('Error al guardar impresora: $e');
    }
  }

  @override
  Future<Either<String, BluetoothInfoEquatable?>> getPrinterSaved() async {
    try {
      final macGuardado = sharedPreferences.getString(_printerMacKey);
      if (macGuardado == null) {
        return Right(null);
      }

      return Right(BluetoothInfoEquatable(
        bluetoothInfo:
            BluetoothInfo(name: 'Impresora guardada', macAdress: macGuardado),
      ));
    } catch (e) {
      return Left('Error al obtener impresora guardada: $e');
    }
  }

  Future<Either<String, List<BluetoothInfoEquatable>>>
      escanearImpresoras() async {
    try {
      final List<BluetoothInfo> dispositivos =
          await PrintBluetoothThermal.pairedBluetooths;

      List<BluetoothInfoEquatable> dispositivosEquatable = dispositivos
          .map(
            (e) => BluetoothInfoEquatable(bluetoothInfo: e),
          )
          .toList();

      return Right(dispositivosEquatable);
    } catch (e) {
      return Left('Error al escanear impresoras: $e');
    }
  }

  @override
  Future<Either<String, Unit>> printPdf(TicketEntity ticketEntity) async {
    try {
      if (printerService.isSystemPrinterSelected()) {
        return _printSystemPdf(
          printerName: 'Venta-${ticketEntity.ventaResponse.venta}',
          onLayout: (_) => generarPdfTicketVentaDepuracion(ticketEntity),
        );
      }

      return _printBytes(() => testTicket(ticketEntity));
    } catch (e) {
      return Left('Error al imprimir PDF: $e');
    }
  }

  @override
  Future<Either<String, Unit>> printClosure(
      CashRegisterClosureTicket ticket) async {
    try {
      if (printerService.isSystemPrinterSelected()) {
        return _printSystemPdf(
          printerName: 'Corte-${ticket.folio}',
          onLayout: (_) => generarPdfCorteCaja(ticket),
        );
      }

      return _printBytes(() => testClosureTicket(ticket));
    } catch (e) {
      return Left('Error al imprimir corte: $e');
    }
  }

  Future<Either<String, Unit>> _printSystemPdf({
    required String printerName,
    required Future<Uint8List> Function(PdfPageFormat format) onLayout,
  }) async {
    final printer = await printerService.getSelectedPrinter();
    if (printer == null) {
      return Left('No hay una impresora del sistema disponible');
    }

    final printed = await Printing.directPrintPdf(
      printer: printer,
      name: printerName,
      format: PdfPageFormat.roll57,
      usePrinterSettings: true,
      onLayout: onLayout,
    );

    return printed
        ? Right(unit)
        : Left('La impresora del sistema no acepto el documento');
  }

  Future<Either<String, Unit>> _printBytes(
    Future<List<int>> Function() buildBytes,
  ) async {
    final eitherPrinter = await getPrinterSaved();
    return eitherPrinter.fold<Future<Either<String, Unit>>>(
      (err) async => Left(err),
      (printerInfo) async {
        if (printerInfo == null) return Left('No hay impresora guardada');
        final mac = printerInfo.bluetoothInfo.macAdress;

        if (!await PrintBluetoothThermal.bluetoothEnabled) {
          return Left('El Bluetooth no esta activado');
        }
        if (!await PrintBluetoothThermal.isPermissionBluetoothGranted) {
          return Left('No hay permisos de bluetooth');
        }

        await PrintBluetoothThermal.disconnect.catchError((_) => false);

        final connected =
            await PrintBluetoothThermal.connect(macPrinterAddress: mac);
        if (!connected) return Left('Fallo al conectar con $mac');

        if (!await PrintBluetoothThermal.connectionStatus) {
          return Left('La impresora no esta conectada');
        }

        final bytes = await buildBytes();
        final result = await PrintBluetoothThermal.writeBytes(bytes);
        if (!result) return Left('La impresora no acepto el corte');

        return Right(unit);
      },
    );
  }
}

Future<List<int>> testTicket(TicketEntity ticket) async {
  List<int> bytes = [];
  // Using default profile
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  //bytes += generator.setGlobalFont(PosFontType.fontA);
  bytes += generator.reset();

  // Generar textos

  bytes += generator.text("VELCEL",
      styles: PosStyles(
          height: PosTextSize.size3,
          width: PosTextSize.size3,
          align: PosAlign.center,
          bold: true));

  bytes += generator.text("sucursal: ${ticket.sucursal}",
      styles: PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        align: PosAlign.center,
      ),
      linesAfter: 1);

  bytes += generator.text("-mercancias-",
      styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
          bold: true));

  if (ticket.paguitos) {
    bytes += generator.text("-Venta con paguitos-",
        styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.center,
            bold: true));
  }

  bytes += generator.text(
    "fecha: ${DateFormat("yyyy-MM-dd").format(ticket.ventaResponse.fecha)}",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
  );
  bytes += generator.text(
    "Hora: ${DateFormat("hh:mm").format(ticket.ventaResponse.fecha)}",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
  );
  bytes += generator.text("Folio: ${ticket.ventaResponse.venta.toString()}",
      styles: PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        align: PosAlign.center,
      ),
      linesAfter: 1);

  for (CartProductEntity product in ticket.cart) {
    bytes += generator.text(
      product.product.displayName,
      styles: PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        align: PosAlign.left,
      ),
    );

    bytes += generator.row([
      PosColumn(
        text: product.quantity.toString(),
        width: 2,
        styles: PosStyles(align: PosAlign.center),
      ),
      PosColumn(
        text: "\$${product.product.price.toStringAsFixed(2)}",
        width: 5,
        styles: PosStyles(align: PosAlign.center),
      ),
      PosColumn(
        text:
            "\$${(product.quantity * product.product.price).toStringAsFixed(2)}",
        width: 5,
        styles: PosStyles(align: PosAlign.center),
      ),
    ]);
  }

  if (ticket.paguitos) {
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "Importe: \$${ticket.total.toStringAsFixed(2)}",
      styles: PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        align: PosAlign.center,
      ),
    );
  }

  bytes += generator.emptyLines(1);

  bytes += generator.text(
    "Atendido por: ${ticket.supplierName}",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
  );

  bytes += generator.emptyLines(1);

  bytes += generator.text(
    "Conserve este ticket para",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
  );

  bytes += generator.text(
    "cualquier aclaración",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
  );

  bytes += generator.emptyLines(1);

  bytes += generator.text(
    "¡Vuelve pronto!",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
  );

  bytes += generator.feed(4);

  return bytes;
}

Future<List<int>> testClosureTicket(CashRegisterClosureTicket ticket) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  var bytes = <int>[];

  bytes += generator.reset();
  bytes += generator.text(
    'VELCEL',
    styles: PosStyles(
      height: PosTextSize.size3,
      width: PosTextSize.size3,
      align: PosAlign.center,
      bold: true,
    ),
  );
  bytes += generator.text(
    'CORTE DE CAJA',
    styles: PosStyles(
      height: PosTextSize.size2,
      width: PosTextSize.size2,
      align: PosAlign.center,
      bold: true,
    ),
  );
  bytes += generator.text(
    ticket.sucursal,
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.emptyLines(1);
  bytes += generator.text(
    'Folio: ${ticket.folio}',
    styles: const PosStyles(align: PosAlign.center, bold: true),
  );
  bytes += generator.text(
    'Usuario: ${ticket.usuario}',
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.text(
    'Apertura: ${_formatDateTime(ticket.fechaApertura)}',
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.text(
    'Cierre: ${DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaCierre)}',
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.hr();

  void addAmount(String label, double amount) {
    bytes += generator.row([
      PosColumn(
        text: label,
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '\$${amount.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
  }

  addAmount('Efectivo', ticket.efectivo);
  addAmount('Tarjeta', ticket.tarjeta);
  addAmount('Fondo inicial', ticket.fondo);
  addAmount('Total bruto', ticket.totalBruto);
  addAmount('Gastos', ticket.gastos);
  addAmount('Total neto', ticket.totalNeto);

  bytes += generator.hr();
  addAmount('Cantidad contada', ticket.cantidadContada);
  addAmount('Diferencia', ticket.diferencia);
  bytes += generator.text(
    'ESTADO: CERRADO',
    styles: const PosStyles(align: PosAlign.center, bold: true),
  );
  bytes += generator.emptyLines(1);
  bytes += generator.text(
    'Conserve este comprobante',
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.feed(4);

  return bytes;
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '--';
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
