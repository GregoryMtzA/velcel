// Run ONLY this file explicitly. All sale writes use verified session TEMPORARY
// tables in velcelco_prueba2026. No production connection is constructed.
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysql1/mysql1.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';
import 'package:velcel/features/store/data/repositories/products_repository_impl.dart';
import 'package:velcel/features/store/domain/entities/cart_method_pay.dart';
import 'package:velcel/features/store/domain/entities/cart_payment_type.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/domain/requests/venta_request.dart';
import 'package:velcel/features/store/domain/response/venta_response.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/ventas/data/repositories/ventas_repository_impl.dart';

const _database = 'velcelco_prueba2026';
const _imei = '350028031597294';
const _tables = {
  'cortes',
  'reportesventas',
  'salidasventas',
  'almacenaje',
  'imeisventas',
  'imeis',
  'registropayjoy',
  'productos',
};
const _routines = {
  'proCrearVenta',
  'proCrearVentaPayjoi',
  'proIterarCadena',
  'proIterarCadenas',
};

// Preserve the session until its temporary rows have been inspected. The real
// repository still runs its real query and transaction implementations.
class _KeepAliveConnection implements MySqlConnection {
  final MySqlConnection actual;
  bool failVerification = false;
  bool legacyEmptyImei = false;
  int verificationFaults = 0;
  _KeepAliveConnection(this.actual);

  @override
  Future<Results> query(String sql, [List<Object?>? values]) {
    if (failVerification && sql.startsWith('SELECT nombre FROM imeis')) {
      verificationFaults++;
      // Inject a real query error against the TEMPORARY table only.
      return actual.query('SELECT DIAG_NONEXISTENT_COLUMN FROM imeis');
    }
    if (legacyEmptyImei && sql.startsWith('CALL proCrearVentaPayjoi')) {
      final legacyValues = List<Object?>.from(values!);
      // Exact behavior of the checked-in HEAD when vr.imeis is [].
      legacyValues[9] = '';
      return actual.query(sql, legacyValues);
    }
    return actual.query(sql, values);
  }

  @override
  Future<T?> transaction<T>(Future<T> Function(TransactionContext) queryBlock,
          {Function(Object)? onError}) =>
      actual.transaction(queryBlock, onError: onError);

  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _checkRoutine(String ddl) {
  final begin = ddl.toUpperCase().indexOf('BEGIN');
  if (begin < 0) throw StateError('Routine without inspected body');
  final body = ddl.substring(begin);
  if (RegExp(r'\b(CREATE|ALTER|DROP|TRUNCATE|PREPARE|EXECUTE|JOIN|REPLACE)\b',
          caseSensitive: false)
      .hasMatch(body
          .replaceAll("REPLACE(cadena1, ',', '')", '')
          .replaceAll("REPLACE(imeisx, ',', '')", ''))) {
    throw StateError('Routine changed: inspect before running diagnostics');
  }
  final refs = RegExp(
    r'\b(?:INSERT\s+INTO|UPDATE|DELETE\s+FROM|FROM)\s+(`?\w+`?(?:\s*\.\s*`?\w+`?)?)',
    caseSensitive: false,
  );
  for (final match in refs.allMatches(body)) {
    final table = match.group(1)!.replaceAll('`', '');
    if (!_tables.contains(table)) {
      throw StateError('Unshadowed/qualified table reference: $table');
    }
  }
  for (final match
      in RegExp(r'\bCALL\s+(`?\w+`?(?:\s*\.\s*`?\w+`?)?)', caseSensitive: false)
          .allMatches(body)) {
    if (!_routines.contains(match.group(1)!.replaceAll('`', ''))) {
      throw StateError('Uninspected nested procedure');
    }
  }
}

Future<MySqlConnection> _temporarySession() async {
  if (dotenv.env['DB_TEST'] != _database) {
    throw StateError('Only $_database is permitted');
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
      throw StateError('Wrong database');
    }
    for (final routine in _routines) {
      final result = await connection.query('SHOW CREATE PROCEDURE $routine');
      _checkRoutine(result.single['Create Procedure'].toString());
    }
    for (final table in _tables) {
      final source = await connection.query('SHOW CREATE TABLE $table');
      final ddl = source.single[1].toString();
      if (!ddl.startsWith('CREATE TABLE `$table`')) {
        throw StateError('Wrong DDL');
      }
      await connection
          .query(ddl.replaceFirst('CREATE TABLE', 'CREATE TEMPORARY TABLE'));
      final created = await connection.query('SHOW CREATE TABLE $table');
      if (!created.single[1].toString().contains('CREATE TEMPORARY TABLE')) {
        throw StateError('Table is not temporary: $table');
      }
    }
    await connection
        .query('INSERT INTO almacenaje (nombre, sucursal, disponibles) '
            "VALUES ('DIAG_PHONE', 'DIAG_TEMP', 5)");
    await connection.query(
        'INSERT INTO imeis (nombre, sucursal, imei) VALUES (?, ?, ?)',
        ['DIAG_PHONE', 'DIAG_TEMP', _imei]);
    await connection.query('INSERT INTO productos '
        '(nombre, nombre_ver, categoria, precio, precioex, rimei, descripcion) '
        "VALUES ('DIAG_PHONE', 'Celular de prueba', 'CELULARES', 1000, 1000, 1, '')");
    return connection;
  } catch (_) {
    await connection.close();
    rethrow;
  }
}

VentaRequest _sale(
        {int quantity = 1,
        List<String> imeis = const [_imei],
        bool duplicateLines = false,
        String credit = 'No'}) =>
    VentaRequest(
      total: quantity * 1000.0,
      metodo: 'Efectivo',
      sucursal: 'DIAG_TEMP',
      usuario: 'DIAG',
      idCorte: 1,
      credito: credit,
      nombres: duplicateLines ? ['DIAG_PHONE', 'DIAG_PHONE'] : ['DIAG_PHONE'],
      cantidades: duplicateLines ? [1, 1] : [quantity],
      imeis: imeis,
      nombreC: 'DIAG',
      telefonoC: '0000000000',
      domicilioC: 'DIAG',
    );

Future<int> _persist(
    ProductsRepositoryImpl repository, VentaRequest request) async {
  final result = await repository.generarVenta(request);
  return result.fold(
      (error) => throw StateError(error.toString()), (sale) => sale.venta);
}

Future<void> _assertRows(MySqlConnection connection, int folio,
    {required int lines,
    required int quantity,
    required int imeis,
    required int remainingStock,
    required int availableImei}) async {
  final rows = await connection.query(
      'SELECT COUNT(*) AS n_lineas, SUM(cantidad) AS unidades '
      'FROM salidasventas WHERE folio = ?',
      [folio]);
  final serials = await connection
      .query('SELECT COUNT(*) AS n FROM imeisventas WHERE folio = ?', [folio]);
  final stock = await connection
      .query("SELECT disponibles FROM almacenaje WHERE nombre = 'DIAG_PHONE'");
  final available = await connection
      .query('SELECT COUNT(*) AS n FROM imeis WHERE imei = ?', [_imei]);
  expect(rows.single['n_lineas'], lines);
  expect(rows.single['unidades'], quantity);
  expect(serials.single['n'], imeis);
  expect(stock.single['disponibles'], remainingStock);
  expect(available.single['n'], availableImei);
  stdout.writeln(
      'TEMP folio=$folio lines=$lines quantity=$quantity imeis=$imeis stock=$remainingStock');
}

class _BranchRepository implements BranchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PrinterRepository implements PrinterRepositoryInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Persist using the real repository, then stop CartState before PDF/network and
// printing. A synthetic Left after success is diagnostic instrumentation only.
class _PersistenceProbe extends ProductsRepositoryImpl {
  final requests = <VentaRequest>[];
  final folios = <int>[];
  _PersistenceProbe(_KeepAliveConnection connection)
      : super(createConnection: () async => connection);

  @override
  Future<Either<Failure, VentaResponse>> generarVenta(
      VentaRequest request) async {
    requests.add(request);
    final response = await super.generarVenta(request);
    if (response.isLeft()) return response;
    response.fold((_) {}, (sale) => folios.add(sale.venta));
    return Left(ServerFailure(message: 'DIAG_STOP_BEFORE_PDF'));
  }
}

Future<CartState> _singleCreditPhone(
    _PersistenceProbe repository, String credit) async {
  final branch = BranchProvider(branchRepository: _BranchRepository())
    ..branch =
        BranchEntity(nombre: 'DIAG_TEMP', nombreVer: 'Prueba', activa: true);
  final cart = CartState(
      productRepository: repository,
      printerRepository: _PrinterRepository(),
      branchProvider: branch);
  final added = await cart.addProduct(
      const ProductEntity(
        name: 'DIAG_PHONE',
        nombreVer: 'Celular de prueba',
        description: '',
        price: 1000,
        image: null,
        rimei: true,
        category: 'CELULARES',
        activo: true,
      ),
      'DIAG_TEMP');
  expect(added.isRight(), isTrue);
  expect(cart.applyForPaguitos(), isTrue);
  expect(cart.cart.single.quantity, 1);
  cart.cartPaymentType =
      cartPaymentTypes.singleWhere((type) => type.name == credit);
  cart.cartMethodPayEntity = cartMethodPayTypes.first;
  cart.creditNameController.text = 'Cliente de prueba';
  cart.creditPhoneController.text = '8341234567';
  cart.creditAddressController.text = 'Domicilio de prueba';
  cart.creditEnchangeController.text = '300';
  cart.imeiProductEntitiesCart.single.imeiController.text = _imei;
  return cart;
}

void main() {
  setUpAll(
      () => dotenv.loadFromString(envString: File('.env').readAsStringSync()));
  late MySqlConnection session;
  late ProductsRepositoryImpl repository;
  setUp(() async {
    session = await _temporarySession();
    repository = ProductsRepositoryImpl(
        createConnection: () async => _KeepAliveConnection(session));
  });
  tearDown(() async => session.close());

  for (final credit in ['Paguitos', 'Tarifario']) {
    test('Credito estricto $credit: un celular desde carrito hasta detalle',
        () async {
      final connection = _KeepAliveConnection(session);
      final probe = _PersistenceProbe(connection);
      final cart = await _singleCreditPhone(probe, credit);
      await cart.verifyImei();
      expect(cart.cart.single.imeiList, [_imei]);
      await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
      expect(probe.requests.single.cantidades, [1]);
      expect(probe.requests.single.credito, credit);
      expect(probe.requests.single.total, 300);
      expect(probe.requests.single.imeis, [_imei]);
      expect(cart.cart.single.quantity, 1);
      final folio = probe.folios.single;
      await _assertRows(session, folio,
          lines: 1, quantity: 1, imeis: 1, remainingStock: 4, availableImei: 0);
      final detail =
          VentasRepositoryImpl(createConnection: () async => connection);
      final products = await detail.getProductos(folio);
      products.fold((e) => fail(e.toString()), (rows) {
        expect(rows.length, 1);
        expect(rows.single.cantidad, 1);
      });
      final imeis = await detail.getIMEIS(folio);
      imeis.fold(
          (e) => fail(e.toString()), (rows) => expect(rows.single.imei, _imei));
      final clients = await detail.getClientes(folio);
      clients.fold((e) => fail(e.toString()), (rows) => expect(rows.length, 1));
    });

    test('Credito estricto $credit: error SQL deja cantidad 1 sin IMEI',
        () async {
      final connection = _KeepAliveConnection(session)..failVerification = true;
      final probe = _PersistenceProbe(connection);
      final cart = await _singleCreditPhone(probe, credit);
      await cart.verifyImei();
      expect(connection.verificationFaults, 1);
      expect(cart.imeiProductEntitiesCart.single.error, isFalse);
      expect(cart.imeiProductEntitiesCart.single.imeiController.text, _imei);
      await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
      expect(probe.requests.single.cantidades, [1]);
      expect(probe.requests.single.imeis, isEmpty);
      await _assertRows(session, probe.folios.single,
          lines: 1, quantity: 1, imeis: 0, remainingStock: 4, availableImei: 1);
    });

    test('Credito estricto $credit: reintento crea otro folio y no cantidad 2',
        () async {
      final connection = _KeepAliveConnection(session);
      final probe = _PersistenceProbe(connection);
      final cart = await _singleCreditPhone(probe, credit);
      await cart.verifyImei();
      await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
      await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
      expect(probe.folios.length, 2);
      expect(probe.folios.toSet().length, 2);
      expect(probe.requests.every((request) => request.cantidades.single == 1),
          isTrue);
      for (final folio in probe.folios) {
        await _assertRows(session, folio,
            lines: 1,
            quantity: 1,
            imeis: 1,
            remainingStock: 3,
            availableImei: 0);
      }
    });
  }

  test(
      'Credito estricto Paguitos: fallo al insertar IMEI conserva salida ya confirmada',
      () async {
    // Artificial fault ONLY in the TEMPORARY table. The real table has no such
    // unique constraint: this establishes transaction behavior, not its cause.
    await session
        .query('ALTER TABLE imeisventas ADD UNIQUE KEY diag_imei (imei)');
    await session
        .query('INSERT INTO imeisventas (folio, imei) VALUES (-1, ?)', [_imei]);
    final connection = _KeepAliveConnection(session);
    final probe = _PersistenceProbe(connection);
    final cart = await _singleCreditPhone(probe, 'Paguitos');
    await cart.verifyImei();
    final result = await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    expect(result.isLeft(), isTrue);
    expect(probe.folios, isEmpty);
    expect(probe.requests.single.cantidades, [1]);
    expect(probe.requests.single.imeis, [_imei]);
    final header = await session.query('SELECT folio FROM reportesventas');
    expect(header.length, 1);
    await _assertRows(session, header.single['folio'] as int,
        lines: 1, quantity: 1, imeis: 0, remainingStock: 4, availableImei: 1);
  });

  test('Credito estricto Paguitos: serializacion de HEAD guarda IMEI vacio',
      () async {
    final connection = _KeepAliveConnection(session)
      ..failVerification = true
      ..legacyEmptyImei = true;
    final probe = _PersistenceProbe(connection);
    final cart = await _singleCreditPhone(probe, 'Paguitos');
    await cart.verifyImei();
    await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    final folio = probe.folios.single;
    await _assertRows(session, folio,
        lines: 1, quantity: 1, imeis: 1, remainingStock: 4, availableImei: 1);
    final serials = await session
        .query('SELECT imei FROM imeisventas WHERE folio = ?', [folio]);
    expect(serials.single['imei'], '');
    final visible =
        await VentasRepositoryImpl(createConnection: () async => connection)
            .getIMEIS(folio);
    visible.fold((e) => fail(e.toString()), (rows) => expect(rows, isEmpty));
  });

  test('Control: cantidad 1 e IMEI se guardan una sola vez', () async {
    final folio = await _persist(repository, _sale());
    await _assertRows(session, folio,
        lines: 1, quantity: 1, imeis: 1, remainingStock: 4, availableImei: 0);
  });
  test('Cantidad 2 sin IMEI: un folio, una linea, dos salidas y ningun IMEI',
      () async {
    final folio = await _persist(repository, _sale(quantity: 2, imeis: []));
    await _assertRows(session, folio,
        lines: 1, quantity: 2, imeis: 0, remainingStock: 3, availableImei: 1);
  });
  test('Cantidad 2 con un IMEI: se acepta la inconsistencia', () async {
    final folio = await _persist(repository, _sale(quantity: 2));
    await _assertRows(session, folio,
        lines: 1, quantity: 2, imeis: 1, remainingStock: 3, availableImei: 0);
  });
  test('Dos nombres repetidos generan dos lineas dentro del mismo folio',
      () async {
    final folio =
        await _persist(repository, _sale(quantity: 2, duplicateLines: true));
    await _assertRows(session, folio,
        lines: 2, quantity: 2, imeis: 1, remainingStock: 3, availableImei: 0);
  });
  test('Dos llamadas de cantidad 1 generan folios distintos', () async {
    final first = await _persist(repository, _sale());
    final second = await _persist(repository, _sale());
    expect(first, isNot(second));
    final headers =
        await session.query('SELECT COUNT(*) AS n FROM reportesventas');
    expect(headers.single['n'], 2);
    await _assertRows(session, second,
        lines: 1, quantity: 1, imeis: 1, remainingStock: 3, availableImei: 0);
    stdout
        .writeln('TEMP repeated purchase: distinct folios $first and $second');
  });
  test('Venta a credito tambien acepta cantidad 2 sin IMEI', () async {
    final folio = await _persist(
        repository, _sale(quantity: 2, imeis: [], credit: 'Paguitos'));
    await _assertRows(session, folio,
        lines: 1, quantity: 2, imeis: 0, remainingStock: 3, availableImei: 1);
  });
}
