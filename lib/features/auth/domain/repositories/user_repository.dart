import 'package:dartz/dartz.dart';
import 'package:velcel/features/auth/domain/entities/user_entity.dart';

import '../../../../core/errors/failures.dart';

abstract class UserRepository {

  Future<Either<Failure, List<UserEntity>>> getUsersForBranch(String sucursal, String tipo);
  Future<UserEntity> getUser(String usuario, String sucursal);

}