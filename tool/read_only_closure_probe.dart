import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql1/mysql1.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  final connection = await MySqlConnection.connect(
    ConnectionSettings(
      host: dotenv.env['HOST']!,
      user: dotenv.env['USER_TEST']!,
      password: dotenv.env['PASSWORD_TEST']!,
      db: dotenv.env['DB_TEST']!,
    ),
  );

  try {
    final branches = await connection.query(
      "SELECT nombre FROM sucursales WHERE UPPER(nombre) LIKE '%JIMENEZ%'",
    );
    print('JIMENEZ branches: ${branches.length}');
    for (final row in branches) {
      print('branch=${row['nombre']}');
    }

    final closures = await connection.query(
      """
      SELECT identificador, sucursal, estado, fechaapertura, fechacierre,
             total, totalconteo, diferencia
      FROM cortes
      WHERE UPPER(sucursal) LIKE '%JIMENEZ%'
      ORDER BY identificador DESC
      LIMIT 20
      """,
    );
    print('JIMENEZ closures: ${closures.length}');
    for (final row in closures) {
      print(
        'closure id=${row['identificador']} branch=${row['sucursal']} '
        'state=${row['estado']} opened=${row['fechaapertura']} '
        'closed=${row['fechacierre']} total=${row['total']} '
        'counted=${row['totalconteo']} difference=${row['diferencia']}',
      );
    }

    final sales = await connection.query(
      """
      SELECT folioCorte, COUNT(*) AS ventas, MIN(fecha) AS primera,
             MAX(fecha) AS ultima
      FROM reportesventas
      WHERE UPPER(sucursal) LIKE '%JIMENEZ%'
      GROUP BY folioCorte
      ORDER BY folioCorte DESC
      LIMIT 20
      """,
    );
    print('JIMENEZ sales groups: ${sales.length}');
    for (final row in sales) {
      print(
        'folioCorte=${row['folioCorte']} sales=${row['ventas']} '
        'first=${row['primera']} last=${row['ultima']}',
      );
    }
  } finally {
    await connection.close();
  }
}
