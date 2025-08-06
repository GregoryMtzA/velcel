import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> createConnection(ConnectionSettings settings) async {
  return await MySqlConnection.connect(settings);
}