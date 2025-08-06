import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:velcel/features/inventory/domain/entities/product_inventory_entity.dart';

class ProductInventoryModel extends ProductInventoryEntity {
  final String categoria;
  final String nombre;
  final int disponibles;
  final String descripcion;

  ProductInventoryModel({
    required this.categoria,
    required this.nombre,
    required this.disponibles,
    required this.descripcion,
  }) : super(
      categoria: categoria,
      nombre: nombre,
      disponibles: disponibles,
      descripcion: descripcion
  );

  factory ProductInventoryModel.fromRawJson(String str) => ProductInventoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductInventoryModel.fromJson(Map<String, dynamic> json) => ProductInventoryModel(
    categoria: json["categoria"],
    nombre: json["nombre"],
    disponibles: json["disponibles"],
    descripcion: json["descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "categoria": categoria,
    "nombre": nombre,
    "disponibles": disponibles,
    "descripcion": descripcion,
  };
}
