import 'dart:convert';

import 'package:velcel/features/services/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity{

  final int folio;
  final String cliente;
  final String telefono;
  final String marca;
  final String modelo;
  final String serie;
  final String imei;
  final String desccorta;
  final DateTime fecharec;
  final DateTime fechasal;
  final String fallarep;
  final String observlleg;
  final String sucursal;
  final String usuarioabre;
  final String estado;
  final String? usuarioCierra;
  final String? observSal;

  ServiceModel({
    required this.folio,
    required this.cliente,
    required this.telefono,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.imei,
    required this.desccorta,
    required this.fecharec,
    required this.fechasal,
    required this.fallarep,
    required this.observlleg,
    required this.sucursal,
    required this.usuarioabre,
    required this.estado,
    this.usuarioCierra,
    this.observSal,
  }) : super(
    folio: folio,
    cliente: cliente,
    telefono: telefono,
    marca: marca,
    modelo: modelo,
    serie: serie,
    imei: imei,
    descCorta: desccorta,
    fechaRec: fecharec,
    fechaSal: fechasal,
    fallaRep: fallarep,
    observLleg: observlleg,
    estado: estado,
    sucursal: sucursal,
    usuarioAbre: usuarioabre,
    observSal: observSal,
    usuarioCierra: usuarioCierra
  );

  factory ServiceModel.fromRawJson(String str) => ServiceModel.fromJson(json.decode(str));

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    folio: json["folio"],
    cliente: json["cliente"],
    telefono: json["telefono"],
    marca: json["marca"],
    modelo: json["modelo"],
    serie: json["serie"],
    imei: json["imei"],
    desccorta: json["desccorta"],
    fecharec: json["fecharec"],
    fechasal: json["fechasal"],
    fallarep: json["fallarep"],
    observlleg: json["observlleg"].toString(),
    sucursal: json["sucursal"],
    usuarioabre: json["usuarioabre"],
    estado: json["estado"],
    usuarioCierra: json["usuariocierra"],
    observSal: json["observsal"] != null ? json["observsal"].toString() : null,
  );
}
