// Diagnostic tests of CURRENT behavior. No database, printer, or network access.
// A capturing repository stops purchase before PDF generation and persistence.
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/enums/enums.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';
import 'package:velcel/features/store/domain/entities/cart_method_pay.dart';
import 'package:velcel/features/store/domain/entities/cart_payment_type.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/domain/repositories/products_repository.dart';
import 'package:velcel/features/store/domain/requests/venta_request.dart';
import 'package:velcel/features/store/domain/response/venta_response.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_page/cart_verify.dart';

const diagnosticImei = '350028031597294';
const phone = ProductEntity(
  name: 'DIAG_PHONE',
  nombreVer: 'Celular de prueba',
  description: '',
  price: 1000,
  image: null,
  rimei: true,
  category: 'CELULARES',
  activo: true,
);

class _BranchRepository implements BranchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PrinterRepository implements PrinterRepositoryInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProductsRepository implements ProductsRepository {
  final requests = <VentaRequest>[];
  Future<Either<Failure, int>> Function()? stockResult;
  Future<Either<Failure, bool>> Function()? imeiResult;

  @override
  Future<Either<Failure, int>> checkStock(String name, String sucursal) async =>
      stockResult == null ? const Right(5) : await stockResult!();

  @override
  Future<Either<Failure, bool>> verifyImei(
          String producto, String imei, String sucursal) async =>
      imeiResult == null ? const Right(true) : await imeiResult!();

  @override
  Future<Either<Failure, VentaResponse>> generarVenta(
      VentaRequest request) async {
    requests.add(request);
    return Left(ServerFailure(message: 'DIAG_CAPTURE_ONLY'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CartState _cart(_ProductsRepository repository) {
  final branch = BranchProvider(branchRepository: _BranchRepository())
    ..branch = BranchEntity(
      nombre: 'DIAG_TEMP',
      nombreVer: 'Prueba',
      activa: true,
    );
  return CartState(
    productRepository: repository,
    printerRepository: _PrinterRepository(),
    branchProvider: branch,
  )
    ..cartPaymentType = cartPaymentTypes.first
    ..cartMethodPayEntity = cartMethodPayTypes.first;
}

Future<void> _mountVerification(WidgetTester tester, CartState cart,
    {double textScale = 1}) async {
  tester.view.physicalSize = const Size(1100, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(ChangeNotifierProvider<CartState>.value(
    value: cart,
    child: MaterialApp(
        builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
        home: Scaffold(
            body: PageView(
          controller: cart.cartPageController,
          children: const [CartVerify(), SizedBox(), SizedBox()],
        ))),
  ));
  await tester.pumpAndSettle();
}

Future<void> _selectCreditInUi(
    WidgetTester tester, CartState cart, String credit) async {
  cart.cartPaymentType = null;
  await _mountVerification(tester, cart);
  await tester.tap(find.text(credit));
  await tester.pumpAndSettle();
  expect(cart.cartPaymentType?.name, credit);
  expect(cart.applyForPaguitos(), isTrue);
  expect(cart.cart.single.quantity, 1);
  cart.creditNameController.text = 'Cliente de prueba';
  cart.creditPhoneController.text = '8341234567';
  cart.creditAddressController.text = 'Domicilio de prueba';
  cart.creditEnchangeController.text = '300';
  cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final credit in ['Paguitos', 'Tarifario']) {
    testWidgets('Credito estricto $credit: un celular conserva cantidad e IMEI',
        (tester) async {
      final repository = _ProductsRepository();
      final cart = _cart(repository);
      await cart.addProduct(phone, 'DIAG_TEMP');
      await _selectCreditInUi(tester, cart, credit);
      await tester.tap(find.text('Verificar IMEIs'));
      await tester.pumpAndSettle();
      expect(cart.cartState, CartStates.purchase);
      await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
      final request = repository.requests.single;
      expect(request.credito, credit);
      expect(request.nombres, ['DIAG_PHONE']);
      expect(request.cantidades, [1]);
      expect(request.imeis, [diagnosticImei]);
      expect(request.total, 300);
      expect(cart.cart.single.quantity, 1);
    });

    testWidgets(
        'Credito estricto $credit: fallo de verificacion pierde solo IMEI',
        (tester) async {
      final repository = _ProductsRepository()
        ..imeiResult =
            () async => Left(ServerFailure(message: 'SQL_TEST_FAILURE'));
      final cart = _cart(repository);
      await cart.addProduct(phone, 'DIAG_TEMP');
      await _selectCreditInUi(tester, cart, credit);
      await tester.tap(find.text('Verificar IMEIs'));
      await tester.pumpAndSettle();
      expect(cart.cartState, CartStates.purchase);
      await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
      final request = repository.requests.single;
      expect(request.credito, credit);
      expect(request.cantidades, [1]);
      expect(request.imeis, isEmpty);
      expect(cart.cart.single.quantity, 1);
    });

    testWidgets(
        'Credito estricto $credit: la UI rechaza un carrito de cantidad 2',
        (tester) async {
      final cart = _cart(_ProductsRepository());
      await cart.addProduct(phone, 'DIAG_TEMP');
      await cart.addProduct(phone, 'DIAG_TEMP');
      cart.cartPaymentType = null;
      await _mountVerification(tester, cart, textScale: 0.75);
      await tester.tap(find.text(credit));
      await tester.pumpAndSettle();
      expect(cart.applyForPaguitos(), isFalse);
      expect(cart.cartPaymentType, isNull);
    });
  }

  test('Una alta y una verificacion envian cantidad 1 y el IMEI', () async {
    final repository = _ProductsRepository();
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
    await cart.verifyImei();
    await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    final request = repository.requests.single;
    expect(request.cantidades, [1]);
    expect(request.imeis, [diagnosticImei]);
  });

  test('Dos altas pendientes acumulan 2 unidades en una sola linea', () async {
    final repository = _ProductsRepository();
    final checks = <Completer<Either<Failure, int>>>[];
    repository.stockResult = () {
      final check = Completer<Either<Failure, int>>();
      checks.add(check);
      return check.future;
    };
    final cart = _cart(repository);
    final first = cart.addProduct(phone, 'DIAG_TEMP');
    final second = cart.addProduct(phone, 'DIAG_TEMP');
    expect(checks.length, 2);
    checks[0].complete(const Right(5));
    await first;
    checks[1].complete(const Right(5));
    await second;
    expect(cart.cart.length, 1);
    expect(cart.cart.single.quantity, 2);
    expect(cart.total, 2000);
    expect(cart.imeiProductEntitiesCart.length, 2);
  });

  test('Alta pendiente posterior a verificar envia 2 unidades y solo 1 IMEI',
      () async {
    final repository = _ProductsRepository();
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    final pending = Completer<Either<Failure, int>>();
    repository.stockResult = () => pending.future;
    final second = cart.addProduct(phone, 'DIAG_TEMP');
    cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
    await cart.verifyImei();
    pending.complete(const Right(5));
    await second;
    expect(
        cart.imeiProductEntitiesCart
            .every((entry) => entry.imeiController.text.isEmpty),
        isTrue);
    await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    expect(repository.requests.single.cantidades, [2]);
    expect(repository.requests.single.imeis, [diagnosticImei]);
  });

  test('Mismo codigo con metadatos distintos genera dos lineas repetidas',
      () async {
    final repository = _ProductsRepository();
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    await cart.addProduct(
        const ProductEntity(
          name: 'DIAG_PHONE',
          nombreVer: 'Celular de prueba actualizado',
          description: '',
          price: 1000,
          image: null,
          rimei: true,
          category: 'CELULARES',
          activo: true,
        ),
        'DIAG_TEMP');
    expect(cart.cart.length, 2);
    await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    expect(repository.requests.single.nombres, ['DIAG_PHONE', 'DIAG_PHONE']);
    expect(repository.requests.single.cantidades, [1, 1]);
  });

  test('Cambiar el carrito reconstruye y vacia el campo IMEI capturado',
      () async {
    final cart = _cart(_ProductsRepository());
    await cart.addProduct(phone, 'DIAG_TEMP');
    final previous = cart.imeiProductEntitiesCart.single.imeiController;
    previous.text = diagnosticImei;
    await cart.addProduct(
        const ProductEntity(
          name: 'DIAG_CABLE',
          nombreVer: 'Cable',
          description: '',
          price: 10,
          image: null,
          rimei: false,
          category: 'ACCESORIOS',
          activo: true,
        ),
        'DIAG_TEMP');
    expect(cart.imeiProductEntitiesCart.single.imeiController,
        isNot(same(previous)));
    expect(cart.imeiProductEntitiesCart.single.imeiController.text, isEmpty);
    expect(previous.text, diagnosticImei);
  });

  testWidgets('Error SQL al verificar permite avanzar y enviar IMEI vacio',
      (tester) async {
    final repository = _ProductsRepository()
      ..imeiResult =
          () async => Left(ServerFailure(message: 'SQL_TEST_FAILURE'));
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
    await _mountVerification(tester, cart);
    await tester.tap(find.text('Verificar IMEIs'));
    await tester.pumpAndSettle();
    expect(cart.cartState, CartStates.purchase);
    expect(cart.cart.single.imeiList, isEmpty);
    expect(cart.imeiProductEntitiesCart.single.error, isFalse);
    await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    expect(repository.requests.single.imeis, isEmpty);
  });

  testWidgets('Respuesta IMEI inexistente si bloquea el avance',
      (tester) async {
    final repository = _ProductsRepository()
      ..imeiResult = () async => const Right(false);
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
    await _mountVerification(tester, cart);
    await tester.tap(find.text('Verificar IMEIs'));
    await tester.pumpAndSettle();
    expect(cart.cartState, isNot(CartStates.purchase));
    expect(cart.imeiProductEntitiesCart.single.error, isTrue);
    expect(find.text('IMEI no válido'), findsOneWidget);
  });

  test('Reverificar con error SQL borra un IMEI que ya habia sido validado',
      () async {
    final repository = _ProductsRepository();
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
    await cart.verifyImei();
    expect(cart.cart.single.imeiList, [diagnosticImei]);
    repository.imeiResult =
        () async => Left(ServerFailure(message: 'SQL_TEST_FAILURE'));
    await cart.verifyImei();
    expect(cart.cart.single.imeiList, isEmpty);
    expect(cart.imeiProductEntitiesCart.single.error, isFalse);
    expect(cart.imeiProductEntitiesCart.single.imeiController.text,
        diagnosticImei);
  });

  testWidgets('Alta tardia y fallo SQL antes del siguiente frame: 2 sin IMEI',
      (tester) async {
    final repository = _ProductsRepository();
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    cart.imeiProductEntitiesCart.single.imeiController.text = diagnosticImei;
    final stock = Completer<Either<Failure, int>>();
    final verification = Completer<Either<Failure, bool>>();
    repository.stockResult = () => stock.future;
    repository.imeiResult = () => verification.future;
    final pendingAdd = cart.addProduct(phone, 'DIAG_TEMP');
    await _mountVerification(tester, cart);
    await tester.tap(find.text('Verificar IMEIs'));
    // Both asynchronous responses arrive before Flutter renders new fields.
    stock.complete(const Right(5));
    await tester.idle();
    await pendingAdd;
    expect(cart.cart.single.quantity, 2);
    verification.complete(Left(ServerFailure(message: 'SQL_TEST_FAILURE')));
    await tester.idle();
    expect(cart.cartState, CartStates.purchase);
    await cart.purchase(1, 'DIAG', 'DIAG_TEMP');
    expect(repository.requests.single.cantidades, [2]);
    expect(repository.requests.single.imeis, isEmpty);
    await tester.pumpAndSettle();
  });

  test('Purchase no impide que dos llamadas alcancen el repositorio', () async {
    final repository = _ProductsRepository();
    final cart = _cart(repository);
    await cart.addProduct(phone, 'DIAG_TEMP');
    await Future.wait([
      cart.purchase(1, 'DIAG', 'DIAG_TEMP'),
      cart.purchase(1, 'DIAG', 'DIAG_TEMP'),
    ]);
    expect(repository.requests.length, 2);
    expect(repository.requests.every((r) => r.cantidades.single == 1), isTrue);
  });
}
