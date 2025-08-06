import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';

import '../../../../core/errors/failures.dart';

class BranchProvider extends ChangeNotifier {

  BranchRepository branchRepository;

  BranchProvider({
    required this.branchRepository,
  });
  
  BranchEntity? _branch;
  BranchEntity? get branch => _branch;
  set branch(BranchEntity? value) {
    _branch = value;
    notifyListeners();
  }

  List<BranchEntity> allBranchs = [];

  Future<void> saveBranch() async => await branchRepository.saveBranch(branch!);

  Future<Either<String, BranchEntity>> getBranch() async {

    Either<Failure, BranchEntity> usecase = await branchRepository.getBranch();

    return usecase.fold(
      (l) {
        return Left( (l as CacheFailure).message );
      },
      (newBranch) {
        branch = newBranch;
        notifyListeners();
        return Right(branch!);
      },
    );

  }

  Future<Either<String, List<BranchEntity>>> getAllBranchs() async {

    Either<Failure, List<BranchEntity>> usecase = await branchRepository.getAllBranchs();

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (newBranchs) {
        allBranchs = newBranchs;
        notifyListeners();
        return Right(allBranchs);
      },
    );

  }
  
}