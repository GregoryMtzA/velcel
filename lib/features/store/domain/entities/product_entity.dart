import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mysql1/mysql1.dart';

class ProductEntity extends Equatable {
  String name;
  String description;
  double price;
  Uint8List image;
  String category;
  bool rimei;

  ProductEntity({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.rimei,
    required this.category,
  });

  @override
  List<Object?> get props => [name, description, price, image, rimei]; // Actualización de props
}
