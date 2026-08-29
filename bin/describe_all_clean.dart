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
    'PI_Inteligencias',
    'PI_Timer'
  ];

  for (var table in tables) {
    try {
      final conn = await MySqlConnection.connect(settings);
      final results = await conn.query(
        "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM information_schema.columns WHERE TABLE_SCHEMA = 'cl204214' AND TABLE_NAME = '$table'"
      );
      final list = results.toList();
      print("\nTable $table columns (${list.length}):");
      for (var r in list) {
        print("  Field: ${r[0]}, Type: ${r[1]}, Length: ${r[2]}");
      }
      await conn.close();
    } catch (e) {
      print("Error describing $table: $e");
    }
  }
}
