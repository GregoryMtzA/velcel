import 'package:equatable/equatable.dart';

class CashRegisterClosureTicket extends Equatable {
  const CashRegisterClosureTicket({
    required this.folio,
    required this.sucursal,
    required this.usuario,
    required this.fechaCierre,
    required this.fondo,
    required this.efectivo,
    required this.tarjeta,
    required this.gastos,
    required this.totalBruto,
    required this.totalNeto,
    required this.cantidadContada,
    required this.diferencia,
    this.fechaApertura,
  });

  final int folio;
  final String sucursal;
  final String usuario;
  final DateTime? fechaApertura;
  final DateTime fechaCierre;
  final double fondo;
  final double efectivo;
  final double tarjeta;
  final double gastos;
  final double totalBruto;
  final double totalNeto;
  final double cantidadContada;
  final double diferencia;

  @override
  List<Object?> get props => [
        folio,
        sucursal,
        usuario,
        fechaApertura,
        fechaCierre,
        fondo,
        efectivo,
        tarjeta,
        gastos,
        totalBruto,
        totalNeto,
        cantidadContada,
        diferencia,
      ];
}
