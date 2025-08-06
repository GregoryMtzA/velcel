import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysql1/mysql1.dart';

import 'cash_register_entity.dart';


void main() {

  late final MySqlConnection mysql;

  setUp(() async {

    ConnectionSettings settings = new ConnectionSettings(
      host: 'velcel.com',
      user: 'velcelco_pruebas',
      password: '3OmmSf,S]g#e',
      db: 'velcelco_prueba',
    );

    mysql = await MySqlConnection.connect(settings);

  },);

  test("Verificar que envian los datos ", () async {

    try{
      Results results = await mysql.query(
        '''SELECT usuario, fechaapertura, fechacierre, cantidadefectivo, cantidadtarjeta, fondo, gastos, total, totalconteo, diferencia
        FROM cortes WHERE (fechaapertura BETWEEN ? AND ?) AND sucursal=? AND estado=? LIMIT 1''',
        ["2024-01-01", "2024-01-30", "INNOVA 2", "Cerrado"]
      );

      print(results);

      // print(json.encode(results.first));

    } catch (e){
      print(e);
    }

  },);

}
