import 'package:equatable/equatable.dart';

class SemiReporteVentaEntity extends Equatable {
  final int folio;
  final double total;
  final String metodo;
  final String credito;
  final DateTime fecha;
  final String usuario;

  SemiReporteVentaEntity({
    required this.folio,
    required this.total,
    required this.metodo,
    required this.credito,
    required this.fecha,
    required this.usuario,
  });

  @override
  List<Object?> get props => [folio, total, metodo, credito, fecha, usuario];

}
