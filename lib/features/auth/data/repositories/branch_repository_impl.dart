import 'package:dartz/dartz.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velcel/core/errors/failures.dart';
import 'package:velcel/core/errors/messages.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/domain/repositories/branch_repository.dart';

const String _branchEntityKey = "BRANCHENTITYKEY";

class BranchRepositoryImpl implements BranchRepository {
  SharedPreferences sharedPreferences;
  final Future<MySqlConnection> Function() createConnection;

  BranchRepositoryImpl(
      {required this.sharedPreferences, required this.createConnection});

  @override
  Future<Either<Failure, List<BranchEntity>>> getAllBranchs() async {
    final mysql = await createConnection();

    try {
      Results results = await mysql.query(
          '''SELECT nombre, nombre_ver, activa, numerodomicilio, ciudad, telefono, calle, tipo  FROM sucursales WHERE nombre!="ADMIN" AND activa=1''');
      List<BranchEntity> sucursalEntities = [];

      for (var result in results) {
        sucursalEntities.add(BranchEntity(
          nombre: result["nombre"],
          nombreVer: result["nombre_ver"],
          activa: result["activa"] == 1 || result["activa"] == true,
          numeroDomicilio: result["numerodomicilio"],
          ciudad: result["ciudad"],
          telefono: result["telefono"],
          calle: result["calle"],
          tipo: result["tipo"],
        ));
      }

      return Right(sucursalEntities);
    } on MySqlException catch (e) {
      return Left(ServerFailure(message: e.message));
    } finally {
      await mysql.close();
    }
  }

  @override
  Future<Either<Failure, BranchEntity>> getBranch() async {
    // await sharedPreferences.remove("BRANCHENTITYKEY");

    try {
      List<String>? branchString =
          await sharedPreferences.getStringList(_branchEntityKey);

      if (branchString == null)
        return Left(CacheFailure(message: ErrorMessages.NOT_BRANCH_EXISTS));

      BranchEntity branchEntity = BranchEntity(
        nombre: branchString[0],
        nombreVer: branchString[1],
        activa: branchString[2] == "true",
        telefono: branchString[3],
        tipo: branchString[4],
        calle: branchString[5],
        ciudad: branchString[6],
        numeroDomicilio:
            branchString[7] != "" ? int.parse(branchString[7]) : null,
      );

      return Right(branchEntity);
    } catch (e) {
      return Left(CacheFailure(message: ErrorMessages.CACHE_FAILURE_MESSAGE));
    }
  }

  @override
  Future<void> saveBranch(BranchEntity branchEntity) async {
    try {
      await sharedPreferences.setStringList(_branchEntityKey, [
        branchEntity.nombre,
        branchEntity.nombreVer,
        branchEntity.activa.toString(),
        branchEntity.telefono ?? "",
        branchEntity.tipo ?? "",
        branchEntity.calle ?? "",
        branchEntity.ciudad ?? "",
        branchEntity.numeroDomicilio != null
            ? branchEntity.numeroDomicilio.toString()
            : ""
      ]);
    } catch (e) {}
  }
}
