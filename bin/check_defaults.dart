import 'package:mysql1/mysql1.dart';

void main() async {
  final settings = ConnectionSettings(
    host: '143.106.241.4',
    port: 3306,
    user: 'cl204214',
    db: 'cl204214',
    password: 'cl*19072008',
    timeout: const Duration(seconds: 4),
  );

  try {
    print("Connecting...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");

    final results = await conn.query(
      "SELECT COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE FROM information_schema.columns WHERE TABLE_SCHEMA = 'cl204214' AND TABLE_NAME = 'PI_Materia'"
    );
    for (var r in results) {
      print("Column: ${r[0]}, Default: ${r[1]}, Nullable: ${r[2]}");
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
