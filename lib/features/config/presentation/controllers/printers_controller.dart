import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:velcel/core/utils/bluetooth_permissions.dart';
import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';

class PrintersControllers extends ChangeNotifier {
  static const _bluetoothOperationTimeout = Duration(seconds: 15);
  static const _androidBluetoothChannel = MethodChannel(
    'com.velcel.velcel/bluetooth',
  );

  PrinterRepositoryInterface repository;
  List<BluetoothInfoEquatable>? _availablePrinters;

  PrintersControllers({
    required this.repository,
  }) {
    repository.getPrinterSaved().then(
      (Either<String, BluetoothInfoEquatable?> response) {
        response.fold(
          (error) {
            debugPrint(error);
          },
          (savedPrinter) {
            if (selectedPrinter == null) {
              selectedPrinter = _availablePrinters == null
                  ? savedPrinter
                  : _findPrinter(_availablePrinters!, savedPrinter);
              notifyListeners();
            }
          },
        );
      },
    );
  }

  BluetoothInfoEquatable? selectedPrinter;

  Future<Either<String, Unit>> selectPrinter(
      BluetoothInfoEquatable value) async {
    try {
      final saved = await repository.savePrinter(value.bluetoothInfo.macAdress);
      return saved.fold(
        (error) => Left(error),
        (_) {
          selectedPrinter = value;
          notifyListeners();
          return Right(unit);
        },
      );
    } catch (_) {
      return Left('No se pudo guardar la impresora');
    }
  }

  Future<Either<String, void>> emparejarImpresora(String macAddress) async {
    try {
      if (Platform.isAndroid &&
          !await PrintBluetoothThermal.isPermissionBluetoothGranted.timeout(
            _bluetoothOperationTimeout,
            onTimeout: () => false,
          )) {
        return Left('Se requieren permisos de Bluetooth');
      }

      final bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled
          .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
      if (!bluetoothEnabled) {
        return Left('Bluetooth desactivado');
      }

      final previousMac = selectedPrinter?.bluetoothInfo.macAdress;

      // El plugin puede devolver true en Windows si ya habia otra conexion.
      await PrintBluetoothThermal.disconnect.catchError((_) => false);

      final result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress)
              .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
      final connected = result &&
          await PrintBluetoothThermal.connectionStatus
              .timeout(_bluetoothOperationTimeout, onTimeout: () => false);

      if (!connected) {
        if (previousMac != null && previousMac != macAddress) {
          await PrintBluetoothThermal.connect(macPrinterAddress: previousMac)
              .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
        }
        return Left('Conexion fallida');
      }

      final saved = await repository.savePrinter(macAddress);
      if (saved.isLeft()) {
        return Left(
          saved.fold((error) => error, (_) => 'Error al guardar impresora'),
        );
      }

      selectedPrinter = BluetoothInfoEquatable(
        bluetoothInfo:
            BluetoothInfo(name: 'Impresora vinculada', macAdress: macAddress),
      );
      notifyListeners();
      return Right(null);
    } catch (_) {
      return Left('Error inesperado');
    }
  }

  Future<Either<String, List<BluetoothInfoEquatable>>>
      escanearImpresoras() async {
    try {
      if (Platform.isAndroid) {
        // print_bluetooth_thermal necesita ubicacion para detectar Bluetooth.
        final hasLocation = await requestFineLocationPermission().timeout(
          _bluetoothOperationTimeout,
          onTimeout: () => false,
        );
        if (!hasLocation) {
          return Left(
              'Se requiere permiso de ubicacion para buscar impresoras');
        }

        final granted = await checkBluetoothPermissions().timeout(
          _bluetoothOperationTimeout,
          onTimeout: () => false,
        );
        final pluginGranted =
            await PrintBluetoothThermal.isPermissionBluetoothGranted.timeout(
          _bluetoothOperationTimeout,
          onTimeout: () => false,
        );
        if (!granted && !pluginGranted) {
          return Left('Se requieren permisos de Bluetooth');
        }
      }

      final bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled
          .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
      if (!bluetoothEnabled) {
        return Left('Activa Bluetooth para buscar impresoras');
      }

      final devices = await _getPairedBluetooths().timeout(
        _bluetoothOperationTimeout,
        onTimeout: () => throw TimeoutException(
          'La consulta de dispositivos Bluetooth tardo demasiado',
        ),
      );
      final printers = devices
          .map((device) => BluetoothInfoEquatable(bluetoothInfo: device))
          .toList();

      _availablePrinters = printers;
      final currentMac = selectedPrinter?.bluetoothInfo.macAdress;
      final connected = currentMac != null &&
          await PrintBluetoothThermal.connectionStatus
              .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
      final availableSelection = _findPrinter(printers, selectedPrinter);
      final nextSelection =
          availableSelection ?? (connected ? selectedPrinter : null);

      if (nextSelection != selectedPrinter) {
        selectedPrinter = nextSelection;
        notifyListeners();
      }

      return Right(printers);
    } catch (error) {
      return Left('Error al escanear impresoras: $error');
    }
  }

  Future<List<BluetoothInfo>> _getPairedBluetooths() async {
    if (!Platform.isAndroid) {
      return PrintBluetoothThermal.pairedBluetooths;
    }

    final rawDevices =
        await _androidBluetoothChannel.invokeMethod<List<dynamic>>(
      'getBondedDevices',
    );

    return (rawDevices ?? const <dynamic>[])
        .map<BluetoothInfo?>((rawDevice) {
          final parts = rawDevice.toString().split('#');
          if (parts.length < 2) return null;

          final macAddress = parts.removeLast().trim();
          if (macAddress.isEmpty) return null;

          final name = parts.join('#').trim();
          return BluetoothInfo(
            name: name.isEmpty ? 'Dispositivo Bluetooth' : name,
            macAdress: macAddress,
          );
        })
        .whereType<BluetoothInfo>()
        .toList();
  }

  Future<Either<String, void>> checkStatusConnect() async {
    final response = await repository.getPrinterSaved();

    return response.fold(
      (error) => Left(error),
      (savedPrinter) async {
        if (savedPrinter == null) {
          return Left('Impresora no configurada');
        }

        if (Platform.isAndroid &&
            !await PrintBluetoothThermal.isPermissionBluetoothGranted.timeout(
              _bluetoothOperationTimeout,
              onTimeout: () => false,
            )) {
          return Left('Se requieren permisos de Bluetooth');
        }

        final bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled
            .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
        if (!bluetoothEnabled) {
          return Left('Bluetooth desactivado');
        }

        await PrintBluetoothThermal.disconnect.catchError((_) => false);

        final connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: savedPrinter.bluetoothInfo.macAdress,
        ).timeout(_bluetoothOperationTimeout, onTimeout: () => false);
        if (!connected) {
          return Left('No se pudo realizar la conexion');
        }

        final isConnected = await PrintBluetoothThermal.connectionStatus
            .timeout(_bluetoothOperationTimeout, onTimeout: () => false);
        if (!isConnected) {
          return Left('Impresora no conectada');
        }

        return Right(null);
      },
    );
  }

  BluetoothInfoEquatable? _findPrinter(
    List<BluetoothInfoEquatable> printers,
    BluetoothInfoEquatable? target,
  ) {
    if (target == null) return null;

    final targetMac = target.bluetoothInfo.macAdress.trim().toUpperCase();
    for (final printer in printers) {
      if (printer.bluetoothInfo.macAdress.trim().toUpperCase() == targetMac) {
        return printer;
      }
    }
    return null;
  }
}
