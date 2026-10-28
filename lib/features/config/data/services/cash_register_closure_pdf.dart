import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../store/domain/entities/cash_register_closure_ticket.dart';

Future<Uint8List> generarPdfCorteCaja(
  CashRegisterClosureTicket ticket,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll57,
      margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      build: (context) {
        final font = pw.Font.courier();
        final boldFont = pw.Font.courierBold();
        final textStyle = pw.TextStyle(font: font, fontSize: 8);
        final boldStyle = pw.TextStyle(font: boldFont, fontSize: 8);
        final currencySymbolStyle = pw.TextStyle(font: boldFont, fontSize: 9);

        pw.Widget amountRow(String label, double amount) {
          return pw.Row(
            children: [
              pw.Expanded(flex: 8, child: pw.Text(label, style: textStyle)),
              pw.Expanded(
                flex: 4,
                child: pw.RichText(
                  textAlign: pw.TextAlign.right,
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '\$',
                        style: currencySymbolStyle,
                      ),
                      pw.TextSpan(
                        text: amount.toStringAsFixed(2),
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              'VELCEL',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: boldFont, fontSize: 18),
            ),
            pw.Text(
              'CORTE DE CAJA',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: boldFont, fontSize: 12),
            ),
            pw.Text(
              ticket.sucursal,
              textAlign: pw.TextAlign.center,
              style: textStyle,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Folio: ${ticket.folio}',
              textAlign: pw.TextAlign.center,
              style: boldStyle,
            ),
            pw.Text(
              'Usuario: ${ticket.usuario}',
              textAlign: pw.TextAlign.center,
              style: textStyle,
            ),
            pw.Text(
              'Apertura: ${_formatDateTime(ticket.fechaApertura)}',
              textAlign: pw.TextAlign.center,
              style: textStyle,
            ),
            pw.Text(
              'Cierre: ${DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaCierre)}',
              textAlign: pw.TextAlign.center,
              style: textStyle,
            ),
            pw.Divider(height: 8),
            amountRow('Efectivo', ticket.efectivo),
            amountRow('Tarjeta', ticket.tarjeta),
            amountRow('Fondo inicial', ticket.fondo),
            amountRow('Total bruto', ticket.totalBruto),
            amountRow('Gastos', ticket.gastos),
            amountRow('Total neto', ticket.totalNeto),
            pw.Divider(height: 8),
            amountRow('Cantidad contada', ticket.cantidadContada),
            amountRow('Diferencia', ticket.diferencia),
            pw.Text(
              'ESTADO: CERRADO',
              textAlign: pw.TextAlign.center,
              style: boldStyle,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Conserve este comprobante',
              textAlign: pw.TextAlign.center,
              style: textStyle,
            ),
            pw.SizedBox(height: 32),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '--';
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
