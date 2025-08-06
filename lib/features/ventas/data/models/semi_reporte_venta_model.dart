import 'package:meta/meta.dart';
import 'dart:convert';

import '../../domain/entities/semi_reporte_venta_entity.dart';

class SemiReporteVentaModel extends SemiReporteVentaEntity {
  final int folio;
  final double total;
  final String metodo;
  final String credito;
  final DateTime fecha;
  final String usuario;

  SemiReporteVentaModel({
    required this.folio,
    required this.total,
    required this.metodo,
    required this.credito,
    required this.fecha,
    required this.usuario,
  }) : super(
    folio: folio,
    total: total,
    metodo: metodo,
    credito: credito,
    fecha: fecha,
    usuario: usuario
  );

  factory SemiReporteVentaModel.fromRawJson(String str) => SemiReporteVentaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SemiReporteVentaModel.fromJson(Map<String, dynamic> json) => SemiReporteVentaModel(
    folio: json["folio"],
    total: json["total"],
    metodo: json["metodo"],
    credito: json["credito"],
    fecha: json["fecha"],
    usuario: json["usuario"],
  );

  Map<String, dynamic> toJson() => {
    "folio": folio,
    "total": total,
    "metodo": metodo,
    "credito": credito,
    "fecha": fecha.toIso8601String(),
    "usuario": usuario,
  };
}
