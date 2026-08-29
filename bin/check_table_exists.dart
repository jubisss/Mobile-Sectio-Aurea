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

    try {
      await conn.query("SELECT 1 FROM PI_Inteligencia LIMIT 1");
      print("Table PI_Inteligencia EXISTS!");
    } catch (e) {
      print("Table PI_Inteligencia does not exist: $e");
    }

    try {
      await conn.query("SELECT 1 FROM PI_Inteligencias LIMIT 1");
      print("Table PI_Inteligencias EXISTS!");
    } catch (e) {
      print("Table PI_Inteligencias does not exist: $e");
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
