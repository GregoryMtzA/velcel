import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/core/app/theme.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/screens/first_screen/widgets/branch_list_widget.dart';
import 'package:velcel/features/auth/presentation/screens/login/screen.dart';
import 'package:velcel/features/auth/presentation/screens/splash_screen/splash_screen.dart';
import 'package:velcel/utils/sucursales.dart';

class SecondPageSelect extends StatefulWidget {
  const SecondPageSelect({super.key});

  @override
  State<SecondPageSelect> createState() => _SecondPageSelectState();
}

class _SecondPageSelectState extends State<SecondPageSelect> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  bool showAnimation = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _controller.addStatusListener((status) {

      if (status == AnimationStatus.forward){
        showAnimation = true;
        setState(() {});
      } else {
        showAnimation = false;
        setState(() {});
      }

    },);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BranchProvider branchProvider = context.watch();

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Stack(
      children: [

        /// Lista de sucursales
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Text(
              "Seleccionar Surcursal",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const Expanded(
              child: BranchListWidget(),
            ),

            const SizedBox(height: 80,),

          ],
        ),

        /// Boton Seleccionar Sucursal
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          height: 60,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(IsselColors.azulSemiOscuro),
              shape: const WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide.none))
            ),
            onPressed: () async => selectBranchs(),
            child: Text("Seleccionar", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),),
          ),
        ),

        /// Lottie
        if (showAnimation)
          Center(
            child: Lottie.asset(
              controller: _controller,
              "assets/lotties/confetti.json",
              width: isPortrait ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height,
              height: isPortrait ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              repeat: false
            ),
          ),

      ],
    );
  }

  Future<void> selectBranchs() async{
    BranchProvider branchProvider = context.read();

    if (branchProvider.branch == null){
      SnackbarService.showIncorrect(context, "Sucursal", "Selecciona una sucursal");
      return;
    }

    DialogService.confirmDialog(
      context: context,
      title: branchProvider.branch!.nombre,
      textButton: "Confirmar",
      onAccept: () async {

        await branchProvider.saveBranch();

        var ticket = _controller.forward();
        await ticket.whenComplete(() => _controller.reset(),);

        await NavigationService.navigateTo(context, SplashScreen.init(context));
      },
    );

  }

}
