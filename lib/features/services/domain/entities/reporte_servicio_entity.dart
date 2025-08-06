import 'package:equatable/equatable.dart';

class ReporteServicioEntity extends Equatable {

  final int folio;
  final DateTime fecha;
  final DateTime fechaEstimada;
  final String sucursal;
  final String cliente;
  final String marca;
  final String modelo;
  final String serie;
  final String imei;
  final String fallaReportada;
  final String observacionLlega;
  final String descripcionCorta;

  ReporteServicioEntity({
    required this.folio,
    required this.fecha,
    required this.fechaEstimada,
    required this.sucursal,
    required this.cliente,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.imei,
    required this.fallaReportada,
    required this.observacionLlega,
    required this.descripcionCorta,
  });

  @override
  List<Object?> get props => [folio, fecha, fechaEstimada, sucursal, cliente, marca, modelo, serie, imei];

}