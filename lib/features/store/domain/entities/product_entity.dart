import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String name;
  final String nombreVer;
  final String description;
  final double price;
  final Uint8List? image;
  final String category;
  final bool rimei;
  final bool activo;

  const ProductEntity({
    required this.name,
    required this.nombreVer,
    required this.description,
    required this.price,
    required this.image,
    required this.rimei,
    required this.category,
    required this.activo,
  });

  String get displayName => nombreVer;

  @override
  List<Object?> get props => [
        name,
        nombreVer,
        description,
        price,
        rimei,
        category,
        activo,
      ];
}
