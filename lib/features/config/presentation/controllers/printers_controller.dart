import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:velcel/core/utils/bluetooth_permissions.dart';
import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';

class PrintersControllers extends ChangeNotifier {

  PrinterRepositoryInterface repository;

  PrintersControllers({
    required this.repository,
  }){
    repository.getPrinterSaved().then((Either<String, BluetoothInfoEquatable?> response) {
      response.fold(
        (l) {
          print(l);
        },
        (r) {
          selectedPrinter = r;
          notifyListeners();
        },
      );
    },);
  }

  BluetoothInfoEquatable? selectedPrinter;

  Future<void> selectPrinter(BluetoothInfoEquatable? value) async {
    try {
      selectedPrinter = value;
      await repository.savePrinter(selectedPrinter!.bluetoothInfo.macAdress);
      notifyListeners();
    } catch (e) {
      print("error 48967");
    }
  }

  Future<Either<String, void>> emparejarImpresora(String macAddress) async {
    try {

      final bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

      if (!bluetoothEnabled) {
        return Left("Bluetooth Desactivado");
      }

      bool result = await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

      if (!result) {
        return Left("Conexion fallida");
      }

      notifyListeners();
      return Right(null);

    } catch (e) {
      return Left("Error inesperado");
    }
  }

  Future<Either<String, List<BluetoothInfoEquatable>>> escanearImpresoras() async {
    try {

      final hasLoc = await requestFineLocationPermission();
      if (!hasLoc) {
        return Left('Se requiere ACCESS_FINE_LOCATION para escanear Bluetooth');
      }

      final ok = await checkBluetoothPermissions();

      final result = await PrintBluetoothThermal.isPermissionBluetoothGranted;

      print("escanenando nuevamente");

      if (ok || result) {
        final List<BluetoothInfo> dispositivos = await PrintBluetoothThermal.pairedBluetooths;

        List<BluetoothInfoEquatable> dispositivosEquatable = dispositivos.map((e) => BluetoothInfoEquatable(bluetoothInfo: e),).toList();

        if (dispositivosEquatable.any((element) => element == selectedPrinter,)) {
          return Right(dispositivosEquatable);
        } else {
          selectedPrinter = dispositivosEquatable.firstWhere((element) => element != selectedPrinter,);
          notifyListeners();
          return Left("La impresora está desconfigurada");
        }
      }

      return Left("No hay permisos");

    } catch (e) {
      return Left('Error al escanear impresoras: $e');
    }
  }

  Future<Either<String, void>> checkStatusConnect() async {

    Either<String, BluetoothInfoEquatable?> response = await repository.getPrinterSaved();

    return response.fold(
      (l) {
        return Left(l);
      },
      (r) async {

        if (r == null) {
          return Left("Impresora no configurada");
        }

        await PrintBluetoothThermal.disconnect.catchError(() {});

        bool connect = await PrintBluetoothThermal.connect(macPrinterAddress: r.bluetoothInfo.macAdress);

        if (!connect) {
          return Left("No se pudo realizar la conexión");
        }

        bool isConnected = await PrintBluetoothThermal.connectionStatus;

        if (!isConnected) {
          return Left("Impresora no conectada");
        }

        return Right(null);

      },
    );

  }

}