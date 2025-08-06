import 'package:equatable/equatable.dart';

class VentaRequest extends Equatable {

  double total;
  String metodo;
  String sucursal;
  String usuario;
  int idCorte;
  String credito;
  List<String> nombres;
  List<int> cantidades;
  List<String>? imeis;
  String? nombreC;
  String? telefonoC;
  String? domicilioC;

  VentaRequest({
    required this.total,
    required this.metodo,
    required this.sucursal,
    required this.usuario,
    required this.idCorte,
    required this.credito,
    required this.nombres,
    required this.cantidades,
    this.imeis,
    this.nombreC,
    this.telefonoC,
    this.domicilioC
  });

  @override
  List<Object?> get props => [total, metodo, sucursal, usuario, idCorte, credito, nombres, cantidades,
                              imeis, nombreC, telefonoC, domicilioC];

}