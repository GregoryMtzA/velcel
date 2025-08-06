import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/services/domain/entities/service_entity.dart';
import 'package:velcel/features/services/domain/requests/service_request.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/services_repository.dart';

class ServicesProvider extends ChangeNotifier {

  ServicesRepository servicesRepository;

  ServicesProvider({
    required this.servicesRepository,
  });

  Future<Either<String, ServiceEntity>> createService(sucursal, empleado, nombreCliente, numeroContacto, marca, modelo, serie, descripcionCorta, imei, fechaEntrega, fallaReportada, observLleg) async {

    ServiceRequest serviceRequest = ServiceRequest(
      cliente: nombreCliente,
      telefono: numeroContacto,
      marca: marca,
      modelo: modelo,
      serie: serie,
      imei: imei,
      descCorta: descripcionCorta,
      fechaSal: fechaEntrega,
      fallaRep: fallaReportada,
      observLleg: observLleg,
      sucursal: sucursal,
      usuarioAbre: empleado,
    );

    Either<Failure, ServiceEntity> usecase = await servicesRepository.createService(serviceRequest);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );


  }

  Future<Either<String, List<ServiceEntity>>> getServicesWithState(String estado, String sucursal) async {

    Either<Failure, List<ServiceEntity>> usecase = await servicesRepository.getServicesWithState(estado, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );

  }

  Future<Either<String, void>> updateService(String observSal, String estado, int folio, String usuario) async {

    Either<Failure, void> usecase = await servicesRepository.updateService(observSal, estado, folio, usuario);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(null),
    );

  }

  Future<Either<String, ServiceEntity>> getServiceWithFolio(int folio, String sucursal) async {

    Either<Failure, ServiceEntity> usecase = await servicesRepository.getServiceWithFolio(folio, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );

  }

}