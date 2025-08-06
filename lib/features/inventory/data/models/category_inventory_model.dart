import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:velcel/features/inventory/domain/entities/category_inventory_entity.dart';

class CategoryInventoryModel extends CategoryInventoryEntity {
  final String categoria;

  CategoryInventoryModel({
    required this.categoria,
  }) : super(
    categoria: categoria
  );

  factory CategoryInventoryModel.fromRawJson(String str) => CategoryInventoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoryInventoryModel.fromJson(Map<String, dynamic> json) => CategoryInventoryModel(
    categoria: json["categoria"],
  );

  Map<String, dynamic> toJson() => {
    "categoria": categoria,
  };
}
