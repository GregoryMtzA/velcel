import 'package:equatable/equatable.dart';

class CashRegisterDataResponse extends Equatable {

  double fondo;
  double totalesEfectivo;
  double totalesTarjeta;
  double totalesGastos;
  double? totalBruto;
  double? totalNeto;

  CashRegisterDataResponse({
    required this.fondo,
    required this.totalesEfectivo,
    required this.totalesTarjeta,
    required this.totalesGastos,
    this.totalBruto,
    this.totalNeto,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [fondo, totalesEfectivo, totalesTarjeta, totalesGastos, totalBruto, totalNeto];

}