import 'package:equatable/equatable.dart';

import '../../../../core/app/enums/enums.dart';

class CartMethodPayEntity extends Equatable{

  final String name;
  final MethodPay enumType;

  const CartMethodPayEntity({
    required this.name,
    required this.enumType
  });

  @override
  String toString() {
    return name;
  }

  @override
  List<Object?> get props => [name, enumType];
}


List<CartMethodPayEntity> cartMethodPayTypes = [

  const CartMethodPayEntity(name: "Efectivo", enumType: MethodPay.efectivo),
  const CartMethodPayEntity(name: "Tarjeta", enumType: MethodPay.tarjeta),

];