import 'package:equatable/equatable.dart';

class ProductInventoryEntity extends Equatable {

  String categoria;
  String nombre;
  int disponibles;
  String descripcion;

  ProductInventoryEntity({
    required this.categoria,
    required this.nombre,
    required this.disponibles,
    required this.descripcion
  });

  @override
  List<Object?> get props => [categoria, nombre, disponibles, descripcion];

}