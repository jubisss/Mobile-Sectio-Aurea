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
    'PI_Timer',
    'PI_Timers',
    'PI_Cronometro_Timer',
    'PI_Tempo',
    'PI_Temporizador',
    'PI_Sessao',
    'PI_Sessoes',
    'PI_Registro',
    'PI_Registros',
    'PI_Usuario',
    'PI_Eventos'
  ];

  try {
    print("Connecting...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");

    for (var table in tables) {
      try {
        await conn.query("SELECT 1 FROM $table LIMIT 1");
        print("Table $table EXISTS!");
      } catch (e) {
        // Table doesn't exist
      }
    }

    await conn.close();
  } catch (e) {
    print("Error: $e");
  }
}
