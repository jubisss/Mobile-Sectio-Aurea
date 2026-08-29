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
      final results = await conn.query("SELECT * FROM PI_Usuario LIMIT 1");
      print("\nPI_Usuario fields count: ${results.fields.length}");
      for (var f in results.fields) {
        print("  Field: ${f.name}, Type: ${f.type}");
      }
    } catch (e) {
      print("Error querying PI_Usuario: $e");
    }

    try {
      final results = await conn.query("SELECT * FROM PI_Eventos LIMIT 1");
      print("\nPI_Eventos fields count: ${results.fields.length}");
      for (var f in results.fields) {
        print("  Field: ${f.name}, Type: ${f.type}");
      }
    } catch (e) {
      print("Error querying PI_Eventos: $e");
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
