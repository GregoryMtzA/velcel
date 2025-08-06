import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:velcel/features/gastos/domain/entities/tipo_gasto_entity.dart';

class TipoGastoModel extends TipoGastoEntity{
  final String tipoGasto;

  TipoGastoModel({
    required this.tipoGasto,
  }) : super(tipoGasto: tipoGasto);

  factory TipoGastoModel.fromRawJson(String str) => TipoGastoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TipoGastoModel.fromJson(Map<String, dynamic> json) => TipoGastoModel(
    tipoGasto: json["tipogasto"],
  );

  Map<String, dynamic> toJson() => {
    "tipogasto": tipoGasto,
  };
}
