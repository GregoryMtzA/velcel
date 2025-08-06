import 'package:dartz/dartz.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velcel/core/errors/exceptions.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/features/auth/domain/entities/user_entity.dart';
import 'package:velcel/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  final Future<MySqlConnection> Function() createConnection;
  SharedPreferences sharedPreferences;

  UserRepositoryImpl({
    required this.sharedPreferences,
    required this.createConnection,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getUsersForBranch(String sucursal, String tipo) async {
    final mysql = await createConnection();
    try{

      Results results = await mysql.query('''SELECT nombre, tipo, telefono, identificador, usuario, sucursal, clave FROM empleados WHERE sucursal=? AND tipo=?''', [sucursal, tipo]);
      List<UserEntity> usersEntities = [];

      for(var result in results){
        usersEntities.add(UserEntity(
            id: result["identificador"],
            clave: result["clave"],
            sucursal: result["clave"],
            usuario: result["usuario"],
            tipo: result["tipo"],
            telefono: result["telefono"],
            nombre: result["nombre"],
          )
        );
      }

      return Right(usersEntities);

    } catch(e){

      return Left(ServerFailure(message: "LOGIN - Contacte a soporte"));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<UserEntity> getUser(String usuario, String sucursal) async {
    final mysql = await createConnection();

    try{

      Results results = await mysql.query('''SELECT nombre, tipo, telefono, identificador, usuario, sucursal, clave FROM empleados WHERE sucursal=? AND usuario=?''', [sucursal, usuario]);
      List<UserEntity> usersEntities = [];

      var result = results.first;

      UserEntity userEntity = UserEntity(
        id: result["identificador"],
        clave: result["clave"],
        sucursal: result["clave"],
        usuario: result["usuario"],
        tipo: result["tipo"],
        telefono: result["telefono"],
        nombre: result["nombre"],
      );


      return userEntity;

    } catch(e){

      throw ServerException(message: "Error, Contacte a soporte");

    } finally {
      await mysql.close();
    }

  }

}