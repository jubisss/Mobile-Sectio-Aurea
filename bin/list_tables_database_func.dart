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

    var dbNameRow = await conn.query("SELECT DATABASE()");
    var dbName = dbNameRow.first[0];
    print("Current Database: $dbName");

    final results = await conn.query(
      "SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA = DATABASE()"
    );
    print("Tables found: ${results.length}");
    for (var r in results) {
      print("  ${r[0]}");
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
