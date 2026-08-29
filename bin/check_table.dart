import 'dart:convert';
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

    var tables = await conn.query("SHOW TABLES");
    print("Tables in database:");
    for (var row in tables) {
      print("Table: ${row[0]}");
    }

    try {
      var results = await conn.query("DESCRIBE PI_Inteligencias");
      print("\nColumns of PI_Inteligencias:");
      for (var r in results) {
        print("Field: ${r[0]}, Type: ${r[1]}, Null: ${r[2]}, Key: ${r[3]}");
      }
    } catch(e) {
      print("Error describing PI_Inteligencias: $e");
    }

    try {
      var results = await conn.query("DESCRIBE PI_Usuario");
      print("\nColumns of PI_Usuario:");
      for (var r in results) {
        print("Field: ${r[0]}, Type: ${r[1]}, Null: ${r[2]}, Key: ${r[3]}");
      }
    } catch(e) {
      print("Error describing PI_Usuario: $e");
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}

