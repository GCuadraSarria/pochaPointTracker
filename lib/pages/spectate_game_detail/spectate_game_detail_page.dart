import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocha_points_tracker/pages/create_achievements/achievement_overlay.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/detail_spectate_chart.dart';
import 'package:pocha_points_tracker/widgets/go_back_button.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SpectateGameDetailPage extends StatefulWidget {
  final String gameId;
  const SpectateGameDetailPage({super.key, required this.gameId});

  @override
  State<SpectateGameDetailPage> createState() => _SpectateGameDetailPageState();
}

class _SpectateGameDetailPageState extends State<SpectateGameDetailPage> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    final currentPlayersProvider = context.read<CurrentPlayers>();

    currentPlayersProvider.addListener(() {
      if (currentPlayersProvider.showAchievement) {
        final name = currentPlayersProvider.achievementPlayer;
        final achievementName = currentPlayersProvider.achievementName;
        final achievementDescription =
            currentPlayersProvider.achievementDescription;

        Future.microtask(() {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AchievementOverlay(
              name: name,
              achievementName: achievementName,
              achievementDescription: achievementDescription,
              onClose: () {
                currentPlayersProvider.resetAchievementOverlay();
              },
            ),
          );
          currentPlayersProvider.resetAchievementOverlay();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // avoid blackscreen
    WakelockPlus.enable();

    // provider
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          List<String> getPlayerList() =>
              List<String>.from(gameData['players'] ?? []);

          final totalScore =
              Map<String, dynamic>.from(gameData['totalScore'] ?? {});
          final bazas = Map<String, dynamic>.from(gameData['bazas'] ?? {});
          final votos = Map<String, dynamic>.from(gameData['votos'] ?? {});
          final players = getPlayerList();
          // Calcular número de rondas
          final int numRondas = gameData['round'] ?? 1;
          String getCards() {
            switch (numRondas) {
              case 8:
                return '7 cartas';
              case 9:
                return '6 cartas';
              case 10:
                return '5 cartas';
              case 11:
                return '4 cartas';
              case 12:
                return '3 cartas';
              case 13:
                return '2 cartas';
              case 14:
                return '1 carta';
              case 15:
                return '1 carta (ciega)';
              default:
                return numRondas == 1
                    ? '$numRondas carta'
                    : '$numRondas cartas';
            }
          }

          // Calcular estadísticas por jugador
          List<Map<String, dynamic>> playerStats = [];

          for (final player in players) {
            final List<dynamic> scores =
                List<dynamic>.from(totalScore[player] ?? []);
            final List<dynamic> votosPlayer =
                List<dynamic>.from(votos[player] ?? []);
            final List<dynamic> bazasPlayer =
                List<dynamic>.from(bazas[player] ?? []);
            int aciertos = 0;
            int maxRachaAciertos = 0;
            int maxRachaFallos = 0;
            int rachaAciertos = 0;
            int rachaFallos = 0;

            for (int i = 0; i < votosPlayer.length; i++) {
              if (i < bazasPlayer.length && votosPlayer[i] == bazasPlayer[i]) {
                aciertos++;
                rachaAciertos++;
                maxRachaAciertos = rachaAciertos > maxRachaAciertos
                    ? rachaAciertos
                    : maxRachaAciertos;
                rachaFallos = 0;
              } else {
                rachaFallos++;
                maxRachaFallos =
                    rachaFallos > maxRachaFallos ? rachaFallos : maxRachaFallos;
                rachaAciertos = 0;
              }
            }
            double porcentajeAcierto =
                votosPlayer.isEmpty ? 0 : (aciertos * 100) / votosPlayer.length;
            playerStats.add({
              'player': player,
              'puntos': scores.isNotEmpty ? scores.last : 0,
              'acierto': porcentajeAcierto,
              'rachaAciertos': maxRachaAciertos,
              'rachaFallos': maxRachaFallos,
            });
          }
          final currentVote =
              Map<String, dynamic>.from(gameData['currentVotes'] ?? {});
          final currentBaz =
              Map<String, dynamic>.from(gameData['currentBazas'] ?? {});

          List<String> toStringListFromFirestore(dynamic value) {
            if (value is List) return value.cast<String>();
            if (value is Map) {
              final map = Map<String, dynamic>.from(value);
              final keys = map.keys.map((k) => int.tryParse(k) ?? 0).toList()
                ..sort();
              return keys.map((k) => map['$k']?.toString() ?? '').toList();
            }
            return [];
          }

          final List<String> winners =
              toStringListFromFirestore(gameData['winner']);
          final List<String> allPlayers =
              playerStats.map((s) => s['player'] as String).toList();
          final List<String> nonWinners =
              allPlayers.where((p) => !winners.contains(p)).toList();
          final startDate = gameData['startDate'];
          DateTime? startDateTime;
          if (startDate is Timestamp) {
            startDateTime = startDate.toDate();
          } else if (startDate is String) {
            startDateTime = DateTime.tryParse(startDate);
          }
          final now = DateTime.now();
          final duration =
              startDateTime != null ? now.difference(startDateTime) : null;
          String elapsed;
          if (duration == null) {
            elapsed = '';
          } else {
            final hours = duration.inHours;
            final minutes = duration.inMinutes % 60;
            final seconds = duration.inSeconds % 60;

            if (hours > 0) {
              elapsed = '$hours h $minutes min $seconds seg';
            } else if (minutes > 0) {
              elapsed = '$minutes min $seconds seg';
            } else {
              elapsed = '$seconds seg';
            }
          }
          final dealer = gameData['dealer'] ?? '-';
          return Consumer<CurrentPlayers>(builder: (context, value, child) {
            return SafeArea(
              child: Stack(
                children: [
                  Scaffold(
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
                        padding: const EdgeInsets.only(
                            left: 12.0, top: 24.0, bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Título y fecha
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Detalle de partida',
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Tiempo alineado a la izquierda
                                  Row(
                                    children: [
                                      Text(
                                        elapsed,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      // El Expanded empuja el texto a la izquierda
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Centrado: Reparte y getCards
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Reparte: $dealer',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      Text(
                                        getCards(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 22),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            DataCardUp(
                                players: players,
                                votos: votos,
                                bazas: bazas,
                                currentVote: currentVote,
                                currentBaz: currentBaz,
                                totalScore: totalScore,
                                ronda: numRondas - 1),
                            const SizedBox(height: 10.0),
                            // Gráfica
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      // Chart
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width: numRondas * 40 >
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width
                                              ? numRondas * 40
                                              : MediaQuery.of(context)
                                                  .size
                                                  .width,
                                          child: DetailSpectateChart(
                                              gameData: gameData),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Leyenda
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 16,
                                        runSpacing: 4,
                                        children: players.map((player) {
                                          final index = players.indexOf(player);
                                          return Row(
                                            spacing: 4,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color:
                                                      CustomColors.lineColors[
                                                          index %
                                                              CustomColors
                                                                  .lineColors
                                                                  .length],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                ),
                                              ),
                                              Text(
                                                player,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 16),
                                      // Tabla resumen por jugador

                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: const [
                                            DataColumn(label: Text('Jugador')),
                                            DataColumn(label: Text('Puntos')),
                                            DataColumn(
                                                label: Text('% Acierto')),
                                            DataColumn(label: Text('Racha +')),
                                            DataColumn(label: Text('Racha -')),
                                          ],
                                          rows: playerStats.map((stats) {
                                            final playerName = stats['player'];
                                            final isWinner =
                                                winners.contains(playerName);

                                            int nonWinnerRank = isWinner
                                                ? 0
                                                : winners.length +
                                                    nonWinners
                                                        .indexOf(playerName) +
                                                    1;

                                            return DataRow(cells: [
                                              DataCell(Row(
                                                children: [
                                                  isWinner
                                                      ? SvgPicture.asset(
                                                          'lib/assets/images/mini_cup.svg',
                                                          height: 18.0,
                                                          width: 18.0,
                                                          semanticsLabel:
                                                              'mini cup',
                                                        )
                                                      : Text(
                                                          '#$nonWinnerRank',
                                                          style:
                                                              const TextStyle(
                                                            color: CustomColors
                                                                .whiteColor,
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.w200,
                                                          ),
                                                        ),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Text(
                                                      playerName,
                                                      style: const TextStyle(
                                                        color: CustomColors
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                              DataCell(Text(
                                                  stats['puntos'].toString())),
                                              DataCell(Text(
                                                  '${stats['acierto'].toStringAsFixed(1)}%')),
                                              DataCell(Text(
                                                  stats['rachaAciertos']
                                                      .toString())),
                                              DataCell(Text(stats['rachaFallos']
                                                  .toString())),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Detalle por ronda
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: numRondas,
                                        itemBuilder: (context, ronda) {
                                          return DataCard(
                                              players: players,
                                              votos: votos,
                                              bazas: bazas,
                                              totalScore: totalScore,
                                              ronda: ronda);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Botón atrás
                            const GoBackButton()
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (currentPlayersProvider.showAchievement)
                    AchievementOverlay(
                        name: currentPlayersProvider.achievementPlayer,
                        achievementName: currentPlayersProvider.achievementName,
                        achievementDescription:
                            currentPlayersProvider.achievementDescription,
                        onClose: () {
                          currentPlayersProvider.resetAchievementOverlay();
                        })
                ],
              ),
            );
          });
        });
  }
}

class DataCardUp extends StatelessWidget {
  const DataCardUp({
    super.key,
    required this.players,
    required this.votos,
    required this.bazas,
    required this.currentVote,
    required this.currentBaz,
    required this.totalScore,
    required this.ronda,
  });

  final List<String> players;
  final Map<String, dynamic> votos;
  final Map<String, dynamic> bazas;
  final Map<String, dynamic> currentVote;
  final Map<String, dynamic> currentBaz;
  final Map<String, dynamic> totalScore;
  final int ronda;

  @override
  Widget build(BuildContext context) {
    Widget buildStreakIcon(int streak) {
      if (streak < 3) {
        return const SizedBox.shrink();
      } else if (streak == 3) {
        return const Icon(Icons.temple_hindu, size: 20, color: Colors.amber);
      } else if (streak == 4) {
        return const Icon(Icons.radio, size: 20, color: Colors.orange);
      } else if (streak == 5) {
        return const Icon(Icons.hourglass_bottom,
            size: 20, color: Colors.deepOrangeAccent);
      } else if (streak == 6) {
        return const Icon(Icons.car_crash, size: 20, color: Colors.amber);
      } else if (streak == 7) {
        return const Icon(Icons.safety_check, size: 20, color: Colors.orange);
      } else if (streak == 8) {
        return const Icon(Icons.bolt, size: 20, color: Colors.deepOrangeAccent);
      } else if (streak == 8) {
        return const Icon(Icons.whatshot, size: 20, color: Colors.redAccent);
      } else if (streak == 9) {
        return const Icon(Icons.whatshot,
            size: 20, color: Color.fromARGB(255, 5, 146, 254));
      } else {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Tooltip(
            message: 'Racha de $streak aciertos',
            child: const Icon(
              Icons.whatshot,
              size: 20,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    int getCurrentStreak(List<dynamic> votos, List<dynamic> bazas) {
      int streak = 0;
      for (int i = votos.length - 1; i >= 0; i--) {
        if (i < bazas.length && votos[i] == bazas[i]) {
          streak++;
        } else {
          break;
        }
      }
      return streak;
    }

    return Card(
      elevation: 2,
      surfaceTintColor: CustomColors.backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ronda ${ronda + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: CustomColors.secondaryColor)),
            const Divider(thickness: 1, color: CustomColors.secondaryColor),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2), // Nombre del jugador
                1: FlexColumnWidth(1), // Voto
                2: FlexColumnWidth(1), // Baza
                3: FlexColumnWidth(1), // Puntos
                4: FixedColumnWidth(30), // Icono
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Jugador',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('Voto', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Baza', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Puntos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(), // Para el icono
                  ],
                ),
                ...players.map((player) {
                  final voto = currentVote[player] ?? '-';
                  final baza = currentBaz[player] ?? '-';
                  final puntos = (totalScore[player] != null &&
                          totalScore[player].length > ronda - 1)
                      ? totalScore[player][ronda - 1]
                      : '-';
                  final acierto = voto == baza && voto != '-';
                  final votosPlayer = List<dynamic>.from(votos[player] ?? []);
                  final bazasPlayer = List<dynamic>.from(bazas[player] ?? []);
                  final streak = getCurrentStreak(votosPlayer, bazasPlayer);
                  return TableRow(
                    children: [
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: 'Racha de $player: $streak',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            spacing: 4,
                            children: [
                              Text(
                                player,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400),
                                overflow: TextOverflow.ellipsis,
                              ),
                              buildStreakIcon(streak),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '$voto',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '$baza',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '$puntos',
                        textAlign: TextAlign.center,
                      ),
                      Center(
                        child: Icon(
                          acierto ? Icons.check : Icons.close,
                          color: baza == '-'
                              ? Colors.transparent
                              : acierto
                                  ? Colors.green
                                  : Colors.red,
                          size: 18,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  const DataCard({
    super.key,
    required this.players,
    required this.votos,
    required this.bazas,
    required this.totalScore,
    required this.ronda,
  });

  final List<String> players;
  final Map<String, dynamic> votos;
  final Map<String, dynamic> bazas;
  final Map<String, dynamic> totalScore;
  final int ronda;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      surfaceTintColor: CustomColors.backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ronda ${ronda + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: CustomColors.secondaryColor)),
            const Divider(thickness: 1, color: CustomColors.secondaryColor),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2), // Nombre del jugador
                1: FlexColumnWidth(1), // Voto
                2: FlexColumnWidth(1), // Baza
                3: FlexColumnWidth(1), // Puntos
                4: FixedColumnWidth(30), // Icono
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('Jugador',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text('Voto', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Baza', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Puntos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(), // Para el icono
                  ],
                ),
                ...players.map((player) {
                  final voto =
                      (votos[player] != null && votos[player].length > ronda)
                          ? votos[player][ronda]
                          : '-';
                  final baza =
                      (bazas[player] != null && bazas[player].length > ronda)
                          ? bazas[player][ronda]
                          : '-';
                  final puntos = (totalScore[player] != null &&
                          totalScore[player].length > ronda)
                      ? totalScore[player][ronda]
                      : '-';
                  final acierto = voto == baza && voto != '-';
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          player,
                          style: const TextStyle(fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$voto',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '$baza',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '$puntos',
                        textAlign: TextAlign.center,
                      ),
                      Center(
                        child: Icon(
                          acierto ? Icons.check : Icons.close,
                          color: baza == '-'
                              ? Colors.transparent
                              : acierto
                                  ? Colors.green
                                  : Colors.red,
                          size: 18,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
