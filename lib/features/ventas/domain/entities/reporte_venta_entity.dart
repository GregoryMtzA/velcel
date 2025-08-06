import 'package:equatable/equatable.dart';
import 'package:velcel/features/ventas/data/models/clientes_venta_model.dart';
import 'package:velcel/features/ventas/data/models/productos_venta_model.dart';
import 'package:velcel/features/ventas/domain/entities/clientes_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/imeis_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/productos_venta_entity.dart';

class ReporteVentaEntity extends Equatable {

  List<ProductosVentaEntity> productos;
  List<ClientesVentaEntity>? clienteCredito;
  List<ImeisVentaEntity> imeisVentaEntity;

  ReporteVentaEntity({
    required this.productos,
    this.clienteCredito,
    required this.imeisVentaEntity,
  });

  @override
  List<Object?> get props => [productos, clienteCredito, imeisVentaEntity];

}