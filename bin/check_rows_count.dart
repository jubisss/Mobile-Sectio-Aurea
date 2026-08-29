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

  try {
    print("Connecting...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");

    for (var table in tables) {
      try {
        final results = await conn.query("SELECT COUNT(*) FROM $table");
        print("Table $table: ${results.first[0]} rows");
      } catch (e) {
        print("Table $table error counting rows: $e");
      }
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
