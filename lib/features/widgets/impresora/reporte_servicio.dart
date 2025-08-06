import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import 'package:velcel/features/store/domain/entities/cart_entity.dart';
import 'package:velcel/features/store/domain/entities/ticket_entity.dart';

import '../../services/domain/entities/reporte_servicio_entity.dart';

Future<Uint8List> generarReporteServicio(ReporteServicioEntity reporteServicioEntity) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final fontTitle = await PdfGoogleFonts.montserratAlternatesBlack();
  final fontSemibold = await PdfGoogleFonts.montserratSemiBold();
  final fontText = await PdfGoogleFonts.montserratRegular();

  // Variables
  String year = reporteServicioEntity.fecha.year.toString();
  String month = reporteServicioEntity.fecha.month.toString().padLeft(2, '0'); // Asegura que siempre tenga dos dígitos
  String day = reporteServicioEntity.fecha.day.toString().padLeft(2, '0');
  String hour = reporteServicioEntity.fecha.hour.toString().padLeft(2, '0');
  String minute = reporteServicioEntity.fecha.minute.toString().padLeft(2, '0');
  String second = reporteServicioEntity.fecha.second.toString().padLeft(2, '0');
  String fechaReporte = '$year-$month-$day';

  // FECHA ESTIMADA
  String yearEstimado = reporteServicioEntity.fechaEstimada.year.toString();
  String monthEstimado = reporteServicioEntity.fechaEstimada.month.toString().padLeft(2, '0'); // Asegura que siempre tenga dos dígitos
  String dayEstimado = reporteServicioEntity.fechaEstimada.day.toString().padLeft(2, '0');
  String fechaEstimada = '$yearEstimado-$monthEstimado-$dayEstimado';

  pw.MemoryImage logo = pw.MemoryImage( (await rootBundle.load("assets/logos/velcel.png")).buffer.asUint8List() );
  pw.TextStyle style = pw.TextStyle(font: fontText, fontSize: 11);

  pdf.addPage(
      pw.MultiPage(
          footer: (pw.Context context) {
            return pw.Container(
                // margin: const pw.EdgeInsets.only(right: 50, top: 20, left: 50),
                // padding: const pw.EdgeInsets.only(bottom: 10.0 * PdfPageFormat.mm),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    "Atención: Conserve este comprobante para cualquier aclaración y para recoger el equipo",
                    textAlign: pw.TextAlign.center,
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 9)
                )
            );
          },

          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [

              pw.Center(child: pw.Image(logo, alignment: pw.Alignment.center, height: 100, width: 100)),
              pw.Center(child: pw.Paragraph(text: "Recibo para servicio", textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontTitle)),),

              pw.SizedBox(height: 20),

              pw.Paragraph(text: "Folio: ${reporteServicioEntity.folio.toString()}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "Fecha: ${fechaReporte}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "Sucursal: ${reporteServicioEntity.sucursal}", textAlign: pw.TextAlign.start, style: style),

              pw.SizedBox(height: 20),

              pw.Paragraph(
                text: "Yo ${reporteServicioEntity.cliente} entregué a Velcel sucursal ${reporteServicioEntity.sucursal} un equipo para su revisión y posible reparación, el equipo cuenta con las siguientes caracteristicas:",
                textAlign: pw.TextAlign.start,
                style: style
              ),
              pw.Paragraph(text: "Marca: ${reporteServicioEntity.marca.toString()}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "Modelo: ${reporteServicioEntity.modelo}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "Serie: ${reporteServicioEntity.serie}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "IMEI: ${reporteServicioEntity.imei}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "Otros datos: ${reporteServicioEntity.descripcionCorta}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "Falla reportada por el cliente: ${reporteServicioEntity.fallaReportada}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "El tecnico realizó las siguientes observaciones: ${reporteServicioEntity.observacionLlega}", textAlign: pw.TextAlign.start, style: style),

              pw.SizedBox(height: 20),
              pw.Paragraph(text: "Fecha estimada de finalización: ${DateFormat("yyyy-MM-dd").format(reporteServicioEntity.fechaEstimada)}", textAlign: pw.TextAlign.start, style: style),
              pw.Paragraph(text: "${reporteServicioEntity.cliente}: ", textAlign: pw.TextAlign.start, style: style),
              pw.SizedBox(height: 5),
              pw.Container(color: PdfColor.fromInt(0xFF000000), width: 200, height: 1),
              pw.SizedBox(height: 10),
              pw.Paragraph(text: "Técnico: ", textAlign: pw.TextAlign.start, style: style),
              pw.SizedBox(height: 5),
              pw.Container(color: PdfColor.fromInt(0xFF000000), width: 200, height: 1),
            ];
          },
      )
  );


  // Solicitar permisos de almacenamiento
  final status = await Permission.storage.request();

  String newFecha = '$year-$month-$day-$hour-$minute-$second';

  if (status.isGranted) {

    try {

      // Obtener el directorio de almacenamiento externo
      final output = await getDownloadsDirectory();
      final file = File('${output!.path}/Servicio-${reporteServicioEntity.folio}-${newFecha}.pdf');

      // Guardar el archivo PDF
      await file.writeAsBytes(await pdf.save());

    } catch (e) {

    }

  }
  else {

    try {

      // Obtener el directorio de almacenamiento externo
      final output = await getDownloadsDirectory();
      final file = File('${output!.path}/Servicio-${reporteServicioEntity.folio}-${newFecha}.pdf');

      // Guardar el archivo PDF
      await file.writeAsBytes(await pdf.save());

    } catch (e){

      print(e);

    }

  }


  return pdf.save();
}
