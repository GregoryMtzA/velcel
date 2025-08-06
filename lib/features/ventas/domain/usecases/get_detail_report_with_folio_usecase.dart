import 'package:dartz/dartz.dart';
import 'package:velcel/features/ventas/domain/repositories/ventas_repository.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reporte_venta_entity.dart';

class GetDetailReportWithFolioUsecase {

  VentasRepository ventaRepository;

  GetDetailReportWithFolioUsecase({
    required this.ventaRepository
  });

  Future<Either<Failure, ReporteVentaEntity>> call(int folio, String credito) async {

    final productosResponse = await ventaRepository.getProductos(folio);

    return productosResponse.fold(
      (l) => Left(l),
      (productos) async {
        final imeisResponse = await ventaRepository.getIMEIS(folio);

        return imeisResponse.fold(
          (l) => Left(l),
          (imeis) async {

            if (credito == "No") {
              return Right(
                ReporteVentaEntity(
                  productos: productos,
                  imeisVentaEntity: imeis
                )
              );
            }

            final clientesResponse = await ventaRepository.getClientes(folio);

            return clientesResponse.fold(
              (l) => Left(l),
              (clientes) {
                return Right(
                  ReporteVentaEntity(
                    productos: productos,
                    imeisVentaEntity: imeis,
                    clienteCredito: clientes
                  )
                );
              },
            );

          },
        );
      },
    );

  }

}