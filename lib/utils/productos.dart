import 'package:equatable/equatable.dart';

class Producto extends Equatable {
  String name;
  double price;
  int stock;
  String? imei;
  String? image; // Nueva propiedad para la imagen
  String category; // Nueva propiedad para la categoría

  Producto({
    required this.name,
    required this.price,
    required this.stock,
    required this.category, // Agregar categoría como requerida
    this.imei,
    this.image, // Constructor actualizado
  });

  @override
  List<Object?> get props => [name, price, stock, imei, image, category]; // Actualización de props
}

List<Producto> fakeProductos = [
  Producto(
    name: "Samsung Galaxy A55 8GB RAM",
    price: 5499,
    stock: 10,
    category: "Celulares",
    imei: 'IMEI-123456789012345', // Ejemplo de IMEI para celular
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/162866-1200-auto?v=638543257050600000&width=1200&height=auto&aspect=true',
  ),
  Producto(
    name: "Honor Magic5 Lite 8GB RAM",
    price: 3749,
    stock: 15,
    category: "Celulares",
    imei: 'IMEI-234567890123456', // Ejemplo de IMEI para celular
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/162851-1200-auto?v=638542400519000000&width=1200&height=auto&aspect=true',
  ),
  Producto(
    name: "Samsung Galaxy A15 6GB RAM",
    price: 2469,
    stock: 20,
    category: "Celulares",
    imei: 'IMEI-345678901234567', // Ejemplo de IMEI para celular
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/162861-1200-auto?v=638542436943900000&width=1200&height=auto&aspect=true',
  ),
  Producto(
    name: "Samsung Galaxy A05 4GB Ram",
    price: 1699,
    stock: 12,
    category: "Celulares",
    imei: 'IMEI-456789012345678', // Ejemplo de IMEI para celular
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/161524-1200-auto?v=638389474921300000&width=1200&height=auto&aspect=true',
  ),
  Producto(
    name: "PANTALLA HYUNDAI 50\" 4K Smart TV Web OS HYUNDAI HYLED5017W4KM",
    price: 5499,
    stock: 5,
    category: "Electrónica",
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/158961-1200-auto?v=638044851478000000&width=1200&height=auto&aspect=true',
  ),
  Producto(
    name: "Apple AirPODS Pro con Estuche de Carga Reacondicionados",
    price: 2999,
    stock: 8,
    category: "Accesorios",
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/158541-1200-auto?v=638028526664830000&width=1200&height=auto&aspect=true',
  ),
  Producto(
    name: "Nintendo Switch Oled Edición Mario Red",
    price: 4429,
    stock: 10,
    category: "Consolas",
    image:
    'https://telmovmx.vtexassets.com/arquivos/ids/162857-1200-auto?v=638542418588400000&width=1200&height=auto&aspect=true',
  ),
];