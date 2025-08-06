import 'package:dartz/dartz.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/domain/requests/venta_request.dart';

import '../../../../core/errors/failures.dart';
import '../response/venta_response.dart';

abstract class ProductsRepository {

  Future<Either<Failure, List<ProductEntity>>> searchProducts(String name, String branchType);
  Future<Either<Failure, int>> checkStock(String name, String sucursal);
  Future<Either<Failure, bool>> verifyImei(String producto, String imei);
  Future<Either<Failure, VentaResponse>> generarVenta(VentaRequest ventaRequest);

}