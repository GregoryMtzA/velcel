import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;   // <-- aquí
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/store/domain/entities/cart_entity.dart';

import '../../../../core/utils/bluetooth_permissions.dart';
import '../../../store/domain/entities/ticket_entity.dart';
import '../../domain/repositories/printer_repository_interface.dart';

const _printerMacKey = 'printer_mac';

class PrinterRepositoryImpl implements PrinterRepositoryInterface {

  SharedPreferences sharedPreferences;

  PrinterRepositoryImpl({
    required this.sharedPreferences,
  });


  /// Guarda el MAC de la impresora.
  Future<Either<String, Unit>> savePrinter(String macAddress) async {
    try {
      final success = await sharedPreferences.setString(_printerMacKey, macAddress);
      if (success) {
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
      // 1) Leer MAC guardado
      final macGuardado = sharedPreferences.getString(_printerMacKey);
      if (macGuardado == null) {
        return Right(null);
      }

      // 2) Revisar permisos
      if (!await PrintBluetoothThermal.bluetoothEnabled) Left('El Bluetooth no esta activado');
      if (!await PrintBluetoothThermal.isPermissionBluetoothGranted) Left('No hay permisos de bluetooth');

      // 3) Escanear dispositivos vinculados
      final dispositivos = await PrintBluetoothThermal.pairedBluetooths;
      // 4) Buscar coincidencia de MAC
      BluetoothInfo? encontrado = dispositivos.firstWhere((d) => d.macAdress == macGuardado, orElse: null);

      return Right(BluetoothInfoEquatable(bluetoothInfo: encontrado));

    } catch (e) {
      return Left('Error al obtener impresora guardada: $e');
    }
  }

  Future<Either<String, List<BluetoothInfoEquatable>>> escanearImpresoras() async {

    try {

      final List<BluetoothInfo> dispositivos = await PrintBluetoothThermal.pairedBluetooths;

      List<BluetoothInfoEquatable> dispositivosEquatable = dispositivos.map((e) => BluetoothInfoEquatable(bluetoothInfo: e),).toList();

      return Right(dispositivosEquatable);

    } catch (e) {
      return Left('Error al escanear impresoras: $e');
    }
  }

  @override
  Future<Either<String, Unit>> printPdf(TicketEntity ticketEntity) async {
    try {
      // 1) Recuperar impresora
      final eitherPrinter = await getPrinterSaved();
      return await eitherPrinter.fold<Future<Either<String, Unit>>>(
        (err) async => Left(err),
        (printerInfo) async {

          // Obtener impresora guardada
          if (printerInfo == null) return Left('No hay impresora guardada');
          final mac = printerInfo.bluetoothInfo.macAdress;

          // 2) Revisar permisos
          if (!await PrintBluetoothThermal.bluetoothEnabled) return Left('El Bluetooth no esta activado');
          if (!await PrintBluetoothThermal.isPermissionBluetoothGranted) return Left('No hay permisos de bluetooth');

          // Desconectar cualquier conexion existente
          await PrintBluetoothThermal.disconnect.catchError((_) {});

          // Realizar una conexion nueva
          final connected = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
          if (!connected) return Left('Fallo al conectar con $mac');

          final exito = await PrintBluetoothThermal.connectionStatus;
          print("ESTA CONECTADA?");
          print(exito);

          // Imprimir
          List<int> ticket = await testTicket(ticketEntity);
          final result = await PrintBluetoothThermal.writeBytes(ticket);
          print("RESULTADO: $result");

          // Retonar exito
          return Right(unit);
        },
      );
    } catch (e) {
      return Left('Error al imprimir PDF: $e');
    }
  }

}



Future<List<int>> testTicket(TicketEntity ticket) async {
  List<int> bytes = [];
  // Using default profile
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  //bytes += generator.setGlobalFont(PosFontType.fontA);
  bytes += generator.reset();

  final ByteData data = await rootBundle.load('assets/logos/velcel.png');
  final Uint8List bytesImg = data.buffer.asUint8List();

  // 4) Redimensiona la imagen al ancho del ticket (paper.width)
  img.Image? image = img.decodeImage(bytesImg);

  final img.Image resized = img.copyResize(
    image!,
    width: (PaperSize.mm58.width * 0.8).ceil(),
  );

  // IMAGEN
  // bytes += generator.image(resized, align: PosAlign.center);

  // Generar textos

  bytes += generator.text(
    "VELCEL",
    styles: PosStyles(
      height: PosTextSize.size3,
      width: PosTextSize.size3,
      align: PosAlign.center,
      bold: true
    )
  );

  bytes += generator.text(
    "sucursal: ${ticket.sucursal}",
    styles: PosStyles(
      height: PosTextSize.size1,
      width: PosTextSize.size1,
      align: PosAlign.center,
    ),
    linesAfter: 1
  );

  bytes += generator.text(
      "-mercancias-",
      styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
          bold: true
      )
  );

  if (ticket.paguitos) {
    bytes += generator.text(
      "-Venta con paguitos-",
      styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.center,
            bold: true
    )
    );
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
  bytes += generator.text(
      "Folio: ${ticket.ventaResponse.venta.toString()}",
      styles: PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        align: PosAlign.center,
      ),
      linesAfter: 1
  );

  for (CartProductEntity product in ticket.cart) {

    bytes += generator.text(
      product.product.name,
      styles: PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        align: PosAlign.left ,
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
        text: "\$${(product.quantity * product.product.price).toStringAsFixed(2)}",
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