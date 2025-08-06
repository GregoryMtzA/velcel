import 'package:dartz/dartz.dart';
import 'package:velcel/core/errors/failures.dart';

import '../entities/branch_entity.dart';

abstract class BranchRepository {

  Future<Either<Failure, List<BranchEntity>>> getAllBranchs();
  Future<void> saveBranch(BranchEntity branchEntity);
  Future<Either<Failure, BranchEntity>> getBranch();

}