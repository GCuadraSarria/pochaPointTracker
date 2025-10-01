import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/detail_chart.dart';
import 'package:pocha_points_tracker/widgets/go_back_button.dart';

class GameRegisterDetailPage extends StatefulWidget {
  final String gameId;
  const GameRegisterDetailPage({super.key, required this.gameId});

  @override
  State<GameRegisterDetailPage> createState() => _GameRegisterDetailPageState();
}

class _GameRegisterDetailPageState extends State<GameRegisterDetailPage> {
  @override
  Widget build(BuildContext context) {
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

          String getFormattedDate() {
            String formattedDate = '';
            if (gameData['startDate'] is Timestamp) {
              DateTime dateTime = (gameData['startDate'] as Timestamp).toDate();
              formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
            } else if (gameData['startDate'] is String) {
              formattedDate = gameData['startDate'];
            }
            return formattedDate;
          }

          final startDate = gameData['startDate'];
          final endDate = gameData['endDate'];
          DateTime? startDateTime;
          DateTime? endDateTime;

          if (startDate is Timestamp) {
            startDateTime = startDate.toDate();
          } else if (startDate is String) {
            startDateTime = DateTime.tryParse(startDate);
          }

          if (endDate is Timestamp) {
            endDateTime = endDate.toDate();
          } else if (endDate is String) {
            endDateTime = DateTime.tryParse(endDate);
          }

          String formattedDuration = '';
          if (startDateTime != null && endDateTime != null) {
            final duration = endDateTime.difference(startDateTime);
            final hours = duration.inHours;
            final minutes = duration.inMinutes % 60;
            final seconds = duration.inSeconds % 60;
            if (hours > 0) {
              formattedDuration = '$hours h. $minutes min. $seconds seg';
            } else if (minutes > 0) {
              formattedDuration = '$minutes min $seconds seg';
            } else {
              formattedDuration = '$seconds seg';
            }
          }
          final totalScore =
              Map<String, dynamic>.from(gameData['totalScore'] ?? {});
          final bazas = Map<String, dynamic>.from(gameData['bazas'] ?? {});
          final votos = Map<String, dynamic>.from(gameData['votos'] ?? {});
          final players = getPlayerList();
          // Calcular número de rondas
          int numRondas = 0;
          for (final scores in totalScore.values) {
            if (scores is List && scores.length > numRondas) {
              numRondas = scores.length;
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

          final List<String> winners =
              List<String>.from(gameData['winner'] ?? []);
          final List<String> allPlayers =
              playerStats.map((s) => s['player'] as String).toList();
          final List<String> nonWinners =
              allPlayers.where((p) => !winners.contains(p)).toList();
          // Ordena playerStats por puntos de mayor a menor
          final sortedPlayerStats = [
            ...playerStats
          ]..sort((a, b) => (b['puntos'] as int).compareTo(a['puntos'] as int));

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
                  padding: const EdgeInsets.only(
                      left: 12.0, top: 24.0, bottom: 24.0),
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
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getFormattedDate(),
                              style: const TextStyle(
                                color: CustomColors.bgGradient4,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Duración: $formattedDuration',
                              style: const TextStyle(
                                color: CustomColors.bgGradient4,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // Gráfica
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                // Chart
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: numRondas * 40 >
                                            MediaQuery.of(context).size.width
                                        ? numRondas * 40
                                        : MediaQuery.of(context).size.width,
                                    child: DetailChart(gameData: gameData),
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
                                            color: CustomColors.lineColors[
                                                index %
                                                    CustomColors
                                                        .lineColors.length],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const SizedBox(
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                        Text(
                                          player,
                                          style: const TextStyle(fontSize: 12),
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
                                      DataColumn(label: Text('% Acierto')),
                                      DataColumn(label: Text('Racha +')),
                                      DataColumn(label: Text('Racha -')),
                                    ],
                                    rows: sortedPlayerStats.map((stats) {
                                      final playerName = stats['player'];
                                      final isWinner =
                                          winners.contains(playerName);

                                      int nonWinnerRank = isWinner
                                          ? 0
                                          : winners.length +
                                              nonWinners.indexOf(playerName) +
                                              1;

                                      return DataRow(cells: [
                                        DataCell(Row(
                                          children: [
                                            isWinner
                                                ? SvgPicture.asset(
                                                    'lib/assets/images/mini_cup.svg',
                                                    height: 18.0,
                                                    width: 18.0,
                                                    semanticsLabel: 'mini cup',
                                                  )
                                                : Text(
                                                    '#$nonWinnerRank',
                                                    style: const TextStyle(
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
                                                  color:
                                                      CustomColors.whiteColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                        DataCell(
                                            Text(stats['puntos'].toString())),
                                        DataCell(Text(
                                            '${stats['acierto'].toStringAsFixed(1)}%')),
                                        DataCell(Text(
                                            stats['rachaAciertos'].toString())),
                                        DataCell(Text(
                                            stats['rachaFallos'].toString())),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Detalle por ronda
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: numRondas,
                                  itemBuilder: (context, ronda) {
                                    return Card(
                                      elevation: 2,
                                      // shadowColor: CustomColors.primaryColor,
                                      surfaceTintColor:
                                          CustomColors.backgroundColor,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Ronda ${ronda + 1}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: CustomColors
                                                        .secondaryColor)),
                                            const Divider(
                                                thickness: 1,
                                                color: CustomColors
                                                    .secondaryColor),
                                            ...players.map((player) {
                                              final voto =
                                                  (votos[player] != null &&
                                                          votos[player].length >
                                                              ronda)
                                                      ? votos[player][ronda]
                                                      : '-';
                                              final baza =
                                                  (bazas[player] != null &&
                                                          bazas[player].length >
                                                              ronda)
                                                      ? bazas[player][ronda]
                                                      : '-';
                                              final acierto =
                                                  voto == baza && voto != '-';
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      player,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Wrap(
                                                    spacing: 12,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Text('Voto: $voto'),
                                                      Text('Baza: $baza'),
                                                      Icon(
                                                        acierto
                                                            ? Icons.check
                                                            : Icons.close,
                                                        color: acierto
                                                            ? Colors.green
                                                            : Colors.red,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }),
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
                      // Botón atrás
                      const GoBackButton()
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
