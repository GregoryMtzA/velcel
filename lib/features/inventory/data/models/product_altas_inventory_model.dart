import 'dart:convert';

import '../../domain/entities/product_altas_inventory_entity.dart';

// TODO: 21/07/26
class ProductAltasInventoryModel extends ProductAltasInventoryEntity {
  final String sucursal;
  final String nombre;
  final int cantidad;
  final DateTime fecha;
  final List<String>? imeis;
  final String? motivo;

  ProductAltasInventoryModel({
    required this.sucursal,
    required this.nombre,
    required this.cantidad,
    required this.fecha,
    required this.imeis,
    this.motivo,
  }) : super(
          sucursal: sucursal,
          nombre: nombre,
          cantidad: cantidad,
          motivo: motivo,
          imeis: imeis,
          fecha: fecha,
        );

  factory ProductAltasInventoryModel.fromRawJson(String str) =>
      ProductAltasInventoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductAltasInventoryModel.fromJson(Map<String, dynamic> json) =>
      ProductAltasInventoryModel(
        sucursal: json["sucursal"],
        nombre: json["nombre"],
        cantidad: json["cantidad"],
        motivo: json["motivo"]?.toString(),
        imeis: json["imeis"] != null
            ? json["imeis"]
                .toString()
                .split(", ")
                .where((imei) => imei.trim().isNotEmpty)
                .map((imei) => imei.trim())
                .toList()
            : null,
        fecha: json["fecha"],
      );

  Map<String, dynamic> toJson() => {
        "sucursal": sucursal,
        "nombre": nombre,
        "cantidad": cantidad,
        "motivo": motivo,
        "imeis": imeis,
        "fecha": fecha,
      };
}
