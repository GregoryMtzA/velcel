import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:velcel/features/ventas/domain/entities/imeis_venta_entity.dart';

class ImeisVentaModel extends ImeisVentaEntity{
  final String imei;

  ImeisVentaModel({
    required this.imei,
  }) : super(
    imei: imei
  );

  factory ImeisVentaModel.fromRawJson(String str) => ImeisVentaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ImeisVentaModel.fromJson(Map<String, dynamic> json) => ImeisVentaModel(
    imei: json["imei"],
  );

  Map<String, dynamic> toJson() => {
    "imei": imei,
  };
}
