import 'package:dartz/dartz.dart';
import 'package:velcel/features/config/domain/entities.dart';

import '../../../store/domain/entities/ticket_entity.dart';

abstract class PrinterRepositoryInterface {

  Future<Either<String, BluetoothInfoEquatable?>> getPrinterSaved();

  Future<Either<String, Unit>> savePrinter(String macAddress);
  Future<Either<String, Unit>> printPdf(TicketEntity ticketEntity);


}