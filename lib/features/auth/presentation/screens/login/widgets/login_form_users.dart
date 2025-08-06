import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';

import '../../../../../../core/app/theme.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../providers/branch_provider.dart';

class LoginFormUsers extends StatefulWidget {
  const LoginFormUsers({super.key});

  @override
  State<LoginFormUsers> createState() => _LoginFormUsersState();
}

class _LoginFormUsersState extends State<LoginFormUsers> {

  late Future<dartz.Either<String, List<UserEntity>>> _future;

  @override
  void initState() {
    UserProvider userProvider = context.read();
    BranchProvider branchProvider = context.read();
    _future = userProvider.getAllUsers(branchProvider.branch!.nombre);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.read();

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {

        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }

        dartz.Either<String, List<UserEntity>> response = snapshot.data!;

        return response.fold(
          (l) {
            return const Center(child: Text("No se encontraron usuarios"),);
          },
          (users) {
            return CustomDropdown<UserEntity>(
              validator: (value) {
                if (value == null) return "Selecciona un usuario";
              },

              hintText: "Seleccionar Usuario",
              closedHeaderPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: CustomDropdownDecoration(
                closedFillColor: Theme.of(context).colorScheme.secondary,
                closedBorderRadius: BorderRadius.circular(25),
                hintStyle: Theme.of(context).textTheme.bodySmall,
                headerStyle: Theme.of(context).textTheme.bodySmall,
                closedSuffixIcon: const Icon(Icons.keyboard_arrow_down),
              ),
              initialItem: userProvider.userEntity,
              items: users,
              onChanged: (value) {

                userProvider.userEntity = value;

              },
            );
          },
        );

      },
    );
  }
}
