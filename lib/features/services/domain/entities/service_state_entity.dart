import 'package:equatable/equatable.dart';

import '../../../../core/app/enums/enums.dart';

class ServiceStateEntity extends Equatable{

  final String name;
  final EnumServiceState enumType;

  const ServiceStateEntity({
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


List<ServiceStateEntity> serviceStatesList = [

  const ServiceStateEntity(name: "Pendiente", enumType: EnumServiceState.pendiente),
  const ServiceStateEntity(name: "Terminado", enumType: EnumServiceState.terminado),
  const ServiceStateEntity(name: "Entregado", enumType: EnumServiceState.entregado),

];