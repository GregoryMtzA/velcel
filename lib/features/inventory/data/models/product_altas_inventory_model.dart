import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:velcel/features/inventory/domain/entities/product_inventory_entity.dart';

import '../../domain/entities/product_altas_inventory_entity.dart';

class ProductAltasInventoryModel extends ProductAltasInventoryEntity {
  final String sucursal;
  final String nombre;
  final int cantidad;
  final DateTime fecha;
  final String? motivo;

  ProductAltasInventoryModel({
    required this.sucursal,
    required this.nombre,
    required this.cantidad,
    required this.fecha,
    this.motivo
  }) : super(
    sucursal: sucursal,
    nombre: nombre,
    cantidad: cantidad,
    motivo: motivo,
    fecha: fecha
  );

  factory ProductAltasInventoryModel.fromRawJson(String str) => ProductAltasInventoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductAltasInventoryModel.fromJson(Map<String, dynamic> json) => ProductAltasInventoryModel(
    sucursal: json["sucursal"],
    nombre: json["nombre"],
    cantidad: json["cantidad"],
    motivo: json["motivo"].toString(),
    fecha: json["fecha"],
  );

  Map<String, dynamic> toJson() => {
    "sucursal": sucursal,
    "nombre": nombre,
    "cantidad": cantidad,
    "motivo": motivo,
    "fecha": fecha,
  };
}
