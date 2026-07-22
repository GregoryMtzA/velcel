import 'dart:convert';

import 'package:velcel/features/inventory/domain/entities/category_inventory_entity.dart';

class CategoryInventoryModel extends CategoryInventoryEntity {
  final String categoria;
  final String categoriaVer;

  CategoryInventoryModel({
    required this.categoria,
    required this.categoriaVer,
  }) : super(
          categoria: categoria,
          categoriaVer: categoriaVer,
        );

  factory CategoryInventoryModel.fromRawJson(String str) =>
      CategoryInventoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoryInventoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryInventoryModel(
        categoria: json["categoria"],
        categoriaVer: json["categoria_ver"],
      );

  Map<String, dynamic> toJson() => {
        "categoria": categoria,
        "categoria_ver": categoriaVer,
      };
}
