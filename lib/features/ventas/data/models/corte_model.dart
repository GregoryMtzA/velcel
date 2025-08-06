import 'dart:convert';

import 'package:velcel/features/ventas/domain/entities/corte_entity.dart';

class CorteModel extends CorteEntity {
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

  CorteModel({
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
  }) : super(
    usuario: usuario,
    fechaapertura: fechaapertura,
    fechacierre: fechacierre,
    cantidadefectivo: cantidadefectivo,
    cantidadtarjeta: cantidadtarjeta,
    fondo: fondo,
    gastos: gastos,
    total: total,
    totalconteo: totalconteo,
    diferencia: diferencia
  );

  factory CorteModel.fromRawJson(String str) => CorteModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CorteModel.fromJson(Map<String, dynamic> json) => CorteModel(
    usuario: json["usuario"],
    fechaapertura: json["fechaapertura"],
    fechacierre: json["fechacierre"],
    cantidadefectivo: json["cantidadefectivo"],
    cantidadtarjeta: json["cantidadtarjeta"],
    fondo: json["fondo"],
    gastos: json["gastos"],
    total: json["total"],
    totalconteo: json["totalconteo"],
    diferencia: json["diferencia"],
  );

  Map<String, dynamic> toJson() => {
    "usuario": usuario,
    "fechaapertura": fechaapertura.toIso8601String(),
    "fechacierre": fechacierre.toIso8601String(),
    "cantidadefectivo": cantidadefectivo,
    "cantidadtarjeta": cantidadtarjeta,
    "fondo": fondo,
    "gastos": gastos,
    "total": total,
    "totalconteo": totalconteo,
    "diferencia": diferencia,
  };
}
