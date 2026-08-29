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
    print("Connecting for PI_Cronometro...");
    final conn1 = await MySqlConnection.connect(settings);
    final results1 = await conn1.query(
      "SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.columns WHERE TABLE_SCHEMA = 'cl204214' AND TABLE_NAME = 'PI_Cronometro'"
    );
    print("PI_Cronometro columns:");
    for (var r in results1) {
      print("  ${r[0]} - ${r[1]}");
    }
    await conn1.close();
  } catch (e) {
    print("Error PI_Cronometro: $e");
  }

  try {
    print("Connecting for PI_Inteligencias...");
    final conn2 = await MySqlConnection.connect(settings);
    final results2 = await conn2.query(
      "SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.columns WHERE TABLE_SCHEMA = 'cl204214' AND TABLE_NAME = 'PI_Inteligencias'"
    );
    print("PI_Inteligencias columns:");
    for (var r in results2) {
      print("  ${r[0]} - ${r[1]}");
    }
    await conn2.close();
  } catch (e) {
    print("Error PI_Inteligencias: $e");
  }
}
