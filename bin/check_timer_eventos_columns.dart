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
    print("Connecting for PI_Timer...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");
    var results = await conn.query("DESCRIBE PI_Timer");
    print("\nColumns of PI_Timer:");
    for (var r in results) {
      print("  ${r[0]} (${r[1]})");
    }
    await conn.close();
  } catch (e) {
    print("Error describing PI_Timer: $e");
  }

  try {
    print("Connecting for PI_Eventos...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");
    var results = await conn.query("DESCRIBE PI_Eventos");
    print("\nColumns of PI_Eventos:");
    for (var r in results) {
      print("  ${r[0]} (${r[1]})");
    }
    await conn.close();
  } catch (e) {
    print("Error describing PI_Eventos: $e");
  }
}
