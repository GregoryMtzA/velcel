import 'dart:convert';

import 'package:velcel/features/gastos/domain/entities/gasto_entity.dart';

class GastoModel extends GastoEntity {
  GastoModel({
    required super.folio,
    required super.tipoGasto,
    required super.importe,
    required super.fecha,
  });

  factory GastoModel.fromRawJson(String str) =>
      GastoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GastoModel.fromJson(Map<String, dynamic> json) => GastoModel(
        folio: json["folio"],
        tipoGasto: json["tipogasto"],
        importe: json["importe"],
        fecha: json["fecha"],
      );

  Map<String, dynamic> toJson() => {
        "folio": folio,
        "tipogasto": tipoGasto,
        "importe": importe,
        "fecha": fecha.toIso8601String(),
      };
}
