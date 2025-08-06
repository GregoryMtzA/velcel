import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {

  String id;
  String? nombre;
  String? telefono;
  String? sucursal;
  String? usuario;
  String? clave;
  String? tipo;

  UserEntity({
    required this.id,
    this.nombre,
    this.telefono,
    this.sucursal,
    this.usuario,
    this.clave,
    this.tipo,
  });

  @override
  String toString() {
    return usuario ?? "";
  }

  @override
  List<Object?> get props => [id, nombre, telefono, sucursal, usuario, clave, tipo];

}