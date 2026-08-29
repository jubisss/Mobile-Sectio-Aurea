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

  final tables = [
    'PI_Usuario',
    'PI_Materia',
    'PI_Tarefas',
    'PI_Bloco',
    'PI_Cronograma',
    'PI_Cronometro',
    'PI_Eventos',
    'PI_Flash',
    'PI_Inteligencias'
  ];

  for (var table in tables) {
    try {
      final conn = await MySqlConnection.connect(settings);
      final results = await conn.query("DESCRIBE $table");
      print("\nTable $table columns:");
      for (var r in results) {
        print("  Field: ${r[0]}, Type: ${r[1]}, Null: ${r[2]}, Key: ${r[3]}");
      }
      await conn.close();
    } catch (e) {
      print("Error describing $table: $e");
    }
  }
}
