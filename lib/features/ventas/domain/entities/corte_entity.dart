import 'package:equatable/equatable.dart';

class CorteEntity extends Equatable{
  final String usuario;
  final DateTime fechaapertura;
  final DateTime fechacierre;
  final double cantidadefectivo;
  final double cantidadtarjeta;
  final double fondo;
  final double gastos;
  final double total;
  final double totalconteo;
  final double diferencia;

  CorteEntity({
    required this.usuario,
    required this.fechaapertura,
    required this.fechacierre,
    required this.cantidadefectivo,
    required this.cantidadtarjeta,
    required this.fondo,
    required this.gastos,
    required this.total,
    required this.totalconteo,
    required this.diferencia,
  });

  @override
  List<Object?> get props => [usuario, fechaapertura, fechacierre, cantidadefectivo, cantidadtarjeta, fondo, gastos, total, totalconteo, diferencia];

}
