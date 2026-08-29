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

    print("Setting lock wait timeout to 2 seconds...");
    await conn.query("SET lock_wait_timeout = 2");

    print("Trying to drop PI_Inteligencias...");
    try {
      await conn.query("DROP TABLE IF EXISTS PI_Inteligencias");
      print("SUCCESS!");
    } catch (e) {
      print("Error dropping PI_Inteligencias: $e");
    }

    await conn.close();
  } catch (e) {
    print("Connection error: $e");
  }
}
