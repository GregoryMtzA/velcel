import 'package:equatable/equatable.dart';

class ServiceRequest extends Equatable {

  final String cliente;
  final String telefono;
  final String marca;
  final String modelo;
  final String serie;
  final String imei;
  final String descCorta;
  final DateTime fechaSal;
  final String fallaRep;
  final String observLleg;
  final String sucursal;
  final String usuarioAbre;
  final String? usuarioCierra;
  final String? observSal;
  final String? estado;

  ServiceRequest({
    required this.cliente,
    required this.telefono,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.imei,
    required this.descCorta,
    required this.fechaSal,
    required this.fallaRep,
    required this.observLleg,
    required this.sucursal,
    required this.usuarioAbre,
    this.usuarioCierra,
    this.observSal,
    this.estado,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [cliente, telefono, marca, modelo, serie, imei, estado, descCorta, fechaSal, fallaRep, observLleg, observSal, sucursal, usuarioAbre, usuarioCierra];

}