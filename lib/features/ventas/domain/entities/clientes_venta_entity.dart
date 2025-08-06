import 'package:equatable/equatable.dart';

class ClientesVentaEntity extends Equatable {
  final String nombre;
  final String domicilio;
  final String telefono;

  ClientesVentaEntity({
    required this.nombre,
    required this.domicilio,
    required this.telefono,
  });

  @override
  List<Object?> get props => [nombre, domicilio, telefono];

}
