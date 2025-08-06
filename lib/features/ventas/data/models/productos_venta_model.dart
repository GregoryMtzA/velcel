import 'dart:convert';

import 'package:velcel/features/ventas/domain/entities/productos_venta_entity.dart';

class ProductosVentaModel extends ProductosVentaEntity{
  final String nombre;
  final int cantidad;

  ProductosVentaModel({
    required this.nombre,
    required this.cantidad,
  }) : super(
    nombre: nombre,
    cantidad: cantidad
  );

  factory ProductosVentaModel.fromRawJson(String str) => ProductosVentaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductosVentaModel.fromJson(Map<String, dynamic> json) => ProductosVentaModel(
    nombre: json["nombre"],
    cantidad: json["cantidad"],
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "cantidad": cantidad,
  };
}
