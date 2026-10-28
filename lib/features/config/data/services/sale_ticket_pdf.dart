import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../store/domain/entities/ticket_entity.dart';

Future<Uint8List> generarPdfTicketVentaDepuracion(
  TicketEntity ticket,
) async {
  final pdf = pw.Document();
  final fecha = ticket.ventaResponse.fecha;
  final font = pw.Font.courier();
  final boldFont = pw.Font.courierBold();
  final textStyle = pw.TextStyle(font: font, fontSize: 8);
  final boldStyle = pw.TextStyle(font: boldFont, fontSize: 8);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll57,
      margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            'VELCEL',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.Text(
            'sucursal: ${ticket.sucursal}',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '-mercancias-',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
          if (ticket.paguitos)
            pw.Text(
              '-Venta con paguitos-',
              textAlign: pw.TextAlign.center,
              style: boldStyle,
            ),
          pw.Text(
            'fecha: ${DateFormat('yyyy-MM-dd').format(fecha)}',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.Text(
            'Hora: ${DateFormat('hh:mm').format(fecha)}',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.Text(
            'Folio: ${ticket.ventaResponse.venta}',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.SizedBox(height: 8),
          for (final product in ticket.cart) ...[
            pw.Text(
              product.product.displayName,
              style: textStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    product.quantity.toString(),
                    style: textStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Text(
                    '\$${product.product.price.toStringAsFixed(2)}',
                    style: textStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Text(
                    '\$${(product.quantity * product.product.price).toStringAsFixed(2)}',
                    style: textStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
          if (ticket.paguitos) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Importe: \$${ticket.total.toStringAsFixed(2)}',
              textAlign: pw.TextAlign.center,
              style: textStyle,
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            'Atendido por: ${ticket.supplierName}',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Conserve este ticket para',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.Text(
            'cualquier aclaración',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '¡Vuelve pronto!',
            textAlign: pw.TextAlign.center,
            style: textStyle,
          ),
          pw.SizedBox(height: 32),
        ],
      ),
    ),
  );

  return pdf.save();
}
