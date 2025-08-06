import 'package:equatable/equatable.dart';

class VentaResponse extends Equatable {

  int venta;
  DateTime fecha;

  VentaResponse({
    required this.venta,
    required this.fecha
  });

  @override
  List<Object?> get props => [venta, fecha];


}