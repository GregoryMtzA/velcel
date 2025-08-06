import 'package:equatable/equatable.dart';

class ProductAltasInventoryEntity extends Equatable {

  String sucursal;
  String nombre;
  int cantidad;
  DateTime fecha;
  String? motivo;

  ProductAltasInventoryEntity({
    required this.sucursal,
    required this.nombre,
    required this.cantidad,
    required this.fecha,
    this.motivo
  });

  @override
  List<Object?> get props => [sucursal, nombre, cantidad, fecha, motivo];

}