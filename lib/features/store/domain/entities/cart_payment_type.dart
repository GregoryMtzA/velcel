import 'package:equatable/equatable.dart';

import '../../../../core/app/enums/enums.dart';

class CartPaymentTypeEntity extends Equatable{

  final String name;
  final PaymentTypes enumType;

  const CartPaymentTypeEntity({
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


List<CartPaymentTypeEntity> cartPaymentTypes = [

  const CartPaymentTypeEntity(name: "Normal", enumType: PaymentTypes.normal),
  const CartPaymentTypeEntity(name: "Paguitos", enumType: PaymentTypes.paguitos),

];