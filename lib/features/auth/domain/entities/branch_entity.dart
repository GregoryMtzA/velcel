import 'package:equatable/equatable.dart';

class BranchEntity extends Equatable {
  final String nombre;
  final String nombreVer;
  final bool activa;
  final String? telefono;
  final String? ciudad;
  final String? calle;
  final int? numeroDomicilio;
  final String? tipo;

  BranchEntity({
    required this.nombre,
    required this.nombreVer,
    required this.activa,
    this.telefono,
    this.ciudad,
    this.calle,
    this.numeroDomicilio,
    this.tipo,
  });

  String get displayName => nombreVer;

  @override
  List<Object?> get props => [
        nombre,
        nombreVer,
        activa,
        telefono,
        ciudad,
        calle,
        numeroDomicilio,
        tipo,
      ];
}
