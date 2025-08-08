import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Verifica y solicita permisos necesarios para Bluetooth.
Future<bool> checkBluetoothPermissions() async {
  if (Platform.isAndroid) {
    final scanStatus    = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    return scanStatus.isGranted && connectStatus.isGranted;
  }
  // iOS no necesita estos permisos de runtime
  return true;
}

Future<bool> requestFineLocationPermission() async {
  final status = await Permission.location.request();
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    // El usuario lo rechazó: puedes mostrar un diálogo explicándole por qué lo necesitas
    return false;
  } else if (status.isPermanentlyDenied) {
    // Debes llevar al usuario a la configuración de la app:
    await openAppSettings();
    return false;
  }
  return false;
}