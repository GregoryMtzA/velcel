import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velcel/features/auth/domain/entities/user_entity.dart';
import 'package:velcel/features/auth/domain/repositories/user_repository.dart';

import '../../../../core/errors/failures.dart';

class UserProvider extends ChangeNotifier {

  UserRepository userRepository;

  UserProvider({
    required this.userRepository,
  });

  UserEntity? _userEntity;
  UserEntity? get userEntity => _userEntity;
  set userEntity(UserEntity? value) {
    _userEntity = value;
    notifyListeners();
  }

  Future<Either<String, List<UserEntity>>> getAllUsers(String sucursal) async {

    Either<Failure, List<UserEntity>> usecase = await userRepository.getUsersForBranch(sucursal, "Empleado");

    return usecase.fold(
      (l) => Left((l as ServerFailure).message),
      (r) => Right(r),
    );

  }

  Future<void> getUser(String usuario, String sucursal) async {

    userEntity = await userRepository.getUser(usuario, sucursal);

  }

}