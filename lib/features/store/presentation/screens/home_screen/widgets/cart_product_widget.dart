import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/utils/productos.dart';

import '../../../../../../core/app/theme.dart';
import '../../../../../widgets/image_app.dart';

class CartProductWidget extends StatelessWidget {

  ProductEntity producto;
  VoidCallback onTap;

  CartProductWidget({
    super.key,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [

            // imagen
            Expanded(child: ImageApp(url: producto.image,),),

            const SizedBox(height: 10,),

            // nombre producto
            Expanded(child: Text(producto.name, textAlign: TextAlign.center, maxLines: 3,),),

            // precio del producto
            Text("\$ ${producto.price.toString()}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: IsselColors.azulClaro, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}
