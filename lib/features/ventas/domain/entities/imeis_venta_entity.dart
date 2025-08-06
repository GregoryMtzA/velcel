import 'package:equatable/equatable.dart';

class ImeisVentaEntity extends Equatable {
  final String imei;

  ImeisVentaEntity({
    required this.imei,
  });

  @override
  List<Object?> get props => [imei];


}
