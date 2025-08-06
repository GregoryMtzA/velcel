import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';

import '../../../../core/app/snackbars.dart';
import '../../../../core/app/theme.dart';
import '../../../widgets/dropdowns/custom_dropdown.dart';
import '../../../widgets/input_app.dart';
import '../../domain/entities/category_inventory_entity.dart';
import '../../domain/entities/product_inventory_entity.dart';

class ViewInventoryScreen extends StatefulWidget {
  const ViewInventoryScreen({super.key});

  @override
  State<ViewInventoryScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<ViewInventoryScreen> {

  late Future<dartz.Either<String, List<ProductInventoryEntity>>> _future;
  late Future<dartz.Either<String, List<CategoryInventoryEntity>>> _futureCategory;
  late TextEditingController nameController = TextEditingController();
  late String sucursal;

  @override
  void initState() {

    InventoryProvider inventoryProvider = context.read();
    BranchProvider branchProvider = context.read();
    sucursal = branchProvider.branch!.nombre;

    inventoryProvider.selectedCategory = null;

    _future = inventoryProvider.getProducts(sucursal);
    _futureCategory = inventoryProvider.getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    InventoryProvider inventoryProvider = context.watch();

    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: InputApp(
                  hintText: "Folio",
                  fillColor: IsselColors.grisClaro,
                  controller: nameController,
                  onFieldSubmitted: (value) async {

                    if (value.isEmpty) {
                      SnackbarService.showIncorrect(context, "Nombre", "Ingresa un nombre");
                      return ;
                    }

                    inventoryProvider.selectedCategory = null;

                    dartz.Either<String, void> response = await inventoryProvider.getProductsWithName(value, sucursal);

                    response.fold(
                      (l) {
                        SnackbarService.showIncorrect(context, "Inventario", l);
                      },
                      (r) {
                        nameController.clear();
                      },
                    );

                  },
                ),
              ),
              const SizedBox(width: 50,),
              /// Seleccion de categoría
              Expanded(
                child: CustomDropdown<CategoryInventoryEntity>(
                  onChanged: (value) async {
                    InventoryProvider inventoryProvider = context.read();
                    inventoryProvider.selectedCategory = value;
                    dartz.Either<String, void> response = await inventoryProvider.getProductsWithCategory(sucursal, inventoryProvider.selectedCategory!.categoria);
                    response.fold(
                      (l) {
                        SnackbarService.showIncorrect(context, "Inventario", l);
                      },
                      (r) {
                        SnackbarService.showCorrect(context, "Productos", "Cargados correctamente");
                      },

                    );
                  },
                  getDisplayValue: (value) => value.categoria,
                  hint: "Seleccionar categoría",
                  selectedValue: inventoryProvider.selectedCategory,
                  future: _futureCategory,
                ),
              ),

            ],
          ),
        ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {

          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }

          dartz.Either<String, List<ProductInventoryEntity>> response = snapshot.data!;

          return response.fold(
                (l) {
              return Center(child: CircularProgressIndicator(color: Colors.red,),);
            },
                (r) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text("Categoría")),
                            Expanded(child: Text("Nombre")),
                            Expanded(child: Text("Disponibles")),
                            Expanded(child: Text("Descripción")),
                          ],
                        ),
                      ),),
                      Expanded(child: ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text("IMEIS MODELO", textAlign: TextAlign.center,)),
                          ],
                        ),
                      ),)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Material(
                            child: ListView.builder(
                              itemCount: inventoryProvider.products.length,
                              itemBuilder: (context, index) {
                                ProductInventoryEntity product = inventoryProvider.products[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: ListTile(
                                    tileColor: Theme.of(context).colorScheme.secondary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(child: Text(product.categoria)),
                                        Expanded(child: Text(product.nombre, style: textStyle(context),)),
                                        Expanded(child: Text(product.disponibles.toString(), style: textStyle(context))),
                                        Expanded(child: Text(product.descripcion, style: textStyle(context))),
                                      ],
                                    ),
                                    onTap: () async {
                                      await inventoryProvider.getImeis(product.nombre);
                                      // await NavigationService.navigate(context, ViewServiceScreen(service: service,));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            child: ListView.builder(
                              itemCount: inventoryProvider.imeis.length,
                              itemBuilder: (context, index) {
                                String imei = inventoryProvider.imeis[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: ListTile(
                                    tileColor: Theme.of(context).colorScheme.secondary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(child: Text(imei, textAlign: TextAlign.center,)),
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
                    ),
                  ),
                ],
              );
            },
          );
        },
      )
    );
  }

  TextStyle textStyle(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium!;
  }

}
