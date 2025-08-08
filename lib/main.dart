import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/dependency_injections/inject_container.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/auth/presentation/screens/splash_screen/splash_screen.dart';
import 'package:velcel/features/config/presentation/controllers/printers_controller.dart';
import 'package:velcel/features/gastos/presentation/providers/gastos_provider.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:velcel/features/services/presentation/providers/services_provider.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';
import 'package:velcel/features/store/presentation/providers/products_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:velcel/features/ventas/presentation/providers/ventas_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await injectContainer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CashRegisterProvider(cashRegisterRepository: locator()),),
        ChangeNotifierProvider(create: (context) => PrintersControllers(repository: locator()),),
        ChangeNotifierProvider(create: (context) => GastosProvider(gastosRepository: locator(), crearGastoUsecase: locator()),),
        ChangeNotifierProvider(create: (context) => VentasProvider(ventasRepository: locator(), getDetailReportWithFolioUsecase: locator()),),
        ChangeNotifierProvider(create: (context) => BranchProvider(branchRepository: locator()),),
        ChangeNotifierProvider(create: (context) => UserProvider(userRepository: locator()),),
        ChangeNotifierProvider(create: (context) => ProductsProvider(productsRepository: locator()),),
        ChangeNotifierProvider(create: (context) => ServicesProvider(servicesRepository: locator()),),
        ChangeNotifierProvider(create: (context) => InventoryProvider(inventoryRepository: locator()),),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale('es', ''),
        supportedLocales: const [
          Locale('es', ''),
        ],
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: lightTheme,
        home: SplashScreen.init(context)
      ),
    );
  }
}