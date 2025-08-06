import 'package:equatable/equatable.dart';

class Sucursal extends Equatable{

  String name;

  Sucursal({
    required this.name
  });

  @override
  List<Object?> get props => [name];

}


List<Sucursal> fakeSucursales = [
  Sucursal(name: "Sucursal de Calle Juárez, Victoria"),
  Sucursal(name: "Sucursal de Avenida Insurgentes, Ciudad de México"),
  Sucursal(name: "Sucursal de Calle Hidalgo, Monterrey"),
  Sucursal(name: "Sucursal de Avenida Revolución, Guadalajara"),
  Sucursal(name: "Sucursal de Calle Zaragoza, Puebla"),
];