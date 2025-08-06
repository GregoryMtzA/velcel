import 'package:dartz/dartz.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/core/errors/messages.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';

import '../../../../dependency_injections/inject_container.dart';

const String _branchEntityKey = "BRANCHENTITYKEY";

class BranchRepositoryImpl implements BranchRepository {

  SharedPreferences sharedPreferences;
  final Future<MySqlConnection> Function() createConnection;

  BranchRepositoryImpl({
    required this.sharedPreferences,
    required this.createConnection
  });

  @override
  Future<Either<Failure, List<BranchEntity>>> getAllBranchs() async {

    final mysql = await createConnection();

    try{

      Results results = await mysql.query('''SELECT nombre, numerodomicilio, ciudad, telefono, calle, tipo  FROM sucursales WHERE nombre!="ADMIN"''');
      List<BranchEntity> sucursalEntities = [];

      for(var result in results){
        sucursalEntities.add(BranchEntity(
            nombre: result["nombre"],
            numeroDomicilio: result["numerodomicilio"],
            ciudad: result["ciudad"],
            telefono: result["telefono"],
            calle: result["calle"],
            tipo: result["tipo"],
          )
        );
      }

      return Right(sucursalEntities);

    } on MySqlException catch(e){

      return Left(ServerFailure(message: e.message));

    } finally {
      await mysql.close();
    }

  }

  @override
  Future<Either<Failure, BranchEntity>> getBranch() async {

    // await sharedPreferences.remove("BRANCHENTITYKEY");

    try {
      List<String>? branchString = await sharedPreferences.getStringList(_branchEntityKey);

      if (branchString == null) return Left(CacheFailure(message: ErrorMessages.NOT_BRANCH_EXISTS));

      BranchEntity branchEntity = BranchEntity(
        nombre: branchString[0],
        calle: branchString[3],
        ciudad: branchString[4],
        numeroDomicilio: branchString[5] != "" ? int.parse(branchString[5]) : null,
        telefono: branchString[1],
        tipo: branchString[2]
      );

      return Right(branchEntity);

    } catch (e) {


      return Left(CacheFailure(message: ErrorMessages.CACHE_FAILURE_MESSAGE));

    }

  }

  @override
  Future<void> saveBranch(BranchEntity branchEntity) async {

    try{

      await sharedPreferences.setStringList(
          _branchEntityKey,
          [branchEntity.nombre, branchEntity.telefono ?? "", branchEntity.tipo ?? "", branchEntity.calle ?? "",
           branchEntity.ciudad ?? "", branchEntity.numeroDomicilio != null ? branchEntity.numeroDomicilio.toString() : ""]
      );

    } catch(e) {

    }

  }

}