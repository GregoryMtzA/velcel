import 'package:equatable/equatable.dart';

class ProductosVentaEntity extends Equatable {
  final String nombre;
  final int cantidad;

  ProductosVentaEntity({
    required this.nombre,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [nombre, cantidad];

}
