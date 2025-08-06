import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../domain/entities/cart_entity.dart';

class ImeiProductEntity extends Equatable {

  CartProductEntity cartProductEntity;
  TextEditingController imeiController;
  bool error;

  ImeiProductEntity({
    required this.cartProductEntity,
    required this.imeiController,
    this.error = false,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [cartProductEntity, imeiController, error];

}