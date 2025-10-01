import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/go_back_button.dart';

class GameRegisterTotalDetailPage extends StatelessWidget {
  final List<String> players;
  const GameRegisterTotalDetailPage({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final games = FirebaseFirestore.instance.collection('games');
    Stream<QuerySnapshot> gamesStream;
    if (players.isEmpty) {
      gamesStream = games.where('status', isEqualTo: 'finished').snapshots();
    } else {
      gamesStream = games
          .where('players', arrayContainsAny: players)
          .where('status', isEqualTo: 'finished')
          .snapshots();
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromARGB(255, 54, 18, 77),
                CustomColors.backgroundColor
              ],
              stops: [0.0, 0.9],
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título y fecha
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalle de partidas',
                        style: TextStyle(
                          color: CustomColors.whiteColor,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                StreamBuilder<QuerySnapshot>(
                  stream: gamesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('No hay partidas.'));
                    }

                    // Filtrado exacto en el cliente si hay jugadores seleccionados
                    final docs = players.isEmpty
                        ? snapshot.data!.docs
                        : snapshot.data!.docs.where((doc) {
                            final docPlayers =
                                List<String>.from(doc['players'] ?? []);
                            final normalizedDocPlayers = docPlayers
                                .map((e) => e.trim().toLowerCase())
                                .toSet();
                            final normalizedSelected = players
                                .map((e) => e.trim().toLowerCase())
                                .toSet();
                            return normalizedDocPlayers.length ==
                                    normalizedSelected.length &&
                                normalizedDocPlayers
                                    .containsAll(normalizedSelected);
                          }).toList();

                    if (docs.isEmpty) {
                      return const Center(
                          child: Text('No hay partidas para ese filtro.'));
                    }

                    // Estadísticas
                    int totalGames = docs.length;
                    final Set<String> allPlayers = {};
                    Map<String, int> totalPoints = {};
                    Map<String, int> maxPoints = {};
                    Map<String, int> minPoints = {};
                    Map<String, int> victories = {};
                    Map<String, int> totalAciertos = {};
                    Map<String, int> totalRondas = {};
                    Map<String, int> maxRachaAciertos = {};
                    Map<String, int> maxRachaFallos = {};
                    Map<String, double> avgPoints = {};
                    Map<String, double> avgAcierto = {};

                    // Recolecta todos los jugadores y calcula estadísticas
                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final playersList =
                          List<String>.from(data['players'] ?? []);
                      allPlayers.addAll(playersList);

                      // Suma puntos por jugador
                      final scores =
                          Map<String, dynamic>.from(data['scores'] ?? {});
                      for (var player in playersList) {
                        final score = (scores[player] ?? 0) as int;
                        totalPoints[player] =
                            (totalPoints[player] ?? 0) + score;
                        maxPoints[player] = maxPoints.containsKey(player)
                            ? (score > maxPoints[player]!
                                ? score
                                : maxPoints[player]!)
                            : score;
                        minPoints[player] = minPoints.containsKey(player)
                            ? (score < minPoints[player]!
                                ? score
                                : minPoints[player]!)
                            : score;
                      }

                      // Cuenta victorias
                      final winners = List<String>.from(data['winner'] ?? []);
                      for (var winner in winners) {
                        victories[winner] = (victories[winner] ?? 0) + 1;
                      }

                      // Aciertos y rachas
                      final votos =
                          Map<String, dynamic>.from(data['votos'] ?? {});
                      final bazas =
                          Map<String, dynamic>.from(data['bazas'] ?? {});
                      for (final player in playersList) {
                        final votosPlayer =
                            List<dynamic>.from(votos[player] ?? []);
                        final bazasPlayer =
                            List<dynamic>.from(bazas[player] ?? []);
                        int aciertos = 0;
                        int rachaAciertos = 0;
                        int rachaFallos = 0;
                        int maxAciertos = 0;
                        int maxFallos = 0;

                        for (int i = 0; i < votosPlayer.length; i++) {
                          if (i < bazasPlayer.length &&
                              votosPlayer[i] == bazasPlayer[i]) {
                            aciertos++;
                            rachaAciertos++;
                            if (rachaAciertos > maxAciertos) {
                              maxAciertos = rachaAciertos;
                            }
                            rachaFallos = 0;
                          } else {
                            rachaFallos++;
                            if (rachaFallos > maxFallos) {
                              maxFallos = rachaFallos;
                            }
                            rachaAciertos = 0;
                          }
                        }
                        totalAciertos[player] =
                            (totalAciertos[player] ?? 0) + aciertos;
                        totalRondas[player] =
                            (totalRondas[player] ?? 0) + votosPlayer.length;
                        if (maxAciertos > (maxRachaAciertos[player] ?? 0)) {
                          maxRachaAciertos[player] = maxAciertos;
                        }
                        if (maxFallos > (maxRachaFallos[player] ?? 0)) {
                          maxRachaFallos[player] = maxFallos;
                        }
                      }
                    }

                    // Medias
                    Map<String, int> partidasJugadas = {};
                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final playersList =
                          List<String>.from(data['players'] ?? []);
                      for (var player in playersList) {
                        partidasJugadas[player] =
                            (partidasJugadas[player] ?? 0) + 1;
                        // Suma el score final de la partida
                      }
                    }
                    avgPoints = {
                      for (var p in totalPoints.keys)
                        p: partidasJugadas[p]! > 0
                            ? totalPoints[p]! / partidasJugadas[p]!
                            : 0
                    };
                    avgAcierto = {
                      for (var p in allPlayers)
                        p: totalRondas[p]! > 0
                            ? (totalAciertos[p]! * 100) / totalRondas[p]!
                            : 0
                    };
                    // Encuentra el valor máximo de cada estadística
                    final maxTotalPuntos = totalPoints.entries.isNotEmpty
                        ? totalPoints.values.reduce((max))
                        : null;
                    final maxMedia = avgPoints.entries.isNotEmpty
                        ? avgPoints.values.reduce((max))
                        : null;
                    final maxPuntos = maxPoints.entries.isNotEmpty
                        ? maxPoints.values.reduce((max))
                        : null;
                    final minPuntos = minPoints.entries.isNotEmpty
                        ? minPoints.values.reduce((min))
                        : null;
                    final maxRachaAciertosVal =
                        maxRachaAciertos.entries.isNotEmpty
                            ? maxRachaAciertos.values.reduce((max))
                            : null;
                    final maxRachaFallosVal = maxRachaFallos.entries.isNotEmpty
                        ? maxRachaFallos.values.reduce((max))
                        : null;
                    final maxPartidas = partidasJugadas.entries.isNotEmpty
                        ? partidasJugadas.values.reduce((max))
                        : null;
                    final maxVictorias = victories.entries.isNotEmpty
                        ? victories.values.reduce((max))
                        : null;
                    final maxAcierto = avgAcierto.entries.isNotEmpty
                        ? avgAcierto.values.reduce((max))
                        : null;

                    // Encuentra el mejor jugador de cada estadística
                    List<String>? maxTotalPuntosPlayer = totalPoints.entries
                        .where((e) => e.value == maxTotalPuntos)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxMediaPlayer = avgPoints.entries
                        .where((e) => e.value == maxMedia)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxPuntosPlayer = maxPoints.entries
                        .where((e) => e.value == maxPuntos)
                        .map((e) => e.key)
                        .toList();
                    List<String>? minPuntosPlayer = minPoints.entries
                        .where((e) => e.value == minPuntos)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxRachaAciertosPlayer = maxRachaAciertos
                        .entries
                        .where((e) => e.value == maxRachaAciertosVal)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxRachaFallosPlayer = maxRachaFallos.entries
                        .where((e) => e.value == maxRachaFallosVal)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxPartidasPlayer = partidasJugadas.entries
                        .where((e) => e.value == maxPartidas)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxVictoriasPlayer = victories.entries
                        .where((e) => e.value == maxVictorias)
                        .map((e) => e.key)
                        .toList();
                    List<String>? maxAciertoPlayer = avgAcierto.entries
                        .where((e) => e.value == maxAcierto)
                        .map((e) => e.key)
                        .toList();

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            // Card de mejores
                            Card(
                              elevation: 2,
                              surfaceTintColor: CustomColors.backgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🏆 Mejores de cada estadística',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CustomColors.secondaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Divider(
                                        thickness: 1,
                                        color: CustomColors.secondaryColor),
                                    Text(
                                        'Más partidas jugadas:  ${maxPartidasPlayer.join(', ')} ($maxPartidas)'),
                                    Text(
                                        'Más victorias:  ${maxVictoriasPlayer.join(', ')} ($maxVictorias)'),
                                    Text(
                                        'Más puntos totales:  ${maxTotalPuntosPlayer.join(', ')} ($maxTotalPuntos)'),
                                    Text(
                                        'Mejor media:  ${maxMediaPlayer.join(', ')} (${maxMedia != null ? maxMedia.toStringAsFixed(1) : '-'})'),
                                    Text(
                                        'Puntuación más alta:  ${maxPuntosPlayer.join(', ')} ($maxPuntos)'),
                                    Text(
                                        'Puntuación más baja:  ${minPuntosPlayer.join(', ')} ($minPuntos)'),
                                    Text(
                                        'Mayor % de acierto:  ${maxAciertoPlayer.join(', ')} (${maxAcierto != null ? maxAcierto.toStringAsFixed(1) : '-'}%)'),
                                    Text(
                                        'Mayor racha de aciertos:  ${maxRachaAciertosPlayer.join(', ')} ($maxRachaAciertosVal)'),
                                    Text(
                                        'Mayor racha de fallos:  ${maxRachaFallosPlayer.join(', ')} ($maxRachaFallosVal)'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView(
                                children: [
                                  Text(
                                    players.isEmpty
                                        ? 'Resumen de todas las partidas'
                                        : 'Resumen de partidas con: ${players.join(", ")}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Partidas jugadas: $totalGames'),
                                  const Divider(),
                                  ...totalPoints.keys.map(
                                    (player) {
                                      final maxPartidas = partidasJugadas
                                              .values.isNotEmpty
                                          ? partidasJugadas.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      final maxVictorias = victories
                                              .values.isNotEmpty
                                          ? victories.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      final maxPuntos = totalPoints
                                              .values.isNotEmpty
                                          ? totalPoints.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      final maxMedia = avgPoints
                                              .values.isNotEmpty
                                          ? avgPoints.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      final maxPuntuacion = maxPoints
                                              .values.isNotEmpty
                                          ? maxPoints.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      final minPuntuacion = minPoints
                                              .values.isNotEmpty
                                          ? minPoints.values
                                              .reduce((a, b) => a < b ? a : b)
                                          : 0;
                                      final maxAcierto = avgAcierto
                                              .values.isNotEmpty
                                          ? avgAcierto.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      final maxRachaAciertosValor =
                                          maxRachaAciertos.values.isNotEmpty
                                              ? maxRachaAciertos.values.reduce(
                                                  (a, b) => a > b ? a : b)
                                              : 0;
                                      final maxRachaFallosValor = maxRachaFallos
                                              .values.isNotEmpty
                                          ? maxRachaFallos.values
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0;
                                      return Card(
                                        elevation: 2,
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        surfaceTintColor:
                                            CustomColors.backgroundColor,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 12.0),
                                          child: Column(
                                            spacing: 4,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Jugador: $player',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Partidas jugadas:  '),
                                                    TextSpan(
                                                      text:
                                                          '${partidasJugadas[player] ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            (partidasJugadas[
                                                                            player] ??
                                                                        0) ==
                                                                    maxPartidas
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text: '  Victorias:  '),
                                                    TextSpan(
                                                      text:
                                                          '${victories[player] ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            (victories[player] ??
                                                                        0) ==
                                                                    maxVictorias
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Puntos totales:  '),
                                                    TextSpan(
                                                      text:
                                                          '${totalPoints[player]}',
                                                      style: TextStyle(
                                                        fontWeight: totalPoints[
                                                                    player] ==
                                                                maxPuntos
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Media de puntos:  '),
                                                    TextSpan(
                                                      text: avgPoints[player]!
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                        fontWeight: avgPoints[
                                                                    player] ==
                                                                maxMedia
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Puntuación más alta:  '),
                                                    TextSpan(
                                                      text:
                                                          '${maxPoints[player]}',
                                                      style: TextStyle(
                                                        fontWeight: maxPoints[
                                                                    player] ==
                                                                maxPuntuacion
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Puntuación más baja:  '),
                                                    TextSpan(
                                                      text:
                                                          '${minPoints[player]}',
                                                      style: TextStyle(
                                                        fontWeight: minPoints[
                                                                    player] ==
                                                                minPuntuacion
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Porcentaje de acierto:  '),
                                                    TextSpan(
                                                      text:
                                                          '${avgAcierto[player]!.toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                        fontWeight: avgAcierto[
                                                                    player] ==
                                                                maxAcierto
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Mayor racha de aciertos:  '),
                                                    TextSpan(
                                                      text:
                                                          '${maxRachaAciertos[player] ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight: (maxRachaAciertos[
                                                                        player] ??
                                                                    0) ==
                                                                maxRachaAciertosValor
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: CustomColors
                                                          .whiteColor),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            '  Mayor racha de fallos:  '),
                                                    TextSpan(
                                                      text:
                                                          '${maxRachaFallos[player] ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight: (maxRachaFallos[
                                                                        player] ??
                                                                    0) ==
                                                                maxRachaFallosValor
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            const GoBackButton(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
