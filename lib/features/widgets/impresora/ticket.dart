import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import 'package:velcel/features/store/domain/entities/cart_entity.dart';
import 'package:velcel/features/store/domain/entities/ticket_entity.dart';


List<Map<String, dynamic>> generateItems(List<CartProductEntity> cl){
  // name | quantity | price
  List<Map<String, dynamic>> items = [];

  for (CartProductEntity cp in cl){
    Map<String, dynamic> item = {"name": cp.product.name, "quantity": cp.quantity, "price": cp.product.price,};

    items.add(item);
  }

  return items;
}


Future<Uint8List> generarPdfTicketVenta(TicketEntity ticketEntity) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final fontTitle = await PdfGoogleFonts.montserratAlternatesBlackItalic();
  final fontText = await PdfGoogleFonts.montserratAlternatesMediumItalic();

  // Convertir items
  final List<Map<String, dynamic>> items = generateItems(ticketEntity.cart);

  // Variables
  final double total = ticketEntity.total;
  final String sucursal = ticketEntity.sucursal;
  final String supplierName = ticketEntity.supplierName;
  final String folio = ticketEntity.ventaResponse.venta.toString();
  final DateTime fecha = ticketEntity.ventaResponse.fecha;

  pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Container(
              // width: context.pageWidth,
              // height: context.pageHeight,
                padding: pw.EdgeInsets.only(left: 20, right: 20),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: <pw.Widget>[
                      // if (profileBloc.businessPos.image != null)
                      //   pw.Image(imagen),

                      pw.SizedBox(height: 5),

                      // Titulo SportTortas
                      pw.Text(
                        "VELCEL",
                        style: pw.TextStyle(
                          font: fontTitle,
                          fontSize: 12.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),

                      pw.SizedBox(height: 5),

                      pw.Text(
                          "sucursal: ${sucursal}",
                          style: pw.TextStyle(
                              fontSize: 6.0,
                              font: fontText
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),
                      pw.Divider(),

                      pw.Text(
                          "- MERCANCIAS -",
                          style: pw.TextStyle(
                              fontSize: 7.0,
                              font: fontTitle
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),

                      if (ticketEntity.paguitos)...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                            "- Venta con paguitos -",
                            style: pw.TextStyle(
                                fontSize: 7.0,
                                font: fontTitle
                              // fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center
                        ),
                      ],

                      pw.SizedBox(height: 5),

                      pw.Text(
                          "Fecha: ${fecha.toString().substring(0,10)}",
                          style: pw.TextStyle(
                              fontSize: 6.0,
                              font: fontText
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),
                      pw.Text(
                          "Hora: ${fecha.toString().substring(11, 19)}",
                          style: pw.TextStyle(
                            font: fontText,
                            fontSize: 6.0,
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),
                      pw.Text(
                          "Folio: ${folio}",
                          style: pw.TextStyle(
                            font: fontText,
                            fontSize: 6.0,
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),

                      pw.Divider(),

                      pw.Table.fromTextArray(
                        context: context,
                        data: <List<String>>[
                          <String>["Producto", "Cant", "Precio", "Total"],
                          for (var item in items)
                            <String>[
                              item["name"],
                              item["quantity"].toString(),
                              "\$${item["price"].toStringAsFixed(2)}",
                              "\$${(item["price"] * item["quantity"]).toStringAsFixed(2)}",
                            ],
                        ],
                        cellAlignment: pw.Alignment.center,
                        headerAlignment: pw.Alignment.center,
                        headerStyle: pw.TextStyle(fontSize: 7, font: fontText,),
                        cellStyle: pw.TextStyle(fontSize: 6, font: fontText,),
                        border: pw.TableBorder(
                            right: pw.BorderSide.none
                        ),
                        headerPadding: pw.EdgeInsets.all(1),
                        cellPadding: pw.EdgeInsets.all(1),
                        columnWidths: {
                          0 : pw.FlexColumnWidth(4),
                          1 : pw.FlexColumnWidth(2),
                          2 : pw.FlexColumnWidth(2),
                          3 : pw.FlexColumnWidth(2),
                        }

                      ),

                      if (ticketEntity.paguitos)...[
                        pw.Divider(),
                        pw.Text(
                            "Importe: ${total}",
                            style: pw.TextStyle(
                                fontSize: 7.0,
                                font: fontTitle
                              // fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center
                        ),
                      ],

                      pw.Divider(),

                      pw.Text(
                          "Atendido por: ${supplierName}",

                          style: pw.TextStyle(
                            font: fontText,
                            fontSize: 8.0,
                            // fontFallback: [pw.Font.ttf(
                            //   File("assets/NotoColorEmoji-Regular.ttf").readAsBytesSync().buffer.asByteData(),
                            // ),]
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),

                      pw.SizedBox(height: 5),

                      pw.Text(
                          "Conserve este ticket para cualquier aclaración",

                          style: pw.TextStyle(
                            font: fontText,
                            fontSize: 8.0,
                            // fontFallback: [pw.Font.ttf(
                            //   File("assets/NotoColorEmoji-Regular.ttf").readAsBytesSync().buffer.asByteData(),
                            // ),]
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),

                      pw.SizedBox(height: 5),

                      pw.Text(
                          "¡Vuelve pronto!",

                          style: pw.TextStyle(
                            font: fontText,
                            fontSize: 8.0,
                            // fontFallback: [pw.Font.ttf(
                            //   File("assets/NotoColorEmoji-Regular.ttf").readAsBytesSync().buffer.asByteData(),
                            // ),]
                            // fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center
                      ),



                    ]
                )
            );
          }
      )
  );

  // Solicitar permisos de almacenamiento

  final status = await Permission.storage.request();

  String year = fecha.year.toString();
  String month = fecha.month.toString().padLeft(2, '0'); // Asegura que siempre tenga dos dígitos
  String day = fecha.day.toString().padLeft(2, '0');
  String hour = fecha.hour.toString().padLeft(2, '0');
  String minute = fecha.minute.toString().padLeft(2, '0');
  String second = fecha.second.toString().padLeft(2, '0');

  String newFecha = '$year-$month-$day-$hour-$minute-$second';

  if (status.isGranted) {
    // Obtener el directorio de almacenamiento externo
    final output = await getDownloadsDirectory();
    final file = File('${output!.path}\$folio-${newFecha}.pdf');

    // Guardar el archivo PDF
    await file.writeAsBytes(await pdf.save());

    // print("${file}");

  } else {
    try {

      // Obtener el directorio de almacenamiento externo
      final output = await getDownloadsDirectory();
      final file = File('${output!.path}/$folio-${newFecha}.pdf');

      // Guardar el archivo PDF
      await file.writeAsBytes(await pdf.save());

      // print("${file}");

    } catch (e){
      print(e);
    }
  }


  return pdf.save();
}
