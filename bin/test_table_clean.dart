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
      final results = await conn.query("SELECT 1 FROM $table LIMIT 1");
      // Fully consume results
      await results.toList();
      print("Table $table: EXISTS");
      await conn.close();
    } catch (e) {
      print("Table $table: DOES NOT EXIST ($e)");
    }
  }
}
