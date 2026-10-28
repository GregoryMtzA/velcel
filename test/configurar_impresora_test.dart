import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';
import 'package:velcel/features/auth/domain/repositories/user_repository.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/config/domain/entities.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/config/presentation/screens/configurar_impresora.dart';

class _PrinterRepository implements PrinterRepositoryInterface {
  String? savedMac;

  @override
  Future<Either<String, BluetoothInfoEquatable?>> getPrinterSaved() async =>
      const Right(null);

  @override
  Future<Either<String, Unit>> savePrinter(String macAddress) async {
    savedMac = macAddress;
    return Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BranchRepository implements BranchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PrintersController extends PrintersControllers {
  _PrintersController(PrinterRepositoryInterface repository)
      : super(repository: repository);

  int scans = 0;

  @override
  Future<Either<String, List<BluetoothInfoEquatable>>>
      escanearImpresoras() async {
    scans++;
    return Right([
      BluetoothInfoEquatable(
        bluetoothInfo: BluetoothInfo(
          name: 'Printer A',
          macAdress: 'AA:BB:CC:DD:EE:FF',
        ),
      ),
      BluetoothInfoEquatable(
        bluetoothInfo: BluetoothInfo(
          name: 'Printer B',
          macAdress: '11:22:33:44:55:66',
        ),
      ),
      BluetoothInfoEquatable(
        bluetoothInfo: BluetoothInfo(
          name: 'Printer C',
          macAdress: '66:55:44:33:22:11',
        ),
      ),
    ]);
  }
}

void main() {
  testWidgets('elige impresora sin repetir la búsqueda en una ventana baja',
      (tester) async {
    tester.view.physicalSize = const Size(900, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = _PrinterRepository();
    final controller = _PrintersController(repository);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PrintersControllers>.value(value: controller),
          ChangeNotifierProvider(
            create: (_) =>
                BranchProvider(branchRepository: _BranchRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => UserProvider(userRepository: _UserRepository()),
          ),
        ],
        child: const MaterialApp(home: ConfigurarImpresora()),
      ),
    );
    await tester.pump();

    expect(controller.scans, 1);
    final dropdown = find.byType(IsselDropdown<BluetoothInfoEquatable>);
    expect(dropdown, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    expect(find.text('Printer A'), findsOneWidget);
    expect(find.text('Printer B'), findsOneWidget);
    expect(find.text('Printer C'), findsOneWidget);
    await tester.tap(find.text('Printer A'));
    await tester.pump();

    expect(repository.savedMac, 'AA:BB:CC:DD:EE:FF');
    expect(controller.scans, 1);
    expect(tester.takeException(), isNull);
  });
}
