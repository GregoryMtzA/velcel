import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql1/mysql1.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velcel/features/auth/data/repositories/branch_repository_impl.dart';
import 'package:velcel/features/auth/data/repositories/user_repository_impl.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';
import 'package:velcel/features/auth/domain/repositories/user_repository.dart';
import 'package:velcel/features/config/data/repositories/printer_repository_impl.dart';
import 'package:velcel/features/config/domain/repositories/printer_repository_interface.dart';
import 'package:velcel/features/gastos/data/repositories/gastos_repository_impl.dart';
import 'package:velcel/features/gastos/domain/repositories/gastos_repository.dart';
import 'package:velcel/features/gastos/domain/usecases/crear_gasto_usecase.dart';
import 'package:velcel/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:velcel/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:velcel/features/services/data/repositories/services_repository_impl.dart';
import 'package:velcel/features/services/domain/repositories/services_repository.dart';
import 'package:velcel/features/store/data/repositories/cash_register_repository_impl.dart';
import 'package:velcel/features/store/data/repositories/products_repository_impl.dart';
import 'package:velcel/features/store/domain/repositories/cash_register_repository.dart';
import 'package:velcel/features/store/domain/repositories/products_repository.dart';
import 'package:velcel/features/ventas/data/repositories/ventas_repository_impl.dart';
import 'package:velcel/features/ventas/domain/repositories/ventas_repository.dart';
import 'package:velcel/features/ventas/domain/usecases/get_detail_report_with_folio_usecase.dart';

import '../core/mysql.dart';

GetIt locator = GetIt.instance;

Future<void> injectContainer() async {
  await dotenv.load(fileName: '.env');
  /// GENERALES
  // var settings = new ConnectionSettings(
  //   host: dotenv.env['HOST']!,
  //   user: dotenv.env['USER_PROD']!,
  //   password: dotenv.env['PASSWORD_PROD']!,
  //   db: dotenv.env['DB_PROD']!,
  // );

  ///PRUEBAS
  ConnectionSettings settings = new ConnectionSettings(
    host: dotenv.env['HOST']!,
    user: dotenv.env['USER_TEST']!,
    password: dotenv.env['PASSWORD_TEST']!,
    db: dotenv.env['DB_TEST']!,
  );

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  locator.registerLazySingleton<Future<MySqlConnection> Function()>(() => () => createConnection(settings));

  locator.registerLazySingleton(() => sharedPreferences,);

  /// Casos de uso
  locator.registerLazySingleton(() => CrearGastoUsecase(gastosRepository: locator()),);
  locator.registerLazySingleton(() => GetDetailReportWithFolioUsecase(ventaRepository: locator()),);

  /// PRODUCTS REPOSITORY
  locator.registerLazySingleton<ProductsRepository>(() => ProductsRepositoryImpl(createConnection: locator()),);
  locator.registerLazySingleton<PrinterRepositoryInterface>(() => PrinterRepositoryImpl(sharedPreferences: locator()));
  locator.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl(createConnection: locator()),);
  locator.registerLazySingleton<VentasRepository>(() => VentasRepositoryImpl(createConnection: locator()),);
  locator.registerLazySingleton<GastosRepository>(() => GastosRepositoryImpl(createConnection: locator()),);
  locator.registerLazySingleton<ServicesRepository>(() => ServicesRepositoryImpl(createConnection: locator()),);
  locator.registerLazySingleton<BranchRepository>(() => BranchRepositoryImpl(sharedPreferences: locator(), createConnection: locator()),);
  locator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sharedPreferences: locator(), createConnection: locator()),);
  locator.registerLazySingleton<CashRegisterRepository>(() => CashRegisterRepositoryImpl(createConnection: locator()),);

}