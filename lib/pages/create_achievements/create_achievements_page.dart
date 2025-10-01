import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateAchievementsPage extends StatefulWidget {
  const CreateAchievementsPage({super.key});

  @override
  State<CreateAchievementsPage> createState() => _CreateAchievementsPageState();
}

class _CreateAchievementsPageState extends State<CreateAchievementsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => crearLogroConJugadores(
                        id: 'victory_1',
                        name: 'El pochiti',
                        description: 'Gana una partida',
                        total: 1,
                        category: 'Victorias',
                        order: 1,
                      ),
                  child: const Text('CREAR LOGRO')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => actualizarTodosLosLogros(),
                  child: const Text('ACTUALIZAR LOGROS')),
            ],
          )
        ],
      ),
    );
  }
}

Future<void> crearLogroConJugadores({
  required String id,
  required String name,
  required String description,
  required String category,
  int? total,
  required int order,
}) async {
  await FirebaseFirestore.instance.collection('achievements').doc(id).set({
    "name": name,
    "description": description,
    "category": category,
    "order": order,
    "objective": total,
  });
}

Future<void> actualizarTodosLosLogros() async {
  final playersSnapshot =
      await FirebaseFirestore.instance.collection('players').get();
  final achievementsSnapshot =
      await FirebaseFirestore.instance.collection('achievements').get();

  final allPlayers = playersSnapshot.docs.map((doc) => doc.data()).toList();

  for (var achievementDoc in achievementsSnapshot.docs) {
    final achievementData = achievementDoc.data();
    final category = achievementData['category'];
    final objective = achievementData['objective'];
    List<Map<String, dynamic>> playersList =
        List<Map<String, dynamic>>.from(achievementData['players'] ?? []);

    // Asegúrate de que todos los jugadores están en el array
    for (var playerData in allPlayers) {
      final playerName = playerData['playerName'];
      int playerIndex = playersList.indexWhere((p) => p['name'] == playerName);
      if (playerIndex == -1) {
        playersList.add({
          'name': playerName,
          'progreso': 0,
          'completado': false,
          'fecha': null,
        });
        playerIndex = playersList.length - 1;
      }

      var playerAchievement = playersList[playerIndex];

      // Si ya está completado, no hacer nada
      if (playerAchievement['completado'] == true) continue;

      int progreso = 0;
      bool completado = false;

      if (category == 'Victorias') {
        progreso = playerData['winGames'] ?? 0;
        completado = progreso >= objective;
      }
      // ...otros tipos de logros

      if (playerAchievement['progreso'] != progreso ||
          playerAchievement['completado'] != completado) {
        playersList[playerIndex] = {
          ...playerAchievement,
          'progreso': progreso,
          'completado': completado,
          'fecha': completado
              ? DateTime.now().toIso8601String()
              : playerAchievement['fecha'],
        };
      }
    }

    // Actualiza el array completo una sola vez por logro
    await achievementDoc.reference.update({'players': playersList});
  }
}
