import 'package:equatable/equatable.dart';

class ProductAltasInventoryEntity extends Equatable {
  final String sucursal;
  final String nombre;
  final int cantidad;
  final DateTime fecha;
  final String? motivo;
  final List<String>? imeis;

  ProductAltasInventoryEntity(
      {required this.sucursal,
      required this.nombre,
      required this.cantidad,
      required this.fecha,
      this.motivo,
      this.imeis});

  @override
  List<Object?> get props => [sucursal, nombre, cantidad, fecha, motivo, imeis];
}
