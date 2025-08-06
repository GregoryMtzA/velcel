import 'package:equatable/equatable.dart';
import 'package:velcel/features/store/domain/entities/cart_entity.dart';
import 'package:velcel/features/store/domain/response/venta_response.dart';

class TicketEntity extends Equatable {

  String sucursal;
  String supplierName;
  double total;
  VentaResponse ventaResponse;
  List<CartProductEntity> cart;
  bool paguitos;

  TicketEntity({
    required this.sucursal,
    required this.total,
    required this.ventaResponse,
    required this.cart,
    required this.supplierName,
    this.paguitos = false,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [sucursal, ventaResponse, cart, total, supplierName, paguitos];

}