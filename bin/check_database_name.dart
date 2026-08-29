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

    final results = await conn.query("SELECT DATABASE()");
    for (var r in results) {
      print("Database: ${r[0]}");
    }

    final results2 = await conn.query("SHOW TABLES");
    print("Tables:");
    for (var r in results2) {
      print("  ${r[0]}");
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
