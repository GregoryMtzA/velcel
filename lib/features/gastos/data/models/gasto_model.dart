import 'dart:convert';

import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';

class GastoModel extends GastoEntity{
  final String tipoGasto;
  final double importe;
  final DateTime fecha;
  final int? folioVentas;

  GastoModel({
    required this.tipoGasto,
    required this.importe,
    required this.fecha,
    this.folioVentas,
  }) : super(
    tipoGasto: tipoGasto,
    importe: importe,
    fecha: fecha
  );

  factory GastoModel.fromRawJson(String str) => GastoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GastoModel.fromJson(Map<String, dynamic> json) => GastoModel(
    tipoGasto: json["tipogasto"],
    importe: json["importe"],
    fecha: json["fecha"],
    folioVentas: json["folioventas"],
  );

  Map<String, dynamic> toJson() => {
    "tipogasto": tipoGasto,
    "importe": importe,
    "fecha": fecha.toIso8601String(),
    "folioventas": folioVentas,
  };
}
