import 'package:dartz/dartz.dart';
import 'package:velcel/features/services/domain/entities/service_entity.dart';
import 'package:velcel/features/services/domain/requests/service_request.dart';

import '../../../../core/errors/failures.dart';

abstract class ServicesRepository {

  Future<Either<Failure, ServiceEntity>> createService(ServiceRequest serviceRequest);
  Future<Either<Failure, List<ServiceEntity>>> getServicesWithState(String estado, String sucursal);
  Future<Either<Failure, ServiceEntity>> getServiceWithFolio(int folio, String sucursal);
  Future<Either<Failure, void>> updateService(String observSal, String estado, int folio, String usuario);

}