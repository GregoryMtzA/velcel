import 'package:equatable/equatable.dart';

class GastoEntity extends Equatable {
  final int folio;
  final String tipoGasto;
  final double importe;
  final DateTime fecha;

  GastoEntity({
    required this.folio,
    required this.tipoGasto,
    required this.importe,
    required this.fecha,
  });

  @override
  List<Object?> get props => [folio, tipoGasto, importe, fecha];
}
