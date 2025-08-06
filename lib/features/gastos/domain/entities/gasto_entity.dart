import 'package:equatable/equatable.dart';

class GastoEntity extends Equatable{
  final String tipoGasto;
  final double importe;
  final DateTime fecha;
  final int? folioVentas;

  GastoEntity({
    required this.tipoGasto,
    required this.importe,
    required this.fecha,
    this.folioVentas,
  });

  @override
  List<Object?> get props => [tipoGasto, importe, fecha, folioVentas];

}
