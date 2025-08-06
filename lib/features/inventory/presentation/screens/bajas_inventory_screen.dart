import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/inventory/domain/entities/product_inventory_entity.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:velcel/features/widgets/date_picker/multi_date_picker.dart';

import '../../domain/entities/product_altas_inventory_entity.dart';

class BajasInventoryScreen extends StatefulWidget {

  const BajasInventoryScreen({super.key});

  @override
  State<BajasInventoryScreen> createState() => _AltasInventoryScreenState();
}

class _AltasInventoryScreenState extends State<BajasInventoryScreen> {

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
            Text("Seleccionar Fecha:", style: Theme.of(context).textTheme.bodyLarge,),

            const SizedBox(width: 20,),

            MultiDatePicker(
              onChange: (date) async {

                InventoryProvider inventoryProvider = context.read();
                BranchProvider branchProvider = context.read();
                String branch = branchProvider.branch!.nombre;

                initDate = date[0];
                endDate = date[1];

                dartz.Either<String, List<ProductAltasInventoryEntity>> response = await inventoryProvider.getProductsBajasWithDate(initDate, endDate, branch);

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
                  Expanded(child: Text("Motivo")),
                  Expanded(child: Text("Fecha")),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Material(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    ProductAltasInventoryEntity product = products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(product.sucursal)),
                            Expanded(child: Text(product.nombre, style: textStyle(context),)),
                            Expanded(child: Text(product.cantidad.toString(), style: textStyle(context))),
                            Expanded(child: Text(product.motivo!, style: textStyle(context))),
                            Expanded(child: Text(product.fecha.toString(), style: textStyle(context))),
                          ],
                        ),
                        onTap: () async {
                          // await NavigationService.navigate(context, ViewServiceScreen(service: service,));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        )
    );
  }

  TextStyle textStyle(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium!;
  }

}
