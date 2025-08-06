import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/ventas/domain/entities/corte_entity.dart';
import 'package:velcel/features/ventas/domain/entities/reporte_venta_entity.dart';
import 'package:velcel/features/ventas/domain/entities/semi_reporte_venta_entity.dart';

import '../../domain/repositories/ventas_repository.dart';
import '../../domain/usecases/get_detail_report_with_folio_usecase.dart';

class VentasProvider extends ChangeNotifier {

  VentasRepository ventasRepository;
  GetDetailReportWithFolioUsecase getDetailReportWithFolioUsecase;

  VentasProvider({
    required this.ventasRepository,
    required this.getDetailReportWithFolioUsecase,
  });

  Future<Either<String, List<SemiReporteVentaEntity>>> getSemiReportsWithFolio(String sucursal, int folio) async {

    final usecase = await ventasRepository.getReportesWithFolio(sucursal, folio);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );

  }

  Future<Either<String, List<SemiReporteVentaEntity>>> getSemiReportsWithDate(String sucursal, DateTime fechaA, DateTime fechaB) async {

    final usecase = await ventasRepository.getReportesWithDate(sucursal, fechaA, fechaB);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );

  }

  Future<Either<String, List<CorteEntity>>> getCortesWithDate(DateTime initDate, DateTime endDate, String branch) async {

    final usecase = await ventasRepository.getCortesWithFecha(branch, initDate, endDate);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (r) => Right(r),
    );

  }

  Future<Either<String, ReporteVentaEntity>> getDetailReportWithFolio(int folio, String credito) async {
    final usecase = await getDetailReportWithFolioUsecase(folio, credito);

    return usecase.fold(
      (l) => Left((l as ServerFailure).message),
      (r) => Right(r),
    );

  }

}