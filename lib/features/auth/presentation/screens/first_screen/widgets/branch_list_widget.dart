import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';

import '../../../../../../core/app/theme.dart';
import '../../../../domain/entities/branch_entity.dart';

class BranchListWidget extends StatefulWidget {

  const BranchListWidget({super.key});

  @override
  State<BranchListWidget> createState() => _BranchListWidgetState();
}

class _BranchListWidgetState extends State<BranchListWidget> {

  late Future<dartz.Either<String, List<BranchEntity>>> _future;

  @override
  void initState() {
    BranchProvider branchProvider = context.read();
    _future = branchProvider.getAllBranchs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BranchProvider branchProvider = context.watch();

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(color: IsselColors.azulSemiOscuro,),);
        }

        dartz.Either<String, List<BranchEntity>> response = snapshot.data!;

        return response.fold(
          (l) {
            return Container(child: Text(l),);
          },
          (branchs) {
            return ListView.builder(
              itemCount: branchs.length,
              itemBuilder: (context, index) {
                BranchEntity branch = branchs[index];

                return ListTile(
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  title: Text(branch.nombre),
                  leading: const Icon(Icons.location_on_outlined),
                  selected: branch == branchProvider.branch,
                  selectedColor: IsselColors.azulSemiOscuro,
                  onTap: () {
                    branchProvider.branch = branch;
                  },
                );

              },
            );

          },
        );

      },
    );
  }
}
