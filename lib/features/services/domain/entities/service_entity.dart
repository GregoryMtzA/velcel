import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {

  final int folio;
  final String cliente;
  final String telefono;
  final String marca;
  final String modelo;
  final String serie;
  final String imei;
  final String descCorta;
  final DateTime fechaRec;
  final DateTime fechaSal;
  final String fallaRep;
  final String observLleg;
  final String sucursal;
  final String usuarioAbre;
  final String estado;
  String? observSal;
  String? usuarioCierra;

  ServiceEntity({
    required this.folio,
    required this.cliente,
    required this.telefono,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.imei,
    required this.descCorta,
    required this.fechaRec,
    required this.fechaSal,
    required this.fallaRep,
    required this.observLleg,
    this.observSal,
    required this.sucursal,
    required this.usuarioAbre,
    this.usuarioCierra,
    required this.estado,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [folio, cliente, telefono, marca, modelo, serie, imei, descCorta, fechaRec, fechaSal, fallaRep, observLleg, observSal, sucursal, usuarioAbre, usuarioCierra, estado];

}