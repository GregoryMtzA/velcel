import 'package:equatable/equatable.dart';

class BranchEntity extends Equatable {

  String nombre;
  String? telefono;
  String? ciudad;
  String? calle;
  int? numeroDomicilio;
  String? tipo;

  BranchEntity({
    required this.nombre,
    this.telefono,
    this.ciudad,
    this.calle,
    this.numeroDomicilio,
    this.tipo,
  });

  @override
  List<Object?> get props => [nombre, telefono, ciudad, calle, numeroDomicilio, tipo];

}