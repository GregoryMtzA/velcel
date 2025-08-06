import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/auth/presentation/screens/first_screen/screen.dart';
import 'package:velcel/features/auth/presentation/screens/splash_screen/provider.dart';
import 'package:velcel/features/store/domain/entities/cash_register_entity.dart';
import 'package:velcel/features/store/presentation/providers/cash_register_provider.dart';

import '../../../../../core/app/navigation.dart';
import '../../../../store/presentation/screens/home_screen/screen.dart';
import '../login/screen.dart';

class SplashScreen extends StatelessWidget {

  SplashScreen._();

  static Widget init(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashScreenProvider(),)
      ],
      builder: (context, child) => SplashScreen._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AuthProviderApp auth = context.read();
    BranchProvider branchProvider = context.read();

    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([branchProvider.getBranch(), Future.delayed(const Duration(seconds: 1))]),
        builder: (context, snapshot) {

          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
            return const LogoWidget();
          }

          dartz.Either<String, BranchEntity> branchResult = snapshot.data![0];

          branchResult.fold(
            (l) {
              WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {

                NavigationService.navigateTo(context, FirstScreen());
              });
            },
            (branch) async {

              WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) async {

                bool result = await openCashRegister(context, branch.nombre);

                if (result) {
                  NavigationService.navigateTo(context, HomeScreen.init(context));
                } else {
                  NavigationService.navigateTo(context, const LoginScreen());
                }

              },);

            }
          );

          return Center(
            child: Hero(
              tag: "heroLogo",
              child: Image.asset("assets/logos/velcel.png", width: MediaQuery.of(context).size.height * 0.45,)
            ),
          );

        },
      ),
    );
  }

  Future<bool> openCashRegister(BuildContext context, String branchName) async {
    CashRegisterProvider cashRegisterProvider = context.read();
    UserProvider userProvider = context.read();

    dartz.Either<String, CashRegisterEntity?> response = await cashRegisterProvider.openCashRegister(branchName);

    return response.fold(
      (l) {
        SnackbarService.showIncorrect(context, "Error", l);
        return false;
      },
      (r) async {
        if (r == null) return false;

        /// Obtener usuario

        await userProvider.getUser(r.usuario!, branchName);

        return true;
      },
    );

  }

}

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key});

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    //Implement animation here
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    return FadeTransition(
      opacity: _animation,
      child: Center(
        child: Image.asset("assets/logos/velcel.png", width: MediaQuery.of(context).size.height * 0.45,),
      ),
    );
  }
}
