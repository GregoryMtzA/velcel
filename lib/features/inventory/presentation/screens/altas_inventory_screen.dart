import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:velcel/features/widgets/date_picker/multi_date_picker.dart';

import '../../domain/entities/product_altas_inventory_entity.dart';

class AltasInventoryScreen extends StatefulWidget {
  const AltasInventoryScreen({super.key});

  @override
  State<AltasInventoryScreen> createState() => _AltasInventoryScreenState();
}

class _AltasInventoryScreenState extends State<AltasInventoryScreen> {
  List<ProductAltasInventoryEntity> products = [];
  DateTime initDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Seleccionar Fecha:",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                width: 20,
              ),
              MultiDatePicker(
                onChange: (date) async {
                  InventoryProvider inventoryProvider = context.read();
                  BranchProvider branchProvider = context.read();
                  String branch = branchProvider.branch!.nombre;

                  initDate = date[0];
                  endDate = date[1];

                  dartz.Either<String, List<ProductAltasInventoryEntity>>
                      response = await inventoryProvider
                          .getProductsAltasWithDate(initDate, endDate, branch);

                  response.fold(
                    (l) {
                      SnackbarService.showIncorrect(context, "Productos", l);
                    },
                    (r) {
                      products = r;
                      setState(() {});
                    },
                  );
                },
                dates: [initDate, endDate],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(child: Text("Sucursal")),
                  Expanded(child: Text("Nombre")),
                  Expanded(child: Text("Cantidad")),
                  Expanded(child: Text("Imeis")),
                  Expanded(child: Text("Fecha")),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Material(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    ProductAltasInventoryEntity product = products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Expanded(child: Text(product.sucursal)),
                            Expanded(
                                child: Text(
                              product.nombre,
                              style: textStyle(context),
                            )),
                            Expanded(
                                child: Text(product.cantidad.toString(),
                                    style: textStyle(context))),
                            Expanded(
                              child: Text(
                                _imeisPreview(product.imeis),
                                style: textStyle(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                                child: Text(product.fecha.toString(),
                                    style: textStyle(context))),
                          ],
                        ),
                        onTap: () async {
                          _showProductInfoDialog(context, product);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }

  TextStyle textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  String _imeisPreview(List<String>? imeis) {
    if (imeis == null || imeis.isEmpty) return "Sin IMEIs";

    const int maxVisibleImeis = 2;
    final List<String> visibleImeis = imeis.take(maxVisibleImeis).toList();
    final int hiddenImeis = imeis.length - visibleImeis.length;

    if (hiddenImeis <= 0) return visibleImeis.join(", ");

    return "${visibleImeis.join(", ")} y $hiddenImeis mas";
  }

  void _showProductInfoDialog(
      BuildContext context, ProductAltasInventoryEntity product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text(
            "Informacion de alta",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
              maxHeight: 420,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: "Sucursal", value: product.sucursal),
                  _InfoRow(label: "Nombre", value: product.nombre),
                  _InfoRow(
                      label: "Cantidad", value: product.cantidad.toString()),
                  _InfoRow(label: "Fecha", value: product.fecha.toString()),
                  _ImeisInfo(imeis: product.imeis),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ImeisInfo extends StatelessWidget {
  final List<String>? imeis;

  const _ImeisInfo({
    required this.imeis,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> productImeis = imeis ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "IMEIs",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          if (productImeis.isEmpty)
            SelectableText(
              "Sin IMEIs",
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...productImeis.map(
              (imei) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SelectableText(
                  imei,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
