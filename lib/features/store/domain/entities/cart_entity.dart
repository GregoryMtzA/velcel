import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';

import '../../../../utils/productos.dart';

class CartProductEntity extends Equatable {

  ProductEntity product;
  List<String> imeiList;
  int quantity;

  CartProductEntity({
    required this.product,
    required this.quantity,
    required this.imeiList,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [product, quantity, imeiList];

}