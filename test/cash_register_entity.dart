import 'package:equatable/equatable.dart';

class CashRegisterEntity extends Equatable {

  int identificador;
  String? sucursal;
  String? usuario;
  DateTime? fechaApertura;
  DateTime? fechaCierre;
  double? cantidadEfectivo;
  double? cantidadTarjeta;
  double? fondo;
  double? gastos;
  double? total;
  double? totalConteo;
  double? diferencia;
  String? estado;

  CashRegisterEntity({
    required this.identificador,
    this.sucursal,
    this.usuario,
    this.fechaApertura,
    this.fechaCierre,
    this.cantidadEfectivo,
    this.cantidadTarjeta,
    this.fondo,
    this.gastos,
    this.total,
    this.totalConteo,
    this.diferencia,
    this.estado,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [identificador, sucursal, usuario, fechaApertura, fechaCierre,
                              cantidadEfectivo, cantidadTarjeta, fondo, gastos, total,
                              totalConteo, diferencia, estado];

}