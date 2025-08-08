import 'package:equatable/equatable.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothInfoEquatable extends Equatable {

  BluetoothInfo bluetoothInfo;

  BluetoothInfoEquatable({
    required this.bluetoothInfo
  });

  @override
  // TODO: implement props
  List<Object?> get props => [bluetoothInfo.name, bluetoothInfo.macAdress];

}