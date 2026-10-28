// Run explicitly: flutter test tool/closure_diagnostic_test.dart --reporter expanded
// Diagnostics of the current behavior, not regression tests for corrected behavior.
// Persistent data is read-only. Write scenarios use verified TEMPORARY tables.
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/core/errors/exceptions.dart';
import 'package:velcel/features/store/data/repositories/cash_register_repository_impl.dart';
import 'package:velcel/features/store/data/repositories/products_repository_impl.dart';
import 'package:velcel/features/store/domain/requests/venta_request.dart';

const _database = 'velcelco_prueba2026';

Future<MySqlConnection> _connect() async {
  if (dotenv.env['DB_TEST'] != _database) {
    throw StateError('Diagnostic only permits $_database');
  }
  final connection = await MySqlConnection.connect(ConnectionSettings(
    host: dotenv.env['HOST']!,
    user: dotenv.env['USER_TEST']!,
    password: dotenv.env['PASSWORD_TEST']!,
    db: _database,
  ));
  try {
    final identity = await connection.query('SELECT DATABASE() AS db');
    if (identity.single['db'] != _database) {
      throw StateError('Unexpected database; aborting');
    }
    return connection;
  } catch (_) {
    await connection.close();
    rethrow;
  }
}

Future<MySqlConnection> _readOnlyConnection() async {
  final connection = await _connect();
  try {
    await connection.query('START TRANSACTION READ ONLY');
    return connection;
  } catch (_) {
    await connection.close();
    rethrow;
  }
}

Future<MySqlConnection> _temporaryConnection({
  String state = 'Cerrado',
  String branch = 'DIAG_TEMP',
}) async {
  final connection = await _connect();
  try {
    // These are all the tables referenced by the tested routines, including
    // nested proIterarCadenas / proIterarCadena calls. SHOW CREATE omits triggers.
    for (final table in [
      'cortes',
      'reportesventas',
      'salidasventas',
      'almacenaje',
      'imeisventas',
      'imeis',
      'registropayjoy',
    ]) {
      final source =
          await connection.query('SHOW CREATE TABLE $_database.$table');
      final ddl = source.single[1].toString();
      if (!ddl.startsWith('CREATE TABLE `$table`')) {
        throw StateError('Unexpected source definition: $table');
      }
      await connection.query(
        ddl.replaceFirst('CREATE TABLE', 'CREATE TEMPORARY TABLE'),
      );
      final definition = await connection.query('SHOW CREATE TABLE $table');
      if (!definition.single[1].toString().contains('CREATE TEMPORARY TABLE')) {
        throw StateError('Temporary table verification failed: $table');
      }
    }
    await connection.query(
      'INSERT INTO cortes '
      '(identificador, sucursal, usuario, estado, fondo, fechaapertura, fechacierre) '
      'VALUES (1, ?, ?, ?, 0, DATE_SUB(NOW(), INTERVAL 1 DAY), '
      'DATE_SUB(NOW(), INTERVAL 1 HOUR))',
      [branch, 'DIAG', state],
    );
    return connection;
  } catch (_) {
    await connection.close();
    rethrow;
  }
}

VentaRequest _sale({int cut = 1, String credit = 'No'}) => VentaRequest(
      total: 1,
      metodo: 'Efectivo',
      sucursal: 'DIAG_TEMP',
      usuario: 'DIAG',
      idCorte: cut,
      credito: credit,
      nombres: ['DIAG_PRODUCT'],
      cantidades: [1],
      nombreC: 'DIAG',
      telefonoC: '0000000000',
      domicilioC: 'DIAG',
    );

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: File('.env').readAsStringSync());
  });

  test('Read real JIMENEZ cuts using repository in read-only transactions',
      () async {
    final repository = CashRegisterRepositoryImpl(
      createConnection: _readOnlyConnection,
    );
    final last = await repository.getLastClosedCutFolio('CELLSHOP JIMENEZ');
    expect(last.isRight(), isTrue);
    last.fold((failure) => fail(failure.toString()), (folio) {
      expect(folio, 15583);
      stdout.writeln('CELLSHOP JIMENEZ last closed cut: $folio');
    });
    final opened = await repository.openCashRegister('CELLSHOP JIMENEZ');
    opened.fold((failure) => fail(failure.toString()), (cut) {
      expect(cut?.identificador, 15588);
      stdout.writeln('CELLSHOP JIMENEZ open cut: ${cut?.identificador}');
    });
    final data =
        await repository.getCashRegisterData('CELLSHOP JIMENEZ', 15583);
    data.fold((failure) => fail(failure.toString()), (data) {
      expect(data.totalesEfectivo, 560);
      expect(data.totalesTarjeta, 0);
      expect(data.totalesGastos, 550);
      expect(
          data.totalesEfectivo +
              data.totalesTarjeta +
              data.fondo -
              data.totalesGastos,
          10);
      stdout.writeln('Cut 15583: cash=560, expenses=550, net=10');
    });
  });

  test('Reproduce normal sale accepted for a CLOSED cut in temporary tables',
      () async {
    final repository = ProductsRepositoryImpl(
      createConnection: () => _temporaryConnection(),
    );
    final response = await repository.generarVenta(_sale());
    response.fold((failure) => fail(failure.toString()), (sale) {
      expect(sale.venta, greaterThan(0));
      stdout.writeln('REPRODUCED: normal sale accepted for closed cut');
    });
  });

  test('Reproduce credit sale accepted for a CLOSED cut in temporary tables',
      () async {
    final repository = ProductsRepositoryImpl(
      createConnection: () => _temporaryConnection(),
    );
    final response = await repository.generarVenta(_sale(credit: 'Payjoy'));
    response.fold((failure) => fail(failure.toString()), (sale) {
      expect(sale.venta, greaterThan(0));
      stdout.writeln('REPRODUCED: credit sale accepted for closed cut');
    });
  });

  test('Reproduce sale accepted for a NONEXISTENT cut in temporary tables',
      () async {
    final repository = ProductsRepositoryImpl(
      createConnection: () => _temporaryConnection(),
    );
    final response = await repository.generarVenta(_sale(cut: 999999));
    expect(response.isRight(), isTrue);
    stdout.writeln('REPRODUCED: sale accepted for nonexistent cut');
  });

  test('Reproduce sale accepted for ANOTHER branch cut in temporary tables',
      () async {
    final repository = ProductsRepositoryImpl(
      createConnection: () =>
          _temporaryConnection(state: 'Abierto', branch: 'DIAG_OTHER'),
    );
    final response = await repository.generarVenta(_sale());
    expect(response.isRight(), isTrue);
    stdout.writeln('REPRODUCED: sale accepted for another branch cut');
  });

  test('Reproduce opening with an existing same-user cut in temporary tables',
      () async {
    final repository = CashRegisterRepositoryImpl(
      createConnection: () => _temporaryConnection(state: 'Abierto'),
    );
    await expectLater(
      repository.registerOpening(0, 'DIAG_TEMP', 'DIAG'),
      throwsA(isA<ServerException>()),
    );
    stdout.writeln('REPRODUCED: duplicate opening produces a support error');
  });
}
