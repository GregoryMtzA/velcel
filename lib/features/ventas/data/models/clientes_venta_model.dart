import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:velcel/features/ventas/domain/entities/clientes_venta_entity.dart';

class ClientesVentaModel extends ClientesVentaEntity {
  final String nombre;
  final String domicilio;
  final String telefono;

  ClientesVentaModel({
    required this.nombre,
    required this.domicilio,
    required this.telefono,
  }) : super(
    nombre: nombre,
    domicilio: domicilio,
    telefono: telefono
  );

  factory ClientesVentaModel.fromRawJson(String str) => ClientesVentaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClientesVentaModel.fromJson(Map<String, dynamic> json) => ClientesVentaModel(
    nombre: json["nombre"],
    domicilio: json["domicilio"],
    telefono: json["telefono"],
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "domicilio": domicilio,
    "telefono": telefono,
  };
}
